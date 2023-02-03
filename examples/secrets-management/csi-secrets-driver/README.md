# EKS Cluster Deployment with new VPC

This example deploys the following Basic EKS Cluster with VPC

- Creates a new sample VPC, 3 Private Subnets and 3 Public Subnets
- Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
- Provisions AWS Secrets Manager and Config Provider for Secret Store CSI Driver
- Creates a namespace , IAM Roles for the service account, and the required CRDs required to retrieve the secrets for the application
- Deploys a sample pod to demonstrate mounting of secrets retrieved from AWS Secrets Manager as CSI Volume

## How to Deploy

### Prerequisites

Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

#### Secrets Management

1. Create the secrets in [AWS Secrets Manager] (https://docs.aws.amazon.com/secretsmanager/latest/userguide/managing-secrets.html)
2. Copy the ARN of the secrets and paste it under `secretsconfig.yaml` . `secretsconfig.yaml` represents `spec.parameters.objects` of [SecretProviderClass](https://docs.aws.amazon.com/secretsmanager/latest/userguide/integrating_csi_driver.html#integrating_csi_driver_SecretProviderClass) .

*Note* At this time, this example supports use cases which refers the secrets using 'A secret specified by full ARN'. If you refer the secret using name, the deployment will fail.

### Deployment Steps

#### Step1: Clone the repo using the command below

```shell script
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

#### Step2: Run Terraform INIT

Initialize a working directory with configuration files

```shell script
cd examples/secrets-management/csi-secrets-driver/
terraform init
```

#### Step3: Run Terraform PLAN

Verify the resources created by this execution

```shell script
terraform plan
```

#### Step4: Finally, Terraform APPLY

to create resources

```shell script
terraform apply
```

Enter `yes` to apply

### Configure `kubectl` and test cluster

EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster.
This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### Step5: Run `update-kubeconfig` command

`~/.kube/config` file gets updated with cluster details and certificate from the below command

```sh
aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>
```

#### Step6: View the `SecretProviderClass`

```sh
kubectl get SecretProviderClass -n <application>
```

#### Step7: Exec in the Pod to view the secrets getting mounted successfully

```sh
kubectl exec -it -n nginx pod/nginx-secrets-pod-sample bash
ls -ltr /mnt/secrets-store
```

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
