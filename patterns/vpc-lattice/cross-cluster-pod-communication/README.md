
# Amazon VPC Lattice - Multi-cluster secure communication

This pattern showcases secure multi-cluster communication between two EKS cluster in different VPCs using VPC Lattice with IAM authorization. It illustrates service discovery and highlights how VPC Lattice facilitates communication between services in EKS clusters with overlapping CIDRs, eliminating the need for networking constructs like private NAT Gateways and Transit Gateways. 

## Scenario

With this solution we showcase how to configure Amazon VPC Lattice using the AWS Gateway API Controller in order to manage Amazon VPC Lattice resources through native K8S Gateway API objects. This pattern deploys two distinct VPCs each having it's own EKS cluster, which contain an application that will be used to demonstrate cross-cluster communication.

The cross-cluster communication will be established through Amazon VPC Lattice, using a private Amazon Route53 domain name protected by a TLS Certificate issued by Certificate Managed and supported by an AWS Private Certificate Authority.

![vpc-lattice-pattern-environment.png](https://raw.githubusercontent.com/aws-ia/terraform-aws-eks-blueprints/main/patterns/vpc-lattice/cross-cluster-pod-communication/assets/vpc-lattice-pattern-cross-cluster.png)



## Deploy

This pattern is composed of 3 Terraform stack, that needs to be deployed in order.

### 1. Create shared Environment

First, we need to deploy the shared environment: 

![vpc-lattice-pattern-environment.png](https://raw.githubusercontent.com/aws-ia/terraform-aws-eks-blueprints/main/patterns/vpc-lattice/cross-cluster-pod-communication/assets/vpc-lattice-pattern-environment.png)

Deploy terraform environment stack:

```bash
cd environment
terraform init
terraform apply --auto-approve
```

### 2. Create EKS cluster 1

Now we will deploy the 2 EKS clusters to match our architecture diagram

Deploy terrform cluster1 stack: 

```bash
cd ../cluster
./deploy.sh cluster1
```

Configure Kubectl:

```bash
eval `terraform output -raw configure_kubectl`
```

### 3. Create EKS cluster 2

Deploy terrform cluster2 stack: 

```bash
./deploy.sh cluster2
```

Configure Kubectl:

```bash
eval `terraform output -raw configure_kubectl`
```

## Validate

In order to validate the connectivity between our services, we can use the following commands:

1. from cluster1 app1, call cluster2 app2 -> success

```bash
kubectl --context eks-cluster1 exec -ti -n apps deployments/demo-cluster1-v1 -c demo-cluster1-v1 -- curl demo-cluster2.vpc-lattice-octank.io
```

```
Requsting to Pod(demo-cluster2-v1-c99c7bb69-2gm5f): Hello from demo-cluster2-v1
```

2. from cluster1 app1, call cluster1 app1 -> forbidden

We can see the response if we call the service but don't have the authorization from VPC lattice:

```bash
kubectl --context eks-cluster1 exec -ti -n apps deployments/demo-cluster1-v1 -c demo-cluster1-v1 -- curl demo-cluster1.vpc-lattice-octank.io
```

```
AccessDeniedException: User: arn:aws:sts::12345678910:assumed-role/vpc-lattice-ccpc-sigv4-client/eks-eks-cluste-demo-clust-1b575f8d-fb77-486a-8a13-af5a2a0f78ae is not authorized to perform: vpc-lattice-svcs:Invoke on resource: arn:aws:vpc-lattice:eu-west-1:12345678910:service/svc-002349360ddc5a463/ because no service-based policy allows the vpc-lattice-svcs:Invoke action 
```

This is because in the VPC lattice IAMAuth Policy of Application1 we only authorize call from namespace apps from cluster2:

```bash
kubectl --context eks-cluster1 get IAMAuthPolicy -n apps demo-cluster1-iam-auth-policy  -o json | jq ".spec.policy | fromjson"
```

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::12345678910:root"
      },
      "Action": "vpc-lattice-svcs:Invoke",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:PrincipalTag/eks-cluster-name": "eks-cluster2",
          "aws:PrincipalTag/kubernetes-namespace": "apps"
        }
      }
    }
  ]
}
```

2. from cluster2 app2, call cluster1 app1 -> success

We can also validate the reverse flow, from cluster2 to cluster1:

```bash
kubectl --context eks-cluster2 exec -ti -n apps deployments/demo-cluster2-v1 -c demo-cluster2-v1 -- curl demo-cluster1.vpc-lattice-octank.io
```

```
Requsting to Pod(demo-cluster1-v1-6d7558f5b4-zk5cg): Hello from demo-cluster1-v1
```

And again, what happen if the flow is not authorized:

```bash
kubectl --context eks-cluster2 exec -ti -n apps deployments/demo-cluster2-v1 -c demo-cluster2-v1 -- curl demo-cluster2.vpc-lattice-octank.io
```

```
AccessDeniedException: User: arn:aws:sts::12345678910:assumed-role/vpc-lattice-ccpc-sigv4-client/eks-eks-cluste-demo-clust-a5c2432b-b84a-492f-8cbc-16f1fa5053eb is not authorized to perform: vpc-lattice-svcs:Invoke on resource: arn:aws:vpc-lattice:eu-west-1:12345678910:service/svc-00b57f32ed0a7b7c3/ because no service-based policy allows the vpc-lattice-svcs:Invoke action<>
```

# Cleanup

## 1. We start by deleting the cluster2 terraform stack. 

> Note that we need to do this in order, so that our kubernetes controllers will be able to clean external resources before deleting the controller, and kubernetes nodes.

```bash
./destroy.sh cluster2
```

> If the VPC was not able to destroy, you may want to re-run the destroy command a second time

## 2. We can then delete the cluster1 terraform stack. 

```bash
./destroy.sh cluster1
```

> If the VPC was not able to destroy, you may want to re-run the destroy command a second time

## 3. Finally delete the environment terraform stack

```bash
cd ../environment
terraform destroy -auto-approve
```