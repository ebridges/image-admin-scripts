#!/usr/bin/perl

use strict;
use warnings;

use File::Basename;
use File::Spec::Functions 'catfile';

for(<DATA>) {
    chomp;
    ## ./1998/199810_Sivananda_Yoga_Retreat_Bahamas/img0014.jpg
    ## 0 1    2                                     3
    my $filepath = $_;

    my @parts = split /\//, $filepath;
    my $dir = $parts[2];
    my $file = $parts[3];

    my $date = undef;

    #print STDERR "file: $file\n";
    if ($file =~ /^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})_\d{2}\.jpg/) {
	# 20080717T154104_01.jpg
	$date = "$1:$2:$3 $4:$5:$6";
    } elsif($dir =~ /^(\d{4})(\d{2})(\d{2})/) {
	# YYYYMMDD
	$date = "$1:$2:$3 00:00:00";
    } elsif($dir =~ /^(\d{4})-(\d{2})-(\d{2})/) {
	# YYYY-MM-DD
	$date = "$1:$2:$3 00:00:00";
    } elsif ($dir =~ /^(\d{4})(\d{2})/) {
	# YYYYMM
	$date = "$1:$2:01 00:00:00";
    }

    unless($date) {
	print STDERR "ERR|$filepath|undef|Can't parse date.\n";
	next;
    }

    my ($filename, $path, $suffix) = &fileparse($filepath, qr/\.[^.]*/);

# OK|Converting to MP4: mvi_0770 ./2004/20041223_Christmas_Krakow_Poland/ .avi
# FFmpeg version SVN-rUNKNOWN, Copyright (c) 2000-2004 Fabrice Bellard
#   configuration:  --enable-gpl --enable-pp --enable-pthreads --enable-vorbis --enable-libogg --enable-a52 --enable-dts --enable-libgsm --enable-dc1394 --disable-debug --enable-shared --prefix=/usr
#   libavutil version: 0d.49.0.0
#   libavcodec version: 0d.51.11.0
#   libavformat version: 0d.50.5.0
#   built on Apr 26 2009 11:34:57, gcc: 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)
# ./2004/20041223_Christmas_Krakow_Poland/.avi: I/O error occured
# Usually that means that input file is truncated and/or corrupted.
    
    if($suffix eq '.avi') {
	print "OK|Converting to MP4: $path $filename $suffix\n";
	my $infile = $filepath;
	my $outfile = "$path$filename.mp4";
	my $output = `ffmpeg -i $infile  -copyts -pix_fmt yuv420p $outfile`;
	#my $output = `ffmpeg -i $infile -c:v libx264 -crf 19 -preset slow -c:a libfdk_aac -b:a 192k -ac 2 $outfile`;
	die("couldn't convert AVI file. $!")
	    unless &handle_error($filepath, $date, $output);
	$filepath = $outfile;
    }

    #print "exiftool '-createdate=$date' '-datetimeoriginal=$date' $filepath\n";
    my $output = `exiftool '-createdate=$date' '-datetimeoriginal=$date' '$filepath'`;
    &handle_error($filepath, $date, $output);
}


sub handle_error {
    my $filepath = shift;
    my $date = shift;
    my $output = shift;
    chomp $output;
    $output =~ s/\n+//g;
    if ($? == 0) {
	print "OK|$filepath|$date|$output\n";
	return 1;
    } elsif ($? == -1) {
	print STDERR "ERR|$filepath|$date|Unable to execute: $! [$output]\n";
	return undef;
    } else {
	print STDERR "ERR|$filepath|$date|Error executing: (" . ($? >> 8) . ") $! [$output]\n";
	return undef;
    }
}

__DATA__
