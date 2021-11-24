/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: MIT-0
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

resource "helm_release" "lb_ingress" {
  count                      = var.manage_via_gitops ? 0 : 1
  name                       = local.lb_ingress_controller_helm_app["name"]
  repository                 = local.lb_ingress_controller_helm_app["repository"]
  chart                      = local.lb_ingress_controller_helm_app["chart"]
  version                    = local.lb_ingress_controller_helm_app["version"]
  namespace                  = local.lb_ingress_controller_helm_app["namespace"]
  timeout                    = local.lb_ingress_controller_helm_app["timeout"]
  values                     = local.lb_ingress_controller_helm_app["values"]
  create_namespace           = local.lb_ingress_controller_helm_app["create_namespace"]
  lint                       = local.lb_ingress_controller_helm_app["lint"]
  description                = local.lb_ingress_controller_helm_app["description"]
  repository_key_file        = local.lb_ingress_controller_helm_app["repository_key_file"]
  repository_cert_file       = local.lb_ingress_controller_helm_app["repository_cert_file"]
  repository_ca_file         = local.lb_ingress_controller_helm_app["repository_ca_file"]
  repository_username        = local.lb_ingress_controller_helm_app["repository_username"]
  repository_password        = local.lb_ingress_controller_helm_app["repository_password"]
  verify                     = local.lb_ingress_controller_helm_app["verify"]
  keyring                    = local.lb_ingress_controller_helm_app["keyring"]
  disable_webhooks           = local.lb_ingress_controller_helm_app["disable_webhooks"]
  reuse_values               = local.lb_ingress_controller_helm_app["reuse_values"]
  reset_values               = local.lb_ingress_controller_helm_app["reset_values"]
  force_update               = local.lb_ingress_controller_helm_app["force_update"]
  recreate_pods              = local.lb_ingress_controller_helm_app["recreate_pods"]
  cleanup_on_fail            = local.lb_ingress_controller_helm_app["cleanup_on_fail"]
  max_history                = local.lb_ingress_controller_helm_app["max_history"]
  atomic                     = local.lb_ingress_controller_helm_app["atomic"]
  skip_crds                  = local.lb_ingress_controller_helm_app["skip_crds"]
  render_subchart_notes      = local.lb_ingress_controller_helm_app["render_subchart_notes"]
  disable_openapi_validation = local.lb_ingress_controller_helm_app["disable_openapi_validation"]
  wait                       = local.lb_ingress_controller_helm_app["wait"]
  wait_for_jobs              = local.lb_ingress_controller_helm_app["wait_for_jobs"]
  dependency_update          = local.lb_ingress_controller_helm_app["dependency_update"]
  replace                    = local.lb_ingress_controller_helm_app["replace"]

  postrender {
    binary_path = local.lb_ingress_controller_helm_app["postrender"]
  }

  dynamic "set" {
    iterator = each_item
    for_each = local.lb_ingress_controller_helm_app["set"] == null ? [] : local.lb_ingress_controller_helm_app["set"]

    content {
      name  = each_item.value.name
      value = each_item.value.value
    }
  }

  dynamic "set_sensitive" {
    iterator = each_item
    for_each = local.lb_ingress_controller_helm_app["set_sensitive"] == null ? [] : local.lb_ingress_controller_helm_app["set_sensitive"]

    content {
      name  = each_item.value.name
      value = each_item.value.value
    }
  }

  depends_on = [aws_iam_role.aws_load_balancer_controller_role, kubernetes_service_account.aws_load_balancer_controller_sa]
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "${var.eks_cluster_id}-lb-controller-policy"
  description = "Allows lb controller to manage ALB and NLB"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole",
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAddresses",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeVpcs",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeInstances",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeTags",
                "ec2:GetCoipPoolUsage",
                "ec2:DescribeCoipPools",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeListenerCertificates",
                "elasticloadbalancing:DescribeSSLPolicies",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:DescribeTags"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cognito-idp:DescribeUserPoolClient",
                "acm:ListCertificates",
                "acm:DescribeCertificate",
                "iam:ListServerCertificates",
                "iam:GetServerCertificate",
                "waf-regional:GetWebACL",
                "waf-regional:GetWebACLForResource",
                "waf-regional:AssociateWebACL",
                "waf-regional:DisassociateWebACL",
                "wafv2:GetWebACL",
                "wafv2:GetWebACLForResource",
                "wafv2:AssociateWebACL",
                "wafv2:DisassociateWebACL",
                "shield:GetSubscriptionState",
                "shield:DescribeProtection",
                "shield:CreateProtection",
                "shield:DeleteProtection"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSecurityGroup"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": "arn:aws:ec2:*:*:security-group/*",
            "Condition": {
                "StringEquals": {
                    "ec2:CreateAction": "CreateSecurityGroup"
                },
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Resource": "arn:aws:ec2:*:*:security-group/*",
            "Condition": {
                "Null": {
                    "aws:ResourceTag/ingress.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags",
                "elasticloadbalancing:DeleteTargetGroup"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
            ],
            "Condition": {
                "Null": {
                    "aws:ResourceTag/ingress.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Resource": "arn:aws:ec2:*:*:security-group/*",
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:DeleteSecurityGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateTargetGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:DeleteRule"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
            ],
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:SetIpAddressType",
                "elasticloadbalancing:SetSecurityGroups",
                "elasticloadbalancing:SetSubnets",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:DeleteTargetGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets"
            ],
            "Resource": "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:SetWebAcl",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:AddListenerCertificates",
                "elasticloadbalancing:RemoveListenerCertificates",
                "elasticloadbalancing:ModifyRule"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

data "aws_iam_policy_document" "aws_load_balancer_controller_assume_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.eks_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:${local.aws_load_balancer_controller_sa}"]
    }

    principals {
      identifiers = [var.eks_oidc_provider_arn]
      type        = "Federated"
    }
  }
}

# IAM role for eks alb controller
resource "aws_iam_role" "aws_load_balancer_controller_role" {
  name               = "${var.eks_cluster_id}-lb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_policy.json
}


# Allows eks alb controller to manage LB's
resource "aws_iam_role_policy_attachment" "eks_role_policy" {
  role       = aws_iam_role.aws_load_balancer_controller_role.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}

# Kubernetes service account for lb controller
resource "kubernetes_service_account" "aws_load_balancer_controller_sa" {
  metadata {
    name        = local.aws_load_balancer_controller_sa
    namespace   = "kube-system"
    annotations = { "eks.amazonaws.com/role-arn" : aws_iam_role.aws_load_balancer_controller_role.arn }
  }
  automount_service_account_token = true
}
