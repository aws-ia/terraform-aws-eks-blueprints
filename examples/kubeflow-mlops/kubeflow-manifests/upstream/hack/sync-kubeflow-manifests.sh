#!/usr/bin/env bash

# This script aims at helping create a PR to update the manifests of the
# kubeflow/kubeflow repo.
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

SRC_DIR=${SRC_DIR:=/tmp/kubeflow-kubeflow}
BRANCH=${BRANCH:=sync-kubeflow-kubeflow-manifests-${COMMIT?}}

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

echo "Copying admission-webhook manifests..."
DST_DIR=$MANIFESTS_DIR/apps/admission-webhook/upstream
rm -r $DST_DIR
cp $SRC_DIR/components/admission-webhook/manifests $DST_DIR -r

echo "Updating README..."
SRC_TXT="\[.*\](https://github.com/kubeflow/kubeflow/tree/.*/components/admission-webhook/manifests)"
DST_TXT="\[$COMMIT\](https://github.com/kubeflow/kubeflow/tree/$COMMIT/components/admission-webhook/manifests)"
sed -i "s|$SRC_TXT|$DST_TXT|g" ${MANIFESTS_DIR}/README.md

echo "Copying centraldashboard manifests..."
DST_DIR=$MANIFESTS_DIR/apps/centraldashboard/upstream
rm -r $DST_DIR
cp $SRC_DIR/components/centraldashboard/manifests $DST_DIR -r

echo "Updating README..."
SRC_TXT="\[.*\](https://github.com/kubeflow/kubeflow/tree/.*/components/centraldashboard/manifests)"
DST_TXT="\[$COMMIT\](https://github.com/kubeflow/kubeflow/tree/$COMMIT/components/centraldashboard/manifests)"
sed -i "s|$SRC_TXT|$DST_TXT|g" ${MANIFESTS_DIR}/README.md

echo "Copying jupyter-web-app manifests..."
DST_DIR=$MANIFESTS_DIR/apps/jupyter/jupyter-web-app/upstream
rm -r $DST_DIR
cp $SRC_DIR/components/crud-web-apps/jupyter/manifests $DST_DIR -r

echo "Updating README..."
SRC_TXT="\[.*\](https://github.com/kubeflow/kubeflow/tree/.*/components/crud-web-apps/jupyter/manifests)"
DST_TXT="\[$COMMIT\](https://github.com/kubeflow/kubeflow/tree/$COMMIT/components/crud-web-apps/jupyter/manifests)"
sed -i "s|$SRC_TXT|$DST_TXT|g" ${MANIFESTS_DIR}/README.md

echo "Copying volumes-web-app manifests..."
DST_DIR=$MANIFESTS_DIR/apps/volumes-web-app/upstream
rm -r $DST_DIR
cp $SRC_DIR/components/crud-web-apps/volumes/manifests $DST_DIR -r

echo "Updating README..."
SRC_TXT="\[.*\](https://github.com/kubeflow/kubeflow/tree/.*/components/crud-web-apps/volumes/manifests)"
DST_TXT="\[$COMMIT\](https://github.com/kubeflow/kubeflow/tree/$COMMIT/components/crud-web-apps/volumes/manifests)"
sed -i "s|$SRC_TXT|$DST_TXT|g" ${MANIFESTS_DIR}/README.md

echo "Copying tensorboards-web-app manifests..."
DST_DIR=$MANIFESTS_DIR/apps/tensorboard/tensorboards-web-app/upstream
rm -r $DST_DIR
cp $SRC_DIR/components/crud-web-apps/tensorboards/manifests $DST_DIR -r

echo "Updating README..."
SRC_TXT="\[.*\](https://github.com/kubeflow/kubeflow/tree/.*/components/crud-web-apps/tensorboards/manifests)"
DST_TXT="\[$COMMIT\](https://github.com/kubeflow/kubeflow/tree/$COMMIT/components/crud-web-apps/tensorboards/manifests)"
sed -i "s|$SRC_TXT|$DST_TXT|g" ${MANIFESTS_DIR}/README.md

echo "Copying profile-controller manifests..."
DST_DIR=$MANIFESTS_DIR/apps/profiles/upstream
rm -r $DST_DIR
cp $SRC_DIR/components/profile-controller/config $DST_DIR -r

echo "Updating README..."
SRC_TXT="\[.*\](https://github.com/kubeflow/kubeflow/tree/.*/components/profile-controller/config)"
DST_TXT="\[$COMMIT\](https://github.com/kubeflow/kubeflow/tree/$COMMIT/components/profile-controller/config)"
sed -i "s|$SRC_TXT|$DST_TXT|g" ${MANIFESTS_DIR}/README.md

echo "Copying notebook-controller manifests..."
DST_DIR=$MANIFESTS_DIR/apps/jupyter/notebook-controller/upstream
rm -r $DST_DIR
cp $SRC_DIR/components/notebook-controller/config $DST_DIR -r

echo "Updating README..."
SRC_TXT="\[.*\](https://github.com/kubeflow/kubeflow/tree/.*/components/notebook-controller/config)"
DST_TXT="\[$COMMIT\](https://github.com/kubeflow/kubeflow/tree/$COMMIT/components/notebook-controller/config)"
sed -i "s|$SRC_TXT|$DST_TXT|g" ${MANIFESTS_DIR}/README.md

echo "Copying tensorboard-controller manifests..."
DST_DIR=$MANIFESTS_DIR/apps/tensorboard/tensorboard-controller/upstream
rm -r $DST_DIR
cp $SRC_DIR/components/tensorboard-controller/config $DST_DIR -r

echo "Updating README..."
SRC_TXT="\[.*\](https://github.com/kubeflow/kubeflow/tree/.*/components/tensorboard-controller/config)"
DST_TXT="\[$COMMIT\](https://github.com/kubeflow/kubeflow/tree/$COMMIT/components/tensorboard-controller/config)"
sed -i "s|$SRC_TXT|$DST_TXT|g" ${MANIFESTS_DIR}/README.md

echo "Successfully copied all manifests."

# DEV: Comment out these commands when local testing
echo "Committing the changes..."
cd $MANIFESTS_DIR
git add apps
git add README.md
git commit -m "Update kubeflow/kubeflow manifests from ${COMMIT}"
