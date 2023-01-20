# AWS VPC CNI Metrics

[AWS VPC CNI Metrics](https://docs.aws.amazon.com/eks/latest/userguide/cni-metrics-helper.html) is a tool that you can use to scrape network interface and IP address information, aggregate metrics at the cluster level, and publish the metrics to Amazon CloudWatch.

To learn more about the metrics helper, see [vcp-cni-metrics-helper](https://github.com/aws/amazon-vpc-cni-k8s/blob/master/cmd/cni-metrics-helper/README.md) on GitHub.

## Usage

VPC CNI Metrics can be deployed by enabling the add-on via the following.

```hcl
enable_aws_vpc_cni_metrics  = true
```

You can optionally customize the Helm chart and the image version.

```hcl
  enable_aws_vpc_cni_metrics  = true
  # Optional aws_vpc_cni_metrics_version
  aws_vpc_cni_metrics_version = "v1.12.1-eksbuild.1"
  # Optional  aws_vpc_cni_metrics_helm_config
  aws_vpc_cni_metrics_helm_config = {
    name             = "cni-metrics-helper"
    chart            = "cni-metrics-helper"
    repository       = "https://aws.github.io/eks-charts"
    version          = "0.1.15"
    namespace        = "kube-system"
    create_namespace = false
    set_values = [
      {
        name  = "serviceAccount.annotations.custom"
        value = "acme"
      },
    ]
  }
```
