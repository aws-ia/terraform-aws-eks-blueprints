# Using the EKS AMI allows us to use ctr to pull images
data "aws_ssm_parameter" "eks_ami" {
  name = "/aws/service/eks/optimized-ami/1.30/amazon-linux-2/recommended/image_id"
}

################################################################################
# Pre-Requisites
################################################################################

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.5"

  name = local.name

  ami = data.aws_ssm_parameter.eks_ami.value

  create_iam_instance_profile = true
  iam_role_policies = {
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    # Optional - to access instance via SSM
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  instance_type = "c6in.16xlarge"

  user_data_replace_on_change = true
  user_data                   = <<-EOT
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

  root_block_device = [
    # Need to increase root volume for pulling images
    {
      volume_size = 256
      volume_type = "gp3"
      iops        = 6000
      throughput  = 500
    },
  ]

  ebs_block_device = [
    # Volume that will contain cached container images
    {
      device_name           = "/dev/xvdb"
      volume_size           = 256
      volume_type           = "gp3"
      iops                  = 6000
      throughput            = 500
      delete_on_termination = false
    }
  ]

  vpc_security_group_ids      = [module.security_group.security_group_id]
  subnet_id                   = one(module.vpc.public_subnets)
  associate_public_ip_address = true

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
