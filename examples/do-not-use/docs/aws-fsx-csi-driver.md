# Amazon FSx for Lustre CSI Driver

This add-on deploys the [Amazon FSx for Lustre CSI Driver](https://docs.aws.amazon.com/eks/latest/userguide/fsx-csi.html) in to an Amazon EKS Cluster.

## Usage

The [Amazon FSx for Lustre CSI Driver](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/kubernetes-addons/aws-fsx-csi-driver) can be deployed by enabling the add-on via the following. 

```hcl
  enable_aws_fsx_csi_driver = true
```

You can optionally customize the Helm chart deployment using a configuration like the following.

```hcl
  enable_aws_fsx_csi_driver = true
  aws_fsx_csi_driver = {
    namespace     = "aws-fsx-csi-driver"
    chart_version = "1.5.1"
    role_policies = <ADDITIONAL_IAM_POLICY_ARN>
  }
```

You can find all available Helm Chart parameter values [here](https://github.com/kubernetes-sigs/aws-fsx-csi-driver/blob/master/charts/aws-fsx-csi-driver/values.yaml)

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
