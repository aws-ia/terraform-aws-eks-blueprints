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

kubectl get pods -n kube-system | grep fsx # Output of the FSx controller and node pods

kubectl get pvc -n emr-data-team-a  # Output of persistent volume for static(`fsx-static-pvc`) and dynamic(`fsx-dynamic-pvc`)

#FSx Storage Class
kubectl get storageclasses | grep fsx
  emr-eks-fsx-lustre   fsx.csi.aws.com         Delete          Immediate              false                  109s

# Output of static persistent volume with name `fsx-static-pv`
kubectl get pv | grep fsx
  fsx-static-pv                              1000Gi     RWX            Recycle          Bound    emr-data-team-a/fsx-static-pvc       fsx

# Output of static persistent volume with name `fsx-static-pvc` and `fsx-dynamic-pvc`
# Pending status means that the FSx for Lustre is still getting created. This will be changed to bound once the filesystem is created. Login to AWS console to verify.
kubectl get pvc -n emr-data-team-a | grep fsx
  fsx-dynamic-pvc   Pending                                             fsx            4m56s
  fsx-static-pvc    Bound     fsx-static-pv   1000Gi     RWX            fsx            4m56s

```

## Spark Job Execution - FSx - Static Provisioning

Execute Spark Job by using FSx for Lustre with statically provisioned volume
Execute the Spark job using the below shell script.

This script requires three input parameters which can be extracted from `terraform apply` output values

    EMR_VIRTUAL_CLUSTER_ID=$1     # Terraform output variable is emrcontainers_virtual_cluster_id
    S3_BUCKET=$2                  # This script requires s3 bucket as input parameter e.g., s3://<bucket-name>
    EMR_JOB_EXECUTION_ROLE_ARN=$3 # Terraform output variable is emr_on_eks_role_arn


Note: THis script downloads the test data to your local mac and uploads to S3 bucket. Verify the shell script for more details

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
kubectl exec -ti ny-taxi-trip-static-exec-1 -c spark-kubernetes-executor -n emr-data-team-a -- df -h

kubectl exec -ti ny-taxi-trip-static-exec-1 -c spark-kubernetes-executor -n emr-data-team-a -- ls -lah /static
```

## Spark Job Execution - FSx - Dynamic Provisioning

Execute Spark Job by using FSx for Lustre with dynamically provisioned volume and Fsx for Lustre file system
Execute the Spark job using the below shell script.


This script requires three input parameters which can be extracted from `terraform apply` output values

    EMR_VIRTUAL_CLUSTER_ID=$1     # Terraform output variable is emrcontainers_virtual_cluster_id
    S3_BUCKET=$2                  # This script requires s3 bucket as input parameter e.g., s3://<bucket-name>
    EMR_JOB_EXECUTION_ROLE_ARN=$3 # Terraform output variable is emr_on_eks_role_arn

Note: THis script downloads the test data to your local mac and uploads to S3 bucket. Verify the shell script for more details

```sh
cd examples/analytics/emr-eks-fsx-lustre/examples/spark-execute/

./fsx-dynamic-spark.sh "<ENTER_EMR_VIRTUAL_CLUSTER_ID>" "s3://<ENTER-YOUR-BUCKET-NAME>" "<EMR_JOB_EXECUTION_ROLE_ARN>"
```

Verify the job execution events

```sh
kubectl get pods --namespace=emr-data-team-a -w
```

```sh
kubectl exec -ti ny-taxi-trip-dynamic-exec-1 -c spark-kubernetes-executor -n emr-data-team-a -- df -h

kubectl exec -ti ny-taxi-trip-dynamic-exec-1 -c spark-kubernetes-executor -n emr-data-team-a -- ls -lah /dynamic
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

Make user all the S3 buckets are empty and deleted once your test is finished

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

## Issue2: Forbidden! Configured service account doesn't have access

Error:

    io.fabric8.kubernetes.client.KubernetesClientException: Failure executing: PATCH at: https://kubernetes.default.svc/api/v1/namespaces/emr-team-a/pods/createnosaprocessedactions-772b9c81ae56a93d-exec-394. Message: Forbidden!Configured service account doesn't have access. Service account may have been revoked. pods "createnosaprocessedactions-772b9c81ae56a93d-exec-394" is forbidden: User "system:serviceaccount:emr-team-a:emr-containers-sa-spark-driver-682942051493-76simz7hn0n7qw78flb3z0c1ldt10ou9nmbeg8sh29" cannot patch resource "pods" in API group "" in the namespace "emr-team-a".

##### Solution :
The following script patches the Kubernetes roles created by EMR job execution for given namespace.
This is a mandatory fix for `EMR6.6/Spark3.2` for missing permissions. This issue will be resolved in future release e.g., EMR6.7 and the patch script may not be required
Repeat the above tests after applying the patch. This script needs to be run for all the namespaces used by by EMR on EKS Jobs

```sh
cd examples/analytics/emr-eks-fsx-lustre/fsx_lustre
python3 emr-eks-sa-fix.py -n "emr-data-team-a"
```
