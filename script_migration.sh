#!/bin/bash
log() {
	  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a migration.log
  }

  if [[ -z "$GITLAB_TOKEN" || -z "$GITHUB_TOKEN" ]]; then
	    echo "Помилка: Не встановлено токени GITLAB_TOKEN або GITHUB_TOKEN."
	      exit 1
      fi

      if [ $# -lt 2 ]; then
	        echo "Використання: $0 <gitlab_repo_url> <github_repo_name>"
		  exit 1
	  fi

	  GITLAB_REPO_URL="$1"
	  GITHUB_REPO_NAME="$2"
	  GITHUB_USER="salievak"

	  REPO_DIR=$(basename -s .git "$GITLAB_REPO_URL")

	  log "Початок міграції репозиторію: $REPO_DIR"

	  log "Клонування репозиторію з GitLab..."
	  git clone --mirror "$GITLAB_REPO_URL" "$REPO_DIR.git"
	  if [ $? -ne 0 ]; then
		    log "Помилка при клонуванні репозиторію з GitLab."
		      exit 1
	      fi

	      cd "$REPO_DIR.git" || exit

	      log "Створення нового репозиторію на GitHub через API..."
	      create_repo_response=$(curl -s -X POST -H "Authorization: token $GITHUB_TOKEN" \
		        -d "{\"name\": \"${GITHUB_REPO_NAME}\", \"private\": false}" \
			  https://api.github.com/user/repos)

	      if echo "$create_repo_response" | grep -q "errors"; then
		        log "Помилка при створенні репозиторію на GitHub: $create_repo_response"
			  exit 1
		  fi

		  GITHUB_REPO_URL="https://$GITHUB_USER:$GITHUB_TOKEN@github.com/$GITHUB_USER/${GITHUB_REPO_NAME}.git"
		  git remote add github "$GITHUB_REPO_URL"

		  log "Відправка всіх гілок та тегів до GitHub..."
		  git push --mirror github
		  if [ $? -ne 0 ]; then
			    log "Помилка при відправці репозиторію до GitHub."
			      exit 1
		      fi

		      log "Міграція репозиторію завершена успішно!"

		      exit 0

