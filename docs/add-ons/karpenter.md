# Karpenter

Karpenter is an open-source node provisioning project built for Kubernetes. Karpenter automatically launches just the right compute resources to handle your cluster's applications. It is designed to let you take full advantage of the cloud with fast and simple compute provisioning for Kubernetes clusters.

For complete project documentation, please visit the [Karpenter documentation](https://karpenter.sh/docs/getting-started/).

## Usage

Karpenter can be deployed by enabling the add-on via the following. Check out the full [example](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/karpenter/locals.tf) to deploy the EKS Cluster with Karpenter.

```hcl
enable_karpenter = true
```

You can optionally customize the Helm chart that deploys `Karpenter` via the following configuration.

```hcl
  enable_karpenter = true
  # Queue optional for native handling of instance termination events
  karpenter_sqs_queue_arn = "arn:aws:sqs:us-west-2:444455556666:queue1"
  # Optional to add name prefix for Karpenter's event bridge rules
  karpenter_event_rule_name_prefix = "Karpenter"
  # Optional  karpenter_helm_config
  karpenter_helm_config = {
    name                       = "karpenter"
    chart                      = "karpenter"
    repository                 = "https://charts.karpenter.sh"
    version                    = "0.19.3"
    namespace                  = "karpenter"
    values = [templatefile("${path.module}/values.yaml", {
         eks_cluster_id       = var.eks_cluster_id,
         eks_cluster_endpoint = var.eks_cluster_endpoint,
         service_account      = var.service_account,
         operating_system     = "linux"
    })]
  }

  karpenter_irsa_policies = [] # Optional to add additional policies to IRSA
```

### GitOps Configuration
The following properties are made available for use when managing the add-on via GitOps.

Refer to [locals.tf](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/karpenter/locals.tf) for latest config. GitOps with ArgoCD Add-on repo is located [here](https://github.com/aws-samples/eks-blueprints-add-ons/blob/main/chart/values.yaml)

```hcl
  argocd_gitops_config = {
    enable                    = true
    serviceAccountName        = local.service_account
    controllerClusterName     = var.eks_cluster_id
    controllerClusterEndpoint = local.eks_cluster_endpoint
    awsDefaultInstanceProfile = var.node_iam_instance_profile
  }
```
