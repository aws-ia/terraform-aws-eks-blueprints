################################################################################
# Outpost Network
################################################################################

variable "outpost_arn" {
  description = "The ARN of the Outpost where the EKS cluster will be provisioned"
  type        = string
}

locals {
  instance_type = element(tolist(data.aws_outposts_outpost_instance_types.this.instance_types), 0)
}

# We can only use the instance types support by the Outpost rack
data "aws_outposts_outpost_instance_types" "this" {
  arn = var.outpost_arn
}

data "aws_subnets" "lookup" {
  filter {
    name   = "outpost-arn"
    values = [var.outpost_arn]
  }
}

# Reverse lookup of the subnet to get the VPC
# This is whats used for the cluster
data "aws_subnet" "this" {
  id = element(tolist(data.aws_subnets.lookup.ids), 0)
}

# These are subnets for the Outpost and restricted to the same VPC
# This is whats used for the cluster
data "aws_subnets" "this" {
  filter {
    name   = "outpost-arn"
    values = [var.outpost_arn]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_subnet.this.vpc_id]
  }
}

data "aws_vpc" "this" {
  id = data.aws_subnet.this.vpc_id
}
