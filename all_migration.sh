#!/bin/bash

INPUT_FILE="list_migration.txt"
while IFS= read -r line; do
	    [[ -z "$line" || "$line" =~ ^# ]] && continue
	      
	      GITLAB_REPO_URL=$(echo "$line" | awk '{print $1}')
	        GITHUB_REPO_NAME=$(echo "$line" | awk '{print $2}')
		  
		  echo "Міграція репозиторію: $GITLAB_REPO_URL -> $GITHUB_REPO_NAME"
		    ./script_migration.sh "$GITLAB_REPO_URL" "$GITHUB_REPO_NAME"
	    done < "$INPUT_FILE"

