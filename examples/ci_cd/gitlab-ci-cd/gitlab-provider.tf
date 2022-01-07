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

data "gitlab_group" "gitops-eks" {
  full_path = "ssp-amazon-eks-terraform-group"
}

data "gitlab_projects" "ssp-amazon-eks" {
  group_id          = data.gitlab_group.gitops-eks.id
  simple            = true
  search            = "ssp-amazon-eks"
  include_subgroups = true
}

resource "gitlab_group_cluster" "aws_cluster" {
  group                 = data.gitlab_group.gitops-eks.id
  name                  = module.aws-eks-accelerator-for-terraform.cluster_name
  domain                = ""
  environment_scope     = "*"
  kubernetes_api_url    = module.aws-eks-accelerator-for-terraform.cluster_endpoint
  kubernetes_token      = data.kubernetes_secret.gitlab-admin-token.data.token
  kubernetes_ca_cert    = trimspace(base64decode(module.aws-eks-accelerator-for-terraform.cluster_certificate_authority_data))
  management_project_id = data.gitlab_projects.ssp-amazon-eks.projects.0.id

  depends_on = [module.aws-eks-accelerator-for-terraform]
}
