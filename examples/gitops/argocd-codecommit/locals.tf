locals {

  name = basename(path.cwd)
  # region          = data.aws_region.current.name
  cluster_version = "1.23"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  node_group_name = "managed-ondemand"

  env = "dev"

  #---------------------------------------------------------------
  # ARGOCD ADD-ON APPLICATION
  #---------------------------------------------------------------

  addon_application = {
    path               = "chart"
    repo_url           = "https://github.com/aws-samples/eks-blueprints-add-ons.git"
    add_on_application = true
  }

  #---------------------------------------------------------------
  # ARGOCD WORKLOAD APPLICATION
  #---------------------------------------------------------------
  # workload_repo = "https://github.com/aws-samples/eks-blueprints-workloads.git"
  workload_repo = aws_codecommit_repository.workloads_repo_cc.clone_url_http

  workload_application = {
    path               = "envs/dev"
    repo_url           = local.workload_repo
    add_on_application = false
    values = {
      labels = {
        env   = local.env
        myapp = "myvalue"
      }
      spec = {
        source = {
          repoURL = local.workload_repo
        }
        blueprint   = "terraform"
        clusterName = local.name
        #karpenterInstanceProfile = "${local.name}-${local.node_group_name}" # Activate to enable Karpenter manifests (only when Karpenter add-on will be enabled in the Karpenter module)
        env = local.env
      }
    }
  }

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}
