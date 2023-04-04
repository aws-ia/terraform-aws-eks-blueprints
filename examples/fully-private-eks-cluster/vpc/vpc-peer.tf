resource "aws_vpc_peering_connection" "cloud9_eks_peer" {
  peer_vpc_id = module.aws_vpc.vpc_id
  vpc_id      = module.cloud9_vpc.vpc_id
  auto_accept = true

  tags = {
    Name = "VPC Peering between the Cloud9 VPC and EKS VPC"
  }
}

resource "aws_route" "public_cloud9_rt_eks" {
  count                     = length(module.cloud9_vpc.public_route_table_ids)
  route_table_id            = element(module.cloud9_vpc.public_route_table_ids, count.index)
  destination_cidr_block    = local.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.cloud9_eks_peer.id
}

resource "aws_route" "private_cloud9_rt_eks" {
  count                     = length(module.cloud9_vpc.private_route_table_ids)
  route_table_id            = element(module.cloud9_vpc.private_route_table_ids, count.index)
  destination_cidr_block    = local.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.cloud9_eks_peer.id
}

resource "aws_route" "private_eks_rt_cloud9" {
  count                     = length(module.aws_vpc.private_route_table_ids)
  route_table_id            = element(module.aws_vpc.private_route_table_ids, count.index)
  destination_cidr_block    = local.cloud9_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.cloud9_eks_peer.id
}

resource "aws_cloud9_environment_ec2" "eks_cloud9" {
  instance_type = "t3.small"
  subnet_id     = module.cloud9_vpc.public_subnets[0]
  tags          = local.tags
  description   = "Cloud9 Env to build a private EKS cluster"
  name          = "EKS-Cloud9"
  owner_arn     = local.cloud9_owner_arn
}
