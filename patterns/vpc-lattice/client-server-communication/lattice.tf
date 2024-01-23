################################################################################
# VPC Lattice service network
################################################################################

resource "aws_vpclattice_service_network" "this" {
  name      = "my-services"
  auth_type = "NONE"

  tags = local.tags
}

resource "aws_vpclattice_service_network_vpc_association" "cluster_vpc" {
  vpc_identifier             = module.cluster_vpc.vpc_id
  service_network_identifier = aws_vpclattice_service_network.this.id
}

resource "aws_vpclattice_service_network_vpc_association" "client_vpc" {
  vpc_identifier             = module.client_vpc.vpc_id
  service_network_identifier = aws_vpclattice_service_network.this.id
}

resource "time_sleep" "wait_for_lattice_resources" {
  depends_on = [helm_release.demo_application]

  create_duration = "120s"
}

################################################################################
# Custom domain name for VPC lattice service
# Records will be created by external-dns using DNSEndpoint objects which
# are created by the VPC Lattice gateway api controller when creating HTTPRoutes
################################################################################

resource "aws_route53_zone" "primary" {
  name = "example.com"

  vpc {
    vpc_id = module.client_vpc.vpc_id
  }

  tags = local.tags
}