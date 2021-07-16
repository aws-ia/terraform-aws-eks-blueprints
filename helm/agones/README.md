# agones Helm Chart

###### Instructions to upload Agones Docker image to AWS ECR

Step1: Get the latest docker image from this link
        
        https://github.com/googleforgames/agones
        
Step2: Download the docker image to your local Mac/Laptop
        
        $ docker pull gcr.io/agones-images/agones-controller:1.15.0
        
Step3: Retrieve an authentication token and authenticate your Docker client to your registry. Use the AWS CLI:
        
        $ aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <account id>.dkr.ecr.eu-west-1.amazonaws.com
        
Step4: Create an ECR repo for Metrics Server if you don't have one 
    
        $ aws ecr create-repository --repository-name gcr.io/agones-images/agones-controller --image-scanning-configuration scanOnPush=true 
              
Step5: After the build completes, tag your image so, you can push the image to this repository:
        
        $ docker tag gcr.io/agones-images/agones-controller:1.15.0 <accountid>.dkr.ecr.eu-west-1.amazonaws.com/gcr.io/agones-images/agones-controller:1.15.0

Step6: Run the following command to push this image to your newly created AWS repository:
        
        $ docker push <accountid>.dkr.ecr.eu-west-1.amazonaws.com/gcr.io/agones-images/agones-controller:1.15.0

### Instructions to download Helm Charts

Helm Chart
    
    https://artifacthub.io/packages/helm/agones/agones

Helm Repo Maintainers

    https://github.com/googleforgames/agones/tree/main/install/helm/agones


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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.49.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.2.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.3.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_security_group_rule.agones_sg_ingress_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [helm_release.agones](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace.agones](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.pc](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.xbox](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [aws_security_group.eks_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | n/a | `any` | n/a | yes |
| <a name="input_eks_sg_id"></a> [eks\_sg\_id](#input\_eks\_sg\_id) | n/a | `any` | n/a | yes |
| <a name="input_expose_udp"></a> [expose\_udp](#input\_expose\_udp) | n/a | `bool` | `false` | no |
| <a name="input_gameserver_maxport"></a> [gameserver\_maxport](#input\_gameserver\_maxport) | n/a | `number` | `8000` | no |
| <a name="input_gameserver_minport"></a> [gameserver\_minport](#input\_gameserver\_minport) | n/a | `number` | `7000` | no |
| <a name="input_image_repo_name"></a> [image\_repo\_name](#input\_image\_repo\_name) | n/a | `string` | `"gcr.io/agones-images"` | no |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | n/a | `string` | `"1.15.0"` | no |
| <a name="input_private_container_repo_url"></a> [private\_container\_repo\_url](#input\_private\_container\_repo\_url) | n/a | `any` | n/a | yes |
| <a name="input_public_docker_repo"></a> [public\_docker\_repo](#input\_public\_docker\_repo) | n/a | `any` | n/a | yes |
| <a name="input_s3_nlb_logs"></a> [s3\_nlb\_logs](#input\_s3\_nlb\_logs) | n/a | `any` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

