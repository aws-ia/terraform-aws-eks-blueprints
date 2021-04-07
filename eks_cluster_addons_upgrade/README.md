### EKS Upgrade Documentation

#### Objective:

The purpose of this document is to provide an overview of the steps for upgrading the EKS Cluster from one version to another. Please note that EKS upgrade documentation gets published by AWS every year. 

The current version of the upgrade documentation while writing this [README](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html) 

#### Pre-Requisites:

    1. Download the latest upgrade docs from AWS sites (https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html)
    2. Always upgrade one increment at a time (E.g., 1.17 to 1.18). AWS doesn't support upgrades from 1.16 to 1.18 directly

This table shows the supported plugin versions for each EKS Kubernetes version

|Kubernetes version|1.19|1.18|1.17|1.16|1.15|1.14|
| ----------- | --- | --- | --- | --- | --- | --- |
|Amazon VPC CNI plugin|1.7.5|1.7.5|1.7.5|1.7.5|1.7.5|1.7.5|
|DNS (CoreDNS)|1.8.0|1.7.0|1.6.6|1.6.6|1.6.6|1.6.6|
|KubeProxy|1.19.6|1.18.9|1.17.12|1.16.15|1.15.12|1.14.9|

#### Steps to upgrade EKS cluster:

    1. Change the version in Terraform to desired version (E.g., 1.18 to 1.19)
    
    2. Apply the changes to the cluster with Terraform. This step will upgrade the Control Plane and Data Plane to the newer version and it will roughly takes 35 mins to 1 hour
    
    3. Once the Cluster is upgraded to desired version then please updated the following plugins as per the instrcutions

#### Steps to upgrade Add-ons:

##### Patch KubeProxy DaemonSet with new image
        4.1 Update the Plugin version from AWS document in this file (source/eks_cluster_upgrade/kubeproxy_upgrade/kubeproxy_upgrade.sh)
        4.2 Executee this shell script (source/eks_cluster_upgrade/kubeproxy_upgrade/kubeproxy_upgrade.sh)
        
##### CoreDNS 
        5.1 Update the Plugin version from AWS document in this file (source/eks_cluster_upgrade/coredns_upgrade/coredns_upgrade.sh)
        5.2 Executee this shell script (source/eks_cluster_upgrade/coredns_upgrade/coredns_upgrade.sh)
        
##### VPC CNI
        6.1 Update the Plugin version from AWS document in this file (source/eks_cluster_upgrade/vpc_cni_upgrade/aws-k8s-cni.yaml)
        6.2 Executee this shell script (source/eks_cluster_upgrade/vpc_cni_upgrade/aws-k8s-cni.yaml)
        
## Important Note      
You may need to update the Cluster Autoscaler for every EKS Cluster version upgrade. If the Autoscalaer is deployed using Helm Chart then make sure you get the latest image and redeploy with Helm chart. 
Depending on the version that you need, you may need to change the previous address to `gcr.io/google-containers/cluster-autoscaler:v1.19.1` . The image address listed on the [releases page](https://github.com/kubernetes/autoscaler/releases).
    


