#!/usr/bin/perl

use strict;

for(<DATA>){
    chomp;
    my @result = `exiftool -q -if '(not \$CreateDate or (\$CreateDate eq "0000:00:00 00:00:00"))' -csv -common "$_"`;
    if(scalar(@result) > 1) {
	chomp @result;
	my @fields = split /,/, $result[1];
	print "$fields[0]\n";
    }
}

__DATA__
