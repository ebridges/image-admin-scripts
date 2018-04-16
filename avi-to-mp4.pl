#!/usr/bin/env perl

use strict;
use warnings;

require './util.pl';

my @created_tags = ('CreateDate', 'DateTimeOriginal');

for(<>) {
    chomp;
    my $filepath = $_;
    my $created = &create_date($filepath);
    die("unable to extract date from metadata [$filepath]\n")
	unless($created);

    my ($filename, $path, $suffix) = &fileparse($filepath, qr/\.[^.]*/);
    
    if(lc($suffix) eq '.avi') {
	&debug("Converting to MP4: $path $filename $suffix");
	my $outfile = "$path$filename.mp4";
       	die("couldn't convert AVI file. $!")
	    unless &convert_avi_to_mp4($filepath, $outfile);	
	$filepath = $outfile;
    }

    my $final_output = &filepath('./new', $created, '.mp4');
    die("Cannot create output directory: [$final_output].\n")
	unless(&mkdirs($final_output));

    my %tag_vals = ();
    @tag_vals{@created_tags} = ($created) x (scalar @created_tags);
    die("Cannot write create date tags for [$final_output].\n")
	unless(&write_tag($filepath, $final_output, %tag_vals));
}

