#!/usr/bin/env bash

# Ensure the root volume partition size is expanded
growpart $(lsblk --noheadings --paths --output PKNAME /dev/xvda | xargs | cut -d " " -f 1) 1

# Mount the 2nd volume
mkfs -t xfs /dev/xvdb
mkdir /cache
mount /dev/xvdb /cache

mkdir -p /cache/var/lib/containerd
mkdir -p /cache/var/lib/kubelet

# containerd needs to be running to pull images
systemctl start containerd

export CONTAINER_RUNTIME_ENDPOINT='unix:///run/containerd/containerd.sock'
export IMAGE_SERVICE_ENDPOINT='unix:///run/containerd/containerd.sock'

# ECR images
ECR_PASSWORD=$(aws ecr get-login-password --region "${region}")
%{ for img in ecr_images ~}
crictl pull --creds "AWS:$${ECR_PASSWORD}" "${img}"
%{ endfor ~}

# Public images
%{ for img in public_images ~}
crictl pull "${img}"
%{ endfor ~}

yum install rsync -y
cd / && rsync -a /var/lib/containerd/ /cache/var/lib/containerd
echo 'synced /var/lib/containerd'
cd / && rsync -a /var/lib/kubelet/ /cache/var/lib/kubelet
echo 'synced /var/lib/kubelet'
