#!/usr/bin/env bash
set -euo pipefail

echo "Installing necessary RBAC."""
kubectl apply -f yamls

echo "Setting up port-forward..."
./hack/proxy_istio.sh
./hack/proxy_pipelines.sh

echo "Running the tests."""
python3 mnist.py

echo "Cleaning up opened processes."""
./hack/cleanup_proxies.sh

echo "Leaving the cluster as is for further inspection."
