#!/bin/bash

echo "Welcome to the GitHub repository downloader!"

# Prompt user for a username
read -p "Please enter a GitHub username (default: baybled): " username
username=${username:-baybled}

# Define function to handle repository traversal
function traverse_repos() {
    local current_dir="$1"
    local path="$2"
    local repo_index=0
    local repo_array=()
    local file_array=()
    local current_path="${path}/${current_dir}"
    
    # Print current location
    echo -e "\nCurrent path: ${current_path}\n"
    
    # Get a list of directories and files in the current directory
    local dir_list=$(ls -d ${current_dir}/*/ 2>/dev/null)
    local file_list=$(ls ${current_dir}/*.sh 2>/dev/null)
    
    # Add a "go back" option if not in the top-level directory
    if [[ "${current_dir}" != "${username}" ]]; then
        let "repo_index+=1"
        repo_array[${repo_index}]="../"
    fi
    
    # Add each repository in the current directory to the list
    for dir in ${dir_list}; do
        let "repo_index+=1"
        repo_array[${repo_index}]=$(basename ${dir})
    done
    
    # Add each file in the current directory to the list
    for file in ${file_list}; do
        let "file_index+=1"
        file_array[${file_index}]=$(basename ${file})
    done
    
    # Print the list of repositories
    echo "Please select a repository to explore:"
    for index in ${!repo_array[@]}; do
        echo "${index}. ${repo_array[${index}]}"
    done
    
    # Print the list of files
    echo "Please select a file to download:"
    for index in ${!file_array[@]}; do
        echo "${index}. ${file_array[${index}]}"
    done
    
    # Prompt user to choose an option
    read -p "Enter a number to make a selection, or 'q' to quit: " selection
    
    # Handle user's selection
    if [[ "${selection}" == "q" ]]; then
        echo "Goodbye!"
        exit 0
    elif [[ "${selection}" == "1" && "${current_dir}" != "${username}" ]]; then
        local parent_dir=$(dirname "${current_dir}")
        traverse_repos "${parent_dir}" "${path}"
    elif [[ "${selection}" -ge "1" && "${selection}" -le "${repo_index}" ]]; then
        local selected_repo="${repo_array[${selection}]}"
        traverse_repos "${selected_repo}" "${current_path}"
    elif [[ "${selection}" -gt "${repo_index}" && "${selection}" -le "$((${repo_index} + ${file_index}))" ]]; then
        local selected_file="${file_array[$((${selection} - ${repo_index}))]}"
        local file_path="${current_path}/${selected_file}"
        read -p "You've selected ${file_path}. Would you like to download and run this file? (y/n): " confirm
        if [[ "${confirm}" == "y" ]]; then
            curl -O "${raw_base}/${path}/${selected_file}"
            chmod +x "${selected_file}"
            ./"${selected_file}"
        fi
    else
        echo "Invalid selection. Please try again."
    fi
}

# Traverse the top-level directory to begin
traverse_repos "${username}" "${username}"
