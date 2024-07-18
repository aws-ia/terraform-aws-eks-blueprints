provider "aws" {
  region = local.region
}

locals {
  name   = "vpc-lattice"
  region = "us-west-2"

  domain = var.custom_domain_name

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

#-------------------------------
# Create Private Hosted Zone
#-------------------------------

resource "aws_route53_zone" "private_zone" {
  name = local.domain

  vpc {
    vpc_id = aws_vpc.example.id
  }

  #we will add vpc association in other terraform stack, prevent this one to revert this
  lifecycle {
    ignore_changes = [
      vpc,
    ]
  }

  force_destroy = true
  tags          = local.tags
}

#dummy VPC that will not be used, but needed to create private hosted zone
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Example VPC"
  }
}

################################################################################
# Create IAM role to talk to VPC Lattice services and get Certificate from Manager
################################################################################
data "aws_iam_policy_document" "eks_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole", "sts:TagSession"]
  }
}
resource "aws_iam_role" "vpc_lattice_role" {
  name               = "${local.name}-sigv4-client"
  description        = "IAM role for aws-sigv4-client VPC Lattice access"
  assume_role_policy = data.aws_iam_policy_document.eks_assume.json
}

resource "aws_iam_role_policy_attachment" "vpc_lattice_invoke_access" {
  role       = aws_iam_role.vpc_lattice_role.name
  policy_arn = "arn:aws:iam::aws:policy/VPCLatticeServicesInvokeAccess"
}

resource "aws_iam_role_policy_attachment" "private_ca_read_only" {
  role       = aws_iam_role.vpc_lattice_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCertificateManagerPrivateCAReadOnly"
}
