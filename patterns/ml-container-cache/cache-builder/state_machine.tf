# Using the EKS AMI allows us to use ctr to pull images
data "aws_ssm_parameter" "eks_ami" {
  name = "/aws/service/eks/optimized-ami/1.30/amazon-linux-2/recommended/image_id"
}

################################################################################
# State Machine
################################################################################

module "state_machine" {
  source  = "terraform-aws-modules/step-functions/aws"
  version = "~> 4.2"

  name = local.name
  definition = templatefile("${path.module}/state_machine.json", {
    ami_id = data.aws_ssm_parameter.eks_ami.value
    base64_encoded_user_data = base64encode(templatefile("${path.module}/user_data.sh", {
      ecr_images = []
      public_images = [
        "nvcr.io/nvidia/k8s-device-plugin:v0.16.2",                 # 120 Mb
        "nvcr.io/nvidia/k8s/dcgm-exporter:3.3.7-3.5.0-ubuntu22.04", # 629 Mb
        "nvcr.io/nvidia/pytorch:24.07-py3",                         # 9.3 Gb
        "nvcr.io/nvidia/tritonserver:24.07-vllm-python-py3",        # 12.6 Gb
      ]
      region = local.region
    }))
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
      "ec2:CreateTags",
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
    sid = "DescribeInstance"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeSnapshots",
    ]
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

output "start_execution_command" {
  description = "Example awscli command to start the state machine execution"
  value = <<-EOT
    aws stepfunctions start-execution \
      --region ${local.region} \
      --state-machine-arn ${module.state_machine.state_machine_arn} \
      --input ${jsonencode(jsonencode(
  {
    InstanceType        = "c6in.24xlarge"
    Iops                = 10000
    Throughput          = 1000
    VolumeSize          = 128
    SnapshotName        = "ml-container-cache"
    SnapshotDescription = "ML container image cache"
  }
))}
  EOT
}

################################################################################
# Snapshot SSM Parameter
################################################################################

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
