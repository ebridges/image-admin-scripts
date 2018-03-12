#!/usr/bin/env perl

## Given a list of directories with words in the directory name, adds 
## `ImageDescription` and (optionally) `IPTC:Keywords` to media files 
## in the directory, deriving the description/keyword from the directory 
## name.
## In order to add keywords to a given file, append `,1` to the directory
## name in the `__DATA__` list.

use strict;
use warnings;

use constant DEBUG => 1;

require './util.pl';

for(<DATA>){
    chomp;

    my ($path,$add_keywords) = split /,/;
    
    my %tag_vals = (
	'ImageDescription' => &extract_description($path)
    );

    if($add_keywords) {
	my @words = &extract_keywords($path);
	$tag_vals{'IPTC:Keywords'} = \@words
    }

    &debug("Directory: $path");
    for(sort keys %tag_vals) {
	if(ref($tag_vals{$_})) {
	    &debug("    $_ => " . join ',', @{$tag_vals{$_}});   
	} else {
	    &debug("    $_ => $tag_vals{$_}");
	}
    }
    
    my @files = glob "$path/*.{jpg,mov,avi,mp4,thm}";

    for(@files) {
	if (-e "output/$_") {
	    &debug("$_ already processed, skipping.");
	    next;
	}
	
	unless(&mkdirs('output', $_)) {
	    die "unable to make parent directory for $_: $!\n";
	}
	
	unless(&write_tag($_, "output/$_", %tag_vals)) {
	    die "unable to write tag for $_\n";
	}
	
	&debug("file [$_] updated.");
    }
    
    &debug('------------');
}

sub extract_description {
    my $path = shift;
    $path =~ m/^\.\/\d{4}\/\d{4}[-]?\d{2}[-]?\d{0,2}_([A-Za-z_0-9-]+)/;
    my $descr = $1;
    &debug("path: [$path]: match: [$descr]");
    $descr =~ s/_/ /g; # Convert underscore to space
    $descr =~ s/([A-Z][a-z]+)(?=[A-Z])/$1 $2/g; # NewYork -> New York
    $descr =~ s/\s+/ /g; # Collapse spaces
    return $descr;
}


sub extract_keywords {
    my $path = shift;
    $path =~ m/^\.\/\d{4}\/\d{4}[-]?\d{2}[-]?\d{0,2}_([A-Za-z_0-9-]+)/;
    my $words = $1;
    my @words = split /_/, $words;
    @words = grep ! /^[a-z]/, @words; # remove words starting with lowercase letter
    @words = map { s/([A-Z][a-z]+)(?=[A-Z])/$1 $2/g ; $_ } @words; # NewYork -> New York
    return @words;
}

__DATA__
