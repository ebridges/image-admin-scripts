# Confirmation

## Reference Count

    nas:/c/photos/pictures# wc -l jpeg-list.txt
    64559 jpeg-list.txt

## Confirmation of `dirs-with-names.pl`

### Sum of JPGs in numbered dirs

    nas:/c/photos/pictures# find [0-9]* -type f -name '*.jpg' ! -wholename '*.AppleDouble*' | wc -l
    53264

### Backed up Files

    nas:/c/photos/pictures# find ./backup -type f -name '*.jpg' ! -wholename '*.AppleDouble*' | wc -l
    11295

### Processed Files

    nas:/c/photos/pictures# find ./output -type f -name '*.jpg' ! -wholename '*.AppleDouble*' | wc -l
    11295

✔ `53264+11295=64559`

### Sum of JPGs in numbered dirs __after moving processed files__

    nas:/c/photos/pictures# find [0-9]* -type f -name '*.jpg' ! -wholename '*.AppleDouble*' | wc -l
    64559

## Confirmation of `normalize-file-path.pl`

### Sum of JPGs in numbered dirs

    nas:/c/photos/pictures# find [0-9]* -type f -name '*.jpg' ! -wholename '*.AppleDouble*' | wc -l
    64559

### Processed Files

    nas:/c/photos/pictures# find ./new -type f -name '*.jpg' ! -wholename '*.AppleDouble*' | wc -l
    64556

### Errors
    [Sun Mar  4 22:42:10 2018] [ERROR] unable to write out new tag for new/2010/2010-02-27/20100227T094335_001.jpg because [Error reading ThumbnailImage data in IFD1]
    [Mon Mar  5 00:20:53 2018] [ERROR] unable to write out new tag for new/2012/2012-08-25/20120825T094558_001.jpg because [Error reading ThumbnailImage data in IFD1]
    [Mon Mar  5 00:20:53 2018] [ERROR] unable to write out new tag for new/2012/2012-08-25/20120825T094604_001.jpg because [Error reading ThumbnailImage data in IFD1]

### Fixed those 3 Images and Reprocessed all files

    nas:/c/photos/pictures# find ./new -type f -name '*.jpg' ! -wholename '*.AppleDouble*' | wc -l
    64559

### Archived all [1-2]* directories, then confirmed

    nas:/c/photos/pictures# tar czf /c/archive/photos/archived-photos.tar.gz [1-2]*
    nas:/c/photos/pictures# tar tzf /c/archive/photos/archived-photos.tar.gz |  grep -v .AppleDouble | egrep 'jpg$' | wc -l
    64559

## Confirmation of `normalize-file-path.pl` for videos

    nas:/c/multimedia/videos/family# wc -l info.csv
    2371 info.csv
    nas:/c/multimedia/videos/family# wc -l video-list.txt
    2371 video-list.txt
    nas:/c/multimedia/videos/family# find new/ -type f | wc -l
    2371
    nas:/c/multimedia/videos/family# find 20*  -type f -iname '*.mov' -o -iname '*.mp4' -o -iname '*.avi' | grep -v AppleDouble | wc -l
    2371


