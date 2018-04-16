use strict;

require './util.pl';

my @tags = ('CreateDate', 'DateTimeOriginal');

for(<DATA>) {
    chomp;
    my $created = &create_date($_);
    my $src = "$_.mp4";
    my $des = $src;
    $des =~ s/\.avi//;

    my %tag_vals = ();
    @tag_vals{@tags} = ($created) x (scalar @tags);

    my $date = $created->strftime( '%Y%m%d' );
    my $time = $created->strftime( '%H%M%S' );
    my $datetime = $date . 'T' . $time;

    my $new_filepath = $datetime . '_001.mp4';
    
    die("Error writing tag for $des: $!\n")
        unless &write_tag($src, $new_filepath, %tag_vals);
}


__DATA__
