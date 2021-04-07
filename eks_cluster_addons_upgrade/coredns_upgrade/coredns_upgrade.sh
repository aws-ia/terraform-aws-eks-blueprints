#!/bin/bash

#-------------------------
# COREDNS UPGRADE
#-------------------------
coredns_version="1.8.0"


echo "Core DNS Version before the Upgrade..."
kubectl get deployment coredns --namespace kube-system -o=jsonpath='{$.spec.template.spec.containers[:1].image}'


echo "Updating the Core DNS image using KUBECTL"
kubectl set image --namespace kube-system deployment.apps/coredns \
            coredns=602401143452.dkr.ecr.eu-west-1.amazonaws.com/eks/coredns:v${coredns_version}-eksbuild.1


echo "Core DNS Version after the Upgrade..."
kubectl get deployment coredns --namespace kube-system -o=jsonpath='{$.spec.template.spec.containers[:1].image}'