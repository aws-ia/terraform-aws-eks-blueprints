# Amazon FSx for Lustre CSI Driver

Fully managed shared storage built on the world's most popular high-performance file system.
This add-on deploys the [Amazon FSx for Lustre CSI Driver](https://aws.amazon.com/fsx/lustre/) into an EKS cluster.

## Usage

The [Amazon FSx for Lustre CSI Driver](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/kubernetes-addons/aws-fsx-csi-driver) can be deployed by enabling the add-on via the following.

```hcl
  enable_aws_fsx_csi_driver = true
```

You can optionally customize the Helm chart that deploys `enable_aws_fsx_csi_driver` via the following configuration.

```hcl
  enable_aws_fsx_csi_driver = true
  aws_fsx_csi_driver_helm_config = {
    name                       = "aws-fsx-csi-driver"
    chart                      = "aws-fsx-csi-driver"
    repository                 = "https://kubernetes-sigs.github.io/aws-fsx-csi-driver/"
    version                    = "1.4.2"
    namespace                  = "kube-system"
    values = [templatefile("${path.module}/aws-fsx-csi-driver-values.yaml", {})] # Create this `aws-fsx-csi-driver-values.yaml` file with your own custom values
  }
  aws_fsx_csi_driver_irsa_policies = ["<ADDITIONAL_IAM_POLICY_ARN>"]
```

Once deployed, you will be able to see a number of supporting resources in the `kube-system` namespace.

```sh
$ kubectl get deployment fsx-csi-controller -n kube-system

NAME                 READY   UP-TO-DATE   AVAILABLE   AGE
fsx-csi-controller   2/2     2            2           4m29s
```

```sh
$ kubectl get daemonset fsx-csi-node -n kube-system

NAME           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                 AGE
fsx-csi-node   3         3         3       3            3           kubernetes.io/os=linux   4m32s
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
