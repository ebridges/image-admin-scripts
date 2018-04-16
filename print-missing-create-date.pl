#!/usr/bin/perl

use strict;

require './util.pl';

for(<DATA>){
    chomp;
    die "unable to locate file [$_]: $!\n"
        unless -e;

    my $date = &tag($_, ('CreateDate', 'DateTimeOriginal'));
    next
	unless $date;

    if(not $date or $date eq '0000:00:00 00:00:00') {
	print "$_\n";
    }
    
    # my @result = `exiftool -q -if '(not \$CreateDate or (\$CreateDate eq "0000:00:00 00:00:00"))' -csv -common "$_"`;
    # if(scalar(@result) > 1) {
    # 	chomp @result;
    # 	my @fields = split /,/, $result[1];
    # 	print "$fields[0]\n";
    # }
}

__DATA__
