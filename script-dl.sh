#!/bin/bash

username=${1:-"baybled"}

get_files() {
  local path="$1"
  local files=($(curl -sSL "https://github.com$path" | grep -oP "(?<=href=\").*?(?=\")" | grep -E "^/$username/.+\.(sh|bash|zsh)$"))
  if [ ${#files[@]} -eq 0 ]; then
    echo "No executable files found in this directory."
  else
    PS3="Select a file to download and run (or 'b' to go back): "
    select file in "${files[@]}"; do
      if [ "$file" == "" ]; then
        echo "Invalid choice!"
      elif [ "$file" == "b" ]; then
        break
      else
        echo "Downloading file $file..."
        curl -sSL "https://raw.githubusercontent.com$path/$file" -o "$file"
        chmod +x "$file"
        read -p "File downloaded successfully. Do you want to run it now? (y/n) " choice
        case "$choice" in
          y|Y ) ./"$file"; break;;
          n|N ) break;;
          * ) echo "Invalid choice!";;
        esac
      fi
    done
  fi
}

PS3="Select a repository to explore (or 'q' to quit): "
while true; do
  repositories=$(curl -sSL "https://github.com/$username?tab=repositories" | grep -oP "(?<=href=\"/).+?(?=/\")" | grep -v -E "(stargazers|forks)" | uniq)
  if [ -z "$repositories" ]; then
    echo "No repositories found for user $username"
    exit 1
  fi
  select repository in $repositories; do
    if [ "$repository" == "" ]; then
      echo "Invalid choice!"
    elif [ "$repository" == "q" ]; then
      exit 0
    else
      path="/$repository"
      echo "$path"
      while true; do
        get_files "$path"
        if [ "$path" == "/"$repository"" ]; then
          break
        else
          path=$(dirname "$path")
          echo "$path"
        fi
      done
      break
    fi
  done
done
