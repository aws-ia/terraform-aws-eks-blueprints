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


provider "aws" {
  region = data.aws_region.current.id
  alias  = "default"
}

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }
  host                   = var.create_eks ? data.aws_eks_cluster.cluster.0.endpoint : ""
  cluster_ca_certificate = var.create_eks ? base64decode(data.aws_eks_cluster.cluster.0.certificate_authority.0.data) : ""
  token                  = var.create_eks ? data.aws_eks_cluster_auth.cluster.0.token : ""
}

provider "helm" {
  kubernetes {
    host                   = var.create_eks ? data.aws_eks_cluster.cluster.0.endpoint : ""
    token                  = var.create_eks ? data.aws_eks_cluster_auth.cluster.0.token : ""
    cluster_ca_certificate = var.create_eks ? base64decode(data.aws_eks_cluster.cluster.0.certificate_authority.0.data) : ""
  }
}
