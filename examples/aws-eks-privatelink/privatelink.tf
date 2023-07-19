# Create an internal ELB with a target group config defined such that it can
# point to and health check k8s API Server endpoint.
module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.6.1"

  name               = "nlb-to-eks-managed-enis"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.private_subnets
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

################################################################################
# Lambda - Add ENI IPs to NLB Target Group
################################################################################

module "add_eni_ips_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 5.0"

  function_name = "${local.name}-add-eni-ips"
  description   = "Adds ENI IPs to NLB target group when EKS API endpoint is created"
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
      principal  = "events.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_rule_arns["eks-api-endpoint-create"]
    }
  }

  tags = local.tags
}

################################################################################
# Lambda - Delete ENI IPs from NLB Target Group
################################################################################

module "delete_eni_ips_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 5.0"

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
          "Resource": ["${module.nlb.target_group_arns[0]}"]
        }
      ]
    }
  EOT

  environment_variables = {
    TARGET_GROUP_ARN = module.nlb.target_group_arns[0]
    EKS_CLUSTER_NAME = module.eks.cluster_name
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
  version = "~> 2.0"

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
        name = module.add_eni_ips_lambda.lambda_function_name
        arn  = module.add_eni_ips_lambda.lambda_function_arn
      }
    ]
    eks-api-endpoint-delete = [
      {
        name = module.delete_eni_ips_lambda.lambda_function_name
        arn  = module.delete_eni_ips_lambda.lambda_function_arn
      }
    ]
  }

  tags = local.tags
}
