# Application Networking with Amazon VPC Lattice and Amazon EKS

This pattern demonstrates where a service in one EKS cluster communicates with a service in another cluster and VPC, using VPC Lattice. Besides it also shows how service discovery works, with support for using custom domain names for services. It also demonstrates how VPC Lattice enables services in EKS clusters with overlapping CIDRs to communicate with each other without the need for any networking constructs like private NAT Gateways and Transit Gateways.

- [Documentation](https://aws.amazon.com/vpc/lattice/)
- [Launch Blog](https://aws.amazon.com/blogs/containers/amazon-vpc-cni-now-supports-kubernetes-network-policies/)

## Scenario

The solution architecture used to demonstrate cross-cluster connectivity with VPC Lattice is shown in the following diagram. The following are the relevant aspects of this architecture.

1. Two VPCs are setup in the same AWS Region, both using the same RFC 1918 address range 192.168.48.0/20
2. An EKS cluster is provisioned in each of the VPC. 
3. An HTTP web service is deployed to the EKS cluster in Cluster1-vpc , exposing a set of REST API endpoints. Another REST API service is deployed to the EKS cluster in Cluster2-vpc and it communicates with an Aurora PostgreSQL database in the same VPC.
AWS Gateway API controller is used in both clusters to manage the Kubernetes Gateway API resources such as Gateway and HTTPRoute. These custom resources orchestrate AWS VPC Lattice resources such as Service Network, Service, and Target Groups that enable communication between the Kubernetes services deployed to the clusters.

![img.png](img/img.png)

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

1. set up the first cluster with its own VPC and the second with an aurora postgres DB 

```shell
   # setting up the cluster1
   cd cluster1
   terraform init
   terraform apply
   
   cd ../cluster2
   terraform init
   terraform apply
```

2. Initialize the aurora postgres database for cluster2 vpc refer [here](./cluster2/postgres-setup/README.md)
3. Initialize Kubernetes secrets for cluster2

```shell
# assuming you are already in the /cluster2 folder
chmod +x secrets.sh && ./secrets.sh
```
4. Deploy the kubernetes artefacts for cluster2 

Deploy the datastore service to the EKS cluster in cluster2. This service fronts an Aurora PostgreSQL database and exposes REST API endpoints with path-prefixes /popular and /summary. To demonstrate canary shifting of traffic, deploy two versions of the datastore service to the cluster as shown below.

```shell
# Apply Kubernetes set of manifests to both clusters that defines the GatewayClass and Gateway resources. The Gateway API controller then creates a Lattice service network with the same name, eks-lattice-network, as that of the Gateway resource if one doesn’t exist and attaches the VPCs to the service network.
export CLUSTER_2=cluster2
export AWS_DEFAULT_REGION=$(aws configure get region)
export AWS_ACCOUNT_NUMBER=$(aws sts get-caller-identity --query "Account" --output text)

export CTX_CLUSTER_2=arn:aws:eks:$AWS_DEFAULT_REGION:${AWS_ACCOUNT_NUMBER}:cluster/$CLUSTER_2


kubectl apply --context="${CTX_CLUSTER_2}" -f ./$CLUSTER_2/gateway-lattice.yml          # GatewayClass and Gateway
kubectl apply --context="${CTX_CLUSTER_2}" -f ./$CLUSTER_2/route-datastore-canary.yml   # HTTPRoute and ClusterIP Services
kubectl apply --context="${CTX_CLUSTER_2}" -f ./$CLUSTER_2/datastore.yml                # Deployment
```

5. Deploy the gateway lattice and the frontend service on cluster1

The frontend service is configured to communicate with the datastore service in cluster1 using its custom domain name. 

```shell
export CLUSTER_1=cluster1
export AWS_DEFAULT_REGION=$(aws configure get region)
export AWS_ACCOUNT_NUMBER=$(aws sts get-caller-identity --query "Account" --output text)

aws eks update-kubeconfig --name $CLUSTER_1 --region $AWS_DEFAULT_REGION

export CTX_CLUSTER_1=arn:aws:eks:$AWS_DEFAULT_REGION:${AWS_ACCOUNT_NUMBER}:cluster/$CLUSTER_1


kubectl apply --context="${CTX_CLUSTER_1}" -f ./$CLUSTER_1/gateway-lattice.yml   # GatewayClass and Gateway
kubectl apply --context="${CTX_CLUSTER_1}" -f ./$CLUSTER_1/frontend.yml  # Frontend service
```

## Testing if cluster1 service could talk to cluster2 service via VPC lattice 

Shell commands below uses kubectl port-forward to forward outgoing traffic from a local port to the server port 3000 on one of the pods of the frontend service, which allows us to test this use case end-to-end without needing any load balancer.

```shell
POD=$(kubectl -context="${CTX_CLUSTER_1}" get pod -n apps -l app=frontend -o jsonpath="{.items[0].metadata.name}")
kubectl -context="${CTX_CLUSTER_1}" -n apps port-forward ${POD} 80:3000 # Port Forwarding

curl -X GET http://localhost/popular/category|jq
curl -X GET http://localhost/summary|jq # you could retry the summary to see if you get a different results from different versions

```

## Destroy

To teardown and remove the resources created in this example:

```shell
cd cluster1
terraform apply -destroy -autoapprove
cd ../cluster2
terraform apply -destroy -autoapprove
```
