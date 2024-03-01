# Istio multi-primary on different networks on EKS

## Business Use Case for Istio Multi-Cluster

**Global Scalability:** Multi-cluster Istio on Amazon EKS allows businesses to scale services globally, ensuring that infrastructure can grow with the demands of international markets.

**Service Isolation:** Services are isolated within clusters, enhancing stability and minimizing the risk of widespread system failures.

**Localized Compliance:** Adherence to regional data protection laws is simplified by deploying services in appropriate AWS regions.

**High Availability:** Geographic distribution of clusters on AWS enhances service availability and reliability.

**Performance Optimization:** Service latency is reduced by deploying clusters closer to users, with Istio managing efficient traffic routing.

**Operational Simplicity:** Istio streamlines complex operations across clusters, providing a unified approach to traffic management, policy enforcement, and monitoring.

**Resilience to Failures:** Multiple clusters act as separate failure domains, ensuring that an issue in one cluster doesn’t impact the overall service availability.

**Data Sovereignty:** Multi-cluster architecture supports data sovereignty requirements by keeping data within the borders of the required jurisdiction.

**Cost-Effective Infrastructure:** AWS's diverse resource offerings enable cost optimization strategies without compromising service quality.

## Istio Multi-Cluster Architecture on Amazon EKS
![Istio Multi-Cluster Architecture](images/istio-multi-cluster-architecture.png "Istio Multi-Cluster Architecture on Amazon EKS")


## Prerequisites

Ensure that you have installed the following tools locally:

