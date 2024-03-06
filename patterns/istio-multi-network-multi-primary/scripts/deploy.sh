#!/bin/sh 

set -e

terraform init 

terraform apply --auto-approve \
    -target=module.vpc_1 \
    -target=module.vpc_2 \
    -target=module.eks_1 \
    -target=module.eks_2 \
    -target=kubernetes_secret.cacerts_cluster1 \
    -target=kubernetes_secret.cacerts_cluster2 \
    -target=module.eks_1_addons.module.aws_load_balancer_controller \
    -target=module.eks_2_addons.module.aws_load_balancer_controller  

terraform apply --auto-approve \
    -target="module.eks_1_addons.helm_release.this[\"istiod\"]" \
    -target="module.eks_2_addons.helm_release.this[\"istiod\"]" \

terraform apply --auto-approve 
