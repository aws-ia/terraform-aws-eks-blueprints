#!/usr/bin/env bash

# Copyright 2021 The Kubeflow Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This shell script is used to setup Kubeflow deployment.
set -euo pipefail

TIMEOUT=600s  # 10mins

echo "Creating Kubeflow namespace..."
kubectl create namespace kubeflow --dry-run=client -o yaml | kubectl apply -f -

echo "Deploying Cert-Manager."
kustomize build common/cert-manager/cert-manager/base | kubectl apply -f -

echo "Waiting for Cert Manager pods to become ready..."
sleep 5
kubectl wait --timeout=${TIMEOUT} -n cert-manager --all --for=condition=Ready pod

echo "Deploying Istio."
kustomize build common/istio-1-11/istio-crds/base | kubectl apply -f -
kustomize build common/istio-1-11/istio-namespace/base | kubectl apply -f -
kustomize build common/istio-1-11/istio-install/base | kubectl apply -f -

echo "Waiting for istio-system Pods to become ready..."
sleep 5
kubectl wait --timeout=${TIMEOUT} -n istio-system --all --for=condition=Ready pod

echo "Deploying Knative."
function install_knative {
    kustomize build common/knative/knative-serving/overlays/gateways | kubectl apply -f -
}

while ! install_knative;
do
    echo "Retrying to install knative..."
    sleep 10
done

kustomize build common/knative/knative-eventing/base | kubectl apply -f -
kustomize build common/istio-1-11/cluster-local-gateway/base | kubectl apply -f -

echo "Waiting for knative-serving Pods to become ready..."
sleep 5
kubectl wait --timeout=${TIMEOUT} -n knative-serving --all --for=condition=Ready pod

echo "Deploying KFP."
function install_kfp {
    kustomize build apps/pipeline/upstream/env/cert-manager/platform-agnostic-multi-user | kubectl apply -f - --validate=false
}

while ! install_kfp;
do
    echo "Retrying to install kfp..."
    sleep 10
done

echo "Waiting for kubeflow/ml-pipelines to become ready..."
sleep 5
kubectl wait --timeout=${TIMEOUT} -n kubeflow -l app=ml-pipeline --for=condition=Ready pod

echo "Deploying KFServing."
kustomize build apps/kfserving/upstream/overlays/kubeflow | kubectl apply -f -

echo "Waiting for kubeflow/kfserving to become ready..."
sleep 5
kubectl wait --timeout=${TIMEOUT} -n kubeflow -l app=kfserving --for=condition=Ready pod

echo "Deploying Katib."
kustomize build apps/katib/upstream/installs/katib-with-kubeflow | kubectl apply -f -

echo "Waiting for kubeflow/katib to become ready..."
sleep 5
kubectl wait --timeout=${TIMEOUT} -n kubeflow -l katib.kubeflow.org/component=controller --for=condition=Ready pod

echo "Deploying Training Operator."
kustomize build apps/training-operator/upstream/overlays/kubeflow | kubectl apply -f -

echo "Waiting for kubeflow/training-operator to become ready..."
sleep 5
kubectl wait --timeout=${TIMEOUT} -n kubeflow -l control-plane=kubeflow-training-operator --for=condition=Ready pod

echo "Installing Profiles Controller."
kustomize build apps/profiles/upstream/overlays/kubeflow | kubectl apply -f -

echo "Waiting for kubeflow/profiles-controller to become ready..."
sleep 5
kubectl wait --timeout=${TIMEOUT} -n kubeflow -l kustomize.component=profiles --for=condition=Ready pod

echo "Creating user resources."
kustomize build common/user-namespace/base | kubectl apply -f -
kustomize build common/cert-manager/kubeflow-issuer/base | kubectl apply -f -

