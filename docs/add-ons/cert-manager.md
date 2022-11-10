# cert-manager

cert-manager adds certificates and certificate issuers as resource types in Kubernetes clusters, and simplifies the process of obtaining, renewing and using those certificates.

For complete project documentation, please visit the [cert-manager documentation site](https://cert-manager.io/docs/).

## Usage

cert-manger can be deployed by enabling the add-on via the following.

```hcl
enable_cert_manager = true
```

cert-manger can optionally leverage the `cert_manager_domain_names` global property of the `kubernetes_addon` submodule for DNS01 protocol. The value for this property should be a list of Route53 domains managed by your account. cert-manager is restricted to the zones from the list.

```
cert_manager_domain_names = [<cluster_domain>, <another_cluster_domain>]
```

With this add-on self-signed CA and ACME cluster issuers will be installed.

You can disable ACME cluster issuers with:

```
cert_manager_install_acme_issuers = false
```

You can set an email address for expiration emails with:

```
cert_manager_email = "user@example.com"
```

You can pass previously created secrets for use as `imagePullSecrets` on the Service Account

```
cert_manager_kubernetes_svc_image_pull_secrets = ["regcred"]
```

You can create prefix of cluster issuer and release

```
cert_manager_cluster_issuer_name = "example"
```

You can pass ID of the CA key that the External Account is bound to.

```
cert_manager_external_account_keyID = "exampleKey"
```

You can pass Secret key of the CA that the External Account is bound to.

```
cert_manager_external_account_secret_key = "exampleSecret"
```

You can pass preferred chain to use, if the ACME server outputs multiple.

```
cert_manager_preferred_chain = "Example CHAIN"
```

You can pass the URL to access the ACME server's  endpoint.

```
cert_manager_acme_server_url = "https://example.com"
```

You can pass your AWS DNS Region.

```
cert_manager_dns_region = "example-region"
```

You can pass common name to be included in the Certificate.

```
cert_manager_certificate_common_name = "example.com"
```

You can give bool value that will mark this Certificate as valid for certificate signing.

```
cert_manager_certificate_is_ca = true
```

You can pass the hosted zone of your route53 domain for managing only that zone.

```
cert_manager_hosted_zone_id = "example zone"
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```

certManager = {
  enable = true
}
```
