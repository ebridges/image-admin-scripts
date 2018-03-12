use strict;
use warnings;
use File::Basename;
use File::Copy;

for(<DATA>){
    chomp;

    my $filename = basename($_);
    my $dir = dirname($_);

    print("filename: [$filename] dirname: [$dir]\n");
    
    my $new_dir = $dir;
    $new_dir =~ s/'//g;

    print("$dir -> $new_dir\n");
    
    if(not -e $new_dir) {
	print("moving new_dir\n");
	move($dir, $new_dir)
	    or warn("Can't move old dir to new dir: $!\n");
    } else {
	print("no need to move $new_dir\n");
    }


    print("filename: $filename\n");
    if(length($filename)) {
	my $new_filename = $filename;
	$new_filename =~ s/'//g;

	print("$filename -> $new_filename\n");
	
	my $src = "$new_dir/$filename";
	my $des = "$new_dir/$new_filename";
	print("$src -> $des\n");
	if(not -e $des) {
	    move($src, $des)
		or warn("Move didn't work: $src -> $des : $!\n");
	} else {
	    print("no need to move $src -> $des\n");
	}
    }
    print("----------------------------------------------\n");
}



__DATA__
