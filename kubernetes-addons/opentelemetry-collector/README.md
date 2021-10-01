# OpenTelemetry Helm Chart

## Introduction

The OpenTelemetry Collector offers a vendor-agnostic implementation on how to receive, process and export telemetry data. In addition, it removes the need to run, operate and maintain multiple agents/collectors in order to support open-source telemetry data formats (e.g. Jaeger, Prometheus, etc.) sending to multiple open-source or commercial back-ends.

## Helm Chart

### Instructions to use Helm Charts

    helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts

Additional details about the official OpenTelemtry helm chart can be found [here](https://github.com/open-telemetry/opentelemetry-helm-charts/tree/main/charts/opentelemetry-collector)

#### Instructions to upload kube-state-metrics Docker image to AWS ECR

## Docker Image

Step1: Download the docker image to your local Mac/Laptop

        $ docker pull otel/opentelemetry-collector:0.31.0

Step2: Retrieve an authentication token and authenticate your Docker client to your registry. Use the AWS CLI:

        $ aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <account id>.dkr.ecr.eu-west-1.amazonaws.com

Step3: Create an ECR repo for kube-state-metrics if you don't have one

         $ aws ecr create-repository --repository-name  otel/opentelemetry-collector--image-scanning-configuration scanOnPush=true

Step4: After the build completes, tag your image so, you can push the image to this repository:

        $ docker tag otel/opentelemetry-collector:0.31.0 <account id>.dkr.ecr.eu-west-1.amazonaws.com/otel/opentelemetry-collector:0.31.0

Step5: Run the following command to push this image to your newly created AWS repository:

        $ docker push <accountid>.dkr.ecr.eu-west-1.amazonaws.com/otel/opentelemetry-collector:0.31.0
