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


resource "aws_prometheus_workspace" "amp_workspace" {
  alias = var.amp_workspace_name
}

resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = "prometheus"
  }
}

//Set up service roles for the ingestion of metrics from Amazon EKS clusters

resource "aws_iam_role" "service_account_amp_ingest_role" {
  name               = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, "amp-ingest-role")
  description        = "Set up a trust policy designed for a specific combination of K8s service account and namespace to sign in from a Kubernetes cluster which hosts the OIDC Idp."
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${var.account_id}:oidc-provider/${var.eks_oidc_provider}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${var.eks_oidc_provider}:sub": "system:serviceaccount:${kubernetes_namespace.prometheus.id}:${var.service_account_amp_ingest_name}"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "permission_policy_ingest" {
  name        = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, "permission_policy_ingest")
  description = "Set up the permission policy that grants ingest (remote write) permissions for all AMP workspaces"

  policy = <<EOF
{
  "Version": "2012-10-17",
   "Statement": [
       {"Effect": "Allow",
        "Action": [
           "aps:RemoteWrite",
           "aps:GetSeries",
           "aps:GetLabels",
           "aps:GetMetricMetadata"
        ],
        "Resource": "*"
      }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "amp_role_attach_policy" {
  role       = aws_iam_role.service_account_amp_ingest_role.name
  policy_arn = aws_iam_policy.permission_policy_ingest.arn
}

//Set up IAM roles for service accounts for the querying of metrics

resource "aws_iam_role" "service_account_amp_query_role" {
  name               = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, "amp-query-role")
  description        = "Setup a trust policy designed for a specific combination of K8s service account and namespace to sign in from a Kubernetes cluster which hosts the OIDC Idp."
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${var.account_id}:oidc-provider/${var.eks_oidc_provider}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${var.eks_oidc_provider}:sub": "system:serviceaccount:${kubernetes_namespace.prometheus.id}:${var.service_account_amp_query_name}"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "permission_policy_query" {
  name        = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, "permission_policy_query")
  description = "Set up the permission policy that grants query permissions for all AMP workspaces"

  policy = <<EOF
{
  "Version": "2012-10-17",
   "Statement": [
       {"Effect": "Allow",
        "Action": [
           "aps:QueryMetrics",
           "aps:GetSeries",
           "aps:GetLabels",
           "aps:GetMetricMetadata"
        ],
        "Resource": "*"
      }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "amp_role_query_attach_policy" {
  role       = aws_iam_role.service_account_amp_query_role.name
  policy_arn = aws_iam_policy.permission_policy_query.arn
}