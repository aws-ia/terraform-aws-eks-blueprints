# EMR EKS with FSx for Lustre 

This example deploys the following resources

- Creates EKS Cluster Control plane with public endpoint (for demo purpose only) with two managed node groups
- Deploys Metrics server with HA, Cluster Autoscaler, Prometheus, VPA, CoreDNS Autoscaler, FSx CSI driver
- EMR on EKS Teams and EMR Virtual cluster for `emr-data-team-a`
- Creates Amazon managed Prometheus Endpoint and configures Prometheus Server addon with remote write configuration to Amazon Managed Prometheus
- Creates PERSISTENT type FSx for Lustre filesystem, Static Persistent volume and Persistent volume claim
- Creates Scratch type FSx for Lustre filesystem with dynamic Persistent volume claim
- S3 bucket to sync FSx for Lustre filesystem data

## Prerequisites:

Ensure that you have installed the following tools on your machine.

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

_Note: Currently Amazon Managed Prometheus supported only in selected regions. Please see this [userguide](https://docs.aws.amazon.com/prometheus/latest/userguide/what-is-Amazon-Managed-Service-Prometheus.html) for supported regions._

## Deploy EKS Clusters with EMR on EKS feature

Clone the repository

```sh
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

Navigate into one of the example directories and run `terraform init`

```sh
cd examples/analytics/emr-eks-fsx-lustre
terraform init
```

Set AWS_REGION and Run Terraform plan to verify the resources created by this execution.

```sh
export AWS_REGION="<enter-your-region>"
terraform plan
```

**Deploy the pattern**

```sh
terraform apply
```

Enter `yes` to apply.

## Verify the resources

Let’s verify the resources created by Step 4.

Verify the Amazon EKS Cluster and Amazon Managed service for Prometheus

```sh
aws eks describe-cluster --name emr-eks-fsx-lustre

aws amp list-workspaces --alias amp-ws-emr-eks-fsx-lustre
```

```sh
# Verify EMR on EKS Namespaces emr-data-team-a and emr-data-team-b and Pod status for Prometheus, Vertical Pod Autoscaler, Metrics Server and Cluster Autoscaler.

aws eks --region <ENTER_YOUR_REGION> update-kubeconfig --name emr-eks-fsx-lustre # Creates k8s config file to authenticate with EKS Cluster

kubectl get nodes # Output shows the EKS Managed Node group nodes

kubectl get ns | grep emr-data-team # Output shows emr-data-team-a and emr-data-team-b namespaces for data teams

kubectl get pods --namespace=prometheus # Output shows Prometheus server and Node exporter pods

kubectl get pods --namespace=vpa  # Output shows Vertical Pod Autoscaler pods

kubectl get pods --namespace=kube-system | grep  metrics-server # Output shows Metric Server pod

kubectl get pods --namespace=kube-system | grep  cluster-autoscaler # Output shows Cluster Autoscaler pod

kubectl get pvc -n emr-data-team-a  # Output of persistent volume for static(`fsx-static-pvc`) and dynamic(`fsx-dynamic-pvc`)

kubectl get storageclasses  # Output of storage class with the name `emr-eks-fsx-lustre` 

kubectl get pv              # Output of static persistent volume with name `fsx-static-pv`
``` 

## Spark Job Execution - FSx - Static Provisioning

Execute Spark Job by using FSx for Lustre with statically provisioned volume
Execute the Spark job using the below shell script.

This script requires three input parameters which can be extracted from `terraform apply` output values

    EMR_VIRTUAL_CLUSTER_ID=$1     # Terraform output variable is emrcontainers_virtual_cluster_id
    S3_BUCKET=$2                  # This script requires s3 bucket as input parameter e.g., s3://<bucket-name>
    EMR_JOB_EXECUTION_ROLE_ARN=$3 # Terraform output variable is emr_on_eks_role_arn

```sh
cd examples/analytics/emr-eks-fsx-lustre/examples/spark-execute/

./fsx-static-spark.sh "<ENTER_EMR_VIRTUAL_CLUSTER_ID>" "s3://<ENTER-YOUR-BUCKET-NAME>" "<EMR_JOB_EXECUTION_ROLE_ARN>"
```

Verify the job execution events

```sh
kubectl get pods --namespace=emr-data-team-a -w
```
This will show the mounted `/data` directory with FSx DNS name

```sh
kubectl exec -ti <executor-pod-name> -c spark-kubernetes-executor -n emr-data-team-a -- df -h
```

## Spark Job Execution - FSx - Dynamic Provisioning

Execute Spark Job by using FSx for Lustre with dynamically provisioned volume
Execute the Spark job using the below shell script.

This script requires three input parameters which can be extracted from `terraform apply` output values

    EMR_VIRTUAL_CLUSTER_ID=$1     # Terraform output variable is emrcontainers_virtual_cluster_id
    S3_BUCKET=$2                  # This script requires s3 bucket as input parameter e.g., s3://<bucket-name>
    EMR_JOB_EXECUTION_ROLE_ARN=$3 # Terraform output variable is emr_on_eks_role_arn

```sh
cd examples/analytics/emr-eks-fsx-lustre/examples/spark-execute/

./fsx-dynamic-spark.sh "<ENTER_EMR_VIRTUAL_CLUSTER_ID>" "s3://<ENTER-YOUR-BUCKET-NAME>" "<EMR_JOB_EXECUTION_ROLE_ARN>"
```

Verify the job execution events

```sh
kubectl get pods --namespace=emr-data-team-a -w
```
This will show the mounted `/data` directory with FSx DNS name

```sh
kubectl exec -ti <executor-pod-name> -c spark-kubernetes-executor -n emr-data-team-a -- df -h
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

## Debugging
##### Issue1: Error: local-exec provisioner error

```sh
Error: local-exec provisioner error \
with module.eks-blueprints.module.emr_on_eks["data_team_b"].null_resource.update_trust_policy,\
 on .terraform/modules/eks-blueprints/modules/emr-eks-fsx-lustre/main.tf line 105, in resource "null_resource" \
 "update_trust_policy":│ 105: provisioner "local-exec" {│ │ Error running command 'set -e│ │ aws emr-containers update-role-trust-policy \
 │ --cluster-name emr-eks-fsx-lustre \│ --namespace emr-data-team-b \│ --role-name emr-eks-fsx-lustre-emr-eks-data-team-b
```

##### Solution :

- emr-containers not present in cli version 2.0.41 Python/3.7.4. For more [details](https://github.com/aws/aws-cli/issues/6162)
  This is fixed in version 2.0.54.
- Action: aws cli version should be updated to 2.0.54 or later : Execute `pip install --upgrade awscliv2 `
