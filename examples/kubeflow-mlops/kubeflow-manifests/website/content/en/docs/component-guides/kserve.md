+++
title = "KServe"
description = "Model serving using KServe with Kubeflow on AWS"
weight = 30
+++

This tutorial shows how to set up a load balancer endpoint for serving prediction requests over an external DNS on AWS.

> Note: Kubeflow on AWS v1.4 uses [KFServing](https://www.kubeflow.org/docs/external-add-ons/kserve/kserve/#kfserving-is-now-kservehttpskservegithubiowebsite07blogarticles2021-09-27-kfserving-transition). The KFServing project is now called KServe.

Read the [background]({{< ref "/docs/deployment/add-ons/load-balancer/guide.md#background" >}}) section of the Load Balancer installation guide to familiarize yourself with the requirements for creating an Application Load Balancer on AWS.

## Prerequisites

This guide assumes that you have:

1. The necessary [prerequisites]({{< ref "/docs/deployment/prerequisites.md" >}}), including a Kubeflow deployment.
2. The [AWS Load Balancer controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/) configured with one of the following deployment options:
    - A Cognito-integrated deployment that is configured with the [AWS Load Balancer controller by default]({{< ref "/docs/deployment/cognito/guide.md#30-configure-ingress" >}}).
    - A deployment that is not integrated with Cognito (for example, the [Vanilla deployment]({{< ref "/docs/deployment/vanilla/guide.md" >}}), which uses Dex as an auth provider), but have followed the [Exposing Kubeflow over Load Balancer guide]({{< ref "/docs/deployment/add-ons/load-balancer/guide.md" >}}).
3. A subdomain for hosting Kubeflow. For this guide, we will use the domain `platform.example.com`.
4. An existing [profile namespace](https://www.kubeflow.org/docs/components/multi-tenancy/getting-started/#manual-profile-creation) for a user in Kubeflow. For this guide, we will use the example profile namespace `staging`.
5. Verified that your current directory is the root of the repository by running the `pwd` command. The output should be `<path/to/kubeflow-manifests>` directory.


## Configure a default domain with KNative Serving

Use [Knative Serving](https://knative.dev/docs/serving/) to set up network routing resources.

The default fully qualified domain name (FQDN) for a route in Knative Serving is `{route}.{namespace}.{default-domain}`. Knative Serving routes use `example.com` as the default domain. If you create an `InferenceService` resource called `sklearn-iris` in the `staging` namespace without changing the default domain, the resulting `InfererenceService` domain would be `http://sklearn-iris.staging.example.com`.

To host an `InferenceService` on the same domain that you use to host Kubeflow (for example, `platform.example.com`), then you will need to edit the `config-domain` ConfigMap in the `knative-serving` namespace to configure `platform.example.com` to be used as the domain for the routes.

Edit the ConfigMap to change the default domain as per your deployment. Remove the `_example` key and replace `example.com` with your domain (e.g. `platform.example.com`).
```
apiVersion: v1
kind: ConfigMap
data:
  platform.example.com: ""
...
```

For more detailed instructions, see the KNative Serving [Changing the default domain](https://knative.dev/docs/serving/using-a-custom-domain/#procedure) procedure. 

## Request a certificate

Request a certificate in AWS Certificate Manager (ACM) to get TLS support from the Load Balancer. 

### Certificate request background

Knative concatenates the namespace in the FQDN for a route and the domain is delimited by a dot by default. The URLs for `InferenceService`  resources created in each namespace will be in a different [subdomain](https://en.wikipedia.org/wiki/Subdomain). 
- For example, if you have two namespaces, `staging` and `prod`, and create an `InferenceService` resource called `sklearn-iris` in both of these namespaces, then the URLs for each resource will be `http://sklearn-iris.staging.platform.example.com` and `http://sklearn-iris.prod.platform.example.com`, respectively. 

This means that you need to specify all subdomains in which you plan to create an `InferenceService` resource while creating the SSL certificate in ACM. 
- For example, for `staging` and `prod` namespaces, you will need to add `*.prod.platform.example.com`, `*.staging.platform.example.com` and `*.platform.example.com` to the certificate. 

DNS only supports wildcard placeholders in the [leftmost part of the domain name](https://en.wikipedia.org/wiki/Wildcard_DNS_record). When you request a wildcard certificate using ACM, the asterisk (*) must be in the leftmost position of the domain name and can protect only one subdomain level. 
- For example, `*.platform.example.com` can protect `staging.platform.example.com`, and `prod.platform.example.com`, but it cannot protect `sklearn-iris.staging.platform.example.com`.

### Create a certificate
> Note: Both of these domains should be requested in the same certificate

Create an ACM certificate for `*.platform.example.com` and `*.staging.platform.example.com` in your cluster's region by following the [create certificates for domain]({{< ref "/docs/deployment/add-ons/load-balancer/guide.md#create-certificates-for-domain" >}}) steps in the Load Balancer installation guide. 

Once the certificate status changes to `Issued`, export the ARN of the certificate created:
```bash
export certArn=<>
```

If you are using Cognito for user authentication, see [Cognito]({{< ref "/docs/component-guides/kserve.md#cognito-ingress" >}}). If you use Dex as the auth provider in your Kubeflow deployment, see [Dex]({{< ref "/docs/component-guides/kserve.md#dex-ingress" >}}). 

## Cognito ingress

It is not currently possible to programatically authenticate a request that uses Amazon Cognito for user authentication through Load Balancer. You cannot generate `AWSELBAuthSessionCookie` cookies by using the access tokens from Cognito. 

To work around this, it is necessary to create a new Load Balancer endpoint for serving traffic that authorizes based on custom strings specified in a predefined HTTP header. 

Use an ingress to set the [HTTP header conditions](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html#http-header-conditions) on your Load Balancer. This creates rules that route requests based on HTTP headers. This can be used for service-to-service communication in your application.

### Create ingress

1. Configure the following parameters for [ingress](https://github.com/awslabs/kubeflow-manifests/blob/main/awsconfigs/common/istio-ingress/overlays/api/params.env):
    - `certArn`: ARN of certificate created during [Request a certificate]({{< ref "/docs/component-guides/kserve.md#request-a-certificate" >}}) step.
    - (optional) `httpHeaderName`: Custom HTTP header name that you want to configure for the rule evaluation. Defaults to `x-api-key`.
    - `httpHeaderValues`: One or more match strings that need to be compared against the header value if the request received. You only need to pass one of the tokens in the request. Pick strong values.
> Note: The `httpHeaderName` and `httpHeaderValues` values correspond to the [HttpHeaderConfig](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html#http-header-conditions) values

2. Replace the `token1` string with a token of your choice. Optionally, replace the `httpHeaderName` string as well.
    ```bash
    printf '
    certArn='$certArn'
    httpHeaderName=x-api-key
    httpHeaderValues=["token1"]
    ' > awsconfigs/common/istio-ingress/overlays/api/params.env
    ```
3. Create the ingress with the following command:
    ```bash
    kustomize build awsconfigs/common/istio-ingress/overlays/api | kubectl apply -f -
    ```
4. Check if the ingress-managed Load Balancer is provisioned. This may take a few minutes to complete.
    ```bash
    kubectl get ingress -n istio-system istio-ingress-api
    NAME                CLASS    HOSTS   ADDRESS                                                              PORTS   AGE
    istio-ingress-api   <none>   *       k8s-istiosys-istioing-xxxxxx-110050202.us-west-2.elb.amazonaws.com   80      14m
    ```

Once your Load Balancer is ready, move on to the [Add DNS records]({{< ref "/docs/component-guides/kserve.md#add-dns-records" >}}) step to add a DNS record for the staging subdomain.

## Dex ingress

### Update the certificate for your Load Balancer

1. Configure the parameters for [ingress](https://github.com/awslabs/kubeflow-manifests/blob/main/awsconfigs/common/istio-ingress/overlays/api/params.env) with the ARN of the certificate created during the [Request a certificate]({{< ref "/docs/component-guides/kserve.md#request-a-certificate" >}}) step.
    ```bash
    printf 'certArn='$certArn'' > awsconfigs/common/istio-ingress/overlays/https/params.env
    ```
2. Update the Load Balancer with the following command:
    ```bash
    kustomize build awsconfigs/common/istio-ingress/overlays/https | kubectl apply -f -
    ``` 
3. Get the Load Balancer address
    ```bash
    kubectl get ingress -n istio-system istio-ingress
    NAME            CLASS    HOSTS   ADDRESS                                                              PORTS   AGE
    istio-ingress   <none>   *       k8s-istiosys-istioing-xxxxxx-110050202.us-west-2.elb.amazonaws.com   80      15d
    ```
Once your Load Balancer is ready, move on to the [Add DNS records]({{< ref "/docs/component-guides/kserve.md#add-dns-records" >}}) step to add a DNS record for the staging subdomain.

## Add DNS records

Once your ingress-managed Load Balancer is ready, copy the `ADDRESS` of that Load Balancer and create a `CNAME` entry to it in [Amazon Route 53](https://aws.amazon.com/route53/) under your subdomain (e.g. `platform.example.com`) for `*.staging.platform.example.com`.

## Run a sample InferenceService

### Create an `AuthorizationPolicy`

Namespaces created by the Kubeflow profile controller have a missing authorization policy that prevents the KFServing predictor and transformer from working. 

> Known Issue: See [kserve/kserve#1558](https://github.com/kserve/kserve/issues/1558) and [kubeflow/kubeflow#5965](https://github.com/kubeflow/kubeflow/issues/5965) for more information.

Create the `AuthorizationPolicy` as mentioned in [issue #82](https://github.com/awslabs/kubeflow-manifests/issues/82#issuecomment-1068641378) as a workaround until this is resolved. Verify that the policies have been created by listing the `authorizationpolicies` in the `istio-system` namespace:
```bash
kubectl get authorizationpolicies -n istio-system
```

### Create an `InferenceService`

Set the environment variable value for `PROFILE_NAMESPACE`(e.g. `staging`) according to your environment:
```bash
export PROFILE_NAMESPACE="staging"
```

Create a scikit-learn `InferenceService` using a [sample](https://github.com/kserve/kserve/blob/release-0.7/docs/samples/v1beta1/sklearn/v2/sklearn.yaml) from the KFserving repository and wait for `READY` to be `True`.

```bash
kubectl apply -n ${PROFILE_NAMESPACE} -f https://raw.githubusercontent.com/kserve/kserve/release-0.7/docs/samples/v1beta1/sklearn/v2/sklearn.yaml
```

### Check `InferenceService` status

Check the `InferenceService` status. Once it is ready, copy the URL to use for sending a prediction request.
```bash
kubectl get inferenceservices sklearn-irisv2 -n ${PROFILE_NAMESPACE}

NAME             URL                                                 READY   PREV   LATEST   PREVROLLEDOUTREVISION   LATESTREADYREVISION                      AGE
sklearn-irisv2   http://sklearn-iris2.staging.platform.example.com   True           100                              sklearn-irisv2-predictor-default-00001   3m31s
```

### Send an inference request

Set the environment variable values for `KUBEFLOW_DOMAIN`(e.g. `platform.example.com`) according to your environment:
```bash
export KUBEFLOW_DOMAIN="platform.example.com"
```

Install dependencies for the script by running:
```bash
cd tests/e2e
pip install requirements.txt
```

Run the sample python script to send an inference request based on your auth provider:

#### Cognito inference 

Run the [inference_sample.py](https://github.com/awslabs/kubeflow-manifests/blob/main/tests/e2e/utils/kserve/inference_sample.py) Python script by exporting the values for `HTTP_HEADER_NAME`(e.g. `x-api-key`) and `HTTP_HEADER_VALUE`(e.g. `token1`) according to the values configured in [ingress section]({{< ref "/docs/component-guides/kserve.md#create-ingress" >}}).
```bash
export AUTH_PROVIDER="cognito"
export HTTP_HEADER_NAME="x-api-key"
export HTTP_HEADER_VALUE="token1"
```

```bash
PYTHONPATH=.. python utils/kserve/inference_sample.py
```

The output should look similar to the following:
```bash
Status Code 200
JSON Response  {
  "model_name": "sklearn-irisv2",
  "model_version": null,
  "id": "e5fc40ba-5f02-42f7-aff8-34042facbe11",
  "parameters": null,
  "outputs": [
    {
      "name": "predict",
      "shape": [
        2
      ],
      "datatype": "FP32",
      "parameters": null,
      "data": [
        1,
        2
      ]
    }
  ]
}
```

#### Dex inference
Run the [inference_sample.py](https://github.com/awslabs/kubeflow-manifests/blob/main/tests/e2e/utils/kserve/inference_sample.py) Python script by exporting the values for `USERNAME`(e.g. `user@example.com`), `PASSWORD` according to the user profile 
```bash
export AUTH_PROVIDER="dex"
export USERNAME="user@example.com"
export PASSWORD="12341234"
```

```bash
PYTHONPATH=.. python utils/kserve/inference_sample.py
```

The output should look similar to the following:
```bash
Status Code 200
JSON Response  {
  "model_name": "sklearn-irisv2",
  "model_version": null,
  "id": "e5fc40ba-5f02-42f7-aff8-34042facbe11",
  "parameters": null,
  "outputs": [
    {
      "name": "predict",
      "shape": [
        2
      ],
      "datatype": "FP32",
      "parameters": null,
      "data": [
        1,
        2
      ]
    }
  ]
}
```
