# aws-for-fluent-bit Helm Chart

###### Instructions to upload aws-for-fluent-bit Docker image to AWS ECR

Step1: Get the latest docker image from this link
        
        https://github.com/aws/aws-for-fluent-bit
        
Step2: Download the docker image to your local Mac/Laptop
        
        $ docker pull amazon/aws-for-fluent-bit:2.13.0
        
Step3: Retrieve an authentication token and authenticate your Docker client to your registry. Use the AWS CLI:
        
        $ aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <account id>.dkr.ecr.eu-west-1.amazonaws.com
        
Step4: Create an ECR repo for Metrics Server if you don't have one 
    
        $ aws ecr create-repository --repository-name amazon/aws-for-fluent-bit --image-scanning-configuration scanOnPush=true 
              
Step5: After the build completes, tag your image so, you can push the image to this repository:
        
        $ docker tag amazon/aws-for-fluent-bit:2.13.0 <accountid>.dkr.ecr.eu-west-1.amazonaws.com/amazon/aws-for-fluent-bit:2.13.0

Step6: Run the following command to push this image to your newly created AWS repository:
        
        $ docker push <accountid>.dkr.ecr.eu-west-1.amazonaws.com/amazon/aws-for-fluent-bit:2.13.0

### Instructions to download Helm Charts

#### Helm Chart
    
    https://artifacthub.io/packages/helm/aws/aws-for-fluent-bit

Helm Repo Maintainers

    https://github.com/aws/eks-charts


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
| [aws_cloudwatch_log_group.eks-worker-logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [helm_release.aws-for-fluent-bit](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace.logging](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_for_fluent_bit_helm_chart_version"></a> [aws\_for\_fluent\_bit\_helm\_chart\_version](#input\_aws\_for\_fluent\_bit\_helm\_chart\_version) | n/a | `string` | `"0.1.11"` | no |
| <a name="input_aws_for_fluent_bit_image_tag"></a> [aws\_for\_fluent\_bit\_image\_tag](#input\_aws\_for\_fluent\_bit\_image\_tag) | n/a | `string` | `"2.13.0"` | no |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | n/a | `any` | n/a | yes |
| <a name="input_ekslog_retention_in_days"></a> [ekslog\_retention\_in\_days](#input\_ekslog\_retention\_in\_days) | n/a | `any` | n/a | yes |
| <a name="input_image_repo_name"></a> [image\_repo\_name](#input\_image\_repo\_name) | n/a | `string` | `"amazon/aws-for-fluent-bit"` | no |
| <a name="input_private_container_repo_url"></a> [private\_container\_repo\_url](#input\_private\_container\_repo\_url) | n/a | `any` | n/a | yes |
| <a name="input_public_docker_repo"></a> [public\_docker\_repo](#input\_public\_docker\_repo) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cw_loggroup_arn"></a> [cw\_loggroup\_arn](#output\_cw\_loggroup\_arn) | EKS Cloudwatch group arn |
| <a name="output_cw_loggroup_name"></a> [cw\_loggroup\_name](#output\_cw\_loggroup\_name) | EKS Cloudwatch group Name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

