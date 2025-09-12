locals {
  dev_name = "xvdb"
}

# SSM parameter where the `cache-builder` stores the generated snapshot ID
# This will be used to reference the snapshot when creating the EKS node group
data "aws_ssm_parameter" "snapshot_id" {
  name = module.ebs_snapshot_builder.ssm_parameter_name
}

################################################################################
# Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = local.name
  kubernetes_version = "1.33"

  # Give the Terraform identity admin access to the cluster
  # which will allow it to deploy resources into the cluster
  enable_cluster_creator_admin_permissions = true
  endpoint_public_access                   = true

  addons = {
    coredns                   = {}
    eks-node-monitoring-agent = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    gpu = {
      # The EKS AL2023 NVIDIA AMI provides all of the necessary components
      # for accelerated workloads w/ EFA
      ami_type       = "AL2023_x86_64_NVIDIA"
      instance_types = ["g6e.xlarge"]

      node_repair_config = {
        enabled = true
      }

      min_size     = 1
      max_size     = 1
      desired_size = 1

      cloudinit_pre_nodeadm = [{
        content      = <<-EOT
          # Mount the second volume for containerd persistent data
          # This volume contains the cached images and layers

          systemctl stop containerd kubelet

          rm -rf /var/lib/containerd/*
          echo '/dev/${local.dev_name} /var/lib/containerd xfs defaults 0 0' >> /etc/fstab
          mount -a

          systemctl restart containerd kubelet

        EOT
        content_type = "text/x-shellscript; charset=\"us-ascii\""
      }]

      # Mount a second volume for containerd persistent data
      # using the snapshot that contains the cached images and layers
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

      # Not required - increased to demonstrate pulling the un-cached
      # image since the default volume size is too small for the image used
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
