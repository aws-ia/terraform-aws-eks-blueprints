# These yaml manifests are provided under folder ./eks-automode-config/
locals {
  storageclass_yamls = [
    "ebs-storageclass.yaml"
  ]
  ingressclass_yamls = [
    "alb-ingressclass.yaml",
    "alb-ingressclassParams.yaml"
  ]
  custom_nodeclass_yamls = [
    "nodeclass-simple.yaml",
    "nodeclass-ebs.yaml"
  ]
  custom_nodepool_yamls = [
    "nodepool-simple.yaml",
    "nodepool-compute-optimized.yaml",
    "nodepool-memory-optimized.yaml",
    "nodepool-graviton-memory-optimized.yaml"
  ]
}

# Apply dfault storage class for EKS AutoMode. EBS CSI Driver runs on AWS side, managed by AWS.
resource "kubectl_manifest" "storageclass_yamls" {
  for_each = toset(local.storageclass_yamls)

  yaml_body = file("${path.module}/eks-automode-config/${each.value}")
}

# Apply default storage class for EKS AutoMode. AWS Load Balancer Controller runs on AWS side, managed by AWS.
resource "kubectl_manifest" "ingressclass_yamls" {
  for_each = toset(local.ingressclass_yamls)

  yaml_body = file("${path.module}/eks-automode-config/${each.value}")
}

# Apply custom nodeClass objects
resource "kubectl_manifest" "custom_nodeClass" {
  for_each = toset(local.custom_nodeclass_yamls)

  yaml_body = templatefile("${path.module}/eks-automode-config/${each.value}", {
    node_iam_role_name = aws_iam_role.custom_nodeclass_role.name
    cluster_name       = module.eks.cluster_name
  })

  depends_on = [
    aws_iam_role.custom_nodeclass_role,
    resource.aws_eks_access_entry.custom_nodeclass
  ]
}

# Apply custom nodePool objects
resource "kubectl_manifest" "custom_nodePool" {
  for_each = toset(local.custom_nodepool_yamls)

  yaml_body = file("${path.module}/eks-automode-config/${each.value}")
}


#---------------------------------------------------------------
# Creating IAM Role and EKS Access Entry for custom nodeClass
#---------------------------------------------------------------

# Create nodeClass Access Entry
resource "aws_eks_access_entry" "custom_nodeclass" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.custom_nodeclass_role.arn
  type          = "EC2"

  depends_on = [aws_iam_role.custom_nodeclass_role]
}

# Associate nodeClass Access Entry with AutoNode policy
resource "aws_eks_access_policy_association" "example" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAutoNodePolicy"
  principal_arn = aws_iam_role.custom_nodeclass_role.arn

  access_scope {
    type = "cluster"
  }
}

# Create nodeClass role and associate with IAM policies
resource "aws_iam_role" "custom_nodeclass_role" {
  name = "custom_nodeclass_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = local.tags
}

# Attach AmazonEKSWorkerNodeMinimalPolicy
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
  role       = aws_iam_role.custom_nodeclass_role.name
}

# Attach AmazonEC2ContainerRegistryPullOnly
resource "aws_iam_role_policy_attachment" "ecr_pull_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.custom_nodeclass_role.name
}
