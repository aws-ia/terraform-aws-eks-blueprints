# ExternalDNS

[External DNS](https://github.com/kubernetes-sigs/external-dns) is a Kubernetes add-on that can automate the management of DNS records based on Ingress and Service resources.

For complete project documentation, please visit the [External DNS Github repository](https://github.com/kubernetes-sigs/external-dns).

## Usage

External DNS can be deployed by enabling the add-on via the following.

```hcl
enable_external_dns = true
```

External DNS can optionally leverage the `eks_cluster_domain` global property of the `kubernetes_addon` submodule. The value for this property should be a Route53 domain managed by your account. ExternalDNS will leverage the value supplied for its `zoneIdFilters` property, which will restrict ExternalDNS to only create records for this domain. See docs [here](https://github.com/bitnami/charts/tree/master/bitnami/external-dns).

```
eks_cluster_domain = <cluster_domain>
```

Alternatively, you can supply a list of Route53 zone ARNs which external-dns will have access to create/manage records:

```hcl
  external_dns_route53_zone_arns = [
    "arn:aws:route53::123456789012:hostedzone/Z1234567890"
  ]
```

You can optionally customize the Helm chart that deploys `external-dns` via the following configuration.

```hcl
  enable_external_dns = true
  external_dns_helm_config = {
    name                       = "external-dns"
    chart                      = "external-dns"
    repository                 = "https://charts.bitnami.com/bitnami"
    version                    = "6.1.6"
    namespace                  = "external-dns"
  }
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```
external_dns = {
  enable            = true
  zoneFilterIds     = local.zone_filter_ids
  serviceAccountName = local.service_account
}
```
