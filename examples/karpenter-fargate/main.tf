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

provider "kubectl" {
  apply_retry_count      = 10
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.this.token
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}

data "aws_availability_zones" "available" {}

locals {
  name   = basename(path.cwd)
  region = "us-west-2"

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
  source = "../.."

  cluster_name    = local.name
  cluster_version = "1.23"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  #----------------------------------------------------------------------------------------------------------#
  # Security groups used in this module created by the upstream modules terraform-aws-eks (https://github.com/terraform-aws-modules/terraform-aws-eks).
  #   Upstream module implemented Security groups based on the best practices doc https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html.
  #   So, by default the security groups are restrictive. Users needs to enable rules for specific ports required for App requirement or Add-ons
  #   See the notes below for each rule used in these examples
  #----------------------------------------------------------------------------------------------------------#
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

    # Allows Control Plane Nodes to talk to Worker nodes on Karpenter ports.
    # This can be extended further to specific port based on the requirement for others Add-on e.g., metrics-server 4443, spark-operator 8080, etc.
    # Change this according to your security requirements if needed
    ingress_nodes_karpenter_port = {
      description                   = "Cluster API to Nodegroup for Karpenter"
      protocol                      = "tcp"
      from_port                     = 8443
      to_port                       = 8443
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  # Add karpenter.sh/discovery tag so that we can use this as securityGroupSelector in karpenter provisioner
  node_security_group_tags = {
    "karpenter.sh/discovery/${local.name}" = local.name
  }

  # Add Karpenter IAM role to the aws-auth config map to allow the controller to register the ndoes to the clsuter
  map_roles = [
    {
      rolearn  = aws_iam_role.karpenter.arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes"
      ]
    }
  ]

  # EKS FARGATE PROFILES
  # We recommend to have Fargate profiles to place your critical workloads and add-ons
  # Then rely on Karpenter to scale your workloads
  # We filter the kube-system pods with labels since not all add-ons can run on Fargate (e.g. aws-node-termination-handler)
  fargate_profiles = {
    # Providing compute for the kube-system namespace where addons that can run on Fargate reside
    coredns = {
      fargate_profile_name = "coredns"
      fargate_profile_namespaces = [{
        namespace = "kube-system",
        k8s_labels = {
          "app.kubernetes.io/name" = "coredns"
        }
      }]
      subnet_ids = module.vpc.private_subnets
    },
    aws_load_balancer_controller = {
      fargate_profile_name = "aws-load-balancer-controller"
      fargate_profile_namespaces = [{
        namespace = "kube-system",
        k8s_labels = {
          "app.kubernetes.io/name" = "aws-load-balancer-controller"
        }
      }]
      subnet_ids = module.vpc.private_subnets
    },
    # Providing compute for the karpenter namespace
    karpenter = {
      fargate_profile_name = "karpenter"
      fargate_profile_namespaces = [{
        namespace = "karpenter"
      }]
      subnet_ids = module.vpc.private_subnets
    }
  }

  tags = local.tags
}

module "eks_blueprints_kubernetes_addons" {
  depends_on = [module.eks_blueprints.fargate_profiles]

  source = "../../modules/kubernetes-addons"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  enable_amazon_eks_vpc_cni = true
  amazon_eks_vpc_cni_config = {
    most_recent = true
  }

  enable_amazon_eks_kube_proxy = true
  amazon_eks_kube_proxy_config = {
    most_recent = true
  }

  remove_default_coredns_deployment = true
  enable_self_managed_coredns       = true
  self_managed_coredns_helm_config = {
    # Sets the correct annotations to ensure the Fargate provisioner is used and not the Karpenter provisioner
    compute_type       = "fargate"
    kubernetes_version = module.eks_blueprints.eks_cluster_version
  }
  enable_coredns_cluster_proportional_autoscaler = true

  enable_karpenter = true

  enable_aws_node_termination_handler = true
  aws_node_termination_handler_helm_config = {
    # We do not wait for the helm chart status since NTH cannot run on Fargate and the Karpenter provioner is not created yet
    # When Karpenter will be running, it will detect the NTH unschedulable pods and provision nodes for them
    wait = false
  }

  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller_helm_config = {
    set_values = [
      {
        name  = "vpcId"
        value = module.vpc.vpc_id
      },
      {
        name  = "podDisruptionBudget.maxUnavailable"
        value = 1
      }
    ]
  }

  tags = local.tags
}

# Allow ingress from the worker nodes security group (Karpenter nodes)
# to the cluster primary security group (Fargate nodes)
resource "aws_security_group_rule" "cluster_primary_ingress_all" {
  type                     = "ingress"
  to_port                  = 0
  protocol                 = "-1"
  from_port                = 0
  security_group_id        = module.eks_blueprints.cluster_primary_security_group_id
  source_security_group_id = module.eks_blueprints.worker_node_security_group_id
}

# Add the Karpenter Provisioners IAM Role
# https://karpenter.sh/v0.19.0/getting-started/getting-started-with-terraform/#create-the-karpentercontroller-iam-role
resource "aws_iam_role" "karpenter" {
  name = "${local.name}-karpenter-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy" "eks_cni" {
  arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

data "aws_iam_policy" "eks_worker_node" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

data "aws_iam_policy" "ecr_read_only" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy" "instance_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "karpenter_eks_cni" {
  role       = aws_iam_role.karpenter.name
  policy_arn = data.aws_iam_policy.eks_cni.arn
}

resource "aws_iam_role_policy_attachment" "karpenter_eks_worker_node" {
  role       = aws_iam_role.karpenter.name
  policy_arn = data.aws_iam_policy.eks_worker_node.arn
}

resource "aws_iam_role_policy_attachment" "karpenter_ecr_read_only" {
  role       = aws_iam_role.karpenter.name
  policy_arn = data.aws_iam_policy.ecr_read_only.arn
}

resource "aws_iam_role_policy_attachment" "karpenter_instance_core" {
  role       = aws_iam_role.karpenter.name
  policy_arn = data.aws_iam_policy.instance_core.arn
}

resource "aws_iam_instance_profile" "karpenter" {
  name = "${local.name}-karpenter-instance-profile"
  role = aws_iam_role.karpenter.name
}

# Add the default provisioner for Karpenter autoscaler
data "kubectl_path_documents" "karpenter_provisioners" {
  pattern = "${path.module}/provisioners/default_provisioner*.yaml"
  vars = {
    azs                     = join(",", local.azs)
    iam-instance-profile-id = "${local.name}-karpenter-instance-profile"
    eks-cluster-id          = local.name
    eks-vpc_name            = local.name
  }
}

resource "kubectl_manifest" "karpenter_provisioner" {
  depends_on = [module.eks_blueprints_kubernetes_addons]
  for_each   = toset(data.kubectl_path_documents.karpenter_provisioners.documents)
  yaml_body  = each.value
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
