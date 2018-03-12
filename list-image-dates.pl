#!/usr/bin/env perl -w

# Renames files to normalized form yyyymmddThhmmss_###.ext based
# on the DateTimeOriginal metadata field.  Then, generates a UUID
# from the new filename and stores that in the ImageUniqueID
# metadata field.

use strict;
use warnings;
use DateTime::Format::Strptime;
use File::Basename;
use Image::ExifTool;
use File::Copy;
use File::Path;

require './util.pl';

my $DRY_RUN=undef;
my $DRY_RUN_DIR='dry-run';
my $DEBUG=1;

my %previously_processed;

my $image_info = $ARGV[0];

# die "Usage: $0 <image-info.txt>\n"
#     unless $image_info;

# open(my $fh, $image_info)
#     or die "Could not open file '$image_info' $!";
# while (my $row = <$fh>) {
#     chomp $row;
#     my($uuid,$create,$filepath) = split /,/, $row;
#     $previously_processed{$filepath} = $uuid;
# }


for(<DATA>){
    chomp;
    unless(-e $_) {
	&error("File not found: [$_], assume already processed.");
	next;
    }
    my ($filename, $dir, $suffix) = fileparse($_, qr/\.[^.]*/);
    my $created = &create_date($_);

    &debug("DateTimeOriginal: $created");

    unless($created) {
	&error("DateTimeOriginal create date not found in [$_]\n");
	next;
    }

    $dir = "$DRY_RUN_DIR/$dir"
	if $DRY_RUN;

    my $old_filepath = $_;
    my $new_filepath = &make_filename($dir, $created, 1, $suffix);

    if(exists $previously_processed{$new_filepath}) {
	&debug("Skipping [$new_filepath] as its been processed already");
	next;
    }
    
    ## Write old file to new location.
    if($DRY_RUN) {
	my $new_dir = dirname($new_filepath);
	if(not -e $new_dir) {
	    &debug("creating dry-run folder: $new_dir");
	    mkpath("$new_dir")
		or die("Cannot create dry-run folder: $new_dir");
	}
	&debug("copying [$old_filepath] to [$new_dir]");
	copy($old_filepath, $new_filepath)
	    or die("unable to copy $old_filepath -> $new_filepath: $!\n");
    } else {
	&debug("moving [$old_filepath] to [$new_filepath]");
        move($old_filepath, $new_filepath)
	    or die("unable to move $old_filepath -> $new_filepath: $!\n");
    }

    ## Add a UUID tag to the image
    $filename = basename($new_filepath);
    my $uuid = `uuid -v5 ns:URL $filename`;
    chomp $uuid;
    &debug("writing 'ImageUniqueId'=[$uuid] to $new_filepath");
    my $result = &write_tag($new_filepath, 'imageuniqueid', $uuid);

    ## log info
    if($result) {
	print "$uuid,$created,$new_filepath\n";
    }
}


sub valid {
    my $val = shift;
    return undef
	unless $val;
    if(length($val) > 0) {
	return $val;
    } else {
	return undef;
    }
}    

sub make_filename {
    my $destdir = shift;
    my $created = shift;
    my $serial = shift;
    my $suffix = shift;

    &debug("destdir: $destdir, created: $created, serial: $serial, suffix: $suffix");
    
    my $dt = parse_date($created);
    my $date = $dt->strftime( '%Y%m%d' );
    my $time = $dt->strftime( '%H%M%S' );
    my $datetime = $date . 'T' . $time;

    my $name = $destdir . $datetime . '_' . sprintf('%03d', $serial) . $suffix;

    # cap recursion at 1000 increments
    while($serial < 1000 && -e $name) {
        &debug("recursing on [$name] since it exists.");
        $name = &make_filename($destdir, $created, ++$serial, $suffix);
    }

    if($serial == 1000) {
        die("too many duplicate image filenames, unable to create new filename for [$name].");
    }

    return $name;
}

    
__DATA__
