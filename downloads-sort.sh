#!/bin/bash

# Define the source directory to search for zip files
source_dir=~/Downloads

# Define the destination directory to move directories containing .sfz/.sf2 files
destination_dir=~/Sound\ Fonts

# Find all zip files in the source directory and its subdirectories
zip_files=$(find "$source_dir" -iname "*.zip" -type f)

# Loop through each zip file and unzip it into a directory with the same name as the zip file
for zip_file in $zip_files; do
    # Create a directory with the same name as the zip file, minus the extension
    dir_name="${zip_file%.*}"
    mkdir -p "$dir_name"

    # Unzip the file into the newly created directory
    unzip -q "$zip_file" -d "$dir_name"

    # Delete the zip file after unzipping
    rm "$zip_file"
done

# Find all directories containing .sfz/.sf2 files
font_dirs=$(find "$source_dir" \( -iname '*.sf2' -o -iname '*.sfz' \) -type f -printf '%h\n' | sort -u)

# Loop through each font directory and move it to the destination directory
for font_dir in $font_dirs; do
    # Only move the directory if it's not already in the destination directory
    if [ "$destination_dir" != "$font_dir" ]; then
        # Move the directory to the destination directory
        mv "$font_dir" "$destination_dir"
        echo "Moved $font_dir to $destination_dir"
    fi
done
