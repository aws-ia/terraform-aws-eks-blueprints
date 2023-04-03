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
$ kubectl get deployment trident-controller -n trident

NAME                 READY   UP-TO-DATE   AVAILABLE   AGE
trident-controller   1/1     1            1           41m
```

```sh
$ kubectl get daemonset trident-node-linux -n trident

NAME                 DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                                     AGE
trident-node-linux   6         6         6       6            6           kubernetes.io/arch=amd64,kubernetes.io/os=linux   42m
```

