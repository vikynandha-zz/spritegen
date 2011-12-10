# Make the script exit if any of the commands executed here return error
set -e

cleanup_names()
{
    rename -v 'y/A-Z/a-z/' *.png
    rename -v 's/ /-/g' *.png
}

generate_src_css()
{
    for file in $(ls *.png)
    do
        filebasename=$(basename $file .png)
        wd=$(pwd)
        dimensions=$(identify $file | sed -n 's/\(^.*\)\ \([0-9]*\)x\([0-9]*\)\ \(.*$\)/\2 \3/p')
        width=$(echo "${dimensions}" | awk '{print $1}')
        height=$(echo "${dimensions}" | awk '{print $2}')
        echo '.sp-'$filebasename' {'
        echo '  background: url("'$wd'/'$file'") no-repeat;'
        echo '  width: '$width'px;'
        echo '  height: '$height'px;'
        echo '}'\\n
    done
}

if [ $# -eq 0 ]
then
    echo "No arguments passed."
    echo "Usage: sh spritege.sh <path to folder containing source images>"
    exit 1
fi

cd $1
path=${PWD}
fname=${PWD##*/}

echo "Source folder: $path"
echo "Cleaning up image filenames to remove whitespaces and make them all-lowercase..."
cleanup_names

echo "Creating source CSS..."
generate_src_css > $fname.css
echo "Source CSS created at $path/$fname.css\n\n"

echo "Creating sprite..."
spritemapper $path/$fname.css
echo "\n\n"

echo 'Compressing sprite image using trimage... (Ignore errors like "<given file> not a supported image file and/or not writeable")'
cd ../
trimage -f $fname.png
echo "\nCompleted!"
