#!/usr/bin/env perl

use strict;
use warnings;

use constant DEBUG => 1;

require './util.pl';

my %sums;
my %files;

for(<>) {
    chomp;
    s/^\.\///;
    my ($file,$uuid,$date,$sum) = split /,/;
    push @{$sums{$sum}}, $file;
    if(exists $files{$file}) {
      &error("Duplicate: [$file].");
      next;
    }
    $files{$file} = $sum;
}

for my $k ( keys %sums ) {
    my @dupes = @{$sums{$k}};
    if ( scalar @dupes > 1 ) {
      @dupes = sort {$b cmp $a} @dupes;
      my $saved = shift @dupes; # save first file
      &debug("found duplicates of [$saved]:");
      for(@dupes) {
          &debug("  $_");
      }

      print "$saved,$files{$saved}\n";
    } 
}
