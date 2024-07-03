locals {
  ecr_account_id  = var.ecr_account_id != "" ? var.ecr_account_id : data.aws_caller_identity.current.account_id
  ecr_region      = var.ecr_region != "" ? var.ecr_region : local.region
}

data "aws_secretsmanager_secret" "docker" {
  name = "ecr-pullthroughcache/docker"
}

resource "aws_ecr_registry_scanning_configuration" "configuration" {
  scan_type = "BASIC"

  rule {
    scan_frequency = "SCAN_ON_PUSH"
    repository_filter {
      filter      = "*"
      filter_type = "WILDCARD"
    }
  }
}  

resource "aws_ecr_pull_through_cache_rule" "docker-hub" {
  ecr_repository_prefix = "docker-hub"
  upstream_registry_url = "registry-1.docker.io"
  credential_arn = data.aws_secretsmanager_secret.docker.arn
}

resource "aws_ecr_pull_through_cache_rule" "ecr" {
  ecr_repository_prefix = "ecr"
  upstream_registry_url = "public.ecr.aws"
}

resource "aws_ecr_pull_through_cache_rule" "k8s" {
  ecr_repository_prefix = "k8s"
  upstream_registry_url = "registry.k8s.io"
}

resource "aws_ecr_pull_through_cache_rule" "quay" {
  ecr_repository_prefix = "quay"
  upstream_registry_url = "quay.io"
}
