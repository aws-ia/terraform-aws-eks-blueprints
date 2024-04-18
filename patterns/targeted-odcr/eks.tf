################################################################################
# Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.4"

  cluster_name    = local.name
  cluster_version = "1.29"

  # To facilitate easier interaction for demonstration purposes
  cluster_endpoint_public_access = true

  # Gives Terraform identity admin access to the cluster
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    iam_role_additional_policies = {
      # Not required, but used in the example to access the nodes to inspect drivers and devices
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }

  eks_managed_node_groups = {
    odcr = {
      instance_types = ["t3.micro", "t3.small"]

      min_size     = 4
      max_size     = 5
      desired_size = 2

      # First subnet is in the "${local.region}a" availability zone
      # where the capacity reservation is created
      subnet_ids = [element(module.vpc.private_subnets, 0)]
      capacity_reservation_specification = {
        capacity_reservation_target = {
          capacity_reservation_resource_group_arn = aws_resourcegroups_group.odcr.arn
        }
      }
    }
  }

  tags = local.tags
}

################################################################################
# Resource Group
################################################################################

resource "aws_resourcegroups_group" "odcr" {
  name        = "${local.name}-p5-odcr"
  description = "P5 instance on-demand capacity reservations"

  configuration {
    type = "AWS::EC2::CapacityReservationPool"
  }

  configuration {
    type = "AWS::ResourceGroups::Generic"

    parameters {
      name   = "allowed-resource-types"
      values = ["AWS::EC2::CapacityReservation"]
    }
  }
}

resource "aws_resourcegroups_resource" "odcr_1" {
  group_arn = aws_resourcegroups_group.odcr.arn
  # Replace the following with the ARN of the capacity reservation
  # provided by AWS when supplied with a capacity reservation
  resource_arn = aws_ec2_capacity_reservation.micro.arn
}

resource "aws_resourcegroups_resource" "odcr_2" {
  group_arn = aws_resourcegroups_group.odcr.arn
  # Replace the following with the ARN of the capacity reservation
  # provided by AWS when supplied with a capacity reservation
  resource_arn = aws_ec2_capacity_reservation.small.arn
}

################################################################################
# Capacity Reservation
# These are created for the example, but are not necessary when
# AWS EC2 provides you with a capacity reservation ID
################################################################################

resource "aws_ec2_capacity_reservation" "micro" {
  instance_type           = "t3.micro"
  instance_platform       = "Linux/UNIX"
  availability_zone       = "${local.region}a"
  instance_count          = 2
  instance_match_criteria = "targeted"

  # Just for example - 30 minutes from time of creation
  end_date      = timeadd(timestamp(), "30m")
  end_date_type = "limited"
}

resource "aws_ec2_capacity_reservation" "small" {
  instance_type           = "t3.small"
  instance_platform       = "Linux/UNIX"
  availability_zone       = "${local.region}a"
  instance_count          = 2
  instance_match_criteria = "targeted"

  # Just for example - 30 minutes from time of creation
  end_date      = timeadd(timestamp(), "30m")
  end_date_type = "limited"
}

################################################################################
# Kubectl Output
################################################################################

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
}
