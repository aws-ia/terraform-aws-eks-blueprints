/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: MIT-0
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

locals {
  tags                = tomap({ "created-by" = var.terraform_version })
  private_subnet_tags = merge(tomap({ "kubernetes.io/role/internal-elb" = "1" }), tomap({ "created-by" = var.terraform_version }))
  public_subnet_tags  = merge(tomap({ "kubernetes.io/role/elb" = "1" }), tomap({ "created-by" = var.terraform_version }))

  service_account_amp_ingest_name = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, "amp-ingest-account")
  service_account_amp_query_name  = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, "amp-query-account")
  amp_workspace_name              = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, "EKS-Metrics-Workspace")

  image_repo = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.id}.amazonaws.com/"

  self_managed_node_platform = var.enable_windows_support ? "windows" : "linux"
}
# ---------------------------------------------------------------------------------------------------------------------
# LABELING EKS RESOURCES
# ---------------------------------------------------------------------------------------------------------------------
module "eks-label" {
  source      = "./modules/aws-resource-label"
  tenant      = var.tenant
  environment = var.environment
  zone        = var.zone
  resource    = "eks"
  tags        = local.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# EKS CONTROL PLANE AND MANAGED WORKER NODES DEPLOYED BY THIS MODULE
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_kms_key" "eks" {
  description = "EKS Secret Encryption Key"
}

module "eks" {
  create_eks      = var.create_eks
  manage_aws_auth = false
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.1.0"
  cluster_name    = module.eks-label.id
  cluster_version = var.kubernetes_version

  vpc_id = var.create_vpc == false ? var.vpc_id : module.vpc.vpc_id

  subnets                         = var.create_vpc == false ? var.private_subnet_ids : module.vpc.private_subnets
  cluster_endpoint_private_access = var.endpoint_private_access
  cluster_endpoint_public_access  = var.endpoint_public_access
  enable_irsa                     = var.enable_irsa
  kubeconfig_output_path          = "./kubeconfig/"

  tags = module.eks-label.tags

  cluster_enabled_log_types = var.enabled_cluster_log_types

  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks.arn
      resources = [
      "secrets"]
    }
  ]

  #############################END OF EKS CLUSTER MODULE #############################################################

  # TODO handle this in aws-ia TF EKS module
  //  map_roles    = local.common_roles
  //  map_users    = var.map_users
  //  map_accounts = var.map_accounts

  # TODO Create a new Self-Managed Node group and remove worker_create_cluster_primary_security_group_rules and worker_groups_launch_template
  #----------------------------------------------------------------------------------
  #   Self-managed node group (worker group)
  #----------------------------------------------------------------------------------
  # Conditionally allow Worker nodes <-> primary cluster SG traffic
  # See https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/faq.md#im-using-both-aws-managed-node-groups-and-self-managed-worker-groups-and-pods-scheduled-on-a-aws-managed-node-groups-are-unable-resolve-dns-even-communication-between-pods
  worker_create_cluster_primary_security_group_rules = var.enable_self_managed_nodegroups

  # Conditionally create a self-managed node group (worker group) - either Windows or Linux
  worker_groups_launch_template = var.enable_self_managed_nodegroups ? [{
    name     = var.self_managed_nodegroup_name
    platform = local.self_managed_node_platform

    # Use custom AMI, user data script template, and its parameters, if provided in input. 
    # Otherwise, use default EKS-optimized AMI, user data script for Windows / Linux.
    ami_id                       = var.self_managed_node_ami_id != "" ? var.self_managed_node_ami_id : var.enable_windows_support ? data.aws_ami.windows2019core.id : data.aws_ami.amazonlinux2eks.id
    userdata_template_file       = var.self_managed_node_userdata_template_file != "" ? var.self_managed_node_userdata_template_file : var.enable_windows_support ? "./templates/userdata-windows.tpl" : "./templates/userdata-amazonlinux2eks.tpl"
    userdata_template_extra_args = var.self_managed_node_userdata_template_extra_params

    override_instance_types = var.self_managed_node_instance_types
    root_encrypted          = true
    root_volume_size        = var.self_managed_node_volume_size

    iam_instance_profile_name = var.enable_windows_support ? module.windows_support_iam[0].windows_instance_profile.name : null
    asg_desired_capacity      = var.self_managed_node_desired_size
    asg_min_size              = var.self_managed_node_min_size
    asg_max_size              = var.self_managed_node_max_size

    kubelet_extra_args = "--node-labels=Environment=${var.environment},Zone=${var.zone},WorkerType=SELF_MANAGED_${upper(local.self_managed_node_platform)}"

    # Extra tags, needed for cluster autoscaler autodiscovery
    tags = var.cluster_autoscaler_enable ? [{
      key                 = "k8s.io/cluster-autoscaler/enabled",
      value               = true,
      propagate_at_launch = true
      }, {
      key                 = "k8s.io/cluster-autoscaler/${module.eks-label.id}",
      value               = "owned",
      propagate_at_launch = true
    }] : []
  }] : []

}

# ---------------------------------------------------------------------------------------------------------------------
# MANAGED NODE GROUPS
# ---------------------------------------------------------------------------------------------------------------------
module "managed-node-groups" {
  for_each = var.managed_node_groups

  source     = "./modules/aws-eks-managed-node-groups"
  managed_ng = each.value

