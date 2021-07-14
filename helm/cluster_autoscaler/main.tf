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

locals {
  image_url = var.public_docker_repo ? var.image_repo_name : "${var.private_container_repo_url}${var.image_repo_name}"
}

resource "helm_release" "autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = var.cluster_autoscaler_helm_version
  namespace  = "kube-system"
  timeout    = "1200"

  set {
    name  = "autoDiscovery.clusterName"
    value = var.eks_cluster_id
  }

  set {
    name  = "replicaCount"
    value = 2
  }

  set {
    name  = "extraArgs.aws-use-static-instance-list"
    value = "true"
  }
  set {
    name  = "awsRegion"
    value = "eu-west-1"
  }
  set {
    name  = "image.repository"
    value = local.image_url
  }

  set {
    name  = "image.tag"
    value = var.cluster_autoscaler_image_tag
  }

  set {
    name  = "nodeSelector.kubernetes\\.io/os"
    value = "linux"
  }
}
