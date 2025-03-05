# 📃 Automatic migration from GitLab to GitHub

# 🛠 Basic settings to get started:

- OS Linux
- install Git
- Bash
- install curl or wget

# 🔐 Generating and storing personal access tokens (PATs)

First, you need to generate personal tokens for your GitLab and GitHub accounts.
If you have any difficulties generating them, you can use the following documentation:

"GitLab: Personal access tokens" - https://docs.gitlab.com/user/profile/personal_access_tokens/
"GitHub: Managing your personal access tokens" - https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens

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

# 
