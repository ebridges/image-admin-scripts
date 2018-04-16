#!/usr/bin/env perl

use strict;
use warnings;
use File::Spec::Functions 'catfile';
use File::Copy 'cp';
use File::Path 'make_path';
use File::Basename;

use constant DEBUG => 1;
use constant CORRECTION => 683225640;

require './util.pl';

my @tags = ('CreateDate', 'DateTimeOriginal');

for(<DATA>){
    chomp;
    next
        unless $_;
    my $created = &create_date($_);
    my $updated = &calc_offset($created);
    my $dest = &filepath('./new', $updated, '.jpg');
    die "unable to create parent dir: $!\n"
	unless(&mkdirs($dest));
    my %tag_vals = ();
    @tag_vals{@tags} = ($updated) x (scalar @tags);
    die("Error writing tag for $_: $!\n")
	unless &write_tag($_, $dest, %tag_vals);
}

sub calc_offset {
    my $date = shift;
    my $future = $date->epoch();
    my $corrected = $future - CORRECTION;
    return DateTime->from_epoch( epoch => $corrected );
}

__DATA__
