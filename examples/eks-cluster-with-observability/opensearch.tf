resource "aws_elasticsearch_domain" "opensearch" {
  domain_name           = "opensearch"
  elasticsearch_version = "OpenSearch_1.1"

  cluster_config {
    instance_type          = "m4.large.elasticsearch"
    instance_count         = 3
    zone_awareness_enabled = true
    zone_awareness_config {
      availability_zone_count = 3
    }
  }
  node_to_node_encryption {
    enabled = true
  }
  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }
  encrypt_at_rest {
    enabled = true
  }
  ebs_options {
    ebs_enabled = true
    volume_size = var.ebs_volume_size
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = var.opensearch_dashboard_user
      master_user_password = var.opensearch_dashboard_pw
    }
  }
}

variable "opensearch_dashboard_user" {
  type = string
}

variable "opensearch_dashboard_pw" {
  type      = string
  sensitive = true
}

variable "ebs_volume_size" {
  type        = number
  description = "volume size in gigabytes"
}

# variable "main_role_arn" {
#   type        = string
#   description = "arn for the principal accessing opensearch"
# }

# resource "aws_elasticsearch_domain_policy" "opensearch_policy" {
#   domain_name = aws_elasticsearch_domain.opensearch.domain_name

#   access_policies = <<POLICIES
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": "es:*",
#             "Principal": "*",
#             "Effect": "Allow",
#             "Resource": "${aws_elasticsearch_domain.opensearch.arn}/*"
#         }
#     ]
# }
# POLICIES
# }
