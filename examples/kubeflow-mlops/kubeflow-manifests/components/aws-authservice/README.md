# AWS AuthService

## Overview
AWS AuthService is an HTTP Server that handles the logging out of an Authenticated user who was connected to Kubeflow using AWS Cognito and Amazon ALB.

## Design
An HTTP Server that listens for a users logout request that then follows the two steps necessary to logout an Authenticated Cognito + ALB user. These being expiring any ALB Cookies and then hitting the Cognito Logout Endpoint. Official [Documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-authenticate-users.html#authentication-logout) lists these steps as required for secure logout.

## Manifests
To install AWS AuthService apply them to your EKS Cluster. The manifests can be found in [awsconfigs](../../awsconfigs/common/aws-authservice/base/).

```
kubectl apply -k ../../awsconfigs/common/aws-authservice/base/
```

These are configurable environment variables used by AWS AuthService in [params.env](../../awsconfigs/common/aws-authservice/base/params.env)

`LOGOUT_URL` [REQUIRED]: The Cognito URL that will be redirected to on Logout.

## Build and Test
If you wish to make custom changes to AWS AuthService you can modify [main.go](main.go)

The image can be built and tagged using Docker.
```
make build IMAGE_URI=<>
```

Finally push the image to ECR or any Container Image Registry like Dockerhub

To use your new image you must modify
  - [kustomization](../../awsconfigs/common/aws-authservice/base/kustomization.yaml#L11)

If user has any custom changes to the manifests, they can choose to modify the [manifests](../../awsconfigs/common/aws-authservice/base/) 

### Configurable Parameters
In testing you must provide a LOGOUT_URL for AWS AuthService to redirect to in the [params.env](../../awsconfigs/common/aws-authservice/base/params.env) file.

Finally apply the manifests 
```
kubectl apply -k ../../awsconfigs/common/aws-authservice/base/
```

## References
[Logout Documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-authenticate-users.html#authentication-logout)

Inspired by [oidc-authservice](https://github.com/arrikto/oidc-authservice)


## Licensing
See the [LICENSE](../../LICENSE) file for our project's licensing. 

