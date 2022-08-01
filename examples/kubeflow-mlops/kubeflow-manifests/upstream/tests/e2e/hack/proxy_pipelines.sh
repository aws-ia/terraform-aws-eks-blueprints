#!/usr/bin/env bash
set -euo pipefail

kubectl port-forward -n kubeflow svc/ml-pipeline-ui 3000:80 &
PIPELINES_PID=$!

echo "Started Pipelines port-forward, pid: $PIPELINES_PID"
echo PIPELINES_PID=$PIPELINES_PID >> pids.env

sleep 1
