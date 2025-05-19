#! /bin/bash

# If changes are found then create a PR with the changes

set -e

PR_TITLE=$1
if [ -z "$PR_TITLE" ]; then
    PR_TITLE="Auto PR"
fi

BRANCH=$2
if [ -z "$BRANCH" ]; then
    BRANCH="main"
fi

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed."
    exit 1
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "GITHUB_TOKEN is not set."
else
    echo "GITHUB_TOKEN is set."
    echo "GITHUB_TOKEN: $GITHUB_TOKEN"
fi

echo "Checking update for branch: $BRANCH"

if [[ `git status --porcelain` ]]; then
    echo "Found changes"

    # Configure Git user identity
    echo "Configuring Git user identity..."
    git config --global user.name "GitHub Actions"
    git config --global user.email "actions@github.com"

    # Create a new branch for the changes
    BRANCH_NAME="predefined_de/autopr_$(date +%s)"
    echo "Creating a new branch: $BRANCH_NAME"
    git checkout -b "$BRANCH_NAME"

    # Stage and commit the changes
    echo "Staging and committing changes..."
    git add -u
    git commit -m "$PR_TITLE"

    # Push the branch to the remote repository
    echo "Pushing changes to remote repository..."
    git push -u origin "$BRANCH_NAME"

    # Create a pull request using GitHub CLI
    echo "Creating a pull request..."
    if [[ "$BRANCH" == "main" ]]; then
        gh pr create --title "$PR_TITLE" --body "Automated PR for changes" --base "$BRANCH" --head "$BRANCH_NAME"
    else
        gh pr create --title "$PR_TITLE" --body "Automated PR for changes" --base "rel/$BRANCH" --head "$BRANCH_NAME"
    fi
else
    echo "No changes to commit"
fi
