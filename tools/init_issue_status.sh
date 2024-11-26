#!/bin/bash

ISSUE_ID=$1
DEFAULT_ASSIGNEE=Lesords

REPO_NAME=$(gh repo view --json name --jq '.name')
ASSIGNEES=$(gh issue view $ISSUE_ID --json assignees --jq '.assignees[].login')
LABELS=$(gh issue view $ISSUE_ID --json labels --jq '.labels[].name')

if [ -z "$LABELS" ]; then
    gh issue edit $ISSUE_ID --add-label "UAY,$REPO_NAME"
fi

if [ -z "$ASSIGNEES" ]; then
    gh issue edit $ISSUE_ID --add-assignee "$DEFAULT_ASSIGNEE"
fi
