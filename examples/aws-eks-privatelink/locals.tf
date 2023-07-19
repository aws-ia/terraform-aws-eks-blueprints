locals {
  name   = basename(path.cwd)
  region = "us-west-2"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }

  # Get patterns for subdomain name (index 1) and domain name (index 2)
  api_server_url_pattern = regex("(https://)([[:alnum:]]+\\.)(.*)", module.eks.cluster_endpoint)

  # Retrieve the subdomain and domain name of the API server endpoint URL
  r53_record_subdomain    = local.api_server_url_pattern[1]
  r53_private_hosted_zone = local.api_server_url_pattern[2]
}
