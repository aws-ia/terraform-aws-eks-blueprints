################################################################################
# Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.8"

  cluster_name                   = local.name
  cluster_version                = "1.29"
  cluster_endpoint_public_access = true

  # Give the Terraform identity admin access to the cluster
  # which will allow resources to be deployed into the cluster
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    initial = {
      instance_types = ["m5.large"]

      min_size     = 3
      max_size     = 10
      desired_size = 3
    }
  }

  tags = local.tags
}



################################################################################
# EKS Blueprints Addons
################################################################################

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.1"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  # EKS Addons
  eks_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni = {
      preserve    = true
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }

    }
    eks-pod-identity-agent = {}
  }

  enable_aws_gateway_api_controller = true
  aws_gateway_api_controller = {
    chart_version           = "v1.0.3"
    create_namespace        = true
    namespace               = "aws-application-networking-system"
    source_policy_documents = [data.aws_iam_policy_document.gateway_api_controller.json]
    set = [
      {
        name  = "clusterName"
        value = module.eks.cluster_name
      },
      {
        name  = "log.level"
        value = "debug"
      },
      {
        name  = "clusterVpcId"
        value = module.vpc.vpc_id
      },
      {
        name  = "defaultServiceNetwork"
        value = "lattice-gateway" # Specify this parameter to create a default VPC lattice service
      },
      # {
      #   name  = "latticeEndpoint"
      #   value = "https://vpc-lattice.${local.region}.amazonaws.com"
      # }
    ]
    wait = true
  }
  enable_external_dns            = true
  external_dns_route53_zone_arns = try([data.terraform_remote_state.environment.outputs.route53_private_zone_arn], [])
  external_dns = {
    create_role = true,
    set = [
      {
        name  = "domainFilters[0]"
        value = local.domain
      },
      {
        name  = "policy"
        value = "sync"
      },
      {
        name  = "sources[0]"
        value = "crd"
      },
      {
        name  = "sources[1]"
        value = "ingress"
      },
      {
        name  = "txtPrefix"
        value = module.eks.cluster_name
      },
      {
        name  = "extraArgs[0]"
        value = "--crd-source-apiversion=externaldns.k8s.io/v1alpha1"
      },
      {
        name  = "extraArgs[1]"
        value = "--crd-source-kind=DNSEndpoint"
      },
      {
        name  = "crdSourceApiversion"
        value = "externaldns.k8s.io/v1alpha1"
      },
      {
        name  = "crdSourceKind"
        value = "DNSEndpoint"
      }
    ]
  }

  tags = local.tags
}

module "eks_blueprints_addon_kyverno" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "~> 1.1" #ensure to update this to the latest/desired version

  chart            = "kyverno"
  chart_version    = "3.0.5"
  repository       = "https://kyverno.github.io/kyverno"
  description      = "Kyverno"
  namespace        = "kyverno"
  create_namespace = true
}

data "aws_iam_policy_document" "gateway_api_controller" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"] # For testing purposes only (highly recommended limit access to specific resources for production usage)

    actions = [
      "vpc-lattice:*",
      "iam:CreateServiceLinkedRole",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeSecurityGroups",
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "tag:GetResources",
    ]
  }
}

################################################################################
# Platform applications
################################################################################

resource "helm_release" "platform_application" {
  name             = "platform-${terraform.workspace}"
  chart            = "./charts/platform"
  create_namespace = true
  namespace        = "lattice-gateway"
  force_update     = true

  #replace = true # This will force a re-deployment

  values = [
    <<EOF
    awsAccountID: "${data.aws_caller_identity.current.account_id}"
    region: "${local.region}"
    version : "v1"

    allowedCluster: ${terraform.workspace == "cluster1" ? "eks-cluster2" : "eks-cluster1"}
    allowedNamespace: "apps"

    vpc1ID: ${module.vpc.vpc_id}
    vpc2ID: to-replace

    certificateArn: ${local.certificate_arn}

    customDomain: ${local.custom_domain}
  EOF
  ]

  depends_on = [module.eks_blueprints_addons, aws_eks_pod_identity_association.apps]
}

################################################################################
# Demo applications
################################################################################

resource "helm_release" "demo_application" {
  name             = "demo-${terraform.workspace}"
  chart            = "./charts/demo"
  create_namespace = true
  namespace        = local.app_namespace
  force_update     = true

  #replace = true # This will force a re-deployment

  values = [
    <<EOF
    awsAccountID: "${data.aws_caller_identity.current.account_id}"
    region: "${local.region}"
    version : "v1"

    allowedCluster: ${terraform.workspace == "cluster1" ? "eks-cluster2" : "eks-cluster1"}
    allowedNamespace: "apps"

    vpc1ID: ${module.vpc.vpc_id}
    vpc2ID: to-replace

    certificateArn: ${local.certificate_arn}

    customDomain: ${local.custom_domain}
  EOF
  ]

  depends_on = [module.eks_blueprints_addons, aws_eks_pod_identity_association.apps, helm_release.platform_application]
}

################################################################################
# Update cluster security group to allow access from VPC Lattice
################################################################################

data "aws_ec2_managed_prefix_list" "vpc_lattice_ipv4" {
  name = "com.amazonaws.${local.region}.vpc-lattice"
}

resource "aws_vpc_security_group_ingress_rule" "cluster_sg_ingress" {
  security_group_id = module.eks.node_security_group_id

  prefix_list_id = data.aws_ec2_managed_prefix_list.vpc_lattice_ipv4.id
  ip_protocol    = "-1"
}


################################################################################
# Associate EKS pod identity for out application
################################################################################

resource "aws_eks_pod_identity_association" "apps" {
  cluster_name    = module.eks.cluster_name
  namespace       = local.app_namespace
  service_account = "default"
  role_arn        = data.terraform_remote_state.environment.outputs.vpc_lattice_client_role_arn
}
