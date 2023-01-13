# GitLab Runner with Managed Node-groups

This example deploys a new EKS cluster, with the GitLab Runner installed. The example also deploys a GitLab project under the user's namespace. This project is a GitLab provided sample: https://gitlab.com/gitlab-org/ci-sample-projects/cicd-templates/android.latest.gitlab-ci.yml-test-project. The runner spawns pods on the managed node-group when a pipeline is triggered.

## How to Deploy

### Prerequisites:

Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
4. [GitLab account](https://gitlab.com)

### Deployment Steps

#### Step 1: Clone the repo using the command below

```sh
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

#### Step 2: Create a GitLab personal access token

From your GitHub profile page, select "Access Tokens". Create a token with "api" privileges. Export that token as the environment variable `GITLAB_TOKEN`:

```sh
export GITLAB_TOKEN=<token>
```

#### Step 3: Run Terraform INIT

Initialize a working directory with configuration files

```sh
cd examples/ci-cd/gitlab-runner-with-managed-node-groups
terraform init
```

#### Step 4: Run Terraform PLAN

Verify the resources created by this execution

```sh
export AWS_REGION=<ENTER YOUR REGION>   # Select your own region
terraform plan
```

#### Step 4: Finally, Terraform APPLY

**Deploy the pattern**

```sh
terraform apply
```

Enter `yes` to apply.

### Configure `kubectl` and test cluster

EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster.
This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### Step 5: Run `update-kubeconfig` command

`~/.kube/config` file gets updated with cluster details and certificate from the below command

    $ aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>

#### Step 6: List all the worker nodes by running the command below

    $ kubectl get nodes


#### Step 7: Trigger a pipeline build

In the GitLab UI find the project created under your profile. Trigger a pipeline with the "Run pipeline" button on the project's "CI/CD > Pipelines" page.


#### Step 7: List all the pods running in `gitlab-runner` namespace

    $ kubectl get pods -n gitlab-runner

## Cleanup

To clean up your environment, destroy the Terraform modules in reverse order.

Destroy the Kubernetes Add-ons, EKS cluster with Node groups and VPC

```sh
terraform destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
terraform destroy -target="module.eks_blueprints" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
```

Finally, destroy any additional resources that are not in the above modules

```sh
terraform destroy -auto-approve
```
