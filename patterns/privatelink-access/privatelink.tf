################################################################################
# Internal NLB
################################################################################

module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.13"

  name               = local.name
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.private_subnets
  internal           = true
  load_balancer_type = "network"

  enforce_security_group_inbound_rules_on_private_link_traffic = "on"
  security_group_ingress_rules = {
    https_from_vpc = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic from client VPC"
      cidr_ipv4   = module.client_vpc.vpc_cidr_block
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  target_groups = {
    eks_https = {
      name              = local.name
      protocol          = "TCP"
      port              = 443
      target_type       = "ip"
      create_attachment = false # The attachment is managed by the create/destroy ENI lambdas dynamically
      vpc_id            = module.vpc.vpc_id
    }
  }

  listeners = {
    https = {
      port     = 443
      protocol = "TCP"
      forward = {
        target_group_key = "eks_https"
      }
    }
  }

  tags = local.tags
}

# VPC Endpoint Service that can be shared with other services in other VPCs.
# This Service Endpoint is created in the VPC where the LB exists; the client
# VPC Endpoint will connect to this service to reach the cluster via AWS PrivateLink
resource "aws_vpc_endpoint_service" "this" {
  acceptance_required        = true
  network_load_balancer_arns = [module.nlb.target_groups.eks_https.arn]

  tags = merge(local.tags,
    { Name = local.name },
  )
}

resource "aws_vpc_endpoint_connection_accepter" "this" {
  vpc_endpoint_service_id = aws_vpc_endpoint_service.this.id
  vpc_endpoint_id         = aws_vpc_endpoint.client.id
}

################################################################################
# VPC Endpoint
# This allows resources in the client VPC to connect to the EKS cluster API
# endpoint in the EKS VPC without going over the internet, using a VPC peering
# connection, or a transit gateway attachment between VPCs
################################################################################

locals {
  # Get patterns for subdomain name (index 1) and domain name (index 2)
  api_server_url_pattern = regex("(https://)([[:alnum:]]+\\.)(.*)", module.eks.cluster_endpoint)

  # Retrieve the subdomain and domain name of the API server endpoint URL
  cluster_endpoint_subdomain = local.api_server_url_pattern[1]
  cluster_endpoint_domain    = local.api_server_url_pattern[2]
}

resource "aws_vpc_endpoint" "client" {
  vpc_id             = module.client_vpc.vpc_id
  service_name       = resource.aws_vpc_endpoint_service.this.service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = module.client_vpc.private_subnets
  security_group_ids = [resource.aws_security_group.client_vpc_endpoint.id]

  tags = merge(local.tags,
    { Name = local.name },
  )
}

# Create a new security group that allows TLS traffic on port 443 and let the
# client applications in Client VPC connect to the VPC Endpoint on port 443
resource "aws_security_group" "client_vpc_endpoint" {
  name_prefix = "${local.name}-"
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

resource "aws_route53_zone" "client" {
  name    = local.cluster_endpoint_domain
  comment = "Private hosted zone for EKS API server endpoint"

  vpc {
    vpc_id = module.client_vpc.vpc_id
  }

  tags = local.tags
}

resource "aws_route53_record" "client" {
  zone_id = resource.aws_route53_zone.client.zone_id
  name    = "${local.cluster_endpoint_subdomain}${local.cluster_endpoint_domain}"
  type    = "A"

  alias {
    name                   = resource.aws_vpc_endpoint.client.dns_entry[0].dns_name
    zone_id                = resource.aws_vpc_endpoint.client.dns_entry[0].hosted_zone_id
    evaluate_target_health = true
  }
}

################################################################################
# Lambda - Create ENI IPs to NLB Target Group
################################################################################

module "create_eni_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.2"

  function_name = "${local.name}-add-eni-ips"
  description   = "Add ENI IPs to NLB target group when EKS API endpoint is created"
  handler       = "create_eni.handler"
  runtime       = "python3.10"
  publish       = true
  source_path   = "lambdas"

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
          "Resource": ["${module.nlb.target_groups.eks_https.arn}"]
        }
      ]
    }
  EOT

  environment_variables = {
    TARGET_GROUP_ARN = module.nlb.target_groups.eks_https.arn
  }

  allowed_triggers = {
    eventbridge = {
      principal  = "events.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_rule_arns["eks-api-endpoint-create"]
    }
  }

  tags = local.tags
}

################################################################################
# Lambda - Delete ENI IPs from NLB Target Group
################################################################################

module "delete_eni_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.2"

  function_name = "${local.name}-delete-eni-ips"
  description   = "Deletes ENI IPs from NLB target group when EKS API endpoint is deleted"
  handler       = "delete_eni.handler"
  runtime       = "python3.10"
  publish       = true
  source_path   = "lambdas"

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
          "Resource": ["${module.nlb.target_groups.eks_https.arn}"]
        }
      ]
    }
  EOT

  environment_variables = {
    TARGET_GROUP_ARN = module.nlb.target_groups.eks_https.arn

    # Passing local.name in lieu of module.eks.cluster_name to avoid dependency
    EKS_CLUSTER_NAME = local.name
  }

  allowed_triggers = {
    eventbridge = {
      principal  = "events.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_rule_arns["eks-api-endpoint-delete"]
    }
  }

  tags = local.tags
}

################################################################################
# EventBridge Rules
################################################################################

module "eventbridge" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "~> 3.14"

  # Use the existing default event bus
  create_bus = false

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
              "description" : ["Amazon EKS ${local.name}"]
            }
          }
        }
      })
      enabled = true
    }

    eks-api-endpoint-delete = {
      description         = "Trigger for a Lambda"
      schedule_expression = "rate(15 minutes)"
    }
  }

  targets = {
    eks-api-endpoint-create = [
      {
        name = module.create_eni_lambda.lambda_function_name
        arn  = module.create_eni_lambda.lambda_function_arn
      }
    ]
    eks-api-endpoint-delete = [
      {
        name = module.delete_eni_lambda.lambda_function_name
        arn  = module.delete_eni_lambda.lambda_function_arn
      }
    ]
  }

  tags = local.tags
}
