#!/usr/bin/perl

use strict;

for(<DATA>){
    chomp;
    `exiftool "-DateTimeOriginal>CreateDate" $_`;
}

__DATA__
