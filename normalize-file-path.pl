#!/usr/bin/env perl

use strict;
use warnings;
use File::Spec::Functions 'catfile';
use File::Copy 'cp';
use File::Path 'make_path';
use File::Basename;

use constant DEBUG => 1;

use constant OLD_ROOT => '.';
use constant NEW_ROOT => 'new';

require './util.pl';

for(<DATA>){
    chomp;
    next
	unless $_;
    my $old_path = $_;

    &debug('---------------------');
    
    ## extract create date
    my $created = &create_date($old_path);
    &debug("[$old_path] created [$created]");
    
    ## create new filename acc. to convention
    my $new_path = &format_new_path($old_path, $created);
    unless($new_path) {
	next;
    }

    ## skip if the file has been processed already
    next
	if(-e &catfile(NEW_ROOT,$new_path));
    
    &debug("[$old_path]-->[$new_path]");

    ## establish directory path if necessary
    my $result = &mkdirs(NEW_ROOT, $new_path);
    unless($result) {
	next;
    }

    ## calculate a unique id & write as tag to file
    my $uuid = &calc_uuid($new_path);
    my $tmp_old_path = 
    $result = &write_tag(
	&catfile(OLD_ROOT,$old_path),
	&catfile(NEW_ROOT,$new_path),
	'imageuniqueid', 
	$uuid);
    unless($result) {
	next;
    }
    &debug("[$new_path] uuid [$uuid]");
    
    ## calculate checksum of the new file
    my $checksum = &calc_checksum(&catfile(NEW_ROOT, $new_path));
    &debug("[$new_path] chksum [".substr($checksum, 0, 16)."...]");

    ## output uuid, chksum, create date, filepath
    my $create_date = &iso8601($created);
    print "$new_path,$uuid,$create_date,$checksum\n";
}

sub format_new_path {
    my $old_path = shift;
    my $created = shift;
    
    my ($unused_a, $unused_b, $suffix) = &fileparse($old_path, qr/\.[^.]*/);

    if($created) {
	my $dir = &format_new_dir($created);

	my $date = $created->strftime( '%Y%m%d' );
	my $time = $created->strftime( '%H%M%S' );
	my $datetime = $date . 'T' . $time;
	
	my $new_path = &format_new_file($dir, $datetime, 1, $suffix);
	unless($new_path) {
	    &error("unable to create new filepath [$new_path] from old path [$old_path]");
	    return undef;
	}
	return $new_path;
    } else {
	&error("unable to get create date from [$old_path]");
	return undef;
    }
}

sub format_new_dir {
    my $dt = shift;
    my $year = $dt->strftime('%Y');
    my $date = $dt->strftime('%Y-%m-%d');
    return "$year/$date";
}

sub format_new_file {
    my $dir = shift;
    my $datetime = shift;
    my $serial = shift;
    my $suffix = shift;

    my $new_filepath = &catfile($dir, $datetime . '_' . sprintf('%03d', $serial) . $suffix);

    &debug("new filepath: [$new_filepath]");
    
    while($serial < 1000 && -e &catfile(NEW_ROOT, $new_filepath)) {
	&debug("recursing on [$new_filepath] since it exists.");
	$new_filepath = &format_new_file($dir, $datetime, ++$serial, $suffix);
    }

    if($serial == 1000) {
	return undef;
    }

    return $new_filepath;
}

__DATA__
