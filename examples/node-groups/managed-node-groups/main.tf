provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}

data "aws_ami" "amazonlinux2eks" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-${local.cluster_version}-*"]
  }

  owners = ["amazon"]
}

data "aws_availability_zones" "available" {}

locals {
  name   = basename(path.cwd)
  region = "us-west-2"

  cluster_version = "1.24"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------
module "eks_blueprints" {
  source = "../../.."

  cluster_name    = local.name
  cluster_version = local.cluster_version

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  node_security_group_additional_rules = {
    # Extend node-to-node security group rules. Recommended and required for the Add-ons
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    # Recommended outbound traffic for Node groups
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    # Allows Control Plane Nodes to talk to Worker nodes on all ports. Added this to simplify the example and further avoid issues with Add-ons communication with Control plane.
    # This can be restricted further to specific port based on the requirement for each Add-on e.g., metrics-server 4443, spark-operator 8080, karpenter 8443 etc.
    # Change this according to your security requirements if needed
    ingress_cluster_to_node_all_traffic = {
      description                   = "Cluster API to Nodegroup all traffic"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  managed_node_groups = {
    # Managed Node groups with minimum config
    mg5 = {
      node_group_name = "mg5"
      instance_types  = ["m5.large"]
      min_size        = 2
      create_iam_role = false # Changing `create_iam_role=false` to bring your own IAM Role
      iam_role_arn    = aws_iam_role.managed_ng.arn
      disk_size       = 100 # Disk size is used only with Managed Node Groups without Launch Templates
      update_config = [{
        max_unavailable_percentage = 30
      }]
    },
    # Managed Node groups with Launch templates using AMI TYPE
    mng_lt = {
      # Node Group configuration
      node_group_name = "mng_lt" # Max 40 characters for node group name

      ami_type               = "AL2_x86_64"  # Available options -> AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
      release_version        = ""            # Enter AMI release version to deploy the latest AMI released by AWS. Used only when you specify ami_type
      capacity_type          = "ON_DEMAND"   # ON_DEMAND or SPOT
      instance_types         = ["r5d.large"] # List of instances used only for SPOT type
      format_mount_nvme_disk = true          # format and mount NVMe disks ; default to false

      # Launch template configuration
      create_launch_template = true              # false will use the default launch template
      launch_template_os     = "amazonlinux2eks" # amazonlinux2eks or bottlerocket

      enable_monitoring = true
      eni_delete        = true
      public_ip         = false # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates

      http_endpoint               = "enabled"
      http_tokens                 = "optional"
      http_put_response_hop_limit = 3

      # pre_userdata can be used in both cases where you provide custom_ami_id or ami_type
      pre_userdata = <<-EOT
        yum install -y amazon-ssm-agent
        systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent
      EOT

      # Taints can be applied through EKS API or through Bootstrap script using kubelet_extra_args
      # e.g., k8s_taints = [{key= "spot", value="true", "effect"="NO_SCHEDULE"}]
      k8s_taints = []

      # Node Labels can be applied through EKS API or through Bootstrap script using kubelet_extra_args
      k8s_labels = {
        Environment = "preprod"
        Zone        = "dev"
        Runtime     = "docker"
      }

      # Node Group scaling configuration
      desired_size = 2
      max_size     = 2
      min_size     = 2

      block_device_mappings = [
        {
          device_name = "/dev/xvda"
          volume_type = "gp3"
          volume_size = 100
        }
      ]

      # Node Group network configuration
      subnet_type = "private" # public or private - Default uses the private subnets used in control plane if you don't pass the "subnet_ids"
      subnet_ids  = []        # Defaults to private subnet-ids used by EKS Control plane. Define your private/public subnets list with comma separated subnet_ids  = ['subnet1','subnet2','subnet3']

      additional_iam_policies = [] # Attach additional IAM policies to the IAM role attached to this worker group

      # SSH ACCESS Optional - Recommended to use SSM Session manager
      remote_access         = false
      ec2_ssh_key           = ""
      ssh_security_group_id = ""

      additional_tags = {
        ExtraTag    = "m5x-on-demand"
        Name        = "m5x-on-demand"
        subnet_type = "private"
      }
    }
    # Managed Node groups with Launch templates using CUSTOM AMI with ContainerD runtime
    mng_custom_ami = {
      # Node Group configuration
      node_group_name = "mng_custom_ami" # Max 40 characters for node group name

      # custom_ami_id is optional when you provide ami_type. Enter the Custom AMI id if you want to use your own custom AMI
      custom_ami_id  = data.aws_ami.amazonlinux2eks.id
      capacity_type  = "ON_DEMAND"   # ON_DEMAND or SPOT
      instance_types = ["r5d.large"] # List of instances used only for SPOT type

      # Launch template configuration
      create_launch_template = true              # false will use the default launch template
      launch_template_os     = "amazonlinux2eks" # amazonlinux2eks or bottlerocket

      # pre_userdata will be applied by using custom_ami_id or ami_type
      pre_userdata = <<-EOT
        yum install -y amazon-ssm-agent
        systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent
      EOT

      # post_userdata will be applied only by using custom_ami_id
      post_userdata = <<-EOT
        echo "Bootstrap successfully completed! You can further apply config or install to run after bootstrap if needed"
      EOT

      # kubelet_extra_args used only when you pass custom_ami_id;
      # --node-labels is used to apply Kubernetes Labels to Nodes
      # --register-with-taints used to apply taints to Nodes
      # e.g., kubelet_extra_args='--node-labels=WorkerType=SPOT,noderole=spark --register-with-taints=spot=true:NoSchedule --max-pods=58',
      kubelet_extra_args = "--node-labels=WorkerType=SPOT,noderole=spark --register-with-taints=test=true:NoSchedule --max-pods=20"

      # bootstrap_extra_args used only when you pass custom_ami_id. Allows you to change the Container Runtime for Nodes
      # e.g., bootstrap_extra_args="--use-max-pods false --container-runtime containerd"
      bootstrap_extra_args = "--use-max-pods false --container-runtime containerd"

      # Taints can be applied through EKS API or through Bootstrap script using kubelet_extra_args
      k8s_taints = []

      # Node Labels can be applied through EKS API or through Bootstrap script using kubelet_extra_args
      k8s_labels = {
        Environment = "preprod"
        Zone        = "dev"
        Runtime     = "containerd"
      }

      enable_monitoring = true
      eni_delete        = true
      public_ip         = false # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates

      # Node Group scaling configuration
      desired_size = 2
      max_size     = 2
      min_size     = 2

      block_device_mappings = [
        {
          device_name = "/dev/xvda"
          volume_type = "gp3"
          volume_size = 150
        }
      ]

      # Node Group network configuration
      subnet_type = "private" # public or private - Default uses the private subnets used in control plane if you don't pass the "subnet_ids"
      subnet_ids  = []        # Defaults to private subnet-ids used by EKS Control plane. Define your private/public subnets list with comma separated subnet_ids  = ['subnet1','subnet2','subnet3']

      additional_iam_policies = [] # Attach additional IAM policies to the IAM role attached to this worker group

      # SSH ACCESS Optional - Recommended to use SSM Session manager
      remote_access         = false
      ec2_ssh_key           = ""
      ssh_security_group_id = ""

      additional_tags = {
        ExtraTag    = "mng-custom-ami"
        Name        = "mng-custom-ami"
        subnet_type = "private"
      }
    }
    # Managed Node group with Launch templates using AMI TYPE and SPOT instances of 2 vCPUs and 8 Gib Memory
    spot_2vcpu_8mem = {
      node_group_name = "mng-spot-2vcpu-8mem"
      capacity_type   = "SPOT"
      instance_types  = ["m5.large", "m4.large", "m6a.large", "m5a.large", "m5d.large"]
      max_size        = 2
      desired_size    = 1
      min_size        = 1

      # Node Group network configuration
      subnet_type = "private" # public or private - Default uses the private subnets used in control plane if you don't pass the "subnet_ids"
      subnet_ids  = []        # Defaults to private subnet-ids used by EKS Control plane. Define your private/public subnets list with comma separated subnet_ids  = ['subnet1','subnet2','subnet3']

      k8s_taints = [{ key = "spotInstance", value = "true", effect = "NO_SCHEDULE" }]
    }

    # Managed Node group with Launch templates using AMI TYPE and SPOT instances of 4 vCPUs and 16 Gib Memory
    spot_4vcpu_16mem = {
      node_group_name = "mng-spot-4vcpu-16mem"
      capacity_type   = "SPOT"
      instance_types  = ["m5.xlarge", "m4.xlarge", "m6a.xlarge", "m5a.xlarge", "m5d.xlarge"]

      # Node Group network configuration
      subnet_type = "private" # public or private - Default uses the private subnets used in control plane if you don't pass the "subnet_ids"
      subnet_ids  = []        # Defaults to private subnet-ids used by EKS Control plane. Define your private/public subnets list with comma separated subnet_ids  = ['subnet1','subnet2','subnet3']

      k8s_taints = [{ key = "spotInstance", value = "true", effect = "NO_SCHEDULE" }]

      # NOTE: If we want the node group to scale-down to zero nodes,
      # we need to use a custom launch template and define some additional tags for the ASGs
      min_size = 0

      # Launch template configuration
      create_launch_template = true              # false will use the default launch template
      launch_template_os     = "amazonlinux2eks" # amazonlinux2eks or bottlerocket

      # This is so cluster autoscaler can identify which node (using ASGs tags) to scale-down to zero nodes
      additional_tags = {
        "k8s.io/cluster-autoscaler/node-template/label/eks.amazonaws.com/capacityType" = "SPOT"
        "k8s.io/cluster-autoscaler/node-template/label/eks/node_group_name"            = "mng-spot-2vcpu-8mem"
      }
    }
  }

  tags = local.tags
}

module "eks_blueprints_kubernetes_addons" {
  source = "../../../modules/kubernetes-addons"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  enable_metrics_server     = true
  enable_cluster_autoscaler = true
  cluster_autoscaler_helm_config = {
    set = [
      {
        name  = "extraArgs.expander"
        value = "priority"
      },
      {
        name  = "expanderPriorities"
        value = <<-EOT
                  100:
                    - .*-spot-2vcpu-8mem.*
                  90:
                    - .*-spot-4vcpu-16mem.*
                  10:
                    - .*
                EOT
      }
    ]
  }

  tags = local.tags
}

#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }

  tags = local.tags
}

#---------------------------------------------------------------
# Custom IAM roles for Node Groups
#---------------------------------------------------------------
data "aws_iam_policy_document" "managed_ng_assume_role_policy" {
  statement {
    sid = "EKSWorkerAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "managed_ng" {
  name                  = "managed-node-role"
  description           = "EKS Managed Node group IAM Role"
  assume_role_policy    = data.aws_iam_policy_document.managed_ng_assume_role_policy.json
  path                  = "/"
  force_detach_policies = true
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  tags = local.tags
}

resource "aws_iam_instance_profile" "managed_ng" {
  name = "managed-node-instance-profile"
  role = aws_iam_role.managed_ng.name
  path = "/"

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}
