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

resource "helm_release" "istio" {
  name                       = var.helm_config["name"]
  repository                 = var.helm_config["repository"]
  chart                      = var.helm_config["chart"]
  version                    = var.helm_config["version"]
  namespace                  = var.helm_config["namespace"]
  timeout                    = var.helm_config["timeout"]
  create_namespace           = var.helm_config["create_namespace"]
  lint                       = var.helm_config["lint"]
  description                = var.helm_config["description"]
  repository_key_file        = var.helm_config["repository_key_file"]
  repository_cert_file       = var.helm_config["repository_cert_file"]
  repository_ca_file         = var.helm_config["repository_ca_file"]
  repository_username        = var.helm_config["repository_username"]
  repository_password        = var.helm_config["repository_password"]
  verify                     = var.helm_config["verify"]
  keyring                    = var.helm_config["keyring"]
  disable_webhooks           = var.helm_config["disable_webhooks"]
  reuse_values               = var.helm_config["reuse_values"]
  reset_values               = var.helm_config["reset_values"]
  force_update               = var.helm_config["force_update"]
  recreate_pods              = var.helm_config["recreate_pods"]
  cleanup_on_fail            = var.helm_config["cleanup_on_fail"]
  max_history                = var.helm_config["max_history"]
  atomic                     = var.helm_config["atomic"]
  skip_crds                  = var.helm_config["skip_crds"]
  render_subchart_notes      = var.helm_config["render_subchart_notes"]
  disable_openapi_validation = var.helm_config["disable_openapi_validation"]
  wait                       = var.helm_config["wait"]
  wait_for_jobs              = var.helm_config["wait_for_jobs"]
  dependency_update          = var.helm_config["dependency_update"]
  replace                    = var.helm_config["replace"]
  values                     = var.helm_config["values"]

  postrender {
    binary_path = var.helm_config["postrender"]
  }

  dynamic "set" {
    iterator = each_item
    for_each = var.helm_config["set"] == null ? [] : var.helm_config["set"]

    content {
      name  = each_item.value.name
      value = each_item.value.value
    }
  }

  dynamic "set_sensitive" {
    iterator = each_item
    for_each = var.helm_config["set_sensitive"] == null ? [] : var.helm_config["set_sensitive"]

    content {
      name  = each_item.value.name
      value = each_item.value.value
    }
  }
}
