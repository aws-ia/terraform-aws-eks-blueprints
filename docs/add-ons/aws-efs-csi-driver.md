# AWS EFS CSI Driver

This add-on deploys the [AWS EFS CSI driver](https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html) into an EKS cluster.

## Usage

The [AWS EFS CSI driver](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/kubernetes-addons/aws-efs-csi-driver) can be deployed by enabling the add-on via the following. Check out the full [example](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/examples/stateful/main.tf) to deploy an EKS Cluster with EFS backing the dynamic provisioning of persistent volumes.

```hcl
  enable_aws_efs_csi_driver = true
```

Once deployed, you will be able to see a number of supporting resources in the `kube-system` namespace.

```sh
$ kubectl get deployment efs-csi-controller -n kube-system

NAME                 READY   UP-TO-DATE   AVAILABLE   AGE
efs-csi-controller   2/2     2            2           4m29s
```

```sh
$ kubectl get daemonset efs-csi-node -n kube-system

NAME           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                 AGE
efs-csi-node   3         3         3       3            3           beta.kubernetes.io/os=linux   4m32s
```

You can optionally customize the Helm chart that deploys the driver via the following configuration.

```hcl
  enable_aws_efs_csi_driver = true

  # Optional aws_efs_csi_driver_helm_config
  aws_efs_csi_driver_helm_config = {
    repository  = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
    version     = "2.2.3"
  }
  aws_efs_csi_driver_irsa_policies = ["<ADDITIONAL_IAM_POLICY_ARN>"]
```

### GitOps Configuration

`ArgoCD` with `App of Apps` GitOps enabled for this Add-on by enabling the following variable

```hcl
argocd_manage_add_ons = true
```

The following is configured to ArgoCD App of Apps for this Add-on.

```hcl
  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account
  }
```