1. [awscli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
4. [istioctl](https://istio.io/latest/docs/ops/diagnostic-tools/istioctl/)

## Deploy 

To deploy the terraform repo, run the commands shown below:
```sh 
terraform init

terraform apply --auto-approve \
    -target=module.vpc_1 \
    -target=module.vpc_2 \
    -target=module.eks_1 \
    -target=module.eks_2 \
    -target=kubernetes_secret.cacerts_cluster1 \
    -target=kubernetes_secret.cacerts_cluster2 

terraform apply --auto-approve \
    -target="module.eks_1_addons.helm_release.this[\"istiod\"]" \
    -target="module.eks_2_addons.helm_release.this[\"istiod\"]" \
    -target=module.eks_1_addons.module.aws_load_balancer_controller \
    -target=module.eks_2_addons.module.aws_load_balancer_controller 

terraform apply --auto-approve 
```

After running the command successfully, set the kubeconfig for both EKS clusters:
```sh 
aws eks update-kubeconfig --region us-west-2 --name eks-1
aws eks update-kubeconfig --region us-west-2 --name eks-2
CTX_CLUSTER1=`aws eks describe-cluster --name eks-1 | jq -r '.cluster.arn'`
CTX_CLUSTER2=`aws eks describe-cluster --name eks-2 | jq -r '.cluster.arn'`
```

## Testing

### Readiness of the Istio Gateway loadbalancers

Before you could do any testing, you need to ensure that:
* The loadbalancer for `istio-eastwestgateway` service is ready for the traffic 
* The loadblanncer target groups have their targets ready. 

Use the following scripts to test the readiness of the LBs.
> Note: Change the k8s context to run it against the other cluster
```sh 
EW_LB_NAME=$(k get svc istio-eastwestgateway -n istio-ingress --context $CTX_CLUSTER1 -o=jsonpath='{.status.loadBalancer.ingress[0].hostname}')

EW_LB_ARN=$(aws elbv2 describe-load-balancers | \
jq -r --arg EW_LB_NAME "$EW_LB_NAME" \
'.LoadBalancers[] | select(.DNSName == $EW_LB_NAME) | .LoadBalancerArn')

TG_ARN=$(aws elbv2 describe-listeners --load-balancer-arn $EW_LB_ARN | jq -r '.Listeners[] | select(.Port == 15443) | .DefaultActions[0].TargetGroupArn')

aws elbv2 describe-target-health --target-group-arn $TG_ARN | jq -r '.TargetHealthDescriptions[0]'
```

You should see an output similar to below before proceeding any further:
```
{
  "Target": {
    "Id": "10.1.0.227",
    "Port": 15443,
    "AvailabilityZone": "us-west-2a"
  },
  "HealthCheckPort": "15443",
  "TargetHealth": {
    "State": "healthy"
  }
}
```

### Cross-Cluster Sync

Run the following commands to ensure that the public Load Balancer IP addresses 
are displayed in the output as shown. 

> Note: Change the k8s context to run it against the other cluster

```sh 
POD_NAME=$(kubectl get pod --context="${CTX_CLUSTER1}" -l app=sleep -o jsonpath='{.items[0].metadata.name}' -n sample)

istioctl --context $CTX_CLUSTER1 proxy-config endpoint $POD_NAME -n sample | grep helloworld
```

The output should be similar to:
```
10.1.8.162:5000                                         HEALTHY     OK                outbound|5000||helloworld.sample.svc.cluster.local
100.21.48.49:15443                                      HEALTHY     OK                outbound|5000||helloworld.sample.svc.cluster.local
34.209.120.99:15443                                     HEALTHY     OK                outbound|5000||helloworld.sample.svc.cluster.local
52.36.169.59:15443                                      HEALTHY     OK                outbound|5000||helloworld.sample.svc.cluster.local
```

If you do public IP addresses in the output proceed further to test multi-cluster 
communication.

### Cross-cluster Load-Balancing 

Run the following command to check cross-cluster loadbalancing from the first cluster.

```
for i in {1..10}
do 
kubectl exec --context="${CTX_CLUSTER1}" -n sample -c sleep \
    "$(kubectl get pod --context="${CTX_CLUSTER1}" -n sample -l \
    app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- curl -sS helloworld.sample:5000/hello
done
```
Also test similar command to check cross-cluster loadbalancing from the second cluster.

```
for i in {1..10}
do 
kubectl exec --context="${CTX_CLUSTER2}" -n sample -c sleep \
    "$(kubectl get pod --context="${CTX_CLUSTER2}" -n sample -l \
    app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- curl -sS helloworld.sample:5000/hello
done
```

In either case the output should be similar to:

```
Hello version: v1, instance: helloworld-v1-867747c89-7vzwl
Hello version: v2, instance: helloworld-v2-7f46498c69-5g9rk
Hello version: v1, instance: helloworld-v1-867747c89-7vzwl
Hello version: v1, instance: helloworld-v1-867747c89-7vzwl
Hello version: v2, instance: helloworld-v2-7f46498c69-5g9rk
Hello version: v1, instance: helloworld-v1-867747c89-7vzwl
Hello version: v2, instance: helloworld-v2-7f46498c69-5g9rk
Hello version: v1, instance: helloworld-v1-867747c89-7vzwl
Hello version: v1, instance: helloworld-v1-867747c89-7vzwl
Hello version: v2, instance: helloworld-v2-7f46498c69-5g9rk
```

## Destroy 
```sh 
# Remove all the Helm installs first, this ensures that all the Load Balancers
# are cleanly destroyed before removing other infrastructure
terraform destroy --auto-approve \
    -target=module.eks_1_addons.helm_release.this \
    -target=module.eks_2_addons.helm_release.this \
    -target=helm_release.multicluster_deploy_1 \
    -target=helm_release.multicluster_deploy_2

# Remove all the rest 
terraform destroy --auto-approve
```

## Troubleshooting

There are many things that can go wrong when deploying a complex solutions such 
as this, Istio multi-primary on different networks.

### Ordering in Terraform deployment

The ordering is important when deploying the resources with Terraform and here 
it is:
1. Deploy the VPCs and EKS clusters 
2. Deploy the `cacerts` secret in the `istio-system` namespace in both clusters
4. Deploy the control plane `istiod` in both clusters
5. Deploy the rest of the resources, including Helm Chart `multicluster-deploy`
in both clusters. 

The `multicluster-deploy` Helm chart includes the following key resources:
1. `Deployment`, `Service Account` and `Service` definitions for `sleep` app
2. `Deployment` and `Service` definitions for `helloworld` app
3. Static `Gateway` definition of `cross-network-gateway` in `istio-ingress` namespace 
4. Templated `Secret` definition of `istio-remote-secret-*`



## Documentation Links 

1. [Install Multi-Primary on different networks](https://istio.io/latest/docs/setup/install/multicluster/multi-primary_multi-network/)
2. [Verifying cross-cluster traffic](https://istio.io/latest/docs/setup/install/multicluster/verify/#verifying-cross-cluster-traffic)
3. [Multicluster Troubleshooting](https://istio.io/latest/docs/ops/diagnostic-tools/multicluster/)
