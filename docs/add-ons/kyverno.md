
# Kyverno

Kyverno is a policy engine that can help kubernetes clusters to enforce security and governance policies

This module takes an opinionated approach to install a set a of baseline policies along with the Kyverno UI which can disabled or removed based on the need.

The baseline and restricted policies covered by the built-in policies are below which can be toggeld via the helm values.

## Baseline
* disallow-capabilities
* disallow-host-namespaces
* disallow-host-path
* disallow-host-ports
* disallow-host-process
* disallow-privileged-containers
* disallow-proc-mount
* disallow-selinux
* restrict-apparmor-profiles
* restrict-seccomp
* restrict-sysctls

## Restricted

* disallow-capabilities-strict
* disallow-privilege-escalation
* require-run-as-non-root-user
* require-run-as-nonroot
* restrict-seccomp-strict
* restrict-volume-types

## References

Pod Secuirty standards - https://kubernetes.io/docs/concepts/security/pod-security-standards/

For more details checkout [kyverno](https://kyverno.io/)


## Usage

Kyverno can be deployed by enabling the add-on via the following.

```hcl
enable_kyverno = true
```

Deploy Kyverno with custom `values.yaml`

```hcl
  # Optional Map value; pass kyverno-values.yaml from consumer module
    kyverno_helm_config = {
    name       = "kyverno"                                             # (Required) Release name.
    repository = "https://kyverno.github.io/kyverno/"                  # (Optional) Repository URL where to locate the requested chart.
    chart      = "kyverno"                                        # (Required) Chart name to be installed.
    version    = "v2.5.2"                                               # (Optional) Specify the exact chart version to install. If this is not specified, it defaults to the version set within default_helm_config: https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/kyverno/locals.tf
    namespace  = "kyverno"                                             # (Optional) The namespace to install the release into.
    values = [templatefile("${path.module}/kyverno-values.yaml", {})]
  }
```


Deploy Kyverno policies with custom `values.yaml`

```hcl
  # Optional Map value; pass kyverno-values.yaml from consumer module
    kyverno_helm_config = {
    name       = "kyverno-policies"                                             # (Required) Release name.
    repository = "https://kyverno.github.io/kyverno/"                  # (Optional) Repository URL where to locate the requested chart.
    chart      = "kyverno-policies"                                        # (Required) Chart name to be installed.
    version    = "v2.5.2"                                               # (Optional) Specify the exact chart version to install. If this is not specified, it defaults to the version set within default_helm_config: https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/kyverno/locals.tf
    namespace  = "kyverno"                                             # (Optional) The namespace to install the release into.
    values = [templatefile("${path.module}/kyverno-policies-values.yaml", {})]
  }
```


Deploy Kyverno Policy reporter UI with custom `values.yaml`

```hcl
  # Optional Map value; pass kyverno-values.yaml from consumer module
    kyverno_helm_config = {
    name       = "policy-reporter"                                             # (Required) Release name.
    repository = "https://kyverno.github.io/kyverno/"                  # (Optional) Repository URL where to locate the requested chart.
    chart      = "policy-reporter"                                        # (Required) Chart name to be installed.
    version    = "v2.5.2"                                               # (Optional) Specify the exact chart version to install. If this is not specified, it defaults to the version set within default_helm_config: https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/kyverno/locals.tf
    namespace  = "kyverno"                                             # (Optional) The namespace to install the release into.
    values = [templatefile("${path.module}/kyverno-policy-reporter-values.yaml", {})]
  }
```
### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```sh
kyverno = {
  enable  = true
}
```
