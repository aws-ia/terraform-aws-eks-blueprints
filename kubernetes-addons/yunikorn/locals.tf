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
  yunikorn_service_account_name = "yunikorn-admin"
  operator_plugins = "general,spark-k8s-operator"
  service_type = "ClusterIP"

  default_yunikorn_helm_app = {
    name                       = "yunikorn"
    chart                      = "yunikorn"
    repository                 = "https://apache.github.io/incubator-yunikorn-release"
    version                    = "0.11.0"
    namespace                  = "yunikorn"
    timeout                    = "1200"
    create_namespace           = true
    description                = "Apache YuniKorn (Incubating) is a light-weight, universal resource scheduler for container orchestrator systems."
    lint                       = false
    wait                       = true
    wait_for_jobs              = false
    verify                     = false
    keyring                    = ""
    repository_key_file        = ""
    repository_cert_file       = ""
    repository_ca_file         = ""
    repository_username        = ""
    repository_password        = ""
    disable_webhooks           = false
    reuse_values               = false
    reset_values               = false
    force_update               = false
    recreate_pods              = false
    cleanup_on_fail            = false
    max_history                = 0
    atomic                     = false
    skip_crds                  = false
    render_subchart_notes      = true
    disable_openapi_validation = false
    dependency_update          = false
    replace                    = false
    postrender                 = ""
    set                        = []
    set_sensitive              = []
    values                     = local.default_yunikorn_helm_values
  }

  yunikorn_helm_app = merge(
    local.default_yunikorn_helm_app,
    var.yunikorn_helm_chart
  )

  default_yunikorn_helm_values = [templatefile("${path.module}/values.yaml", {
    yunikorn_sa_name = local.yunikorn_service_account_name
    operator_plugins = local.operator_plugins
    service_type = local.service_type
    embed_admission_controller = false
  })]

  argocd_gitops_config = {
    enable             = true
    serviceAccount = local.yunikorn_service_account_name
    operatorPlugins = local.operator_plugins
    serviceType = local.service_type
    embed_admission_controller = false
  }
}
