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

resource "helm_release" "prometheus" {
  count                      = var.manage_via_gitops ? 0 : 1
  name                       = local.prometheus_helm_app["name"]
  repository                 = local.prometheus_helm_app["repository"]
  chart                      = local.prometheus_helm_app["chart"]
  version                    = local.prometheus_helm_app["version"]
  namespace                  = local.prometheus_helm_app["namespace"]
  timeout                    = local.prometheus_helm_app["timeout"]
  create_namespace           = local.prometheus_helm_app["create_namespace"]
  lint                       = local.prometheus_helm_app["lint"]
  description                = local.prometheus_helm_app["description"]
  repository_key_file        = local.prometheus_helm_app["repository_key_file"]
  repository_cert_file       = local.prometheus_helm_app["repository_cert_file"]
  repository_ca_file         = local.prometheus_helm_app["repository_ca_file"]
  repository_username        = local.prometheus_helm_app["repository_username"]
  repository_password        = local.prometheus_helm_app["repository_password"]
  verify                     = local.prometheus_helm_app["verify"]
  keyring                    = local.prometheus_helm_app["keyring"]
  disable_webhooks           = local.prometheus_helm_app["disable_webhooks"]
  reuse_values               = local.prometheus_helm_app["reuse_values"]
  reset_values               = local.prometheus_helm_app["reset_values"]
  force_update               = local.prometheus_helm_app["force_update"]
  recreate_pods              = local.prometheus_helm_app["recreate_pods"]
  cleanup_on_fail            = local.prometheus_helm_app["cleanup_on_fail"]
  max_history                = local.prometheus_helm_app["max_history"]
  atomic                     = local.prometheus_helm_app["atomic"]
  skip_crds                  = local.prometheus_helm_app["skip_crds"]
  render_subchart_notes      = local.prometheus_helm_app["render_subchart_notes"]
  disable_openapi_validation = local.prometheus_helm_app["disable_openapi_validation"]
  wait                       = local.prometheus_helm_app["wait"]
  wait_for_jobs              = local.prometheus_helm_app["wait_for_jobs"]
  dependency_update          = local.prometheus_helm_app["dependency_update"]
  replace                    = local.prometheus_helm_app["replace"]
  values                     = local.prometheus_helm_app["values"]

  postrender {
    binary_path = local.prometheus_helm_app["postrender"]
  }

  dynamic "set" {
    iterator = each_item
    for_each = var.aws_managed_prometheus_enable ? distinct(concat(local.amp_config_values, local.prometheus_helm_app["set"])) : local.prometheus_helm_app["set"]

    content {
      name  = each_item.value.name
      value = each_item.value.value
    }
  }

  dynamic "set_sensitive" {
    iterator = each_item
    for_each = local.prometheus_helm_app["set_sensitive"] == null ? [] : local.prometheus_helm_app["set_sensitive"]

    content {
      name  = each_item.value.name
      value = each_item.value.value
    }
  }

}
