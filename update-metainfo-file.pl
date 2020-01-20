#!/usr/bin/env perl

use strict;
use warnings;

use constant DEBUG => 1;

use constant ARCHIVE_DIR => '/Users/ebridges/Archive';

use File::Spec::Functions 'catfile';

require './util.pl';

my %sums;
my %files;

for(<>) {
    chomp;
    s/^\.\///;
    my ($file,$uuid,$date,$sum) = split /,/;
    my $type = &type($file);
    die("file does not exist: $file\n")
	unless(-e &catfile(ARCHIVE_DIR, $type, $file));
    # ./2014/2014-12-23/20141223T190643_001.jpg
    # 2017/2017-10-06/20171006T225659_01.mov
    if($file =~ /^[\.\/]*([\d]{4})\/([\d]{4}-[\d]{2}-[\d]{2})\/([\d]{8}T[\d]{6})_([\d]{2})\.([a-z]{3})$/) {
	my $prefix = $1 . '/' . $2 . '/' . $3;
	my $serial = int($4);
	my $suffix = $5;
	
	my $seq = sprintf('%03d', $serial);
	my $filepath = $prefix . '_' . $seq . '.' . $suffix;
	
	print("filepath: $filepath\n");
    } else {
	&debug("$file not matched.");
    }
}

