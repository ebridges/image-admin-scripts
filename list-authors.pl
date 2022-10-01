#!/usr/bin/env perl

use strict;
use warnings;

require './util.pl';

for(<>){
    chomp;
    next
        unless $_;
    my $author = &author($_);
    print("$_,$author\n");
}
