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

variable "install_base" {
  type        = bool
  default     = false
  description = "Install Istio `base` Helm Chart"
}

variable "install_cni" {
  type        = bool
  default     = false
  description = "Install Istio `cni` Helm Chart"
}

variable "install_istiod" {
  type        = bool
  default     = false
  description = "Install Istio `istiod` Helm Chart"
}

variable "install_gateway" {
  type        = bool
  default     = false
  description = "Install Istio `gateway` Helm Chart"
}

variable "base_helm_config" {
  type        = any
  default     = {}
  description = "Istio `base` Helm Chart Configuration"
}

variable "cni_helm_config" {
  type        = any
  default     = {}
  description = "Istio `cni` Helm Chart Configuration"
}

variable "istiod_helm_config" {
  type        = any
  default     = {}
  description = "Istio `istiod` Helm Chart Configuration"
}

variable "gateway_helm_config" {
  type        = any
  default     = {}
  description = "Istio `gateway` Helm Chart Configuration"
}

variable "manage_via_gitops" {
  type        = bool
  default     = false
  description = "Determines if the add-on should be managed via GitOps."
}
