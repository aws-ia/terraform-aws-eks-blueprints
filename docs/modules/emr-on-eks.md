# EMR on EKS

EMR on EKS is a deployment option in EMR that allows you to automate the provisioning and management of open-source big data frameworks on EKS.
This module deploys the necessary resources to run EMR Spark Jobs on EKS Cluster.

- Create a new Namespace to run Spark workloads
- Create K8s Role and Role Binding to allow the username `emr-containers` on a given namespace(`spark`)
- Create RBAC permissions and adding EMR on EKS service-linked role into aws-auth configmap
- Enables IAM Roles for Service Account (IRSA)
- Update trust relationship for job execution role

## Usage

[EMR on EKS](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/emr-on-eks) can be deployed by enabling the module via the following.

Checkout this [Blog](https://aws.amazon.com/blogs/mt/monitoring-amazon-emr-on-eks-with-amazon-managed-prometheus-and-amazon-managed-grafana/) to setup Observability for EMR on EKS Spark Jobs

```hcl
    #---------------------------------------
    # ENABLE EMR ON EKS
    #---------------------------------------
    enable_emr_on_eks = true
    emr_on_eks_teams = {
      emr-team-a = {
        namespace               = "emr-data-team-a"
        job_execution_role      = "emr-eks-data-team-a"
        additional_iam_policies = ["<ENTER-IAM-POLICY-ARN>"]
      }
      emr-team-b = {
        namespace               = "emr-data-team-b"
        job_execution_role      = "emr-eks-data-team-b"
        additional_iam_policies = ["<ENTER-IAM-POLICY-ARN>"]
      }
    }
```

Once deployed, you can create Virtual EMR Cluster and execute Spark jobs. See the [document](https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/setting-up-registration.html) below for more details.
