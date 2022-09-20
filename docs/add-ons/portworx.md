# Portworx add-on for EKS Blueprints

## Introduction

[Portworx](https://portworx.com/) is a Kubernetes data services platform that provides persistent storage, data protection, disaster recovery, and other capabilities for containerized applications. This blueprint installs Portworx on Amazon Elastic Kubernetes Service (EKS) environment.

- [Helm chart](https://github.com/portworx/helm)

## Examples Blueprint

To get started look at these sample [blueprints](../../examples/portworx).

## Requirements

For the add-on to work, Portworx needs additional permission to AWS resources which can be provided in the following way. For an example blueprint, click [here](../../examples/portworx). 

Note: Portworx currently does not support obtaining these permissions with an IRSA. Its support will be added with future releases.

### Creating the required IAM policy resource

1. Add the below code block in your terraform script to create a policy with the required permissions. Make a note of the resource name for the policy you created:

```
resource "aws_iam_policy" "<policy-resource-name>" {
  name = "<policy-name>"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:AttachVolume",
          "ec2:ModifyVolume",
          "ec2:DetachVolume",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:DeleteTags",
          "ec2:DeleteVolume",
          "ec2:DescribeTags",
          "ec2:DescribeVolumeAttribute",
          "ec2:DescribeVolumesModifications",
          "ec2:DescribeVolumeStatus",
          "ec2:DescribeVolumes",
          "ec2:DescribeInstances",
          "autoscaling:DescribeAutoScalingGroups"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
```

2. Run `terraform apply` command for the policy (replace it with your resource name):

```bash
terraform apply -target="aws_iam_policy.<policy-resource-name>"
```
3. Attach the newly created AWS policy ARN to the node groups in your cluster:

```
 managed_node_groups = {
    node_group_1 = {
      node_group_name           = "my_node_group_1"
      instance_types            = ["t2.small"]
      min_size                  = 3
      max_size                  = 3
      subnet_ids                = module.vpc.private_subnets

      #Add this line to the code block or add the new policy ARN to the list if it already exists
      additional_iam_policies   = [aws_iam_policy.<policy-resource-name>.arn]

    }
  }
```
4. Run the command below to apply the changes. (This step can be performed even if the cluster is up and running. The policy attachment happens without having to restart the nodes)
```bash
terraform apply -target="module.eks_blueprints"
```


## Usage

After completing the requirement step, installing Portworx is simple, set ```enable_portworx``` variable to true inside the Kubernetes add-on module.

```
  enable_portworx = true
```

To customize Portworx installation, pass the configuration parameter as an object as shown below:

```
  enable_portworx         = true
  portworx_chart_values   = {
    clusterName="testCluster"
    imageVersion="2.11.1"
  }
}
```
