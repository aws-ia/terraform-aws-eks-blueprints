# EMR on EKS

EMR on EKS is a deployment option in EMR that allows you to automate the provisioning and management of open-source big data frameworks on EKS.
This module deploys the necessary resources to run EMR Spark Jobs on EKS Cluster.

- Create a new Namespace to run Spark workloads
- Create K8s Role and Role Binding to allow `emr-containers` user on a given namespace(`spark`)
- Create RBAC permissions and adding EMR on EKS service-linked role into aws-auth configmap
- Enables IAM Roles for Service Account (IRSA)
- Update trust relationship for job execution role

## Usage

[EMR on EKS](modules/emr-on-eks/README.md) can be deployed by enabling the module via the following.


```hcl
  enable_emr_on_eks = true               # Default is false
  emr_on_eks_namespace = "spark"         # Optional default value is spark
```

Once deployed, you can create Virtual EMR Cluster and execute Spark jobs. See the document below for more details.

https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/setting-up-registration.html
