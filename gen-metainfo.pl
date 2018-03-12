#!/usr/bin/env perl

use strict;
use warnings;

require './util.pl';

for(<>) {
    chomp;
    die "unable to locate file [$_]: $!\n"
	unless -e;
    my $file = $_;
    my $date = &create_date($file);
    my $csum = &calc_checksum($file);
    my $uuid = &calc_uuid($file);
    print "$file,$uuid,$date,$csum\n";
}
