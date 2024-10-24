# Add all changes in working directory to the staging area
alias gad='git add .'

# Amend the most recent commit
alias gamd='git commit --amend'

# List all local branches
alias gbr='git branch | grep .'

# List all remote branches
alias gbrr='git branch -r | grep .'

# Delete a branch
alias gbd='git branch -d'
alias gbD='git branch -D'

# Create a new branch and switch to it
alias gcb='git checkout -b'

# Remove files from the index (staging area)
alias gcr='git rm -r --cached'

# Fetch from and integrate with another repository or a local branch (short for 'git pull origin')
alias gpull='git pull origin'

# Update remote refs along with associated objects (short for 'git push origin')
alias gpush='git push origin'

# Show the working tree status
alias gst='git status'

# Switch to another branch
alias gsw='git switch'
