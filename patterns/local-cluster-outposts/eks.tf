################################################################################
# Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24"

  cluster_name    = local.name
  cluster_version = "1.30"

  # Gives Terraform identity admin access to cluster which will
  # allow deploying resources (EBS storage class) into the cluster
  enable_cluster_creator_admin_permissions = true

  vpc_id     = data.aws_vpc.this.id
  subnet_ids = data.aws_subnets.this.ids

  outpost_config = {
    control_plane_instance_type = local.instance_type
    outpost_arns                = [var.outpost_arn]
  }

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    ingress_vpc_https = {
      description = "Remote host to control plane"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = [data.aws_vpc.this.cidr_block]
    }
  }

  self_managed_node_groups = {
    outpost = {
      name     = local.name
      ami_type = "AL2023_x86_64_STANDARD"

      min_size      = 1
      max_size      = 3
      desired_size  = 2
      instance_type = local.instance_type

      # Additional configuration values required to join local cluster to EKS
      cloudinit_pre_nodeadm = [
        {
          content_type = "application/node.eks.aws"
          content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              cluster:
                enableOutpost: true
                id: ${module.eks.cluster_id}
          EOT
        }
      ]
    }
  }

  tags = local.tags
}

################################################################################
# GP2 Storage Class
# Required for local cluster on Outposts
################################################################################

resource "kubernetes_storage_class_v1" "this" {
  metadata {
    name = "ebs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type      = "gp2"
    encrypted = "true"
  }
}
