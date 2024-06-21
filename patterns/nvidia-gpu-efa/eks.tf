################################################################################
# Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.9"

  cluster_name    = local.name
  cluster_version = "1.29"

  # Give the Terraform identity admin access to the cluster
  # which will allow it to deploy resources into the cluster
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access           = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  # Add security group rules on the node group security group to
  # allow EFA traffic
  enable_efa_support = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    nvidia-efa = {
      # The EKS AL2 GPU AMI provides all of the necessary components
      # for accelerated workloads w/ EFA
      ami_type       = "AL2_x86_64_GPU"
      instance_types = ["p5.48xlarge"]


      # Uncomment this block and specify capacity_reservation_id
      # to use an on-demand capacity reservation (ODCR) for your EFA instances
      #capacity_reservation_specification = {
      #  capacity_reservation_target = {
      #    capacity_reservation_id = "cr-xxxxxxxxxxxxxxxxx"
      #  }
      #}

      pre_bootstrap_user_data = <<-EOT
        # Mount instance store volumes in RAID-0 for kubelet and containerd
        # https://github.com/awslabs/amazon-eks-ami/blob/master/doc/USER_GUIDE.md#raid-0-for-kubelet-and-containerd-raid0
        /bin/setup-local-disks raid0
      EOT

      min_size     = 2
      max_size     = 2
      desired_size = 2

      # This will:
      # 1. Create a placement group to place the instances close to one another
      # 2. Ignore subnets that reside in AZs that do not support the instance type
      # 3. Expose all of the available EFA interfaces on the launch template
      enable_efa_support = true

      labels = {
        "vpc.amazonaws.com/efa.present" = "true"
        "nvidia.com/gpu.present"        = "true"
      }

      taints = {
        # Ensure only GPU workloads are scheduled on this node group
        gpu = {
          key    = "nvidia.com/gpu"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }
    }

    # This node group is for core addons such as CoreDNS
    default = {
      instance_types = ["m5.large"]

      min_size     = 1
      max_size     = 2
      desired_size = 2
    }
  }

  tags = local.tags
}
