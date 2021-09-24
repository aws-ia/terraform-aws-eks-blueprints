# Nginx Ingress Controller Deployment Guide

# Introduction

 Nginx ingress is a modern HTTP reverse proxy and load balancer made to deploy microservices with ease. Fore more detials about [Ingress-Nginx can be found here](https://kubernetes.github.io/ingress-nginx/)
 
# Helm Chart

### Instructions to use Helm Charts

Add Helm repo for Nginx Ingress Controller

    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

    https://github.com/kubernetes/ingress-nginx/blob/master/charts/ingress-nginx/values.yaml

    https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx

# Docker Image for nginx ingress controller.

###### Instructions to upload Ingress Nginx Docker image to AWS ECR

        
Step1: Download the docker image to your local Mac/Laptop
        
        $ docker pull ingress-nginx/controller:v0.47.0
        
Step2: Retrieve an authentication token and authenticate your Docker client to your registry. Use the AWS CLI:
        
        $ aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <account id>.dkr.ecr.eu-west-1.amazonaws.com
        
Step3: Create an ECR repo for Ingress Nginx Controller if you don't have one 
    
        $ aws ecr create-repository \
              --repository-name nginx-ingress \
              --image-scanning-configuration scanOnPush=true 
              
Step4: After the build completes, tag your image so, you can push the image to this repository:
        
        $ docker tag nginx-ingress:v <accountid>.dkr.ecr.eu-west-1.amazonaws.com/nginx-ingress:v0.47.0
        
Step5: Run the following command to push this image to your newly created AWS repository:
        
        $ docker push <accountid>.dkr.ecr.eu-west-1.amazonaws.com/nginx-ingress:v0.47.0



#### AWS Service annotations for Nginx Ingress Controller
Here is the link to get the AWS ELB [service annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/service/annotations/) for Nginx Ingress controller


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
| [helm_release.nginx](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | n/a | `any` | n/a | yes |
| <a name="input_image_repo_name"></a> [image\_repo\_name](#input\_image\_repo\_name) | n/a | `string` | `"ingress-nginx/controller"` | no |
| <a name="input_nginx_helm_chart_version"></a> [nginx\_helm\_chart\_version](#input\_nginx\_helm\_chart\_version) | n/a | `any` | n/a | yes |
| <a name="input_nginx_image_tag"></a> [nginx\_image\_tag](#input\_nginx\_image\_tag) | n/a | `any` | n/a | yes |
| <a name="input_private_container_repo_url"></a> [private\_container\_repo\_url](#input\_private\_container\_repo\_url) | n/a | `any` | n/a | yes |
| <a name="input_public_docker_repo"></a> [public\_docker\_repo](#input\_public\_docker\_repo) | n/a | `any` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->




