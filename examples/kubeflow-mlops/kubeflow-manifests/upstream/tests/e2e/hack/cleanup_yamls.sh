#!/usr/bin/env bash
source pids.env

echo "Killing background jobs..."

kill -KILL $ISTIO_PID
echo "Killed istio port-forward."

kill -KILL $PIPELINES_PID
echo "Killed pipelines port-forward."

kubectl delete experiments.kubeflow.org -n kubeflow-user-example-com mnist-e2e

kubectl delete tfjobs.kubeflow.org -n kubeflow-user-example-com mnist-e2e

kubectl delete inferenceservices.serving.kubeflow.org -n kubeflow-user-example-com mnist-e2e
