# kube-state-metrics Helm Chart

#Introduction
kube-state-metrics is a  service that listens to the Kubernetes API server and generates metrics about the state of the objects

# Helm Chart

### Instructions to use Helm Charts

    helm repo add bitnami https://charts.bitnami.com/bitnami
    https://github.com/bitnami/bitnami-docker-kube-state-metrics
    https://artifacthub.io/packages/helm/bitnami/kube-state-metrics

###### Instructions to upload kube-state-metrics Docker image to AWS ECR
# Docker Image
        
Step1: Download the docker image to your local Mac/Laptop
        
        $ docker pull bitnami/kube-state-metrics:2.1.0 
        
Step2: Retrieve an authentication token and authenticate your Docker client to your registry. Use the AWS CLI:
        
        $ aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <account id>.dkr.ecr.eu-west-1.amazonaws.com
        
Step3: Create an ECR repo for kube-state-metrics if you don't have one 
    
         $ aws ecr create-repository --repository-name  bitnami/kube-state-metrics--image-scanning-configuration scanOnPush=true 
              
Step4: After the build completes, tag your image so, you can push the image to this repository:
        
        $ docker tag bitnami/kube-state-metrics:2.1.0 <account id>.dkr.ecr.eu-west-1.amazonaws.com/bitnami/kube-state-metrics:2.1.0

Step5: Run the following command to push this image to your newly created AWS repository:
        
        $ docker push <accountid>.dkr.ecr.eu-west-1.amazonaws.com/bitnami/kube-state-metrics:2.1.0 


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
| [helm_release.kube-state-metrics](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_image_repo_name"></a> [image\_repo\_name](#input\_image\_repo\_name) | n/a | `string` | `"bitnami/kube-state-metrics"` | no |
| <a name="input_kube_state_metrics_helm_chart_version"></a> [kube\_state\_metrics\_helm\_chart\_version](#input\_kube\_state\_metrics\_helm\_chart\_version) | n/a | `any` | n/a | yes |
| <a name="input_kube_state_metrics_image_tag"></a> [kube\_state\_metrics\_image\_tag](#input\_kube\_state\_metrics\_image\_tag) | n/a | `any` | n/a | yes |
| <a name="input_private_container_repo_url"></a> [private\_container\_repo\_url](#input\_private\_container\_repo\_url) | n/a | `any` | n/a | yes |
| <a name="input_public_docker_repo"></a> [public\_docker\_repo](#input\_public\_docker\_repo) | n/a | `any` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

