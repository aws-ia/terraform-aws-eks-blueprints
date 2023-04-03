# Amazon FSx for NetApp ONTAP
 CSI Driver

Amazon FSx for NetApp ONTAP is a fully managed service that provides highly reliable, scalable, high-performing, and feature-rich file storage built on NetApp's popular ONTAP file system.
This add-on deploys the [Amazon FSx for NetApp ONTAP CSI Driver](https://aws.amazon.com/fsx/netapp-ontap/) into an EKS cluster.

## Usage

The [Amazon FSx for NetApp ONTAP CSI Driver](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/kubernetes-addons/aws-fsxn-csi-driver) can be deployed by enabling the add-on via the following.

```hcl
  enable_aws_fsxn_csi_driver = true
```

You can optionally customize the Helm chart that deploys `enable_aws_fsxn_csi_driver` via the following configuration.

```hcl
  enable_aws_fsxn_csi_driver = true
  aws_fsx_csi_driver_helm_config = {
    name                       = "trident-operator"
    chart                      = "trident-operator"
    repository                 = "https://netapp.github.io/trident-helm-chart"
    version                    = "23.01.0"
    namespace                  = "trident"
    values = [templatefile("${path.module}/values.yaml", {})] # Create this `values.yaml` file with your own custom values
  }
```

Once deployed, you will be able to see a number of supporting resources in the `trident` namespace.

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

