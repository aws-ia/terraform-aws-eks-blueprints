# Cell-Based Architecture for Amazon EKS

This pattern demonstrates how to configure a cell-based architecture for Amazon Elastic Kubernetes Service (Amazon EKS) workloads. It moves away from typical multiple Availability Zone (AZ) clusters to a single Availability Zone cluster. These single AZ clusters are called cells, and the aggregation of these cells in each Region is called a supercell. These cells help to ensure that a failure in one cell doesn't affect the cells in another, reducing data transfer costs and improving both the availability and resiliency against AZ wide failures for Amazon EKS workloads.

Refer to the [AWS Solution Guidance](https://aws.amazon.com/solutions/guidance/cell-based-architecture-for-amazon-eks/) for more details.

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) for the prerequisites. This pattern consists 1 VPC and 3 public & private subnets across 3 AZs. Also 3 Amazon EKS clusters are deployed, each in single AZ.

```bash
terraform init
terraform apply -target="module.vpc" -auto-approve
terraform apply -target="module.eks_az1" -auto-approve
terraform apply -target="module.eks_az2" -auto-approve
terraform apply -target="module.eks_az3" -auto-approve
terraform apply -auto-approve
```

## Validate

1. Export the necessary environment variables and update the local kubeconfig file.

```bash
export CELL_1=cell-based-eks-az1
export CELL_2=cell-based-eks-az2
export CELL_3=cell-based-eks-az3
export AWS_REGION=$(aws configure get region) #AWS region of the EKS clusters
export AWS_ACCOUNT_NUMBER=$(aws sts get-caller-identity --query "Account" --output text)
export SUBNET_ID_CELL1=$(terraform output -raw subnet_id_az1)
export SUBNET_ID_CELL2=$(terraform output -raw subnet_id_az2)
export SUBNET_ID_CELL3=$(terraform output -raw subnet_id_az3)
alias kgn="kubectl get node -o custom-columns='NODE_NAME:.metadata.name,READY:.status.conditions[?(@.type==\"Ready\")].status,INSTANCE-TYPE:.metadata.labels.node\.kubernetes\.io/instance-type,AZ:.metadata.labels.topology\.kubernetes\.io/zone,CAPACITY-TYPE:.metadata.labels.karpenter\.sh/capacity-type,VERSION:.status.nodeInfo.kubeletVersion,OS-IMAGE:.status.nodeInfo.osImage,INTERNAL-IP:.metadata.annotations.alpha\.kubernetes\.io/provided-node-ip'"
```

```bash
aws eks update-kubeconfig --name $CELL_1 --region $AWS_REGION --alias $CELL_1
aws eks update-kubeconfig --name $CELL_2 --region $AWS_REGION --alias $CELL_2
aws eks update-kubeconfig --name $CELL_3 --region $AWS_REGION --alias $CELL_3
```

2. Lets start our validation using Cell 1 which is running in AZ1. Verify the existing nodes are deployed to AZ1 (us-west-2a)

```bash
kgn --context ${CELL_1}
```
```output
NODE_NAME                                  READY   INSTANCE-TYPE   AZ           CAPACITY-TYPE   VERSION               OS-IMAGE         INTERNAL-IP
ip-10-0-12-83.us-west-2.compute.internal   True    m5.large        us-west-2a   <none>          v1.28.3-eks-e71965b   Amazon Linux 2   10.0.12.83
ip-10-0-7-191.us-west-2.compute.internal   True    m5.large        us-west-2a   <none>          v1.28.3-eks-e71965b   Amazon Linux 2   10.0.7.191
```

3. Deploy the necessary Karpenter resources like `EC2NodeClass`, `NodePool` and configure them to use AZ1 to launch any EC2 resources

```bash
sed -i'.bak' -e 's/SUBNET_ID_CELL1/'"${SUBNET_ID_CELL1}"'/g' az1.yaml

kubectl apply -f az1.yaml --context ${CELL_1}
```

4. Deploy a sample application `inflate` with 20 replicas and watch for Karpenter to launch the EC2 worker nodes in AZ1

```bash
kubectl apply -f inflate.yaml --context ${CELL_1}

kubectl wait --for=condition=ready pods --all --timeout 2m --context ${CELL_1}
```

5. List the EKS worker nodes to verify all of them are deployed to AZ1

```bash
kgn --context ${CELL_1}
```
```output
NODE_NAME                                   READY   INSTANCE-TYPE   AZ           CAPACITY-TYPE   VERSION               OS-IMAGE         INTERNAL-IP
ip-10-0-11-154.us-west-2.compute.internal   True    c7g.8xlarge     us-west-2a   spot            v1.28.3-eks-e71965b   Amazon Linux 2   10.0.11.154
ip-10-0-12-83.us-west-2.compute.internal    True    m5.large        us-west-2a   <none>          v1.28.3-eks-e71965b   Amazon Linux 2   10.0.12.83
ip-10-0-7-191.us-west-2.compute.internal    True    m5.large        us-west-2a   <none>          v1.28.3-eks-e71965b   Amazon Linux 2   10.0.7.191
```

6. Repeat the steps from 2 to 5 for Cell 2 and Cell 3 using --context $CELL_2, $CELL_3 respectively.

## Destroy

To teardown and remove the resources created in the pattern, the typical steps of execution are as follows:

```bash
terraform destroy -target="module.eks_blueprints_addons_az1" -auto-approve
terraform destroy -target="module.eks_blueprints_addons_az2" -auto-approve
terraform destroy -target="module.eks_blueprints_addons_az3" -auto-approve
terraform destroy -target="module.eks_az1" -auto-approve
terraform destroy -target="module.eks_az2" -auto-approve
terraform destroy -target="module.eks_az3" -auto-approve
terraform destroy -auto-approve
```
