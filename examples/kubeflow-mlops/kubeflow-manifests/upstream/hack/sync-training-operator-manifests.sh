#!/usr/bin/env bash

# This script aims at helping create a PR to update the manifests of the
# kubeflow/training-operator repo.
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

SRC_DIR=${SRC_DIR:=/tmp/kubeflow-training-operator}
BRANCH=${BRANCH:=sync-kubeflow-training-operator-manifests-${COMMIT?}}

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

echo "Copying training-operator manifests..."
DST_DIR=$MANIFESTS_DIR/apps/training-operator/upstream
rm -r $DST_DIR
cp $SRC_DIR/manifests $DST_DIR -r


echo "Successfully copied all manifests."

# DEV: Comment out these commands when local testing
echo "Committing the changes..."
cd $MANIFESTS_DIR
git add apps
git commit -m "Update kubeflow/training-operator manifests from ${COMMIT}"
