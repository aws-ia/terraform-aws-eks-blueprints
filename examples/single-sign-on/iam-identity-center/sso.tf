# Pre requisite
# Enable AWS IAM Identity Manager (https://console.aws.amazon.com/singlesignon/home/)

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

data "aws_caller_identity" "current" {}

data "aws_ssoadmin_instances" "this" {}

resource "aws_ssoadmin_permission_set" "admin" {
  name             = "EKSClusterAdmin"
  description      = "Amazon EKS Cluster Admins."
  instance_arn     = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  relay_state      = "https://s3.console.aws.amazon.com/s3/home?region=us-west-2#"
  session_duration = "PT1H"
}

resource "aws_ssoadmin_permission_set" "user" {
  name             = "EKSClusterUser"
  description      = "Amazon EKS Cluster Users."
  instance_arn     = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  relay_state      = "https://s3.console.aws.amazon.com/s3/home?region=us-west-2#"
  session_duration = "PT1H"
}

data "aws_iam_policy_document" "admin" {
  statement {
    sid = "EKSAdmin"
    actions = [
      "eks:*"
    ]
    resources = [
      module.eks.cluster_arn
    ]
  }
  statement {
    sid = "AssumeRole"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "user" {
  statement {
    sid = "EKSRead"
    actions = [
      "eks:List*",
      "eks:Describe*",
      "eks:AccessKubernetesApi"
    ]
    resources = [
      module.eks.cluster_arn
    ]
  }

  statement {
    sid = "AssumeRole"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_ssoadmin_permission_set_inline_policy" "admin" {
  inline_policy      = data.aws_iam_policy_document.admin.json
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
}

resource "aws_ssoadmin_permission_set_inline_policy" "user" {
  inline_policy      = data.aws_iam_policy_document.user.json
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.user.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "admin" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "user" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.user.arn
}

resource "aws_identitystore_user" "admin" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  display_name      = "Platform Admin"
  user_name         = "admin@example.com"

  name {
    family_name = "Admin"
    given_name  = "Platform"
  }
}

resource "aws_identitystore_user" "user" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  display_name      = "Developer User"
  user_name         = "user@example.com"

  name {
    family_name = "User"
    given_name  = "Developer"
  }
}

resource "aws_identitystore_group" "operators" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  display_name      = "eks-operators"
  description       = "EKS Operators Cluster Group"
}

resource "aws_identitystore_group" "developers" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  display_name      = "eks-developers"
  description       = "EKS Developers Cluster Group"
}

resource "aws_identitystore_group_membership" "operators" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  group_id          = aws_identitystore_group.operators.group_id
  member_id         = aws_identitystore_user.admin.user_id
}

resource "aws_identitystore_group_membership" "developers" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  group_id          = aws_identitystore_group.developers.group_id
  member_id         = aws_identitystore_user.user.user_id
}

resource "aws_ssoadmin_account_assignment" "operators" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn

  principal_id   = aws_identitystore_group.operators.group_id
  principal_type = "GROUP"

  target_id   = data.aws_caller_identity.current.account_id
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "developer" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.user.arn

  principal_id   = aws_identitystore_group.developers.group_id
  principal_type = "GROUP"

  target_id   = data.aws_caller_identity.current.account_id
  target_type = "AWS_ACCOUNT"
}

resource "kubernetes_cluster_role_binding_v1" "cluster_admin" {
  metadata {
    name = "sso-cluster-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "Group"
    name      = "eks-operators"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_cluster_role_binding_v1" "cluster_viewer" {
  metadata {
    name = "sso-cluster-viewer"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }
  subject {
    kind      = "Group"
    name      = "eks-developers"
    api_group = "rbac.authorization.k8s.io"
  }
}

data "kubernetes_config_map_v1" "awsauth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
}

data "aws_iam_roles" "admin" {
  name_regex  = "AWSReservedSSO_EKSClusterAdmin_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"

  depends_on = [
    aws_ssoadmin_account_assignment.operators,
    aws_ssoadmin_account_assignment.operators
  ]
}

data "aws_iam_roles" "user" {
  name_regex  = "AWSReservedSSO_EKSClusterUser_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"

  depends_on = [
    aws_ssoadmin_account_assignment.operators,
    aws_ssoadmin_account_assignment.developer
  ]
}

locals {
  sso_role_prefix = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role"
}

resource "kubernetes_config_map_v1_data" "example" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = merge(data.kubernetes_config_map_v1.awsauth.data, {
    "mapRoles" = yamlencode([{
      rolearn  = "${local.sso_role_prefix}/${tolist(data.aws_iam_roles.admin.names)[0]}"
      username = "admin"
      groups   = ["eks-operators"]
      },
      {
        rolearn  = "${local.sso_role_prefix}/${tolist(data.aws_iam_roles.user.names)[0]}"
        username = "user"
        groups   = ["eks-developers"]
      }
  ]) })

  force = true

  depends_on = [
    data.kubernetes_config_map_v1.awsauth,
    data.aws_iam_roles.admin,
    data.aws_iam_roles.user
  ]
}
