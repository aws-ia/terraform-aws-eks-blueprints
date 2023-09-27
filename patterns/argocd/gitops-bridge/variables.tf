variable "gitops_addons_org" {
  description = "Git repository org/user contains for addons"
  default     = "https://github.com/aws-samples"
}
variable "gitops_addons_repo" {
  description = "Git repository contains for addons"
  default     = "eks-blueprints-add-ons"
}
variable "gitops_addons_basepath" {
  description = "Git repository base path for addons"
  default     = "argocd/"
}
variable "gitops_addons_path" {
  description = "Git repository path for addons"
  default     = "bootstrap/control-plane/addons"
}
variable "gitops_addons_revision" {
  description = "Git repository revision/branch/ref for addons"
  default     = "HEAD"
}
