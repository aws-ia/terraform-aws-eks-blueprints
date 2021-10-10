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

resource "helm_release" "traefik" {
  name             = local.traefik_helm_app["name"]
  repository       = local.traefik_helm_app["repository"]
  chart            = local.traefik_helm_app["chart"]
  version          = local.traefik_helm_app["version"]
  namespace        = local.traefik_helm_app["namespace"]
  timeout          = local.traefik_helm_app["timeout"]
  values           = local.traefik_helm_app["values"]
  create_namespace = local.traefik_helm_app["create_namespace"]
  lint             = local.traefik_helm_app["lint"]

  dynamic "set" {
    iterator = each_item
    for_each = local.traefik_helm_app["set"] == null ? [] : local.traefik_helm_app["set"]

    content {
      name  = each_item.value.name
      value = each_item.value.value
    }
  }

  dynamic "set_sensitive" {
    iterator = each_item
    for_each = local.traefik_helm_app["set_sensitive"] == null ? [] : local.traefik_helm_app["set_sensitive"]

    content {
      name  = each_item.value.name
      value = each_item.value.value
    }
  }

}
