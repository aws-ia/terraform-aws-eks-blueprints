locals {
  user_data = <<-EOT
    #!/usr/bin/env bash

    # Increase the partition size for the root volume
    growpart /dev/nvme0n1 1

    # Create & mount the filesystem for the 2nd volume
    mkfs -t xfs /dev/xvdb
    mkdir /cache
    mount /dev/xvdb /cache

    mkdir -p /cache/var/lib/containerd
    mkdir -p /cache/var/lib/kubelet

    # Get ECR credentials to pull images (if needed)
    ECR_PASSWORD=$(aws ecr get-login-password --region "${local.region}")
    if [[ -z $${ECR_PASSWORD} ]]; then
      echo >&2 "Unable to retrieve the ECR password. Image pull may not be properly authenticated."
    fi

    # containerd needs to be running to pull images
    systemctl restart containerd

    export CONTAINER_RUNTIME_ENDPOINT=unix:///run/containerd/containerd.sock
    exportIMAGE_SERVICE_ENDPOINT=unix:///run/containerd/containerd.sock

    # crictl pull --creds "AWS:$${ECR_PASSWORD}" "<image>"

    # Images pulled for example are in public repositories, no auth requried
    crictl pull nvcr.io/nvidia/k8s-device-plugin:v0.16.2                  # 120 Mb
    crictl pull nvcr.io/nvidia/k8s/dcgm-exporter:3.3.7-3.5.0-ubuntu22.04  # 629 Mb
    crictl pull nvcr.io/nvidia/pytorch:24.07-py3                          # 9.3 Gb
    crictl pull nvcr.io/nvidia/tritonserver:24.07-vllm-python-py3         # 12.6 Gb

    yum install rsync -y
    cd / && rsync -a /var/lib/containerd/ /cache/var/lib/containerd
    echo 'synced /var/lib/containerd'
    cd / && rsync -a /var/lib/kubelet/ /cache/var/lib/kubelet
    echo 'synced /var/lib/kubelet'
  EOT
}


################################################################################
# State Machine
################################################################################

module "state_machine" {
  source  = "terraform-aws-modules/step-functions/aws"
  version = "~> 4.2"

  name = local.name
  definition = templatefile("${path.module}/state_machine.json", {
    ami_id                   = data.aws_ssm_parameter.eks_ami.value
    base64_encoded_user_data = base64encode(local.user_data)
    iam_instance_profile_arn = aws_iam_instance_profile.ec2.arn
    security_group_id        = module.security_group.security_group_id
    subnet_id                = one(module.vpc.public_subnets)
    ssm_parameter_name       = aws_ssm_parameter.snapshot_id.name
  })

  attach_policy_json = true
  policy_json        = data.aws_iam_policy_document.state_machine.json

  tags = local.tags
}

data "aws_iam_policy_document" "state_machine" {
  statement {
    sid     = "SSMGetParameter"
    actions = ["ssm:GetParameter"]
    resources = [
      # EKS SSM param
      "arn:aws:ssm:${local.region}::parameter/aws/service/eks/optimized-ami/*",
    ]
  }

  statement {
    sid       = "PassRole"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.ec2.arn]
  }

  statement {
    sid = "Instance"
    actions = [
      "ec2:RunInstances",
      "ec2:TerminateInstances",
      "ec2:CreateSnapshot",
    ]
    resources = [
      "arn:aws:ec2:*::image/*",
      "arn:aws:ec2:*::snapshot/*",
      "arn:aws:ec2:*:*:security-group/*",
      "arn:aws:ec2:*:*:subnet/*",
      "arn:aws:ec2:*:*:instance/*",
      "arn:aws:ec2:*:*:volume/*",
      "arn:aws:ec2:*:*:network-interface/*",
    ]
  }

  statement {
    sid       = "DescribeInstance"
    actions   = ["ec2:DescribeInstances"]
    resources = ["*"]
  }

  statement {
    sid = "SendSSMCaommand"
    actions = [
      "ssm:SendCommand",
      "ssm:GetCommandInvocation",
    ]
    resources = ["*"]
  }

  statement {
    sid     = "SSMPutParameter"
    actions = ["ssm:PutParameter"]
    resources = [
      aws_ssm_parameter.snapshot_id.arn,
    ]
  }
}

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

resource "aws_ssm_parameter" "snapshot_id" {
  name  = "/${local.name}/snapshot_id"
  type  = "String"
  value = "todo"

  lifecycle {
    # The state machine will be responsible for the value after creation
    ignore_changes = [
      value
    ]
  }
}
