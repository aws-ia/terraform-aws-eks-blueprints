# This module will create a VPC to which the client application will be deployed
# Since there are no restrictions on this VPC, it will have both kind of subnets
# and will have access to services outside of the VPC via the NAT Gateway
module "client_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.client_vpc_name
  cidr = var.vpc_cidr

  azs = local.azs
  private_subnets = [
    for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)
  ]
  public_subnets = [
    for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k + 10)
  ]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.client_vpc_name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.client_vpc_name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.client_vpc_name}-default" }

  tags = local.tags
}

# Create a security group for client instance such that it allows ingress TCP
# traffic on port 22 (SSH), port 443 (HTTPS) from anywhere and egress TCP/UDP
# traffic on port 53 (DNS) to anywhere
module "client_instance_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "allow-ingress-ssh-tls-egress-all"
  description = "Security group for client instance"
  vpc_id      = module.client_vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      description = "Traffic on all ports and protocols"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = local.tags
}

# Create a SSH key pair
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create an AWS key pair with the public key of the SSH key pair created earlier
resource "aws_key_pair" "this" {
  key_name   = var.aws_key_pair_name
  public_key = tls_private_key.this.public_key_openssh

  # This command would run on Linux/Unix/Mac only and assumes that you have a
  # folder at this path: ${var.ssh_key_local_path}
  provisioner "local-exec" {
    command = <<EOF
    echo '${tls_private_key.this.private_key_pem}' > \
    ${var.ssh_key_local_path}/${var.aws_key_pair_name}.pem
    EOF
  }
  tags = local.tags
}

# Spin up a sample instance in the client VPC for testing purposes only
# Block this code module if and when needed as this is entirely optional
module "client_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                   = "client-privatelink-instance"
  instance_type          = "t2.micro"
  key_name               = resource.aws_key_pair.this.key_name
  monitoring             = true
  vpc_security_group_ids = [module.client_instance_sg.security_group_id]
  subnet_id              = module.client_vpc.public_subnets[0]
  user_data              = file("user-data.sh")

  associate_public_ip_address = true

  tags = local.tags
}

# Configure the Private EKS VPC by setting only private subnets and without a
# NAT Gateway, effectively preventing ingress/exgress outside of VPC
module "private_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.service_vpc_name
  cidr = var.vpc_cidr

  azs = local.azs
  private_subnets = [
    for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)
  ]

  # No NAT Gateway prevents ingress into the VPC, making VPC extra private
  enable_nat_gateway = false

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

# Explicitly create a Internet Gateway here in the Private EKS VPC as without an
# internet gateway, a NLB cannot be created. Config option of create_igw = true
# (default) did not work during the VPC creation as it requires public subnets
# and the related routes that connect them to IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = module.private_vpc.vpc_id
  tags   = local.tags
}

# Define security group for Private EKS VPC endpoints such that only ingress
# that is allowed is HTTPS traffic on TCP on port 443 and only from the private
# subnets. For egress allow HTTPS traffic on TCP to all the services outside of
# the VPC on port 443
module "private_vpc_endpoints_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.eks_cluster_name}-vpc-endpoints"
  description = "Security group for VPC endpoint access"
  vpc_id      = module.private_vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      description = "VPC CIDR HTTPS"
      cidr_blocks = join(",", module.private_vpc.private_subnets_cidr_blocks)
    },
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      description = "All egress HTTPS"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = local.tags
}

# Create all the endpoints for the Private EKS VPC in one go
module "private_vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.0"

  vpc_id             = module.private_vpc.vpc_id
  security_group_ids = [module.private_vpc_endpoints_sg.security_group_id]

  endpoints = merge(
    {
      # For S3 create an Gateway VPC endpoint
      s3 = {
        service         = "s3"
        service_type    = "Gateway"
        route_table_ids = module.private_vpc.private_route_table_ids
        tags = {
          Name = "${var.eks_cluster_name}-s3"
        }
      }
    },
    {
      # For all other AWS listed below, create an Interface VPC endpoint
      for service in toset(["autoscaling", "ecr.api", "ecr.dkr",
        "ec2", "ec2messages", "elasticloadbalancing", "sts", "kms",
      "logs", "ssm", "ssmmessages"]) :
      replace(service, ".", "_") =>
      {
        service             = service
        subnet_ids          = module.private_vpc.private_subnets
        private_dns_enabled = true
        tags                = { Name = "${var.eks_cluster_name}-${service}" }
      }
    }
  )

  tags = local.tags
}

