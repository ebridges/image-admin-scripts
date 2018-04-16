use Image::ExifTool qw(:Public);
use DateTime::Format::Strptime;
use File::Basename;
use Digest::SHA;
use File::Spec::Functions 'catfile';
use File::Path 'make_path';

use constant ISO_8601_FORMAT => '%Y-%m-%dT%H:%M:%S';


sub correct_date {
    my $date = shift;
    my $correction = shift;
    my $future = $date->epoch();
    my $corrected = $future - $correction;
    return DateTime->from_epoch( epoch => $corrected );
}



sub convert_avi_to_mp4 {
    my $avi = shift;
    my $mp4 = shift;
    `ffmpeg -i $avi -copyts -pix_fmt yuv420p $mp4`;
#    die("ffmpeg -i $avi -copyts -pix_fmt yuv420p $mp4");
    if($?) {
	&error("Error converting $avi to MP4: $!");
	return undef;
    } else {
	return 1;
    }
}


sub filepath {
    my $prefix = shift;
    my $created = shift;
    my $suffix = lc(shift);
    my $idx = shift || 1;
    my $year = $created->strftime( '%Y' );
    my $date = $created->strftime( '%Y-%m-%d' );
    my $datetime = $created->strftime( '%Y%m%dT%H%M%S' );
    my $seq = sprintf('%03d', $idx);
    my $filepath = "$prefix/$year/$date/$datetime" . '_' . $seq . $suffix;
    &debug("new filepath: $filepath");
    return $filepath;
}

sub create_date {
    my $image = shift;
    my @tags = ('CreateDate', 'DateTimeOriginal');
    my $date = &tag($image, @tags);

    if($date) {
	return &parse_date($date);
    } else {
	return undef;
    }
}

sub iso8601 {
    my $dt = shift;
    return $dt->strftime(ISO_8601_FORMAT);
}

sub parse_date {
    my $dt = shift;
    my $pattern = shift || ISO_8601_FORMAT;
    my $parser = DateTime::Format::Strptime->new(
	pattern => $pattern,
	on_error => 'croak',
    );
    return $parser->parse_datetime($dt);
}

sub tag {
    my $image = shift;
    my @tags = @_;
    my $exifTool = new Image::ExifTool;
    $exifTool->Options(DateFormat => ISO_8601_FORMAT);
    my $info = $exifTool->ImageInfo($image, \@tags);
    for (keys %$info) {
	&debug("$_ => $$info{$_}");
	return trim($$info{$_});
    }
    return undef;
}


sub write_tag {
    my $src = shift;
    my $des = shift;
    my %tag_vals = @_;

    &debug("writing tags [".join(',',%tag_vals)."] from [$src] to [$des]");
    
    my $exifTool = new Image::ExifTool;
    $exifTool->Options(DateFormat => ISO_8601_FORMAT);

    my $errmsg = undef;
    my ($success) = $exifTool->ExtractInfo($src);
    unless($success) {
	&error("unable to extract tag info on image [$src] because [".$exifTool->GetValue('Error')."]");
	return undef;
    }
    
    while (my ($tag, $val) = each %tag_vals) {
	($success, $errmsg) = $exifTool->SetNewValue($tag => $val);
	unless($success) {
	    &error("unable to update tag value [$tag::$val] because [$errmsg]");
	    return undef;
	}
    }

    if($des) {
	$success = $exifTool->WriteInfo($src, $des);
	unless($success) {
	    &error("unable to write out new tag for $des because [".$exifTool->GetValue('Error')."]");
	    return undef;
	}
    } else {
	$success = $exifTool->WriteInfo($src);
	unless($success) {
	    &error("unable to write out tag for $src because [".$exifTool->GetValue('Error')."]");
	    return undef;
	}
    }

    return 1;
}

sub mkdirs {
    my $new = &catfile(@_);
    
    my $dir = &dirname($new);
    if(not -e $dir) {
	unless(&make_path($dir)) {
	    &error("unable to create [$dir]");
	    return undef;
	}
	&debug("parent directories created for [$dir]");
    } else {
	&debug("parent directories already exist for [$dir]");
    }
    
    1;
}

sub calc_uuid {
    my $filepath = shift;
    my $filename = &basename($filepath);
    my $uuid = `uuid -v5 ns:URL $filename`;
    chomp $uuid;
    return $uuid;
}

sub calc_checksum {
    my $filename = shift;
    
    &debug("checksum($filename)");
    
    open my $fh, '<:raw', $filename
        or die "cannnot open $filename";

    $sha = Digest::SHA->new(512);
    $sha->addfile($fh);

    return $sha->hexdigest;
}

sub type {
    my $file = shift;
    my ($unused_1, $unused_2, $suffix) = &fileparse($_, qr/\.[^.]*/);
    $suffix =~ s/^\.//;
    return 'image'
        if $suffix =~ /jpg|png/;
    return 'video'
        if $suffix =~ /mp4|mov|avi/;
    return undef;
}

sub trim {
    my $val = shift;
    $val =~ s/^\s+|\s+$//g;
    return $val;
}

sub debug {
    my $msg = shift;
    &logger("[DEBUG] $msg")
        if DEBUG;
}

sub error {
    my $msg = shift;
    &logger("[ERROR] $msg");
}

sub logger {
    my $msg = shift;
    my $now = scalar(localtime());
    print STDERR ("[$now] $msg\n");
}

1;
