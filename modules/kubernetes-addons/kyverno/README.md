# Kyverno

Kyverno is a policy engine that can help kubernetes clusters to enforce security and governance policies

This module takes an opinionated approach to install a set a of baseline policies along with the Kyverno UI which can disabled or removed based on the need.


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