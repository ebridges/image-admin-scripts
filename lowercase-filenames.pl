use strict;
use File::Copy;
use File::Basename;

for(<DATA>){
    chomp;
    my $filename = basename($_);
    my $dir = dirname($_);

    print("::: filename: [$filename] dirname: [$dir]\n");

    my $new_filename = $filename;
    $new_filename = lc($filename);

    my $src = "$dir/$filename";
    my $des = "$dir/$new_filename";
    
    print("::: src: [$src] des: [$des]\n");
    move($src, $des)
	or warn("Move didn't work: $src -> $des : $!\n");
}


__DATA__
