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

With this add-on self-signed CA and Let's Encrypt cluster issuers will be installed.

You can disable Let's Encrypt cluster issuers with:

```
cert_manager_install_letsencrypt_issuers = false
```

You can set an email address for expiration emails with:

```
cert_manager_letsencrypt_email = "user@example.com"
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```

certManager = {
  enable = true
}
```
