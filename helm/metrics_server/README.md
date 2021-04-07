# Metrics Server Helm Chart

###### Instructions to upload Metrics Server Docker image to AWS ECR

Step1: Get the latest docker image from this link
        
        https://github.com/kubernetes-sigs/metrics-server
        
Step2: Download the docker image to your local Mac/Laptop
        
        $ docker pull k8s.gcr.io/metrics-server/metrics-server:v0.4.2
        
Step3: Retrieve an authentication token and authenticate your Docker client to your registry. Use the AWS CLI:
        
        $ aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <account id>.dkr.ecr.eu-west-1.amazonaws.com
        
Step4: Create an ECR repo for Metrics Server if you don't have one 
    
        $ aws ecr create-repository \
              --repository-name k8s.gcr.io/metrics-server/metrics-server \
              --image-scanning-configuration scanOnPush=true 
              
Step5: After the build completes, tag your image so, you can push the image to this repository:
        
        $ docker tag k8s.gcr.io/metrics-server/metrics-server:v0.4.2 <accountid>.dkr.ecr.eu-west-1.amazonaws.com/k8s.gcr.io/metrics-server/metrics-server:v0.4.2
        
Step6: Run the following command to push this image to your newly created AWS repository:
        
        $ docker push <accountid>.dkr.ecr.eu-west-1.amazonaws.com/k8s.gcr.io/metrics-server/metrics-server:v0.4.2

### Instructions to download Helm Charts

Helm Chart
    
    https://artifacthub.io/packages/helm/appuio/metrics-server

Helm Repo Maintainers

    https://charts.appuio.ch
    

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
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
| [helm_release.metric_server](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_image_repo_name"></a> [image\_repo\_name](#input\_image\_repo\_name) | n/a | `string` | `"k8s.gcr.io/metrics-server/metrics-server"` | no |
| <a name="input_image_repo_url"></a> [image\_repo\_url](#input\_image\_repo\_url) | n/a | `any` | n/a | yes |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | n/a | `string` | `"v0.4.2"` | no |
| <a name="input_public_docker_repo"></a> [public\_docker\_repo](#input\_public\_docker\_repo) | n/a | `any` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

