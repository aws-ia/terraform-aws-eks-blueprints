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
  definition = nonsensitive(templatefile("${path.module}/state_machine.json", {
    ami_id = data.aws_ssm_parameter.eks_ami.value
    base64_encoded_user_data = base64encode(templatefile("${path.module}/user_data.sh", {
      # Update `ecr_images` and/or `public_images` as needed for your use case
      ecr_images = []
      public_images = [
        "public.ecr.aws/data-on-eks/vllm-ray2.32.0-inf2-llama3:latest",
      ]
      region = local.region
    }))
    availability_zones       = join("\",\"", slice(data.aws_availability_zones.available.names, 0, 3))
    iam_instance_profile_arn = aws_iam_instance_profile.ec2.arn
    security_group_id        = module.security_group.security_group_id
    subnet_id                = one(module.vpc.public_subnets)
    ssm_parameter_name       = aws_ssm_parameter.snapshot_id.name
  }))

  attach_policy_json = true
  policy_json        = data.aws_iam_policy_document.state_machine.json

  tags = local.tags
}

data "aws_iam_policy_document" "state_machine" {
  # EKS AMI SSM parameter
  statement {
    sid       = "SSMGetParameter"
    actions   = ["ssm:GetParameter"]
    resources = ["arn:aws:ssm:${local.region}::parameter/aws/service/eks/optimized-ami/*"]
  }

  # State machine pass IAM role to EC2
  statement {
    sid       = "PassRole"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.ec2.arn]
  }

  # State machine EC2 API calls to create/terminate instances and snapshots
  statement {
    sid = "Instance"
    actions = [
      "ec2:CreateTags",
      "ec2:RunInstances",
      "ec2:TerminateInstances",
      "ec2:CreateSnapshot",
      "ec2:EnableFastSnapshotRestores",
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

  # State machine EC2 API calls to check instance/snapshot state
  statement {
    sid = "DescribeInstance"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeSnapshots",
    ]
    resources = ["*"]
  }

  # State machine SSM API calls to check cloud-init status
  statement {
    sid = "SendSSMCaommand"
    actions = [
      "ssm:SendCommand",
      "ssm:GetCommandInvocation",
    ]
    resources = ["*"]
  }

  # State machine SSM API call to update the snapshot ID parameter
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
  value = "xxx"

  lifecycle {
    # The state machine will be responsible for the value after creation
    ignore_changes = [
      value
    ]
  }
}