# Create EKS cluster by not excplicitly setting the variable
# cluster_endpoint_private_access which will then default to false and creates
# an EKS cluster that is only accessible within the VPC in which it is created
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.15.3"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version

  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  vpc_id     = module.private_vpc.vpc_id
  subnet_ids = module.private_vpc.private_subnets

  eks_managed_node_groups = {
    mng = var.managed_node_group
  }

  # Adding additional tag only for the sake of creating an implicit dependency
  # on the 'vpc_endpoints' module. The 'depends_on' meta-argument resulted in an
  # error and hence this hack.
  tags = merge(local.tags, {
    EndpointsTotalCount = length(module.private_vpc_endpoints.endpoints)
  })
}

# Create an internal ELB with a target group config defined such that it can
# point to and health check k8s API Server endpoint.
module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.6.1"

  name               = "nlb-to-eks-managed-enis"
  vpc_id             = module.private_vpc.vpc_id
  subnets            = module.private_vpc.private_subnets
  internal           = true
  load_balancer_type = "network"

  target_groups = [{
    name_prefix      = "pref-"
    backend_protocol = "TCP"
    backend_port     = 443
    target_type      = "ip"
    health_check = {
      enabled  = true
      path     = "/readyz"
      protocol = "HTTPS"
      matcher  = "200"
    }
  }]

  http_tcp_listeners = [{
    port               = 443
    protocol           = "TCP"
    target_group_index = 0
  }]

  tags = local.tags
}

# Create a new rule in the EKS Managed SG such that it allows TCP traffic on
# port 443 from the NLB IP addresses
resource "aws_security_group_rule" "allow_tls_service" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = local.nlb_ip_cidrs
  security_group_id = data.aws_security_group.eks_managed_sg.id
}

# Create a VPC Endpoint Service such that the service can be then shared with
# other services in other VPCs. This Service Endpoint is created in the VPC
# where the LB exists
resource "aws_vpc_endpoint_service" "this" {
  acceptance_required        = true
  network_load_balancer_arns = [module.nlb.lb_arn]

  tags = merge({
    Name = var.endpoint_service_name
  }, local.tags)
}

# Create a new security group that allows TLS traffic on port 443 and let the
# client applications in Client VPC connect to the VPC Endpoint on port 443
resource "aws_security_group" "allow_tls_client" {
  name        = "allow-ingress-tls-egress-all"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.client_vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.client_vpc.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = local.tags
}

# Create a VPC Endpoint in the Client VPC and bind it to the Service Endpoint
# created earlier such that the service in the client VPC can locally connect to
# the endpoint to be able to access the API Server Endpoint of the remote EKS
# cluster in the Serivce VPC
resource "aws_vpc_endpoint" "this" {
  vpc_id             = module.client_vpc.vpc_id
  service_name       = resource.aws_vpc_endpoint_service.this.service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = module.client_vpc.public_subnets
  security_group_ids = [resource.aws_security_group.allow_tls_client.id]
  tags = merge({
    Name = var.endpoint_name
  }, local.tags)
}

# Accept a pending VPC Endpoint connection accept request to VPC Endpoint
# Service
resource "aws_vpc_endpoint_connection_accepter" "this" {
  vpc_endpoint_service_id = aws_vpc_endpoint_service.this.id
  vpc_endpoint_id         = aws_vpc_endpoint.this.id

  depends_on = [module.eks]
}

# Create a private hosted zone for the Client VPC matching the domain name of
# the API server URL
resource "aws_route53_zone" "private" {
  name = local.r53_private_hosted_zone

  vpc {
    vpc_id = module.client_vpc.vpc_id
  }
}

