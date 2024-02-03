provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

data "aws_availability_zones" "available" {}

locals {
  name   = basename(path.cwd)
  region = "us-west-2"

  cluster_version = "1.29"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

################################################################################
# Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ingress traffic"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_self_all = {
      description = "Node to node all egress traffic"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      self        = true
    }
  }

  eks_managed_node_group_defaults = {
    iam_role_additional_policies = {
      # Not required, but used in the example to access the nodes to inspect drivers and devices
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }

  eks_managed_node_groups = {
    # For running services that do not require GPUs
    default = {
      instance_types = ["m5.large"]

      min_size     = 1
      max_size     = 5
      desired_size = 2
    }

    efa = {
      ami_type       = "AL2_x86_64_GPU"
      instance_types = ["g5.8xlarge"]

      min_size     = 1
      max_size     = 1
      desired_size = 1

      subnet_ids = slice(module.vpc.private_subnets, 0, 1)

      network_interfaces = [
        {
          description                 = "EFA interface"
          delete_on_termination       = true
          device_index                = 0
          associate_public_ip_address = false
          interface_type              = "efa"
        }
      ]

      placement = {
        group_name = aws_placement_group.efa.name
      }

      taints = {
        dedicated = {
          key    = "nvidia.com/gpu"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }
    }
  }

  tags = local.tags
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

  # We want to wait for the Fargate profiles to be deployed first
  create_delay_dependencies = [for group in module.eks.eks_managed_node_groups : group.node_group_arn]

  enable_aws_efs_csi_driver    = true
  enable_aws_fsx_csi_driver    = true
  enable_kube_prometheus_stack = true
  kube_prometheus_stack = {
    values = [
      <<-EOT
        prometheus:
          prometheusSpec:
            serviceMonitorSelectorNilUsesHelmValues: false
      EOT
    ]
  }
  enable_metrics_server = true

  helm_releases = {
    prometheus-adapter = {
      description      = "A Helm chart for k8s prometheus adapter"
      namespace        = "prometheus-adapter"
      create_namespace = true
      chart            = "prometheus-adapter"
      chart_version    = "4.2.0"
      repository       = "https://prometheus-community.github.io/helm-charts"
      values = [
        <<-EOT
          replicas: 2
          podDisruptionBudget:
            enabled: true
        EOT
      ]
    }
    gpu-operator = {
      description      = "A Helm chart for NVIDIA GPU operator"
      namespace        = "gpu-operator"
      create_namespace = true
      chart            = "gpu-operator"
      chart_version    = "v23.3.2"
      repository       = "https://nvidia.github.io/gpu-operator"
      values = [
        <<-EOT
          dcgmExporter:
            enabled: false
          driver:
            enabled: false
          toolkit:
            version: v1.13.5-centos7
          operator:
            defaultRuntime: containerd
          validator:
            driver:
              env:
                # https://github.com/NVIDIA/gpu-operator/issues/569
                - name: DISABLE_DEV_CHAR_SYMLINK_CREATION
                  value: "true"
        EOT
      ]
    }
  }

  tags = local.tags
}

################################################################################
# Amazon Elastic Fabric Adapter (EFA)
################################################################################

resource "kubernetes_daemonset" "aws_efa_k8s_device_plugin" {
  metadata {
    name      = "aws-efa-k8s-device-plugin-daemonset"
    namespace = "kube-system"
  }

  spec {
    selector {
      match_labels = {
        name = "aws-efa-k8s-device-plugin"
      }
    }

    template {
      metadata {
        labels = {
          name = "aws-efa-k8s-device-plugin"
        }
      }

      spec {
        volume {
          name = "device-plugin"

          host_path {
            path = "/var/lib/kubelet/device-plugins"
          }
        }

        container {
          name  = "aws-efa-k8s-device-plugin"
          image = "602401143452.dkr.ecr.us-west-2.amazonaws.com/eks/aws-efa-k8s-device-plugin:v0.4.3"

          volume_mount {
            name       = "device-plugin"
            mount_path = "/var/lib/kubelet/device-plugins"
          }

          image_pull_policy = "Always"

          security_context {
            capabilities {
              drop = ["ALL"]
            }
          }
        }

        host_network = true

        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "beta.kubernetes.io/instance-type"
                  operator = "In"
                  values   = ["c5n.18xlarge", "c5n.9xlarge", "c5n.metal", "c6a.48xlarge", "c6a.metal", "c6gn.16xlarge", "c6i.32xlarge", "c6i.metal", "c6id.32xlarge", "c6id.metal", "c6in.32xlarge", "c6in.metal", "c7g.16xlarge", "c7g.metal", "c7gd.16xlarge", "c7gn.16xlarge", "c7i.48xlarge", "dl1.24xlarge", "g4dn.12xlarge", "g4dn.16xlarge", "g4dn.8xlarge", "g4dn.metal", "g5.12xlarge", "g5.16xlarge", "g5.24xlarge", "g5.48xlarge", "g5.8xlarge", "hpc7g.16xlarge", "hpc7g.4xlarge", "hpc7g.8xlarge", "i3en.12xlarge", "i3en.24xlarge", "i3en.metal", "i4g.16xlarge", "i4i.32xlarge", "i4i.metal", "im4gn.16xlarge", "inf1.24xlarge", "m5dn.24xlarge", "m5dn.metal", "m5n.24xlarge", "m5n.metal", "m5zn.12xlarge", "m5zn.metal", "m6a.48xlarge", "m6a.metal", "m6i.32xlarge", "m6i.metal", "m6id.32xlarge", "m6id.metal", "m6idn.32xlarge", "m6idn.metal", "m6in.32xlarge", "m6in.metal", "m7a.48xlarge", "m7a.metal-48xl", "m7g.16xlarge", "m7g.metal", "m7gd.16xlarge", "m7i.48xlarge", "p3dn.24xlarge", "p4d.24xlarge", "p5.48xlarge", "r5dn.24xlarge", "r5dn.metal", "r5n.24xlarge", "r5n.metal", "r6a.48xlarge", "r6a.metal", "r6i.32xlarge", "r6i.metal", "r6id.32xlarge", "r6id.metal", "r6idn.32xlarge", "r6idn.metal", "r6in.32xlarge", "r6in.metal", "r7a.48xlarge", "r7g.16xlarge", "r7g.metal", "r7gd.16xlarge", "r7iz.32xlarge", "trn1.32xlarge", "trn1n.32xlarge", "vt1.24xlarge", "x2idn.32xlarge", "x2idn.metal", "x2iedn.32xlarge", "x2iedn.metal", "x2iezn.12xlarge", "x2iezn.metal"]
                }
              }

              node_selector_term {
                match_expressions {
                  key      = "node.kubernetes.io/instance-type"
                  operator = "In"
                  values   = ["c5n.18xlarge", "c5n.9xlarge", "c5n.metal", "c6a.48xlarge", "c6a.metal", "c6gn.16xlarge", "c6i.32xlarge", "c6i.metal", "c6id.32xlarge", "c6id.metal", "c6in.32xlarge", "c6in.metal", "c7g.16xlarge", "c7g.metal", "c7gd.16xlarge", "c7gn.16xlarge", "c7i.48xlarge", "dl1.24xlarge", "g4dn.12xlarge", "g4dn.16xlarge", "g4dn.8xlarge", "g4dn.metal", "g5.12xlarge", "g5.16xlarge", "g5.24xlarge", "g5.48xlarge", "g5.8xlarge", "hpc7g.16xlarge", "hpc7g.4xlarge", "hpc7g.8xlarge", "i3en.12xlarge", "i3en.24xlarge", "i3en.metal", "i4g.16xlarge", "i4i.32xlarge", "i4i.metal", "im4gn.16xlarge", "inf1.24xlarge", "m5dn.24xlarge", "m5dn.metal", "m5n.24xlarge", "m5n.metal", "m5zn.12xlarge", "m5zn.metal", "m6a.48xlarge", "m6a.metal", "m6i.32xlarge", "m6i.metal", "m6id.32xlarge", "m6id.metal", "m6idn.32xlarge", "m6idn.metal", "m6in.32xlarge", "m6in.metal", "m7a.48xlarge", "m7a.metal-48xl", "m7g.16xlarge", "m7g.metal", "m7gd.16xlarge", "m7i.48xlarge", "p3dn.24xlarge", "p4d.24xlarge", "p5.48xlarge", "r5dn.24xlarge", "r5dn.metal", "r5n.24xlarge", "r5n.metal", "r6a.48xlarge", "r6a.metal", "r6i.32xlarge", "r6i.metal", "r6id.32xlarge", "r6id.metal", "r6idn.32xlarge", "r6idn.metal", "r6in.32xlarge", "r6in.metal", "r7a.48xlarge", "r7g.16xlarge", "r7g.metal", "r7gd.16xlarge", "r7iz.32xlarge", "trn1.32xlarge", "trn1n.32xlarge", "vt1.24xlarge", "x2idn.32xlarge", "x2idn.metal", "x2iedn.32xlarge", "x2iedn.metal", "x2iezn.12xlarge", "x2iezn.metal"]
                }
              }
            }
          }
        }

        toleration {
          key      = "CriticalAddonsOnly"
          operator = "Exists"
        }

        toleration {
          key      = "aws.amazon.com/efa"
          operator = "Exists"
          effect   = "NoSchedule"
        }

        priority_class_name = "system-node-critical"
      }
    }

    strategy {
      type = "RollingUpdate"
    }
  }
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

# Group instances within clustered placement group so they are in close proximity
resource "aws_placement_group" "efa" {
  name     = local.name
  strategy = "cluster"
}
