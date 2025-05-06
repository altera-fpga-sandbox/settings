#! /bin/bash

# If changes are found then create a pr with the changes

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
    dt pr init feat/autopr_$(date +%s)
    git add -u
    git commit -m "$PR_TITLE"

    if [[ "$BRANCH" == "main" ]]; then
        dt pr create --no-fork --title="$PR_TITLE"
    else
        dt pr create --no-fork --title="$PR_TITLE" --base=rel/$BRANCH
    fi
else
    echo "No changes to commit"
fi
