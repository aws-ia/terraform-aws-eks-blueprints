# AWS Managed Node Groups

## Introduction

Amazon EKS Managed Node Groups lets you create, update, scale, and terminate worker nodes for your EKS cluster. All managed nodes are provisioned as part of an Amazon EC2 Auto Scaling group that's managed for you by Amazon EKS. Moreover, all resources including Amazon EC2 instances and Auto Scaling groups run within your AWS account. By default, instances in a managed node group use the latest version of the Amazon EKS optimized Amazon Linux 2 AMI for its cluster's Kubernetes version

This module allows you to create ON-DEMAND, SPOT and BOTTLEROCKET(with custom ami) managed nodegroups. You can instantiate the module once with map of node group values to create multiple node groups.

*NOTE*:
 - You can't create managed nodes in an AWS Region where you have AWS Outposts, AWS Wavelength, or AWS Local Zones enabled.
 - You can create self-managed nodes in an AWS Region where you have AWS Outposts, AWS Wavelength, or AWS Local Zones enabled

## Managed Node Groups Example

```hcl
  managed_node_groups = {
    #---------------------------------------------------------#
    # ON-DEMAND Worker Group - Worker Group - 1
    #---------------------------------------------------------#
    mg_4 = {
      # 1> Node Group configuration - Part1
      node_group_name        = "managed-ondemand"  # MAX Length is only 40 Characters
      create_launch_template = true              # false will use the default launch template
      launch_template_os     = "amazonlinux2eks" # amazonlinux2eks or windows or bottlerocket
      public_ip              = false             # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
      pre_userdata           = <<-EOT
            yum install -y amazon-ssm-agent
            systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent"
        EOT
      # 2> Node Group scaling configuration
      desired_size    = 3
      max_size        = 3
      min_size        = 3
      max_unavailable = 1 # or percentage = 20

      # 3> Node Group compute configuration
      ami_type       = "AL2_x86_64" # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
      capacity_type  = "ON_DEMAND"  # ON_DEMAND or SPOT
      instance_types = ["m4.large"] # List of instances used only for SPOT type
      disk_size      = 50

      # 4> Node Group network configuration
      subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

      k8s_taints = []
      # optionally, configure a taint on the node group:
      # k8s_taints = [{key= "purpose", value="execution", "effect"="NO_SCHEDULE"}]

      k8s_labels = {
        Environment = "preprod"
        Zone        = "dev"
        WorkerType  = "ON_DEMAND"
      }
      additional_tags = {
        ExtraTag    = "m5x-on-demand"
        Name        = "m5x-on-demand"
        subnet_type = "private"
      }

      create_worker_security_group = true # false uses the default worker security group created by EKS Cluster

    },
    #---------------------------------------------------------#
    # SPOT Worker Group - Worker Group - 2
    #---------------------------------------------------------#
    /*
    spot_m5 = {
      # 1> Node Group configuration - Part1
      node_group_name        = "managed-spot-m5"
      create_launch_template = true              # false will use the default launch template
      launch_template_os        = "amazonlinux2eks" # amazonlinux2eks  or bottlerocket
      public_ip              = false             # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
      pre_userdata           = <<-EOT
                 yum install -y amazon-ssm-agent
                 systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent"
             EOT

      # Node Group scaling configuration
      desired_size = 3
      max_size     = 3
      min_size     = 3

      # Node Group update configuration. Set the maximum number or percentage of unavailable nodes to be tolerated during the node group version update.
      max_unavailable = 1 # or percentage = 20

      # Node Group compute configuration
      ami_type       = "AL2_x86_64"
      capacity_type  = "SPOT"
      instance_types = ["t3.medium", "t3a.medium"]
      disk_size      = 50

      # Node Group network configuration

      subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

      k8s_taints = []

      k8s_labels = {
        Environment = "preprod"
        Zone        = "dev"
        WorkerType  = "SPOT"
      }
      additional_tags = {
        ExtraTag    = "spot_nodes"
        Name        = "spot"
        subnet_type = "private"
      }
    },

    #---------------------------------------------------------#
    # BOTTLEROCKET - Worker Group - 3
    #---------------------------------------------------------#
    brkt_m5 = {
      node_group_name        = "managed-brkt-m5"
      create_launch_template = true           # false will use the default launch template
      launch_template_os        = "bottlerocket" # amazonlinux2eks  or bottlerocket
      public_ip              = false          # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
      pre_userdata           = ""

      desired_size    = 3
      max_size        = 3
      min_size        = 3
      max_unavailable = 1

      ami_type       = "CUSTOM"
      capacity_type  = "ON_DEMAND" # ON_DEMAND or SPOT
      instance_types = ["m5.large"]
      disk_size      = 50
      custom_ami_id  = "ami-044b114caf98ce8c5" # https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami-bottlerocket.html

      # Node Group network configuration

      subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

      k8s_taints = {}
      k8s_labels = {
        Environment = "preprod"
        Zone        = "dev"
        OS          = "bottlerocket"
        WorkerType  = "ON_DEMAND_BOTTLEROCKET"
      }
      additional_tags = {
        ExtraTag = "bottlerocket"
        Name     = "bottlerocket"
      }
      #security_group ID
      create_worker_security_group = true
    }

      */
  } # END OF MANAGED NODE GROUPS
```

