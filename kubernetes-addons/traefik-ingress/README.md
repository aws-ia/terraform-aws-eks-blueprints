# Traefik Ingress Controller Deployment Guide

# Introduction

 Traefik is a modern HTTP reverse proxy and load balancer made to deploy microservices with ease. Fore more detials about [Traefik can be found here](https://doc.traefik.io/traefik/providers/kubernetes-ingress/)

# NOTE
 - Deployment Server should have access to Internet to fetch the Helm Charts from Public Repo.
 Alternatively you can sync public repo charts to your internal artifactory
 - By default, docker images for Helm chart pulled from Docker Hub which requires Internet access to your EKS Cluster.
 Alternatively, you can leverage internal aritifactory or Amazon ECR with private endpoints


# Helm Chart

### Instructions to use Helm Charts

Add Helm repo for Traefik Ingress Controller

    helm repo add traefik https://helm.traefik.io/traefik

    https://github.com/traefik/traefik-helm-chart/blob/v9.18.1/traefik/values.yaml

    https://artifacthub.io/packages/helm/traefik/traefik

# Steps to use ECR repo for Docker image

###### Instructions to upload Traefik Docker image to AWS ECR

Step1: Get the latest docker image from this link

        https://github.com/traefik/traefik

Step2: Download the docker image to your local Mac/Laptop

        $ docker pull traefik:v2.4.8

Step3: Retrieve an authentication token and authenticate your Docker client to your registry. Use the AWS CLI:

        $ aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <account id>.dkr.ecr.eu-west-1.amazonaws.com

Step4: Create an ECR repo for traefik controller if you don't have one

        $ aws ecr create-repository \
              --repository-name traefik \
              --image-scanning-configuration scanOnPush=true

Step5: After the build completes, tag your image so, you can push the image to this repository:

        $ docker tag traefik:v2.4.8 <accountid>.dkr.ecr.eu-west-1.amazonaws.com/traefik:v2.4.8

Step6: Run the following command to push this image to your newly created AWS repository:

        $ docker push <accountid>.dkr.ecr.eu-west-1.amazonaws.com/traefik:v2.4.8


##### How to test Traefik WebUI

Once the Traefik deployment is successful then run the below command from your mac where you have acces to EKS cluster using kubectl

    $ kubectl port-forward svc/traefik -n kube-system 9000:9000

Now open the browser from your mac and enter the below URL to access Traefik Web UI

    http://127.0.0.1:9000/dashboard/

![alt text](https://github.com/aws-samples/aws-eks-accelerator-for-terraform/blob/a8ceac6c977a3ccbcb95ef7fb21fff0daf0b7081/images/traefik_web_ui.png "Traefik Dashboard")

#### AWS Service annotations for Traefik Ingress Controller
Here is the link to get the AWS ELB [service annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/service/annotations/) for Traefik Ingress controller


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
SPDX-License-Identifier: MIT-0

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.traefik](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_traefik_helm_chart"></a> [traefik\_helm\_chart](#input\_traefik\_helm\_chart) | n/a | `any` | `{}` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
