#!/bin/bash

# Define function to handle user input
function handle_input {
  local input=$1
  if [[ $input == "b" ]]; then
    # Move back one directory
    path=$(dirname "$path")
  elif [[ $input =~ ^[0-9]+$ ]]; then
    # Check if selection is a directory
    local selection=${choices[$input]}
    local selection_url=${urls[$input]}
    if [[ $selection == */ ]]; then
      # Move into selected directory
      path=$path/$selection
      # Download HTML content of selected directory
      local content=$(curl -s $selection_url)
      # Parse links to find subdirectories and files
      parse_links "$content"
    else
      # Download selected file
      echo "Downloading $selection..."
      curl -O $selection_url
      # Make file executable
      chmod +x $selection
      # Ask if user wants to run file now
      read -p "Do you want to run $selection now? (y/n): " choice
      case "$choice" in 
        y|Y ) ./$selection;;
        n|N ) echo "Okay, exiting...";;
        * ) echo "Invalid choice. Exiting...";;
      esac
      # Move back to previous directory
      path=$(dirname "$path")
    fi
  else
    echo "Invalid input, please try again."
  fi
}

# Define function to parse links in HTML content
function parse_links {
  local content=$1
  # Clear arrays
  unset choices urls
  # Find links to subdirectories and files
  local links=$(echo "$content" | grep -Eo 'href="[^"]+"' | cut -d'"' -f2)
  for link in $links; do
    if [[ $link == */ ]]; then
      # Add subdirectory to choices array
      choices+=("${link%/}/")
      urls+=("$path/$link")
    elif [[ $link == *.sh ]]; then
      # Add script file to choices array
      choices+=("$link")
      urls+=("$path/$link")
    fi
  done
}

# Set default username
username="baybled"
# Set starting path
path="https://github.com/$username"

echo "Welcome to the Github Repository Browser!"
echo "Type the number of a choice to navigate or 'b' to go back."
echo

while true; do
  # Download HTML content of current directory
  local content=$(curl -s $path)
  # Parse links to find subdirectories and files
  parse_links "$content"
  # Print current location
  echo "Current Location: ${path#https://github.com/}"
  # Print choices
  for i in "${!choices[@]}"; do
    echo "[$i] ${choices[$i]}"
  done
  # Get user input
  read -p "Enter selection: " input
  # Handle user input
  handle_input "$input"
done
