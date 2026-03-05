#!/usr/bin/env bash

set -e

BRANCH="main"
INTERVAL=5

echo "GitOps agent starting..."
echo "Branch: $BRANCH"

LAST_COMMIT=$(git rev-parse HEAD)

echo "Current commit: $LAST_COMMIT"

docker compose up -d --build

while true
do
    git fetch origin $BRANCH

    NEW_COMMIT=$(git rev-parse origin/$BRANCH)

    if [ "$NEW_COMMIT" != "$LAST_COMMIT" ]; then
        echo ""
        echo "Change detected!"
        echo "Old commit: $LAST_COMMIT"
        echo "New commit: $NEW_COMMIT"

        git pull origin $BRANCH

        echo "Rebuilding containers..."
        docker compose up -d --build

        echo "Deployment complete"

        LAST_COMMIT=$NEW_COMMIT
    fi

    sleep $INTERVAL
done