# Create an Alias A record pointing to the DNS name of the VPC endpoint
resource "aws_route53_record" "alias_k8s_api_server" {
  zone_id = resource.aws_route53_zone.private.zone_id
  name    = format("%s%s", local.r53_record_subdomain, local.r53_private_hosted_zone)
  type    = "A"
  alias {
    name    = resource.aws_vpc_endpoint.this.dns_entry[0].dns_name
    zone_id = resource.aws_vpc_endpoint.this.dns_entry[0].hosted_zone_id

    evaluate_target_health = true
  }
}

# Create a randomly named S3 bucket to store the Lambda ZIP files
resource "aws_s3_bucket" "this" {
  tags = local.tags
}

# Define a Lambda to handle the API Endpoint ENI creation
module "handle_eni_create_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "eks-api-endpoints-create-event-handler"
  description   = "Lambda that handles creation of EKS API endpoints"
  handler       = "handler.lambda_handler"
  runtime       = "python3.10"
  publish       = true
  source_path   = "handle-eni-create"
  store_on_s3   = true
  s3_bucket     = resource.aws_s3_bucket.this.id

  attach_policy_json = true
  policy_json        = <<-EOT
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "elasticloadbalancing:RegisterTargets"
              ],
              "Resource": ["${module.nlb.target_group_arns[0]}"]
          }
      ]
  }
  EOT

  environment_variables = {
    TARGET_GROUP_ARN = module.nlb.target_group_arns[0]
  }

  allowed_triggers = {
    eventbridge = {
      principal = "events.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_rule_arns[
        "eks-api-endpoint-create"
      ]
    }
  }

  tags = local.tags
}

# Define a Lambda to handle the API Endpoint ENI deletion
module "handle_eni_cleanup_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "eks-api-endpoints-cleanup-event-handler"
  description   = "Lambda that handles deletion of EKS API endpoints"
  handler       = "handler.lambda_handler"
  runtime       = "python3.10"
  publish       = true
  source_path   = "handle-eni-cleanup"
  store_on_s3   = true
  s3_bucket     = resource.aws_s3_bucket.this.id

  attach_policy_json = true
  policy_json        = <<-EOT
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "ec2:DescribeNetworkInterfaces",
                  "elasticloadbalancing:Describe*"
              ],
              "Resource": ["*"]
          },
          {
              "Effect": "Allow",
              "Action": [
                  "elasticloadbalancing:DeregisterTargets"
              ],
              "Resource": ["${module.nlb.target_group_arns[0]}"]
          }
      ]
  }
  EOT

  environment_variables = {
    TARGET_GROUP_ARN = module.nlb.target_group_arns[0]
    EKS_CLUSTER_NAME = var.eks_cluster_name
  }

  allowed_triggers = {
    eventbridge = {
      principal = "events.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_rule_arns[
        "eks-api-endpoint-cleanup"
      ]
    }
  }

  tags = local.tags
}

# One single eventbridge module that defines two rules and invokes one Lambda
# for each rule that is matched
module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"

  # Use the existing default event bus
  create_bus = false

  # Create two rules, one to handle ENI creation and one to handle deletion
  rules = {
    eks-api-endpoint-create = {
      event_pattern = jsonencode({
        "source" : ["aws.ec2"],
        "detail-type" : ["AWS API Call via CloudTrail"],
        "detail" : {
          "eventSource" : ["ec2.amazonaws.com"],
          "eventName" : ["CreateNetworkInterface"],
          "sourceIPAddress" : ["eks.amazonaws.com"],
          "responseElements" : {
            "networkInterface" : {
              "description" : ["Amazon EKS ${var.eks_cluster_name}"]
            }
          }
        }
      })
      enabled = true
    }
    eks-api-endpoint-cleanup = {
      description         = "Trigger for a Lambda"
      schedule_expression = "rate(${var.handle_eni_cleanup_lambda_freq} minutes)"
    }
  }

  # Define the Lambda targets that need to be triggered, one for each rule
  targets = {
    eks-api-endpoint-create = [
      {
        name = module.handle_eni_create_lambda.lambda_function_name
        arn  = module.handle_eni_create_lambda.lambda_function_arn
      }
    ]
    eks-api-endpoint-cleanup = [
      {
        name = module.handle_eni_cleanup_lambda.lambda_function_name
        arn  = module.handle_eni_cleanup_lambda.lambda_function_arn
      }
    ]
  }

  tags = local.tags
}
