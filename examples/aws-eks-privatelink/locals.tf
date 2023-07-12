locals {
  azs = data.aws_availability_zones.available.names

  client_vpc_name  = format("%s-%s-%s", var.eks_cluster_name, "client", "vpc")
  service_vpc_name = format("%s-%s", var.eks_cluster_name, "vpc")

  nlb_ip_cidrs = [
    for ip_addr in data.dns_a_record_set.nlb.addrs :
    format("%s/32", ip_addr)
  ]

  # Get patterns for subdomain name (index 1) and domain name (index 2)
  api_server_url_pattern = regex("(https://)([[:alnum:]]+\\.)(.*)",
  module.eks.cluster_endpoint)

  # Retrieve the subdomain and domain name of the API server endpoint URL
  r53_record_subdomain    = local.api_server_url_pattern[1]
  r53_private_hosted_zone = local.api_server_url_pattern[2]

  tags = {
    Blueprint  = basename(path.cwd)
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}
