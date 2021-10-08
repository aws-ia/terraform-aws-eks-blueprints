module "eks-cluster-dev" {
  # VPC VARIABLE
  create_vpc = true

  # EKS CLUSTER CORE VARIABLES
  org         = "aws"     # Organization Name. Used to tag resources
  tenant      = "aws001"  # AWS account name or unique id for tenant
  environment = "preprod" # Environment area eg., preprod or prod
  zone        = "dev"     # Environment with in one sub_tenant or business unit

  # EKS CONTROL PLANE VARIABLES
  kubernetes_version       = "1.20"
  enable_vpc_cni_addon     = true
  vpc_cni_addon_version    = "v1.8.0-eksbuild.1"
  enable_coredns_addon     = true
  coredns_addon_version    = "v1.8.3-eksbuild.1"
  enable_kube_proxy_addon  = true
  kube_proxy_addon_version = "v1.20.4-eksbuild.2"

  # HELM MODULES
  aws_for_fluent_bit_enable       = true
  cluster_autoscaler_enable       = true
  lb_ingress_controller_enable    = true
  metrics_server_enable           = true
  nginx_ingress_controller_enable = true
}
