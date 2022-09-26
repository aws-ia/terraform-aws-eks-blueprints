# NVIDIA Device Plugin

The NVIDIA device plugin for Kubernetes is a Daemonset that allows you to automatically:

* Expose the number of GPUs on each nodes of your cluster
* Keep track of the health of your GPUs
* Run GPU enabled containers in your Kubernetes cluster.


For complete project documentation, please visit the [NVIDIA Device Plugin](https://github.com/NVIDIA/k8s-device-plugin#readme).

Additionally, refer to this AWS [blog](https://aws.amazon.com/blogs/compute/running-gpu-accelerated-kubernetes-workloads-on-p3-and-p2-ec2-instances-with-amazon-eks/) for more information on how the add-on can be tested.

## Usage

NVIDIA device plugin can be deployed by enabling the add-on via the following.

```hcl
enable_nvidia_device_plugin = true
```

You can optionally customize the Helm chart via the following configuration.

```hcl
  enable_nvidia_device_plugin = true
  # Optional nvidia_device_plugin_helm_config
  nvidia_device_plugin_helm_config = {
    name                       = "nvidia-device-plugin"
    chart                      = "nvidia-device-plugin"
    repository                 = "https://nvidia.github.io/k8s-device-plugin"
    version                    = "0.12.3"
    namespace                  = "nvidia-device-plugin"
    values = [templatefile("${path.module}/values.yaml", {
      ...
    })]
  }
```

### GitOps Configuration
The following properties are made available for use when managing the add-on via GitOps.

Refer to [locals.tf](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/nvidia-device-plugin/locals.tf) for latest config. GitOps with ArgoCD Add-on repo is located [here](https://github.com/aws-samples/eks-blueprints-add-ons/blob/main/chart/values.yaml)

```hcl
  argocd_gitops_config = {
    enable = true
  }
```
