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
  image_url = var.public_docker_repo ? var.cert_manager_image_repo_name : "${var.private_container_repo_url}/${var.cert_manager_image_repo_name}"
}

resource "helm_release" "cert-manager" {
  name       = var.cert_manager_helm_chart_name
  repository = var.cert_manager_helm_chart_url
  chart      = var.cert_manager_helm_chart_name
  version    = var.cert_manager_helm_chart_version
  namespace  = "kube-system"
  timeout    = "600"

  values = [templatefile("${path.module}/cert-manager-values.tpl", {
    image       = local.image_url
    tag         = var.cert_manager_image_tag
    installCRDs = var.cert_manager_install_crds
  })]

}

resource "helm_release" "cert_manager_ca" {
  chart     = "${path.module}/chart/cert-manager-ca"
  name      = "cert-manager-ca"
  namespace = "kube-system"
  depends_on = [
    helm_release.cert-manager
  ]
}
