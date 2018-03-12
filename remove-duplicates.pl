#!/usr/bin/env perl

use strict;
use warnings;

use constant DEBUG => 1;

require './util.pl';

my %sums;
my %files;

for(<DATA>) {
    chomp;
    my ($file,$uuid,$date,$sum) = split /,/;
    push @{$sums{$sum}}, $file;
    $files{$file} = $sum;
}

for my $k ( keys %sums ) {
    my @dupes = @{$sums{$k}};
    if ( scalar @dupes > 1 ) {
	@dupes = sort {$b cmp $a} @dupes;
	my $saved = shift @dupes; # save first file
	&debug("found duplicates of [$saved]:");
	for(@dupes){
	    &debug("  $_");
	}
	if (not DEBUG) {
	    unless(-e $saved) {
		die("Can't find saved file: $saved\n");
	    }

	    for(@dupes) {
		if(-e) {
		    unless(unlink) {
			&error("error deleting [$_]: $!");
		    }
		}		
	    }
	}
	print "$saved,$files{$saved}\n";
    } else {
	print pop(@{$sums{$k}}) . ",$k\n";
    }
}

&debug(scalar(keys(%sums)) . ' de-duped images.');

__DATA__
