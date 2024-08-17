#!/usr/bin/env bash

systemctl stop kubelet
systemctl stop containerd

# Ensure the root volume partition size is expanded
growpart $(lsblk --noheadings --paths --output PKNAME /dev/xvda | xargs | cut -d " " -f 1) 1

# Move images pulled as part of AMI creation process
yum install rsync -y
mkdir -p /tmp/containerd
cd / && rsync -a /var/lib/containerd/ /tmp/containerd

# Mount the 2nd volume
mkfs -t xfs /dev/xvdb
rm -rf /var/lib/containerd/*
mount /dev/xvdb /var/lib/containerd/
cd / && rsync -a /tmp/containerd/ /var/lib/containerd

# containerd needs to be running to pull images
systemctl start containerd

export CONTAINER_RUNTIME_ENDPOINT='unix:///run/containerd/containerd.sock'
export IMAGE_SERVICE_ENDPOINT='unix:///run/containerd/containerd.sock'

# ECR images
ECR_PASSWORD=$(aws ecr get-login-password --region "${region}")
%{ for img in ecr_images ~}
ctr -n k8s.io images pull --label io.cri-containerd.pinned=pinned --label io.cri-containerd.image=managed --platform amd64 --creds "AWS:$${ECR_PASSWORD}" "${img}"
%{ endfor ~}

# Public images
%{ for img in public_images ~}
ctr -n k8s.io images pull --label io.cri-containerd.pinned=pinned --label io.cri-containerd.image=managed --platform amd64 "${img}"
%{ endfor ~}
