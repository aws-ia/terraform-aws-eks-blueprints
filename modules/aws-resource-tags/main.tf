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
  label_order = [
    "tenant",
    "environment",
    "zone",
    "resource",
  "attributes"]
  org         = var.org == null ? "" : var.org
  tenant      = var.tenant == null ? "" : var.tenant
  environment = var.environment
  zone        = var.zone
  resource    = var.resource
  attributes  = var.attributes == null ? "" : var.attributes
  delimiter   = "-"
  input_tags  = var.tags == null ? {} : var.tags
  enabled     = var.enabled == null ? "false" : var.enabled

  id = join(local.delimiter, [local.tenant, local.environment, local.zone, local.resource])


  tags_context = {
    name        = local.id
    tenant      = local.tenant
    environment = local.environment
    zone        = local.zone
    resource    = local.resource

  }
  tags = merge(local.tags_context, local.input_tags)

}