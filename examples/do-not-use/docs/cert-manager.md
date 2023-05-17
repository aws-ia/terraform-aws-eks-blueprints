# Certificate Manager

[Cert-manager](https://cert-manager.io/) is a X.509 certificate controller for Kubernetes-like workloads. It will obtain certificates from a variety of Issuers, both popular public Issuers as well as private Issuers, and ensure the certificates are valid and up-to-date, and will attempt to renew certificates at a configured time before expiry. This Add-on deploys this controller in an Amazon EKS Cluster.

## Usage

To deploy cert-manager Add-on via [EKS Blueprints Addons](https://github.com/aws-ia/terraform-aws-eks-blueprints-addons), reference the following parameters under the `module.eks_blueprints_addons`.

```hcl
module "eks_blueprints_addons" {

  enable_cert_manager         = true
}
```

### Helm Chart customization

It's possible to customize your deployment using the Helm Chart parameters inside the `cert-manager` configuration block:

```hcl
  cert-manager = {
    chart_version    = "v1.11.1"
    namespace        = "cert-manager"
    create_namespace = true
  }
```

You can find all available Helm Chart parameter values [here]https://github.com/cert-manager/cert-manager/blob/master/deploy/charts/cert-manager/values.yaml

## Validation

1. Validate if the Cert-Manger Pods are Running.

```sh
kubectl -n cert-manager get pods
NAME                                      READY   STATUS    RESTARTS   AGE
cert-manager-5989bcc87-96qvf              1/1     Running   0          2m49s
cert-manager-cainjector-9b44ddb68-8c7b9   1/1     Running   0          2m49s
cert-manager-webhook-776b65456-k6br4      1/1     Running   0          2m49s
```

2. Create a SelfSigned ClusterIssuer resource in the cluster.

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-cluster-issuer
spec:
  selfSigned: {}
```

```sh
kubectl get clusterissuers -o wide selfsigned-cluster-issuer
NAME                        READY   STATUS   AGE
selfsigned-cluster-issuer   True             3m
```

2. Create a Certificate in a given Namespace.

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example
  namespace: default
spec:
  isCA: true
  commonName: example
  secretName: example-secret
  privateKey:
    algorithm: ECDSA
    size: 256
  issuerRef:
    name: selfsigned-cluster-issuer
    kind: ClusterIssuer
    group: cert-manager.io
```

3.  Check the `certificate` status in it should be in `Ready` state, and be pointing to a `secret` created in the same Namespace.

```sh
kubectl get certificate -o wide
NAME      READY   SECRET           ISSUER                      STATUS                                          AGE
example   True    example-secret   selfsigned-cluster-issuer   Certificate is up to date and has not expired   44s

kubectl get secret example-secret
NAME             TYPE                DATA   AGE
example-secret   kubernetes.io/tls   3      70s
```

## Resources

[GitHub Repo](https://github.com/cert-manager/cert-manager)
[Helm Chart](https://github.com/cert-manager/cert-manager/blob/master/deploy/charts/cert-manager/)
