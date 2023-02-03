# secrets-store-csi-driver-provider-aws

AWS Secrets Manager and Config Provider for Secret Store CSI Driver allows you to get secret contents stored in AWS Key Management Service instance and use the Secrets Store CSI driver interface to mount them into Kubernetes pods. For detailed architectual overview, refer [How to use AWS Secrets & Configuration Provider with your Kubernetes Secrets Store CSI driver] (https://aws.amazon.com/blogs/security/how-to-use-aws-secrets-configuration-provider-with-kubernetes-secrets-store-csi-driver/)

## Usage

csi-secrets-store-provider-aws can be deployed by enabling the add-ons via the following.

```hcl
enable_secrets_store_csi_driver = true
enable_secrets_store_csi_driver_provider_aws = true
```
