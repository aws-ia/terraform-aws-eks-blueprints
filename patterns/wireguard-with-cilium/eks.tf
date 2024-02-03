################################################################################
# Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                   = local.name
  cluster_version                = "1.29"
  cluster_endpoint_public_access = true

  # EKS Addons
  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    initial = {
      instance_types = ["m5.large"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    # Cilium Wireguard Port https://github.com/cilium/cilium/blob/main/Documentation/security/network/encryption-wireguard.rst
    ingress_cilium_wireguard = {
      description = "Allow Cilium Wireguard node to node"
      protocol    = "udp"
      from_port   = 51871
      to_port     = 51871
      type        = "ingress"
      self        = true
    }
  }

  tags = local.tags
}

################################################################################
# Kubectl Output
################################################################################

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
}

################################################################################
# EKS Blueprints Addons
################################################################################

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.14"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  helm_releases = {
    cilium = {
      name             = "cilium"
      chart            = "cilium"
      version          = "1.14.1"
      repository       = "https://helm.cilium.io/"
      description      = "Cilium Add-on"
      namespace        = "kube-system"
      create_namespace = false

      values = [
        <<-EOT
          cni:
            chainingMode: aws-cni
          enableIPv4Masquerade: false
          tunnel: disabled
          endpointRoutes:
            enabled: true
          l7Proxy: false
          encryption:
            enabled: true
            type: wireguard
        EOT
      ]
    }
  }

  tags = local.tags
}
