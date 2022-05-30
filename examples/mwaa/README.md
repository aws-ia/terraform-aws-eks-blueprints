## Using Amazon MWAA with Amazon EKS

The example demonstrates how to use Amazon Managed Workflows for Apache Airflow (MWAA) with Amazon EKS.

This example was originated from the steps provided on MWAA documentation on the link below:
[mwaa-eks-example](https://docs.aws.amazon.com/mwaa/latest/userguide/mwaa-eks-example.html)

### Considerations

1. If you used a specific profile when you ran Terraform commands to create the kubeconfig(Line 225) you need to remove the env: section added to the dags/kube_config.yaml file so that it works correctly with Amazon MWAA. To do so, delete the following from the file and then save it:

env:
- name: AWS_PROFILE
  value: profile_name

Then you need to run terraform apply again.

2. Ideally we recommend adding the steps to sync requirements/sync dags to the MWAA S3 Bucket as part of a CI/CD pipeline. Generally Dags development have a different lifecycle than the Terraform code to provision infrastructure.
However for simplicity we are providing steps for that using Terraform running AWS CLI commands on null_resource.  

## How to Deploy

### Prerequisites:

Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Deployment Steps

#### Step 1: Clone the repo using the command below

```shell script
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

#### Step 2: Run Terraform INIT

Initialize a working directory with configuration files

```shell script
cd examples/mwaa/
terraform init
```

#### Step 3: Run Terraform PLAN

Verify the resources created by this execution

```shell script
export AWS_REGION=<ENTER YOUR REGION>   # Select your own region
terraform plan
```

#### Step 4: Finally, Terraform APPLY

to create resources

```shell script
terraform apply
```

Enter `yes` to apply

### Configure `kubectl` and test cluster

EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster.
This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### Step 5: Run `update-kubeconfig` command

`~/.kube/config` file gets updated with cluster details and certificate from the below command

    $ aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>

#### Step 6: List all the worker nodes by running the command below

    $ kubectl get nodes

#### Step 7: List all the pods running in `kube-system` namespace

    $ kubectl get pods -n kube-system

## How to Destroy

The following command destroys the resources created by `terraform apply`

```shell script
cd examples/mwaa
terraform destroy --auto-approve
```
