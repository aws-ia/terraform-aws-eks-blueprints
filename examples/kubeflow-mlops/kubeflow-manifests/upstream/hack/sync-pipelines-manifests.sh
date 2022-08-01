#!/usr/bin/env bash

# This script aims at helping create a PR to update the manifests of the
# kubeflow/pipelines repo.
# This script:
# 1. Checks out a new branch
# 2. Copies files to the correct places
# 3. Commits the changes
#
# Afterwards the developers can submit the PR to the kubeflow/manifests
# repo, based on that local branch

# strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

SRC_DIR=${SRC_DIR:=/tmp/kubeflow-pipelines}
BRANCH=${BRANCH:=sync-kubeflow-pipelines-manifests-${COMMIT?}}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
MANIFESTS_DIR=$(dirname $SCRIPT_DIR)

echo "Creating branch: ${BRANCH}"

# DEV: Comment out this if when local testing
if [ -n "$(git status --porcelain)" ]; then
  # Uncommitted changes
  echo "WARNING: You have uncommitted changes, exiting..."
  exit 1
fi

if [ `git branch --list $BRANCH` ]
then
   echo "WARNING: Branch $BRANCH already exists. Exiting..."
   exit 1
fi

# DEV: Comment out this checkout command when local testing
git checkout -b $BRANCH

echo "Checking out in $SRC_DIR to $COMMIT..."
cd $SRC_DIR
if [ -n "$(git status --porcelain)" ]; then
  # Uncommitted changes
  echo "WARNING: You have uncommitted changes, exiting..."
  exit 1
fi
git checkout $COMMIT

echo "Copying pipelines manifests..."
DST_DIR=$MANIFESTS_DIR/apps/pipeline/upstream
rm -r $DST_DIR
cp $SRC_DIR/manifests/kustomize $DST_DIR -r


echo "Successfully copied all manifests."

echo "Updating README..."
SRC_TXT="\[.*\](https://github.com/kubeflow/pipelines/tree/.*/manifests/kustomize)"
DST_TXT="\[$COMMIT\](https://github.com/kubeflow/pipelines/tree/$COMMIT/manifests/kustomize)"

sed -i "s|$SRC_TXT|$DST_TXT|g" ${MANIFESTS_DIR}/README.md

# DEV: Comment out these commands when local testing
echo "Committing the changes..."
cd $MANIFESTS_DIR
git add apps
git add README.md
git commit -m "Update kubeflow/pipelines manifests from ${COMMIT}"
