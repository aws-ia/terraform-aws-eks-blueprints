# Bottlerocket OS

[Bottlerocket](https://aws.amazon.com/bottlerocket/) is an open source operating system specifically designed for running containers. Bottlerocket build system is based on Rust. It's a container host OS and doesn't have additional software's or package managers other than what is needed for running containers hence its very light weight and secure. Container optimized operating systems are ideal when you need to run applications in Kubernetes  with minimal setup and do not want to worry about security or updates, or want OS support from  cloud provider. Container operating systems does updates transactionally.

Bottlerocket has two containers runtimes running. Control container **on** by default used for AWS Systems manager and remote API access. Admin container **off** by default for deep debugging and exploration.

Bottlerocket [Launch templates userdata](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/aws-eks-managed-node-groups/templates/userdata-bottlerocket.tpl) uses the TOML format with Key-value pairs.  
Remote API access API via SSM agent. You can launch trouble shooting container via user data `[settings.host-containers.admin] enabled = true`.

### Features
* [Secure](https://github.com/bottlerocket-os/bottlerocket/blob/develop/SECURITY_FEATURES.md) - Opinionated, specialized and highly secured
* **Flexible** - Multi cloud and multi orchestrator
* **Transactional** -  Image based upgraded and rollbacks
* **Isolated** - Separate container Runtimes

### Updates
Bottlerocket can be updated automatically via Kubernetes  Operator

```sh
    kubectl apply -f Bottlerocket_k8s.csv.yaml
    kubectl get ClusterServiceVersion Bottlerocket_k8s | jq.'status'
```
