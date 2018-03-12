#!/usr/bin/env perl

use strict;
use warnings;

use constant DEBUG => 1;

require './util.pl';

for(<>) {
    chomp;
    s/^\.\///;
    my ($file,$uuid,$date,$sum) = split /,/;
    my $type = &type($file);
    die("unable to determine type from $file")
      unless $type;
    print "$file,$type,$date,$uuid,$sum\n";
}