  eks_cluster_name          = module.eks.cluster_id
  private_subnet_ids        = var.create_vpc == false ? var.private_subnet_ids : module.vpc.private_subnets
  public_subnet_ids         = var.create_vpc == false ? var.public_subnet_ids : module.vpc.public_subnets
  cluster_ca_base64         = module.eks.cluster_certificate_authority_data
  cluster_endpoint          = module.eks.cluster_endpoint
  cluster_autoscaler_enable = var.cluster_autoscaler_enable
  worker_security_group_id  = module.eks.worker_security_group_id # TODO Create New SecGroup for each node group
  tags                      = module.eks-label.tags

  depends_on = [module.eks]

}
# ---------------------------------------------------------------------------------------------------------------------
# FARGATE PROFILES
# ---------------------------------------------------------------------------------------------------------------------
module "fargate-profiles" {
  for_each = length(var.fargate_profiles) > 0 && var.enable_fargate ? var.fargate_profiles : {}

  source          = "./modules/aws-eks-fargate"
  fargate_profile = each.value

  eks_cluster_name   = module.eks.cluster_id
  private_subnet_ids = var.create_vpc == false ? var.private_subnet_ids : module.vpc.private_subnets
  public_subnet_ids  = var.create_vpc == false ? var.public_subnet_ids : module.vpc.public_subnets

  tags = module.eks-label.tags

  depends_on = [module.eks]

}


# ---------------------------------------------------------------------------------------------------------------------
# RBAC DEPLOYMENT
# ---------------------------------------------------------------------------------------------------------------------
module "rbac" {
  source      = "./modules/rbac"
  tenant      = var.tenant
  environment = var.environment
  zone        = var.zone

  depends_on = [module.eks]
}
# ---------------------------------------------------------------------------------------------------------------------
# Windows Support
# ---------------------------------------------------------------------------------------------------------------------
# Create IAM resources for Linux and Windows node roles, instance profiles
# This is needed due to this issue: https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1456
module "windows_support_iam" {
  count        = var.create_eks && var.enable_windows_support ? 1 : 0
  source       = "./modules/windows-support/iam"
  cluster_name = module.eks-label.id
  tags         = module.eks-label.tags
  # Conditionally attach specific policies to the node IAM roles
  aws_managed_prometheus_enable = var.aws_managed_prometheus_enable
  cluster_autoscaler_enable     = var.cluster_autoscaler_enable
  autoscaler_policy_arn         = var.cluster_autoscaler_enable ? module.iam.eks_autoscaler_policy_arn : null

}

# Create Windows-specific VPC resource controller, admission webhook
module "windows_support_vpc_resources" {
  count        = var.create_eks && var.enable_windows_support ? 1 : 0
  source       = "./modules/windows-support/vpc-resources"
  cluster_name = module.eks.cluster_id

  depends_on = [module.eks]
}
# ---------------------------------------------------------------------------------------------------------------------
# AWS EKS Add-ons (VPC CNI, CoreDNS, KubeProxy )
# ---------------------------------------------------------------------------------------------------------------------
module "aws-eks-addon" {
  source                = "./modules/aws-eks-addon"
  cluster_name          = module.eks.cluster_id
  enable_vpc_cni_addon  = var.enable_vpc_cni_addon
  vpc_cni_addon_version = var.vpc_cni_addon_version

  enable_coredns_addon  = var.enable_coredns_addon
  coredns_addon_version = var.coredns_addon_version

  enable_kube_proxy_addon  = var.enable_kube_proxy_addon
  kube_proxy_addon_version = var.kube_proxy_addon_version
  tags                     = module.eks-label.tags

  depends_on = [module.eks]
}
# ---------------------------------------------------------------------------------------------------------------------
# IAM Module
# ---------------------------------------------------------------------------------------------------------------------
module "iam" {
  //  count        = var.create_eks ? 1 : 0
  source                    = "./modules/iam"
  environment               = var.environment
  tenant                    = var.tenant
  zone                      = var.zone
  account_id                = data.aws_caller_identity.current.account_id
  cluster_autoscaler_enable = var.cluster_autoscaler_enable

}
# ---------------------------------------------------------------------------------------------------------------------
# AWS Managed Prometheus Module
# ---------------------------------------------------------------------------------------------------------------------
module "aws_managed_prometheus" {
  count                           = var.create_eks && var.aws_managed_prometheus_enable == true ? 1 : 0
  source                          = "./modules/aws_managed_prometheus"
  environment                     = var.environment
  tenant                          = var.tenant
  zone                            = var.zone
  account_id                      = data.aws_caller_identity.current.account_id
  region                          = data.aws_region.current.id
  eks_cluster_id                  = module.eks.cluster_id
  eks_oidc_provider               = split("//", module.eks.cluster_oidc_issuer_url)[1]
  service_account_amp_ingest_name = local.service_account_amp_ingest_name
  service_account_amp_query_name  = local.service_account_amp_query_name
  amp_workspace_name              = local.amp_workspace_name
}
# ---------------------------------------------------------------------------------------------------------------------
# S3 BUCKET MODULE
# ---------------------------------------------------------------------------------------------------------------------
module "s3" {
  //  count        = var.create_eks ? 1 : 0
  source         = "./modules/s3"
  s3_bucket_name = "${var.tenant}-${var.environment}-${var.zone}-elb-accesslogs-${data.aws_caller_identity.current.account_id}"
  account_id     = data.aws_caller_identity.current.account_id

}


