# Ray with Amazon EKS

This example deploys an EKS Cluster running the Ray Operator.

- Creates a new sample VPC, 3 Private Subnets and 3 Public Subnets
- Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
- Creates EKS Cluster Control plane with public endpoint (for demo reasons only) with one managed node group
- Deploys Ray Operator, AWS Load Balancer Controller, Ingress-nginx and External DNS add-ons
- Deploys a Ray Cluster in the `ray-cluster` namespace

## Prerequisites

Ensure that you have installed the following tools on your machine.

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
4. [python3](https://www.python.org/)
5. [jq](https://stedolan.github.io/jq/)

Additionally for end-to-end configuration of Ingress, this examples expects the following to be pre-configured.

1. A [Route53 Public Hosted Zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-configuring.html) configured in the account where you are deploying this example. E.g. "bar.com"
2. An [ACM Certificate](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html) in the account + region where you are deploying this example. A wildcard certificate is preferred, e.g. "*.bar.com"

## Deploy the EKS Cluster with Ray Operator

### Clone the repository

```sh
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

### Build Docker Image for Ray Cluster

First, in order to run the RayCluster, we need to push a container image to ECR repository that contains the all the dependencies. You can see the [Dockerfile](sample-job/Dockerfile) to see the python dependencies packaged in. The next series of steps we will setup an ECR repository, build the docker image for our model and push it to the ECR repository.

Create an ECR repository

```sh
aws ecr create-repository --repository-name ray-demo
```

Login to the ECR repository

```sh
aws ecr get-login-password \
  --region $AWS_REGION | docker login \
  --username AWS \
  --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ray-demo
```

Build the docker image containing our model deployment.

```sh
docker build sources -t $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ray-demo
```

Push the docker image to the ECR repo

```sh
docker push $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ray-demo
```

### Initialize Terraform

Navigate into the example directory and run `terraform init`

```sh
cd examples/ai-ml/ray/
terraform init
```

### Terraform Plan

Run Terraform plan to verify the resources created by this execution.

```sh
export AWS_REGION=<enter-your-region>
export ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')
export TF_VAR_eks_cluster_domain="bar.com"
export TF_VAR_acm_certificate_domain="*.bar.com"
terraform apply
```

### Deploy the pattern

```sh
terraform apply
```

Enter `yes` to apply.

### Verify Deployment

Update kubeconfig

```sh
aws eks update-kubeconfig --name ray
```

Verify all pods are running.

```sh
kubectl get pods -A

NAMESPACE       NAME                                            READY   STATUS    RESTARTS   AGE
external-dns    external-dns-99dd9564f-s7c4p                    1/1     Running   0          8h
ingress-nginx   ingress-nginx-controller-5756658855-6ctgt       1/1     Running   0          8h
kube-system     aws-load-balancer-controller-67b5dd7d69-rpxm4   1/1     Running   0          8h
kube-system     aws-load-balancer-controller-67b5dd7d69-znjj5   1/1     Running   0          8h
kube-system     aws-node-9wmbs                                  1/1     Running   0          9h
kube-system     aws-node-qj8rj                                  1/1     Running   0          9h
kube-system     aws-node-wlfbg                                  1/1     Running   0          9h
kube-system     coredns-7f5998f4c-9mwrr                         1/1     Running   0          9h
kube-system     coredns-7f5998f4c-wmd9m                         1/1     Running   0          9h
kube-system     kube-proxy-c8rrq                                1/1     Running   0          9h
kube-system     kube-proxy-hh965                                1/1     Running   0          9h
kube-system     kube-proxy-qlt9b                                1/1     Running   0          9h
ray-cluster     example-cluster-ray-head-j6vwh                  1/1     Running   0          8h
ray-cluster     example-cluster-ray-worker-jdkjd                1/1     Running   0          8h
ray-cluster     example-cluster-ray-worker-rwplm                1/1     Running   0          8h
ray-operator    ray-operator-5b985c9d77-4rtq6                   1/1     Running   0          8h
```

### Sample Jobs

#### Ray Serve - Summarize

As a sample deployment, we will use [Ray Serve](https://docs.ray.io/en/latest/serve/index.html) to deploy a sample machine learning model and expose it to the outside world via the Ingress configuration. The code for this deployment can be found [here](sources/hface_t5_summarize_serve.py). We use the [Hugging Face T5](https://huggingface.co/docs/transformers/model_doc/t5) model to serve an endpoint to summarize an arbitrary block of text. This model is deployed as Kubernetes [Job](sample-jobs/summarize-serve-job.yaml).

Create the Job to deploy the model to the Ray Cluster

```sh
envsubst < sample-jobs/summarize-serve-job.yaml | kubectl create -f -

job.batch/ray-summarize-job-cjdd8 created
```

Tail the logs of the job to verify successful deployment of the job.

```sh
kubectl logs -n ray-cluster ray-summarize-job-cjdd8-wmxm8 -f

Caught schedule exception
2022-07-08 17:03:29,579 INFO common.py:220 -- Exception from actor creation is ignored in destructor. To receive this exception in application code, call a method on the actor reference before its destructor is run.
(ServeController pid=458) INFO 2022-07-08 17:03:30,684 controller 458 checkpoint_path.py:17 - Using RayInternalKVStore for controller checkpoint and recovery.
(ServeController pid=458) INFO 2022-07-08 17:03:30,788 controller 458 http_state.py:115 - Starting HTTP proxy with name 'SERVE_CONTROLLER_ACTOR:SERVE_PROXY_ACTOR-node:10.0.12.204-0' on node 'node:10.0.12.204-0' listening on '0.0.0.0:8000'
(HTTPProxyActor pid=496) INFO:     Started server process [496]
(ServeController pid=458) INFO 2022-07-08 17:03:33,701 controller 458 deployment_state.py:1217 - Adding 1 replicas to deployment 'Summarizer'.
Downloading: 100%|██████████| 1.17k/1.17k [00:00<00:00, 2.04MB/s]
Downloading:   0%|          | 0.00/231M [00:00<?, ?B/s]
Downloading:   2%|▏         | 5.68M/231M [00:00<00:03, 59.5MB/s]
Downloading:   5%|▍         | 11.4M/231M [00:00<00:04, 47.3MB/s]
Downloading:   7%|▋         | 16.0M/231M [00:00<00:04, 45.2MB/s]
Downloading:   9%|▉         | 20.5M/231M [00:00<00:04, 45.9MB/s]
Downloading:  11%|█         | 25.8M/231M [00:00<00:04, 48.9MB/s]
Downloading:  13%|█▎        | 31.1M/231M [00:00<00:04, 51.2MB/s]
Downloading:  16%|█▌        | 36.4M/231M [00:00<00:03, 52.7MB/s]
Downloading:  18%|█▊        | 41.5M/231M [00:00<00:03, 52.7MB/s]
Downloading:  20%|██        | 46.6M/231M [00:00<00:03, 52.1MB/s]
Downloading:  22%|██▏       | 51.5M/231M [00:01<00:03, 51.5MB/s]
Downloading:  25%|██▍       | 56.6M/231M [00:01<00:03, 51.9MB/s]
Downloading:  27%|██▋       | 61.7M/231M [00:01<00:03, 52.3MB/s]
Downloading:  29%|██▉       | 66.9M/231M [00:01<00:03, 53.2MB/s]
Downloading:  31%|███       | 72.0M/231M [00:01<00:03, 51.1MB/s]
Downloading:  33%|███▎      | 76.9M/231M [00:01<00:03, 51.2MB/s]
Downloading:  36%|███▌      | 82.2M/231M [00:01<00:02, 52.5MB/s]
Downloading:  38%|███▊      | 87.3M/231M [00:01<00:02, 52.6MB/s]
Downloading:  40%|████      | 92.6M/231M [00:01<00:02, 53.5MB/s]
Downloading:  42%|████▏     | 97.7M/231M [00:01<00:02, 53.5MB/s]
Downloading:  45%|████▍     | 103M/231M [00:02<00:02, 54.2MB/s]
Downloading:  47%|████▋     | 108M/231M [00:02<00:02, 53.5MB/s]
Downloading:  49%|████▉     | 114M/231M [00:02<00:02, 54.3MB/s]
Downloading:  51%|█████▏    | 119M/231M [00:02<00:02, 54.6MB/s]
Downloading:  54%|█████▎    | 124M/231M [00:02<00:02, 54.8MB/s]
Downloading:  56%|█████▌    | 129M/231M [00:02<00:01, 54.2MB/s]
Downloading:  58%|█████▊    | 135M/231M [00:02<00:01, 54.7MB/s]
Downloading:  61%|██████    | 140M/231M [00:02<00:01, 54.2MB/s]
Downloading:  63%|██████▎   | 145M/231M [00:02<00:01, 53.2MB/s]
Downloading:  65%|██████▌   | 150M/231M [00:02<00:01, 53.9MB/s]
Downloading:  67%|██████▋   | 155M/231M [00:03<00:01, 44.7MB/s]
Downloading:  70%|██████▉   | 161M/231M [00:03<00:01, 48.3MB/s]
Downloading:  72%|███████▏  | 167M/231M [00:03<00:01, 51.2MB/s]
Downloading:  74%|███████▍  | 172M/231M [00:03<00:01, 52.3MB/s]
Downloading:  77%|███████▋  | 177M/231M [00:03<00:01, 50.8MB/s]
Downloading:  79%|███████▉  | 182M/231M [00:03<00:00, 52.2MB/s]
Downloading:  81%|████████▏ | 188M/231M [00:03<00:00, 53.2MB/s]
Downloading:  84%|████████▎ | 193M/231M [00:03<00:00, 54.2MB/s]
Downloading:  86%|████████▌ | 198M/231M [00:03<00:00, 53.9MB/s]
Downloading:  88%|████████▊ | 204M/231M [00:04<00:00, 53.6MB/s]
Downloading:  90%|█████████ | 209M/231M [00:04<00:00, 53.5MB/s]
Downloading:  93%|█████████▎| 214M/231M [00:04<00:00, 54.0MB/s]
Downloading:  95%|█████████▍| 219M/231M [00:04<00:00, 54.6MB/s]
Downloading:  97%|█████████▋| 225M/231M [00:04<00:00, 54.8MB/s]
Downloading: 100%|██████████| 231M/231M [00:04<00:00, 52.5MB/s]
Downloading: 100%|██████████| 773k/773k [00:00<00:00, 29.1MB/s]
Downloading: 100%|██████████| 1.32M/1.32M [00:00<00:00, 25.5MB/s]
```

##### Test Summarize Deployment

The client code uses python `requests` module to invoke the `/summarize` endpoint with a block of text. If all goes well, the endpoint should return summarized text of the block text submitted.

```sh
python sources/summarize_client.py

two astronauts steered their fragile lunar module safely and smoothly to the historic landing . the first men to reach the moon -- Armstrong and his co-pilot, col. Edwin E. Aldrin Jr. of the air force -- brought their ship to rest on a level, rock-strewn plain .
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
