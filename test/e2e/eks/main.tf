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

terraform {
  required_version = ">= 1.0.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.66.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.7.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
  }
}

provider "aws" {
  region = data.aws_region.current.id
  alias  = "default"
}

terraform {
  backend "s3" {
    bucket = "terraform-ssp-github-actions-state"
    key    = "e2e/eks/terraform-main.tfstate"
    region = "us-west-2"
  }
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "terraform_remote_state" "vpc_s3_backend" {
  backend = "s3"
  config = {
    bucket = "terraform-ssp-github-actions-state"
    key    = "e2e/vpc/terraform-main.tfstate"
    region = "us-west-2"
  }
}

locals {
  tenant             = "aws001"  # AWS account name or unique id for tenant
  environment        = "preprod" # Environment area eg., preprod or prod
  zone               = "test"     # Environment with in one sub_tenant or business unit
  kubernetes_version = "1.21"
  terraform_version  = "Terraform v1.0.1"

  vpc_id             = data.terraform_remote_state.vpc_s3_backend.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.vpc_s3_backend.outputs.private_subnets
  public_subnet_ids  = data.terraform_remote_state.vpc_s3_backend.outputs.public_subnets
  cluster_name = join("-", [local.tenant, local.environment, local.zone, "eks"])
}

module "aws-eks-accelerator-for-terraform" {
  source = "../.."

  tenant            = local.tenant
  environment       = local.environment
  zone              = local.zone
  terraform_version = local.terraform_version

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = local.vpc_id
  private_subnet_ids = local.private_subnet_ids

  # EKS CONTROL PLANE VARIABLES
  create_eks         = true
  kubernetes_version = local.kubernetes_version

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    mg_4 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["m4.large"]
      subnet_ids      = local.private_subnet_ids
    }
  }
  # EKS SELF-MANAGED NODE GROUPS
  self_managed_node_groups = {
    self_mg_4 = {
      node_group_name    = "self-managed-ondemand"
      instance_types  = ["m4.large"]
      subnet_ids      = local.private_subnet_ids
    }
  }
  # Fargate profiles
  fargate_profiles = {
    default = {
      fargate_profile_name = "default"
      fargate_profile_namespaces = [
        {
          namespace = "default"
          k8s_labels = {
            Environment = "preprod"
            Zone        = "dev"
            env         = "fargate"
          }
        }]
      subnet_ids = local.private_subnet_ids
      additional_tags = {
        ExtraTag = "Fargate"
      }
    },
  }

  # EKS Addons
  enable_eks_addon_vpc_cni = true
  enable_eks_addon_coredns = true
  enable_eks_addon_kube_proxy = true
  enable_eks_addon_aws_ebs_csi_driver = true

  #K8s Add-ons
  aws_lb_ingress_controller_enable = true
  metrics_server_enable            = true
  cluster_autoscaler_enable        = true
  prometheus_enable = true
  ingress_nginx_controller_enable = true
  aws_for_fluentbit_enable = true
  traefik_ingress_controller_enable = true
  agones_enable = true
  aws_open_telemetry_enable = true
  spark_on_k8s_operator_enable = true
  argocd_enable = true
  keda_enable = true
  vpa_enable = true
  yunikorn_enable = true
  fargate_fluentbit_enable = true

  # AWS Managed Services
  aws_managed_prometheus_enable         = true
  aws_managed_prometheus_workspace_name = "amp-workspace-${local.cluster_name}"

  enable_emr_on_eks = true
  emr_on_eks_teams = {
    data_team_a = {
      emr_on_eks_namespace     = "emr-data-team-a"
      emr_on_eks_iam_role_name = "emr-eks-data-team-a"
    }

    data_team_b = {
      emr_on_eks_namespace     = "emr-data-team-b"
      emr_on_eks_iam_role_name = "emr-eks-data-team-b"
    }
  }

}
