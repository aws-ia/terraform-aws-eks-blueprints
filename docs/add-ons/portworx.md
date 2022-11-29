# Portworx add-on for EKS Blueprints

## Introduction

[Portworx](https://portworx.com/) is a Kubernetes data services platform that provides persistent storage, data protection, disaster recovery, and other capabilities for containerized applications. This blueprint installs Portworx on Amazon Elastic Kubernetes Service (EKS) environment.

- [Helm chart](https://github.com/portworx/helm)

## Requirements

For the add-on to work, Portworx needs additional permission to AWS resources which can be provided in the following way.

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

To customize Portworx installation, pass the configuration values as shown below:

```
  enable_portworx         = true

  portworx_helm_config = {
    set = [
      {
        name  = "clusterName"
        value = "testCluster"
      },
      {
        name  = "imageVersion"
        value = "2.11.1"
      }
    ]
  }

}
```

## Portworx Configuration

The following tables lists the configurable parameters of the Portworx chart and their default values.

| Parameter | Description | Default |
|-----------|-------------| --------|
| `imageVersion` | The image tag to pull | "2.11.0" |
| `useAWSMarketplace` | Set this variable to true if you wish to use AWS marketplace license for Portworx | "false" |
| `clusterName` | Portworx Cluster Name| portworx-\<random_string\> |
| `drives` | Semi-colon seperated list of drives to be used for storage. (example: "/dev/sda;/dev/sdb" or "type=gp2,size=200;type=gp3,size=500")  |  "type=gp2,size=200"|
| `useInternalKVDB` | boolen variable to set internal KVDB on/off | true |
| `kvdbDevice` | specify a separate device to store KVDB data, only used when internalKVDB is set to true | type=gp2,size=150 |
| `envVars` | semi-colon-separated list of environment variables that will be exported to portworx. (example: MYENV1=val1;MYENV2=val2) | "" |
| `maxStorageNodesPerZone` | The maximum number of storage nodes desired per zone| 3 |
| `useOpenshiftInstall` | boolen variable to install Portworx on Openshift .| false |
| `etcdEndPoint` | The ETCD endpoint. Should be in the format etcd:http://(your-etcd-endpoint):2379. If there are multiple etcd endpoints they need to be ";" seperated. | "" |
| `dataInterface` | Name of the interface <ethX>.| none |
| `managementInterface` |  Name of the interface <ethX>.| none |
| `useStork` | [Storage Orchestration for Hyperconvergence](https://github.com/libopenstorage/stork).| true  |
| `storkVersion` | Optional: version of Stork. For eg: 2.11.0, when it's empty Portworx operator will pick up version according to Portworx version. | "2.11.0" |
| `customRegistryURL` | URL where to pull Portworx image from | ""  |
| `registrySecret` | Image registery credentials to pull Portworx Images from a secure registry | "" |
| `licenseSecret` | Kubernetes secret name that has Portworx licensing information | ""  |
| `monitoring` | Enable Monitoring on Portworx cluster | false  |
| `enableCSI` | Enable CSI | false  |
| `enableAutopilot` | Enable Autopilot | false  |
| `KVDBauthSecretName` | Refer [Securing with certificates in Kubernetes](https://docs.portworx.com/operations/etcd/#securing-with-certificates-in-kubernetes) to  create a kvdb secret and specify the name of the secret here| none |
| `deleteType` | Specify which strategy to use while Uninstalling Portworx. "Uninstall" values only removes Portworx but with "UninstallAndWipe" value all data from your disks including the Portworx metadata is also wiped permanently | UninstallAndWipe |
