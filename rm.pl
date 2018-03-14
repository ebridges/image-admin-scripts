
use strict;
use warnings;

use File::Spec::Functions 'catfile';
use File::Copy 'move';

use constant OUTPUT => 'backup';
use constant DEBUG => 1;

require './util.pl';

for(<DATA>){
    chomp;
    my ($orig,$ignored) = split /,/;
    my $copy = &catfile(OUTPUT, $orig);

    my @orig = glob "$orig/*.jpg";
    my @copy = glob "$copy/*.jpg";

    my $orig_cnt = scalar(@orig);
    my $copy_cnt = scalar(@copy);

    if ($orig_cnt == $copy_cnt) {
    	&debug("MATCH: $orig ($orig_cnt == $copy_cnt)");
    } else {
    	&error("MISMATCH: $orig");
    }

    # die("Error moving [$orig] to [$copy]: $!\n")
    #	unless(move($orig, $copy));
}

__DATA__
