# aws-privateca-issuer

AWS ACM Private CA is a module of the [AWS Certificate Manager](https://aws.amazon.com/certificate-manager/) that can setup and manage private CAs. `cert-manager` is a Kubernetes add-on to automate the management and issuance of TLS certificates from various issuing sources. It will ensure certificates are valid and up to date periodically, and attempt to renew certificates at an appropriate time before expiry. This module `aws-pca-issuer` is a addon for `cert-manager` that issues certificates using AWS ACM PCA.

See the [aws-privateca-issuer documentation](https://cert-manager.github.io/aws-privateca-issuer/).

## Usage

aws_privateca_issuer can be deployed by enabling the add-on via the following.

```hcl
enable_cert_manager   = true
enable_aws_privateca_issuer = true
```

Create `AWSPCAClusterIssuer` custom resource definition (CRD). It is a Kubernetes resources that represent certificate authorities (CAs) from AWS ACM and are able to generate signed certificates by honoring certificate signing requests. For more details on external `Issuer` types, please check [aws-privateca-issuer](https://github.com/cert-manager/aws-privateca-issuer)

```hcl
resource "kubernetes_manifest" "cluster-pca-issuer" {
  manifest = {
    apiVersion = "awspca.cert-manager.io/v1beta1"
    kind       = "AWSPCAClusterIssuer"

    metadata = {
      name = "logical.name.of.this.issuer"
    }

    spec = {
      arn = "ARN for AWS PCA"
      region: "data.aws_region.current.id OR AWS region of the AWS PCA"

    }
  }
}
```

Create `Certificate` CRD. Certificates define a desired X.509 certificate which will be renewed and kept up to date. For more details on how to specify and request Certificate resources, please check [Certificate Resources guide](https://cert-manager.io/docs/usage/certificate/).

A Certificate is a namespaced resource that references `AWSPCAClusterIssuer` (created in above step) that determine what will be honoring the certificate request.

```hcl
resource "kubernetes_manifest" "example_pca_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"

    metadata = {
      name = "name of the certificate"
      namespace = "default or any namespace"
    }

    spec = {
      commonName = "common name for your certificate"
      duration = "duration"
      issuerRef = {
          group = "awspca.cert-manager.io"
          kind = "AWSPCAClusterIssuer"
          name: "name of AWSPCAClusterIssuer created above"
      }
      renewBefore = "360h0m0s"
      secretName = "name of the secret where certificate will be mounted"
      usages = [
          "server auth",
          "client auth"
      ]
      privateKey = {
          algorithm: "RSA"
          size: 2048
        }
    }
  }

}
```

When a Certificate is created, a corresponding CertificateRequest resource is created by `cert-manager` containing the encoded X.509 certificate request, Issuer reference, and other options based upon the specification of the Certificate resource.

This Certificate CRD will tell cert-manager to attempt to use the Issuer (as AWS ACM) to obtain a certificate key pair for the specified domains. If successful, the resulting TLS key and certificate will be stored in a kubernetes secret named , with keys of tls.key, and tls.crt respectively. This secret will live in the same namespace as the Certificate resource.

Now, you may run `kubectl get Certificate` to view the status of Certificate Request from AWS PCA.

```
NAME      READY   SECRET                                 AGE
example   True    aws001-preprod-dev-eks-clusterissuer   3h35m
```

If the status is `True`, that means, the `tls.crt`, `tls.key` and `ca.crt` will all be available in [Kubernetes Secret](https://kubernetes.io/docs/concepts/configuration/secret/)

```
aws001-preprod-dev-eks-clusterissuer
Name:         aws001-preprod-dev-eks-clusterissuer
Namespace:    default
Labels:       <none>
Annotations:  cert-manager.io/alt-names:
              cert-manager.io/certificate-name: example
              cert-manager.io/common-name: example.com
              cert-manager.io/ip-sans:
              cert-manager.io/issuer-group: awspca.cert-manager.io
              cert-manager.io/issuer-kind: AWSPCAClusterIssuer
              cert-manager.io/issuer-name: aws001-preprod-dev-eks
              cert-manager.io/uri-sans:

Type:  kubernetes.io/tls

Data
====
ca.crt:   1785 bytes
tls.crt:  1517 bytes
tls.key:  1679 bytes
```
