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

echo "Checking update for branch: $BRANCH"

if [[ `git status --porcelain` ]]; then
    echo "Found changes"

    # Create a new branch for the changes
    BRANCH_NAME="predefined_de/autopr_$(date +%s)"
    git checkout -b "$BRANCH_NAME"

    # Stage and commit the changes
    git add -u
    git commit -m "$PR_TITLE"

    # Push the branch to the remote repository
    git push -u origin "$BRANCH_NAME"

    # Create a pull request using GitHub CLI
    if [[ "$BRANCH" == "main" ]]; then
        gh pr create --title "$PR_TITLE" --body "Automated PR for changes" --base "$BRANCH" --head "$BRANCH_NAME"
    else
        gh pr create --title "$PR_TITLE" --body "Automated PR for changes" --base "rel/$BRANCH" --head "$BRANCH_NAME"
    fi
else
    echo "No changes to commit"
fi
