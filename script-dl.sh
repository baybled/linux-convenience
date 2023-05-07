#!/bin/bash

# Define the function for fetching the files
function fetch_files() {
    url="https://raw.githubusercontent.com/$1/$2/$3"
    curl -sSL $url
}

# Define the function for displaying the files in a tree-like structure
function tree() {
    local path="$1"
    local indent="${2:-}"
    local items=$(ls -a "$path")
    for item in $items; do
        if [[ $item == "." || $item == ".." ]]; then
            continue
        fi
        echo "${indent}${item}"
        if [[ -d "$path/$item" ]]; then
            tree "$path/$item" "${indent}    "
        fi
    done
}

# Set the default username to "baybled"
username=${1:-baybled}

# Initialize the repository list
repositories=$(curl -sSL "https://github.com/$username?tab=repositories" | grep -oP "(?<=href=\"/).+?(?=\")" | grep -v -E "(stargazers|forks)")

# Initialize the current directory as the top-level directory
current_dir=""

# Enter the main loop
while true; do
    # Display the current directory
    echo -e "\nCurrent directory: $current_dir\n"

    # Display the repositories
    i=1
    for repository in $repositories; do
        if [[ -z "$current_dir" ]]; then
            echo "  $i. $repository"
        else
            echo "  $i. .."
            tree_output=$(tree "$current_dir" "    ")
            if [[ -n "$tree_output" ]]; then
                echo "$tree_output"
            else
                echo "    (empty)"
            fi
            break
        fi
        let i++
    done

    # Read the user's choice
    read -p "Enter your choice: " choice

    # Handle the user's choice
    if [[ -z "$current_dir" && "$choice" =~ ^[0-9]+$ && $choice -ge 1 && $choice -le $(echo $repositories | wc -w) ]]; then
        current_dir=$(fetch_files "$username" $(echo $repositories | cut -d " " -f $choice)/HEAD/)
    elif [[ -n "$current_dir" && "$choice" == "1" ]]; then
        current_dir=$(dirname "$current_dir")
    elif [[ -n "$current_dir" && "$choice" =~ ^[0-9]+$ && $choice -ge 2 && $choice -le $(ls -a "$current_dir" | grep -v "^\.\.$" | wc -l) ]]; then
        file=$(ls -a "$current_dir" | grep -v "^\.\.$" | sed "${choice}q;d")
        fetch_files "$username" "$(echo $current_dir | cut -d "/" -f 2-)/$file"
        chmod +x "$file"
        read -p "Do you want to run the file now? (y/n) " run
        if [[ "$run" == "y" ]]; then
            ./"$file"
        fi
    fi
done
