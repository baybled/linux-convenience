#!/bin/bash

username=${1:-baybled}

echo "Searching for repositories in user $username's GitHub account..."

repositories=$(curl -s "https://api.github.com/users/$username/repos?per_page=1000" | grep -oP '(?<="name":")[^"]+')

if [ -z "$repositories" ]; then
  echo "No repositories found for user $username."
  exit 1
fi

echo "Found the following repositories:"
echo "$repositories"

read -p "Enter the number of the repository you want to download from: " repository_number
repository=$(echo "$repositories" | sed -n "${repository_number}p")

echo "Searching for bash scripts in repository $repository..."

files=$(curl -s "https://api.github.com/repos/$username/$repository/contents" | jq -r '.[] | select(.type == "file" and .name | endswith(".sh")) | .name')

echo "Found the following bash script files:"
echo "$files"

read -p "Enter the number of the file you want to download: " file_number
file=$(echo "$files" | sed -n "${file_number}p")

echo "Downloading file $file..."

curl -s "https://raw.githubusercontent.com/$username/$repository/master/$file" -o "$file"
chmod +x "$file"

read -p "Do you want to run the script now? (y/n) " run_now

if [ "$run_now" == "y" ]; then
    "./$file"
fi
