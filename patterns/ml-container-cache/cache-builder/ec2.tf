################################################################################
# Instance IAM Role & Profile
################################################################################

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    sid = "EC2NodeAssumeRole"
    actions = [
      "sts:TagSession",
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name_prefix           = "${local.name}-instance-"
  assume_role_policy    = data.aws_iam_policy_document.ec2_assume_role.json
  force_detach_policies = true

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ec2_role" {
  for_each = {
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  }

  policy_arn = each.value
  role       = aws_iam_role.ec2.name
}

resource "aws_iam_instance_profile" "ec2" {
  name_prefix = "${local.name}-instance-"
  role        = aws_iam_role.ec2.name

  tags = local.tags
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = local.name
  vpc_id = module.vpc.vpc_id

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
