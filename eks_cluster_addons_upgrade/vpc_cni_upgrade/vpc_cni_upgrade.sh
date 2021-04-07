#!/bin/bash

#-------------------------
#VPC CNI UPGARDE
#-------------------------

echo "VPC CNI Plugin before the Upgrade..."
kubectl describe daemonset aws-node --namespace kube-system | grep Image | cut -d "/" -f 2

echo "Downloading the latest VPC CNI Manifest..."
curl -o aws-k8s-cni.yaml https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/v1.7.9/config/v1.7/aws-k8s-cni.yaml

echo "Replace region in the manifest with the EKS Cluster region ..."
sed -i -e 's/us-west-2/eu-west-1/' aws-k8s-cni.yaml

echo "VPC CNI Plugin getting updated using KUBECTL..."
kubectl apply -f aws-k8s-cni.yaml

echo "VPC CNI Plugin after the Upgrade..."
kubectl describe daemonset aws-node --namespace kube-system | grep Image | cut -d "/" -f 2