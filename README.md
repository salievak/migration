# 📃 Automatic migration from GitLab to GitHub

# 🛠 Basic settings to get started:

- OS Linux
- install Git
- Bash
- install curl or wget

# 🔐 Generating and storing personal access tokens (PATs)

First, you need to generate personal tokens for your GitLab and GitHub accounts.
If you have any difficulties generating them, you can use the following documentation:
- "GitLab: Personal access tokens" - https://docs.gitlab.com/user/profile/personal_access_tokens/
- "GitHub: Managing your personal access tokens" - https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens

After generation, you need to store your tokens as environment variables.
To do this, add the following values to the file ``~/.bashrc``:
```
export GITLAB_TOKEN=<YOUR_GITLAB_TOKEN>
export GITHUB_TOKEN=<YOUR_GITHUB_TOKEN>
```
and apply changes:
```
source ~/.bashrc
```
That's all, now let's move on to implementing the migration script.

# ⚙ Initializing the project and creating a repository for the script

Create a project directory on your machine where all work will take place and initialize a git repository to save the script:
```
mkdir migraion_project
cd migration_project
git init
```
and create the ``script_migration.sh`` file (it is important to grant execution rights):
```
touch script_migration.sh
chmod +x script_migration.sh
```
In the ``script_migration.sh`` file, we write our script for migrating a repository from GitLab to GitHub.
💎 Let's look at the key points:
- checking for tokens
```
if [[ -z "$GITLAB_TOKEN" || -z "$GITHUB_TOKEN" ]]; then
  echo "Error: No tokens installed GITLAB_TOKEN or GITHUB_TOKEN."
  exit 1
fi
```
- checking the given arguments:
```
if [ $# -lt 2 ]; then
  echo "Usage: $0 <gitlab_repo_url> <github_repo_name>"
  exit 1
fi

GITLAB_REPO_URL="$1"
GITHUB_REPO_NAME="$2"
```
- cloning a repository from GitLab:
```
log "Cloning a repository from GitLab..."
git clone --mirror "$GITLAB_REPO_URL" "$REPO_DIR.git"
if [ $? -ne 0 ]; then
  log "Error cloning a repository from GitLab."
  exit 1
fi

cd "$REPO_DIR.git" || exit
```
- creating a new repository on GitHub via the API:
```
log "Create a new repository on GitHub using the API..."
create_repo_response=$(curl -s -X POST -H "Authorization: token $GITHUB_TOKEN" \
  -d "{\"name\": \"${GITHUB_REPO_NAME}\", \"private\": false}" \
  https://api.github.com/user/repos)
```
- adding a new remote for GitHub:
```
GITHUB_REPO_URL="https://$GITHUB_USER:$GITHUB_TOKEN@github.com/$GITHUB_USER/${GITHUB_REPO_NAME}.git"
git remote add github "$GITHUB_REPO_URL"
```
- sending all data to GitHub:
```
log "Send all branches and tags to GitHub..."
git push --mirror github
if [ $? -ne 0 ]; then
  log "Error when sending a repository to GitHub."
  exit 1
fi

log "Repository migration completed successfully!"
```
- event logging:
```
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a migration.log
}
```
💎 To implement bulk migrations, you can create a text file that contains the GitLab repositories and the names of the new GitHub repositories:
for example ``list_migration.txt``
```
#gitlab_repo_url github_repo_name
https://gitlab.com/testgr/migrationtest1.git migrationtest1
```
We use the following script for mass migration (file ``all_migration.sh``):
```
INPUT_FILE="list_migration.txt"
while IFS= read -r line; do

  [[ -z "$line" || "$line" =~ ^# ]] && continue
  
  GITLAB_REPO_URL=$(echo "$line" | awk '{print $1}')
  GITHUB_REPO_NAME=$(echo "$line" | awk '{print $2}')
  
  echo "Repository migration: $GITLAB_REPO_URL -> $GITHUB_REPO_NAME"
  ./script_migration.sh "$GITLAB_REPO_URL" "$GITHUB_REPO_NAME"
done < "$INPUT_FILE"
```
Now, to start the migration of one repository, use the following command:
```
./script_migration.sh "https://gitlab.com/your_group/your_repo.git" "new_github_repo_name"
```
To run a mass migration, we run another script with a pre-prepared list in ``list_migration.txt``:
```
./all_migration.sh
```
⭐ That's all, test this script on your test project before using it on production projects.
