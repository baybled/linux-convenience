#!/bin/bash

# Set default username if none provided
username=${1:-"baybled"}

# Initialize variables
response=""
url="https://api.github.com/users/$username/repos"
declare -a paths=("$url")

# Define function to list contents of a directory
function list_contents {
  local contents=($(ls -p $1 | grep -v /))
  if [[ ${#contents[@]} -eq 0 ]]; then
    echo "No files found."
    return 1
  fi

  echo "Choose a file to download (or enter 'back' to go up a level):"
  for i in "${!contents[@]}"; do
    printf "%s\t%s\n" "$i" "${contents[$i]}"
  done
}

# Define function to traverse directories
function traverse_directory {
  local path="${paths[-1]}"
  local response

  while [[ -n "$path" ]]; do
    local contents=($(curl -s "$path" | jq -r '.[] | select(.type == "dir") | .name'))

    if [[ ${#contents[@]} -eq 0 ]]; then
      echo "No directories found at this level."
    else
      echo "Choose a directory to enter (or enter 'back' to go up a level):"
      for i in "${!contents[@]}"; do
        printf "%s\t%s\n" "$i" "${contents[$i]}"
      done

      read -r response
      if [[ "$response" == "back" ]]; then
        paths=("${paths[@]:0:${#paths[@]}-1}")
        continue
      fi

      local selection=${contents[$response]}
      if [[ -n "$selection" ]]; then
        path="$path/$selection"
        paths+=("$path")
      else
        echo "Invalid selection."
      fi
    fi

    list_contents "$(echo $path | cut -d'/' -f5-)"
    read -r response

    if [[ "$response" == "back" ]]; then
      paths=("${paths[@]:0:${#paths[@]}-1}")
      continue
    fi

    local filename="${contents[$response]}"
    if [[ -n "$filename" ]]; then
      echo "Downloading file: $filename"
      curl -s -O "$url/$filename"
      chmod +x "$filename"
      read -p "Run file now? (y/n) " run_file
      if [[ "$run_file" == "y" ]]; then
        ./"$filename"
      fi
      return 0
    fi

    echo "Invalid selection."
  done
}

# Call function to start traversal
traverse_directory

# Display current directory structure
tree_output=$(tree -d "$username" | sed 's/[0-9]* directories, [0-9]* files//')
echo -e "\nCurrent directory structure:"
echo "$tree_output"
