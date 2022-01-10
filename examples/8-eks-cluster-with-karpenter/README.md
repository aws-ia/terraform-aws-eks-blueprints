# EKS Cluster with Karpenter Cluster Autoscaler 

Karpenter is an open-source node provisioning project built for Kubernetes. Karpenter automatically launches just the right compute resources to handle your cluster's applications. It is designed to let you take full advantage of the cloud with fast and simple compute provisioning for Kubernetes clusters.

This example shows how to deploy and leverage Karpenter for Autoscaling. The following resources will be deployed by this example.

 - Creates a new VPC, 3 Private Subnets and 3 Public Subnets
 - Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
 - Creates EKS Cluster Control plane with one Self-managed node group with Max ASG of 1
 - Deploys Karpenter Helm Chart 

# How to Deploy
## Prerequisites:
Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
3. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
4. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deployment Steps
#### Step1: Clone the repo using the command below

```shell script
git clone https://github.com/aws-samples/aws-eks-accelerator-for-terraform.git
```

#### Step2: Run Terraform INIT
to initialize a working directory with configuration files

```shell script
cd examples/8-eks-cluster-with-karpenter/
terraform init
```

#### Step3: Run Terraform PLAN
to verify the resources created by this execution

```shell script
export AWS_REGION=<ENTER-YOUR-REGION>   # Select your own region
terraform plan
```

#### Step4: Finally, Terraform APPLY
to create resources

```shell script
terraform apply
```

Enter `yes` to apply

### Configure kubectl and test cluster
EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster. This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### Step5: Run update-kubeconfig command.
`~/.kube/config` file gets updated with cluster details and certificate from the below command

    $ aws eks --region eu-west-1 update-kubeconfig --name <cluster-name>

#### Step6: List all the worker nodes by running the command below
You should see one Self-managed node up and running

    $ kubectl get nodes

#### Step7: List all the pods running in karpenter namespace

    $ kubectl get pods -n karpenter
    
    # Output should look like below
      NAME                                    READY   STATUS    RESTARTS   AGE
      karpenter-controller-5f959cdc44-8dmjb   1/1     Running   0          31m
      karpenter-webhook-65f48f8d49-5hkpb      1/1     Running   0          31m
    
#### Step8: Deploy the default provisionar
Kaprpenter will be ready to spin up SPOT/ON-DEMAND nodes based on the provided configuraiton in `default_provisionar.yaml`

    $ cd examples/8-eks-cluster-with-karpenter/provisioners
    $ kubectl apply -f default_provisionar.yaml

#### Step9: Run this sample `deplolyment` to verify the Autoscaling triggered by Karpenter

    $ cd examples/8-eks-cluster-with-karpenter/provisioners
    $ kubectl apply -f sample_deployment.yaml


# How to Destroy
```shell script
cd examples/8-eks-cluster-with-karpenter
terraform destroy
```

<!--- BEGIN_TF_DOCS --->

<!--- END_TF_DOCS --->
