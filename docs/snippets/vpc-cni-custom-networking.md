---
title: VPC CNI Custom Networking
---

Custom networking addresses the IP exhaustion issue by assigning the node and Pod IPs from secondary VPC address spaces (CIDR). Custom networking support supports ENIConfig custom resource. The ENIConfig includes an alternate subnet CIDR range (carved from a secondary VPC CIDR), along with the security group(s) that the Pods will belong to. When custom networking is enabled, the VPC CNI creates secondary ENIs in the subnet defined under ENIConfig. The CNI assigns Pods an IP addresses from a CIDR range defined in a ENIConfig CRD.

Since the primary ENI is not used by custom networking, the maximum number of Pods you can run on a node is lower. The host network Pods continue to use IP address assigned to the primary ENI. Additionally, the primary ENI is used to handle source network translation and route Pods traffic outside the node.

- [Documentation](https://docs.aws.amazon.com/eks/latest/userguide/cni-custom-network.html)
- [Best Practices Guide](https://aws.github.io/aws-eks-best-practices/reliability/docs/networkmanagement/#cni-custom-networking)

## VPC CNI Configuration

In this example, the `vpc-cni` addon is configured using `before_compute = true`. This is done to ensure the `vpc-cni` is created and updated *before* any EC2 instances are created so that the desired settings have applied before they will be referenced. With this configuration, you will now see that nodes created will have `--max-pods 110` configured do to the use of prefix delegation being enabled on the `vpc-cni`.

If you find that your nodes are not being created with the correct number of max pods (i.e. - for `m5.large`, if you are seeing a max pods of 29 instead of 110), most likely the `vpc-cni` was not configured *before* the EC2 instances.

## Components

To enable VPC CNI custom networking, you must configuring the following components:

1. Create a VPC with additional CIDR block associations. These additional CIDR blocks will be used to create subnets for the VPC CNI custom networking:

      ```json
      module "vpc" {
      source  = "terraform-aws-modules/vpc/aws"

      # Truncated for brevity
      ...

      secondary_cidr_blocks = [local.secondary_vpc_cidr] # can add up to 5 total CIDR blocks

      azs = local.azs
      private_subnets = concat(
         [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)],
         [for k, v in local.azs : cidrsubnet(local.secondary_vpc_cidr, 2, k)]
      )

      ...
      }
      ```

2. Specify the VPC CNI custom networking configuration in the `vpc-cni` addon configuration:

      ```json
      module "eks" {
      source  = "terraform-aws-modules/eks/aws"

      # Truncated for brevity
      ...

      cluster_addons = {
         vpc-cni = {
            before_compute = true
            most_recent    = true # To ensure access to the latest settings provided
            configuration_values = jsonencode({
            env = {
               AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG = "true"
               ENI_CONFIG_LABEL_DEF               = "topology.kubernetes.io/zone"
            })
         }
      }

      ...
      }
      ```

3. Create the `ENIConfig` custom resource for each subnet that you want to deploy pods into:

      ```json
      resource "kubectl_manifest" "eni_config" {
      for_each = zipmap(local.azs, slice(module.vpc.private_subnets, 3, 6))

      yaml_body = yamlencode({
         apiVersion = "crd.k8s.amazonaws.com/v1alpha1"
         kind       = "ENIConfig"
         metadata = {
            name = each.key
         }
         spec = {
            securityGroups = [
            module.eks.node_security_group_id,
            ]
            subnet = each.value
         }
      })
      }
      ```

Once those settings have been successfully applied, you can verify if custom networking is enabled correctly by inspecting one of the `aws-node-*` (AWS VPC CNI) pods:

```sh
kubectl describe pod aws-node-ttg4h -n kube-system

# Output should look similar below (truncated for brevity)
  Environment:
    ADDITIONAL_ENI_TAGS:                    {}
    AWS_VPC_CNI_NODE_PORT_SUPPORT:          true
    AWS_VPC_ENI_MTU:                        9001
    AWS_VPC_K8S_CNI_CONFIGURE_RPFILTER:     false
    AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG:     true # <- this should be set to true
    AWS_VPC_K8S_CNI_EXTERNALSNAT:           false
    AWS_VPC_K8S_CNI_LOGLEVEL:               DEBUG
    ...
```
