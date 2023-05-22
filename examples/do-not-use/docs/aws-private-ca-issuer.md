# AWS Private CA (PCA) Issuer

[AWS Private CA](https://aws.amazon.com/private-ca/) is an AWS service that can setup and manage private CAs, as well as issue private certifiates. This Add-on deployes the AWS Private CA Issuer as an [external issuer](https://cert-manager.io/docs/configuration/external/) to **cert-manager** that signs off certificate requests using AWS Private CA in an Amazon EKS Cluster.

## Usage

### Pre-requisites

To deploy the AWS PCA, you need to install cert-manager first, refer to this [documentation](https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/docs/cert-manager.md) to do it through EKS Blueprints Addons.

### Deployment

With **cert-manager** deployed in place, you can deploy the AWS Private CA Issuer Add-on via [EKS Blueprints Addons](https://github.com/aws-ia/terraform-aws-eks-blueprints-addons), reference the following parameters under the `module.eks_blueprints_addons`.

```hcl
module "eks_blueprints_addons" {

  enable_cert_manager         = true
  enable_aws_privateca_issuer = true
  aws_privateca_issuer = {
    acmca_arn        = aws_acmpca_certificate_authority.this.arn
  }
}
```

### Helm Chart customization

It's possible to customize your deployment using the Helm Chart parameters inside the `aws_load_balancer_controller` configuration block:

```hcl
  aws_privateca_issuer = {
    acmca_arn        = aws_acmpca_certificate_authority.this.arn
    namespace        = "aws-privateca-issuer"
    create_namespace = true
  }
```

You can find all available Helm Chart parameter values [here](https://github.com/cert-manager/aws-privateca-issuer/blob/main/charts/aws-pca-issuer/values.yaml).

## Validation

1. List all the pods running in `aws-privateca-issuer` and `cert-manager` Namespace.

```sh
kubectl get pods -n aws-privateca-issuer
kubectl get pods -n cert-manager
```

2. Check the `certificate` status in it should be in `Ready` state, and be pointing to a `secret` created in the same Namespace.

```sh
kubectl get certificate -o wide
NAME      READY   SECRET                  ISSUER                    STATUS                                          AGE
example   True    example-clusterissuer   tls-with-aws-pca-issuer   Certificate is up to date and has not expired   41m

kubectl get secret example-clusterissuer
NAME                    TYPE                DATA   AGE
example-clusterissuer   kubernetes.io/tls   3      43m
```

## Resources

[GitHub Repo](https://github.com/cert-manager/aws-privateca-issuer)
[Helm Chart](https://github.com/cert-manager/aws-privateca-issuer/tree/main/charts/aws-pca-issuer)
[AWS Docs](https://docs.aws.amazon.com/privateca/latest/userguide/PcaKubernetes.html)
