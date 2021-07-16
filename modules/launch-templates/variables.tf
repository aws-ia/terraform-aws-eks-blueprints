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

variable "cluster_ca_base64" {
  type        = string
  default     = ""
  description = "Base64-encoded cluster certificate-authority-data"
}
variable "cluster_endpoint" {
  type        = string
  default     = ""
  description = "Cluster K8s API server endpoint"
}
variable "cluster_name" {
  type        = string
  description = "Cluster name"
}
variable "bootstrap_extra_args" {
  type        = string
  default     = ""
  description = "Extra bootstrap script arguments in userdata script"
}
variable "kubelet_extra_args" {
  type        = string
  default     = ""
  description = "Extra kubelet arguments in userdata script"
}
variable "pre_userdata" {
  type        = string
  default     = ""
  description = "Extra snippet to be executed prior to the main userdata script"
}
variable "post_userdata" {
  type        = string
  default     = ""
  description = "Extra snippet to be executed after the main userdata script"
}

variable "node_group_name" {}
//variable "instance_type" {}
variable "volume_size" {
  default = "50"
}
variable "tags" {}
variable "worker_security_group_id" {}
variable "public_launch_template" {
  default = false
}
variable "use_custom_ami" {
  type        = bool
  default     = false
  description = "Use custom AMI"
}
variable "custom_ami_type" {
  type        = string
  default     = ""
  description = "Custom AMI type. Must be one of: amazonlinux2eks, bottlerocket, windows, other. If the value is 'other', custom_userdata_template_filepath must be provided."
}
variable "custom_ami_id" {
  type        = string
  default     = ""
  description = "Custom AMI ID, e.g. /aws/service/bottlerocket/aws-k8s-1.20/x86_64/latest/image_id"
}
variable "custom_userdata_template_filepath" {
  type        = string
  default     = ""
  description = "Custom userdata template file path"
}
variable "custom_userdata_template_params" {
  type        = map(any)
  default     = {}
  description = "Custom userdata template additional params"
}
