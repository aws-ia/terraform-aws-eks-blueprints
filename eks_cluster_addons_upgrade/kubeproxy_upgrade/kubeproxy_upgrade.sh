#!/bin/bash

#-------------------------
#KUBE PROXY UPGRADE
#-------------------------
kube_proxy_version="1.19.6"

echo "KUBE PROXY Version before the Upgrade..."
kubectl get daemonset kube-proxy --namespace kube-system -o=jsonpath='{$.spec.template.spec.containers[:1].image}'

echo "Updating the Kube Proxy image using KUBECTL"
kubectl set image daemonset.apps/kube-proxy \
    -n kube-system \
    kube-proxy=602401143452.dkr.ecr.eu-west-1.amazonaws.com/eks/kube-proxy:v${kube_proxy_version}-eksbuild.2

echo "KUBE PROXY Version after the Upgrade..."
kubectl get daemonset kube-proxy --namespace kube-system -o=jsonpath='{$.spec.template.spec.containers[:1].image}'