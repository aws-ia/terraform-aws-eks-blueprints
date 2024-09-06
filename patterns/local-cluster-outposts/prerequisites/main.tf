terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.61"
    }
  }

  # ##  Used for end-to-end testing on project; update to suit your needs
  # backend "s3" {
  #   bucket = "terraform-ssp-github-actions-state"
  #   region = "us-west-2"
  #   key    = "e2e/local-clusters-outposts-prerequisites/terraform.tfstate"
  # }
}

provider "aws" {
  region = local.region
}

locals {
  region = "us-west-2"
  name   = "ex-${basename(path.cwd)}"

  terraform_version = "1.3.10"

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# Pre-Requisites
################################################################################

module "ssm_bastion_ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.5"

  name = "${local.name}-bastion"

  create_iam_instance_profile = true
  iam_role_policies = {
    AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
  }

  instance_type     = element(tolist(data.aws_outposts_outpost_instance_types.this.instance_types), 0)
  ami_ssm_parameter = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"

  user_data                   = <<-EOT
    #!/bin/bash

    # Add ssm-user since it won't exist until first login
    adduser -m ssm-user
    tee /etc/sudoers.d/ssm-agent-users <<'EOF'
    # User rules for ssm-user
    ssm-user ALL=(ALL) NOPASSWD:ALL
    EOF
    chmod 440 /etc/sudoers.d/ssm-agent-users

    cd /home/ssm-user

    # Install Terraform
    dnf install git -y
    curl -sSO https://releases.hashicorp.com/terraform/${local.terraform_version}/terraform_${local.terraform_version}_linux_amd64.zip
    sudo unzip -qq terraform_${local.terraform_version}_linux_amd64.zip terraform -d /usr/bin/
    rm terraform_${local.terraform_version}_linux_amd64.zip

    # Install kubectl
    curl -LO https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl

    # Copy Terraform files
    for TF_FILE in eks main outpost; do
      curl -O https://raw.githubusercontent.com/aws-ia/terraform-aws-eks-blueprints/feat/hybrid-section/patterns/local-cluster-outposts/$${TF_FILE}.tf
    done
    terraform init -upgrade

    chown -R ssm-user:ssm-user /home/ssm-user/
  EOT
  user_data_replace_on_change = true

  vpc_security_group_ids = [module.bastion_security_group.security_group_id]
  subnet_id              = element(data.aws_subnets.this.ids, 0)

  tags = local.tags
}

output "ssm_start_session" {
  description = "SSM start session command to connect to remote host created"
  value       = "aws ssm start-session --region ${local.region} --target ${module.ssm_bastion_ec2.id}"
}

module "bastion_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${local.name}-bastion"
  description = "Security group to allow provisioning ${local.name} EKS local cluster on Outposts"
  vpc_id      = data.aws_vpc.this.id

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = data.aws_vpc.this.cidr_block
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = local.tags
}
