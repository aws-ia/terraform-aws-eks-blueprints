################################################################################
# Required Input
################################################################################

# See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/capacity-blocks-using.html
# on how to obtain a ML capacity block reservation. Once acquired, you can provide
# the reservation ID through this input to deploy the pattern
variable "capacity_reservation_id" {
  description = "The ID of the ML capacity block reservation to use for the node group"
  type        = string
}

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
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  # Add security group rules on the node group security group to
  # allow EFA traffic
  enable_efa_support = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    # This node group is for core addons such as CoreDNS
    default = {
      instance_types = ["m5.large"]

      min_size     = 1
      max_size     = 2
      desired_size = 2
    }
  }

  # Note: ML capacity block reservations are only supported
  # on self-managed node groups at this time
  self_managed_node_groups = {
    odcr = {
      # The EKS AL2 GPU AMI provides all of the necessary components
      # for accelerated workloads w/ EFA
      ami_type      = "AL2_x86_64_GPU"
      instance_type = "p5.48xlarge"

      pre_bootstrap_user_data = <<-EOT
        # Mount instance store volumes in RAID-0 for kubelet and containerd
        # https://github.com/awslabs/amazon-eks-ami/blob/master/doc/USER_GUIDE.md#raid-0-for-kubelet-and-containerd-raid0
        /bin/setup-local-disks raid0

        # Ensure only GPU workloads are scheduled on this node group
        export KUBELET_EXTRA_ARGS='--node-labels=vpc.amazonaws.com/efa.present=true,nvidia.com/gpu.present=true \
          --register-with-taints=nvidia.com/gpu=true:NoSchedule'

      EOT

      min_size     = 2
      max_size     = 2
      desired_size = 2

      # This will:
      # 1. Create a placement group to place the instances close to one another
      # 2. Ignore subnets that reside in AZs that do not support the instance type
      # 3. Expose all of the available EFA interfaces on the launch template
      enable_efa_support = true

      # ML capacity block reservation
      instance_market_options = {
        market_type = "capacity-block"
      }
      capacity_reservation_specification = {
        capacity_reservation_target = {
          capacity_reservation_id = var.capacity_reservation_id
        }
      }
    }
  }

  tags = local.tags
}

################################################################################
# Helm charts
################################################################################

resource "helm_release" "nvidia_device_plugin" {
  name             = "nvidia-device-plugin"
  repository       = "https://nvidia.github.io/k8s-device-plugin"
  chart            = "nvidia-device-plugin"
  version          = "0.14.5"
  namespace        = "nvidia-device-plugin"
  create_namespace = true
  wait             = false

  values = [
    <<-EOT
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: 'nvidia.com/gpu.present'
                operator: In
                values:
                - 'true'
    EOT
  ]
}

resource "helm_release" "aws_efa_device_plugin" {
  name       = "aws-efa-k8s-device-plugin"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-efa-k8s-device-plugin"
  version    = "v0.4.4"
  namespace  = "kube-system"
  wait       = false

  values = [
    <<-EOT
      nodeSelector:
        vpc.amazonaws.com/efa.present: 'true'
      tolerations:
        - key: nvidia.com/gpu
          operator: Exists
          effect: NoSchedule
    EOT
  ]
}