<!--- BEGIN_TF_DOCS --->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_node_group.managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_instance_profile.managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.managed_ng_AmazonEC2ContainerRegistryReadOnly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.managed_ng_AmazonEKSWorkerNodePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.managed_ng_AmazonEKS_CNI_Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.managed_ng_AmazonSSMManagedInstanceCore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.managed_node_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_iam_policy_document.managed_ng_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_context"></a> [context](#input\_context) | Input configuration for the Node groups | <pre>object({<br>    # EKS Cluster Config<br>    eks_cluster_id    = string<br>    cluster_ca_base64 = string<br>    cluster_endpoint  = string<br>    cluster_version   = string<br>    # VPC Config<br>    vpc_id             = string<br>    private_subnet_ids = list(string)<br>    public_subnet_ids  = list(string)<br>    # Security Groups<br>    worker_security_group_ids = list(string)<br><br>    # Http config<br>    http_endpoint               = string<br>    http_tokens                 = string<br>    http_put_response_hop_limit = number<br>    # Data sources<br>    aws_partition_dns_suffix = string<br>    aws_partition_id         = string<br>    #IAM<br>    iam_role_path                 = string<br>    iam_role_permissions_boundary = string<br>    # Tags<br>    tags = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_managed_ng"></a> [managed\_ng](#input\_managed\_ng) | Map of maps of `eks_node_groups` to create | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_managed_nodegroup_arn"></a> [managed\_nodegroup\_arn](#output\_managed\_nodegroup\_arn) | EKS Managed node group id |
| <a name="output_managed_nodegroup_iam_instance_profile_arn"></a> [managed\_nodegroup\_iam\_instance\_profile\_arn](#output\_managed\_nodegroup\_iam\_instance\_profile\_arn) | IAM instance profile arn for EKS Managed Node Group |
| <a name="output_managed_nodegroup_iam_instance_profile_id"></a> [managed\_nodegroup\_iam\_instance\_profile\_id](#output\_managed\_nodegroup\_iam\_instance\_profile\_id) | IAM instance profile id for EKS Managed Node Group |
| <a name="output_managed_nodegroup_iam_role_arn"></a> [managed\_nodegroup\_iam\_role\_arn](#output\_managed\_nodegroup\_iam\_role\_arn) | IAM role ARN for EKS Managed Node Group |
| <a name="output_managed_nodegroup_iam_role_name"></a> [managed\_nodegroup\_iam\_role\_name](#output\_managed\_nodegroup\_iam\_role\_name) | IAM role name for EKS Managed Node Group |
| <a name="output_managed_nodegroup_id"></a> [managed\_nodegroup\_id](#output\_managed\_nodegroup\_id) | EKS Managed node group id |
| <a name="output_managed_nodegroup_launch_template_arn"></a> [managed\_nodegroup\_launch\_template\_arn](#output\_managed\_nodegroup\_launch\_template\_arn) | Launch Template ARN for EKS Managed Node Group |
| <a name="output_managed_nodegroup_launch_template_id"></a> [managed\_nodegroup\_launch\_template\_id](#output\_managed\_nodegroup\_launch\_template\_id) | Launch Template ID for EKS Managed Node Group |
| <a name="output_managed_nodegroup_launch_template_latest_version"></a> [managed\_nodegroup\_launch\_template\_latest\_version](#output\_managed\_nodegroup\_launch\_template\_latest\_version) | Launch Template version for EKS Managed Node Group |
| <a name="output_managed_nodegroup_status"></a> [managed\_nodegroup\_status](#output\_managed\_nodegroup\_status) | EKS Managed Node Group status |

<!--- END_TF_DOCS --->
