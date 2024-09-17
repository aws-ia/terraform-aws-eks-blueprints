locals {
  dev_name = "xvdb"
}

data "aws_ssm_parameter" "snapshot_id" {
  name = "/cache-builder/snapshot_id"
}

################################################################################
# Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.17"

  cluster_name    = local.name
  cluster_version = "1.30"

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

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    gpu = {
      # The EKS AL2 GPU AMI provides all of the necessary components
      # for accelerated workloads w/ EFA
      ami_type       = "AL2_x86_64_GPU"
      instance_types = ["g6e.xlarge"]

      min_size     = 1
      max_size     = 1
      desired_size = 1

      pre_bootstrap_user_data = <<-EOT
        # Mount the second volume for containerd persistent data
        # This volume contains the cached images and layers

        systemctl stop containerd kubelet

        rm -rf /var/lib/containerd/*
        echo '/dev/${local.dev_name} /var/lib/containerd xfs defaults 0 0' >> /etc/fstab
        mount -a

        systemctl restart containerd kubelet

      EOT

      block_device_mappings = {
        (local.dev_name) = {
          device_name = "/dev/${local.dev_name}"
          ebs = {
            # Snapshot ID from the cache builder
            snapshot_id = nonsensitive(data.aws_ssm_parameter.snapshot_id.value)
            volume_size = 64
            volume_type = "gp3"
          }
        }
      }

      labels = {
        "nvidia.com/gpu.present" = "true"
        "ml-container-cache"     = "true"
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

      block_device_mappings = {
        "xvda" = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size = 64
            volume_type = "gp3"
          }
        }
      }
    }
  }

  tags = local.tags
}
