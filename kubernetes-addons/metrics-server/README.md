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
| [helm_release.metrics_server](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_metrics_server_helm_chart"></a> [metrics\_server\_helm\_chart](#input\_metrics\_server\_helm\_chart) | n/a | `any` | `{}` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
