### To Do

0. dedupe
1. Sort into appropriate subfolders
2. Rename filename to standard form.
3. Assign UUID for each file.
4. create checksum of file.
5. output filename, create date, checkum, uuid.

* Deduping

1. Generate a checksum of every file.  Pipe that to `remove-duplicates.pl`.
2. Output of `remove-duplicates.pl` lists checksum & filename of every file.
3. Confirm counts of files with lines of output from remove-duplicates.


### Database File

* `image-info.csv`
  - database of all images with uuid, checksum & create date.

### Scripts

* `normalize-file-path.pl`
  - copies files to a new location with normalized paths & validated metadata.

* `remove-duplicates.pl`
   - given a set of checksums, identify files with matching checksums and remove duplicates.

* `list-image-dates.pl`
  - renames image files to have a standard filename, and adds a UUID for the image based on the filename.

* `print-missing-create-date.pl`
  - lists images whose tag (`CreateDate`) is missing or empty.

* `copy-originaldate-to-createdate.pl`
  - copies the value of one tag (`DateTimeOriginal` to another `CreateDate`)

* `create-date-from-path.pl`
  - infers the create date from the file path of the image.


### Commands

* Download a bunch of files from S3, preserving directory structure:
```
for i in `cat list.txt ` ; do aws s3 cp s3://cc.roja.media/photos/pictures/$i `dirname $i` ; done
```

* Find empty directories
```
find . -type d -empty
```

* Delete all `.AppleDouble` directories
```
find . -name ".Parent" -exec rm {} \; && find . -name ".AppleDouble" -type d -empty -delete
```

* List all JPGs under current directory

```
find . -type f -name '*.jpg' ! -wholename '*.AppleDouble*'
```

* List all Videos under current directory

```
find . -type f -a \( -iname '*.mov' -o -iname '*.mp4' -o -iname '*.avi' \) ! -wholename '*.AppleDouble*'
```

* Checksum all JPGs

```
find . -type f -name '*.jpg' ! -wholename '*.AppleDouble*' -exec sha512sum {} \;
```

* Find lines in file A not in file B

```
diff --new-line-format="" --unchanged-line-format="" <(sort deduped-list.txt) <(sort jpeg-list.txt)
```

