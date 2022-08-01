#!/usr/bin/env bash
source pids.env

echo "Killing background jobs..."

kill -KILL $ISTIO_PID
echo "Killed istio port-forward."

kill -KILL $PIPELINES_PID
echo "Killed pipelines port-forward."
