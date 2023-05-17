# EKS Blueprint Example with Elastic Fabric Adapter

## Table of Contents

- [EKS Blueprint Example with Elastic Fabric Adapter](#eks-blueprint-example-with-elastic-fabric-adapter)
  - [Table of Contents](#table-of-contents)
  - [Elastic Fabric Adapter Overview](#elastic-fabric-adapter-overview)
  - [Setup Details](#setup-details)
- [Terraform Doc](#terraform-doc)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
- [Example Walkthrough](#example-walkthrough)
  - [1. Clone Repository](#1-clone-repository)
  - [2. Configure Terraform Plan](#2-configure-terraform-plan)
  - [3. Initialize Terraform Plan](#3-initialize-terraform-plan)
  - [4. Create Terraform Plan](#4-create-terraform-plan)
  - [5. Apply Terraform Plan](#5-apply-terraform-plan)
  - [6. Connect to EKS](#6-connect-to-eks)
  - [7. Deploy Kubeflow MPI Operator](#7-deploy-kubeflow-mpi-operator)
  - [8. Test EFA](#8-test-efa)
    - [8.1. EFA Info Test](#81-efa-info-test)
    - [8.2. EFA NCCL Test](#82-efa-nccl-test)
  - [9. Cleanup](#9-cleanup)
- [Conclusion](#conclusion)

## Elastic Fabric Adapter Overview

[Elastic Fabric Adapter (EFA)](https://aws.amazon.com/hpc/efa/) is a network interface supported by [some Amazon EC2 instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/efa.html#efa-instance-types) that provides high-performance network communications at scale on AWS. Commonly, high-performance computing, simulation, and large AI model training jobs require EFA, in order to minimize the time to job completion. This example provides a blueprint for deploying an [Amazon EKS](https://aws.amazon.com/eks/) cluster with EFA-enabled nodes, which can be used to run such jobs.

## Setup Details

There are three requirements that need to be satisfied, in order for EFA to work:

1. The EC2 instance type must support EFA and the EFA adapter must be enabled.
2. The EFA software must be installed
3. The security group attached to the EC2 instance must allow all incoming and outgoing traffic to itself

In the provided Terraform EKS Blueprint example here, these requirements are satisfied automatically.  

# Terraform Doc

The main Terraform doc [main.tf](main.tf) contains local variables, local data, vpc and eks definitions, device plugins, and addons.

## Requirements

Requirements are specified in the [providers.tf](providers.tf) file. This file is used to install all needed providers when `terraform init` is executed.

## Providers

Providers are defined in [main.tf](main.tf#L3). They include `aws`, `kubernetes`, `helm`, and `kubectl`.

## Modules

The following modules are included in the template:

1. [vpc](main.tf#L240) - defines the VPC which will be used to host the EKS cluster

2. [eks](main.tf#L92) - defines the EKS cluster
   The EKS cluster contains a managed nodedgroup called `sys` for running system pods,
   and an unmanaged nodegroup called `efa` which has the necessary configuration to enable EFA on the nodes in that group.

3. [eks_blueprints_kubernetes_addons](main.tf#L220) - defines EKS cluster addons to be deployed


## Resources

The [resources section of main.tf](main.tf#69) creates a placement group, deploys the [EFA](https://github.com/aws-samples/aws-efa-eks) and [NVIDIA](https://github.com/NVIDIA/k8s-device-plugin) device plugins.

## Inputs

There are no required user-inputs.
The template comes with default inputs which create an EKS cluster called `eks-efa` in region `us-east-1`.
These settings can be adjusted in the [variables.tf](variables.tf) file.

## Outputs

When the `terraform apply` completes successfully, the EKS cluster id, and the command to connect to the cluster are provided as outputs as described in [outputs.tf](outputs.tf).

# Example Walkthrough

## 1. Clone Repository

```bash
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
cd terraform-aws-eks-bluerpints/examples/eks-efa
```

## 2. Configure Terraform Plan

Edit [variables.tf](variables.tf) and the [locals section of main.tf](main.tf#L54) as needed.

## 3. Initialize Terraform Plan

```bash
terraform init
```

<details>
<summary>Output:</summary>
Initializing the backend...
Initializing modules...
Downloading registry.terraform.io/terraform-aws-modules/eks/aws 19.13.1 for eks...
- eks in .terraform/modules/eks
- eks.eks_managed_node_group in .terraform/modules/eks/modules/eks-managed-node-group
- eks.eks_managed_node_group.user_data in .terraform/modules/eks/modules/_user_data
- eks.fargate_profile in .terraform/modules/eks/modules/fargate-profile
Downloading registry.terraform.io/terraform-aws-modules/kms/aws 1.1.0 for eks.kms...
- eks.kms in .terraform/modules/eks.kms
- eks.self_managed_node_group in .terraform/modules/eks/modules/self-managed-node-group
- eks.self_managed_node_group.user_data in .terraform/modules/eks/modules/_user_data
- eks_blueprints_kubernetes_addons in ../../modules/kubernetes-addons
- eks_blueprints_kubernetes_addons.adot_collector_haproxy in ../../modules/kubernetes-addons/adot-collector-haproxy
- eks_blueprints_kubernetes_addons.adot_collector_haproxy.helm_addon in ../../modules/kubernetes-addons/helm-addon
- eks_blueprints_kubernetes_addons.adot_collector_haproxy.helm_addon.irsa in ../../modules/irsa
- eks_blueprints_kubernetes_addons.adot_collector_java in ../../modules/kubernetes-addons/adot-collector-java
- eks_blueprints_kubernetes_addons.adot_collector_java.helm_addon in ../../modules/kubernetes-addons/helm-addon
- ...
- eks_blueprints_kubernetes_addons.opentelemetry_operator in ../../modules/kubernetes-addons/opentelemetry-operator
- eks_blueprints_kubernetes_addons.opentelemetry_operator.cert_manager in ../../modules/kubernetes-addons/cert-manager
- eks_blueprints_kubernetes_addons.opentelemetry_operator.cert_manager.helm_addon in ../../modules/kubernetes-addons/helm-addon
- eks_blueprints_kubernetes_addons.opentelemetry_operator.cert_manager.helm_addon.irsa in ../../modules/irsa
- eks_blueprints_kubernetes_addons.opentelemetry_operator.helm_addon in ../../modules/kubernetes-addons/helm-addon
- eks_blueprints_kubernetes_addons.opentelemetry_operator.helm_addon.irsa in ../../modules/irsa
Downloading registry.terraform.io/portworx/portworx-addon/eksblueprints 0.0.6 for eks_blueprints_kubernetes_addons.portworx...
- eks_blueprints_kubernetes_addons.portworx in .terraform/modules/eks_blueprints_kubernetes_addons.portworx
Downloading git::https://github.com/aws-ia/terraform-aws-eks-blueprints.git for eks_blueprints_kubernetes_addons.portworx.helm_addon...
- eks_blueprints_kubernetes_addons.portworx.helm_addon in .terraform/modules/eks_blueprints_kubernetes_addons.portworx.helm_addon/modules/kubernetes-addons/helm-addon
- eks_blueprints_kubernetes_addons.portworx.helm_addon.irsa in .terraform/modules/eks_blueprints_kubernetes_addons.portworx.helm_addon/modules/irsa
- eks_blueprints_kubernetes_addons.prometheus in ../../modules/kubernetes-addons/prometheus
-...
- eks_blueprints_kubernetes_addons.yunikorn.helm_addon in ../../modules/kubernetes-addons/helm-addon
- eks_blueprints_kubernetes_addons.yunikorn.helm_addon.irsa in ../../modules/irsa
Downloading registry.terraform.io/terraform-aws-modules/vpc/aws 4.0.1 for vpc...
- vpc in .terraform/modules/vpc

Initializing provider plugins...
- Finding latest version of hashicorp/random...
- Finding hashicorp/kubernetes versions matching ">= 2.6.1, >= 2.10.0, >= 2.16.1"...
- Finding latest version of hashicorp/http...
- Finding hashicorp/helm versions matching ">= 2.4.1, >= 2.5.1, >= 2.8.0"...
- Finding gavinbunney/kubectl versions matching ">= 1.14.0"...
- Finding hashicorp/aws versions matching ">= 3.72.0, >= 4.10.0, >= 4.13.0, >= 4.35.0, >= 4.47.0, >= 4.57.0"...
- Finding hashicorp/time versions matching ">= 0.7.0, >= 0.8.0, >= 0.9.0"...
- Finding hashicorp/null versions matching ">= 3.0.0"...
- Finding hashicorp/tls versions matching ">= 3.0.0"...
- Finding hashicorp/cloudinit versions matching ">= 2.0.0"...
- Installing hashicorp/helm v2.9.0...
- Installed hashicorp/helm v2.9.0 (signed by HashiCorp)
- Installing gavinbunney/kubectl v1.14.0...
- Installed gavinbunney/kubectl v1.14.0 (self-signed, key ID AD64217B5ADD572F)
- Installing hashicorp/tls v4.0.4...
- Installed hashicorp/tls v4.0.4 (signed by HashiCorp)
- Installing hashicorp/cloudinit v2.3.2...
- Installed hashicorp/cloudinit v2.3.2 (signed by HashiCorp)
- Installing hashicorp/random v3.5.1...
- Installed hashicorp/random v3.5.1 (signed by HashiCorp)
- Installing hashicorp/http v3.3.0...
- Installed hashicorp/http v3.3.0 (signed by HashiCorp)
- Installing hashicorp/time v0.9.1...
- Installed hashicorp/time v0.9.1 (signed by HashiCorp)
- Installing hashicorp/null v3.2.1...
- Installed hashicorp/null v3.2.1 (signed by HashiCorp)
- Installing hashicorp/kubernetes v2.20.0...
- Installed hashicorp/kubernetes v2.20.0 (signed by HashiCorp)
- Installing hashicorp/aws v4.66.1...
- Installed hashicorp/aws v4.66.1 (signed by HashiCorp)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/cli/plugins/signing.html

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
</details>

## 4. Create Terraform Plan

```bash
terraform plan -out tfplan
```

<details>
<summary>Output:</summary>

```text
...
# module.vpc.aws_vpc.this[0] will be created
  + resource "aws_vpc" "this" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.11.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
...

Plan: 80 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + configure_kubectl = "aws eks update-kubeconfig --region us-east-1 --name eks-efa"
  + eks_cluster_id    = (known after apply)

───────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan"
```
</details>

## 5. Apply Terraform Plan

```bash
terraform apply tfplan
```

<details>

<summary>Output:</summary>

```text
aws_placement_group.efa_pg: Creating...
module.eks.aws_cloudwatch_log_group.this[0]: Creating...
module.vpc.aws_vpc.this[0]: Creating...
module.eks.module.eks_managed_node_group["sys"].aws_iam_role.this[0]: Creating...
module.vpc.aws_eip.nat[0]: Creating...
module.eks.aws_iam_role.this[0]: Creating...
...
module.eks.aws_eks_cluster.this[0]: Still creating... [1m40s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [1m50s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [2m0s elapsed]
...
module.eks.aws_eks_addon.this["kube-proxy"]: Still creating... [30s elapsed]
module.eks_blueprints_kubernetes_addons.module.aws_fsx_csi_driver[0].module.helm_addon.helm_release.addon[0]: Still creating... [20s elapsed]
module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].module.helm_addon.helm_release.addon[0]: Still creating... [20s elapsed]
module.eks.aws_eks_addon.this["vpc-cni"]: Creation complete after 35s [id=eks-efa:vpc-cni]
module.eks.aws_eks_addon.this["kube-proxy"]: Creation complete after 35s [id=eks-efa:kube-proxy]
module.eks_blueprints_kubernetes_addons.module.aws_fsx_csi_driver[0].module.helm_addon.helm_release.addon[0]: Still creating... [30s elapsed]
module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].module.helm_addon.helm_release.addon[0]: Still creating... [30s elapsed]
module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].module.helm_addon.helm_release.addon[0]: Creation complete after 36s [id=aws-efs-csi-driver]
module.eks_blueprints_kubernetes_addons.module.aws_fsx_csi_driver[0].module.helm_addon.helm_release.addon[0]: Creation complete after 36s [id=aws-fsx-csi-driver]
╷
│ Warning: "default_secret_name" is no longer applicable for Kubernetes v1.24.0 and above
│
│   with module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].module.helm_addon.module.irsa[0].kubernetes_service_account_v1.irsa[0],
│   on ../../modules/irsa/main.tf line 37, in resource "kubernetes_service_account_v1" "irsa":
│   37: resource "kubernetes_service_account_v1" "irsa" {
│
│ Starting from version 1.24.0 Kubernetes does not automatically generate a token for service accounts, in this case, "default_secret_name" will be empty
│
│ (and one more similar warning elsewhere)
╵

Apply complete! Resources: 80 added, 0 changed, 0 destroyed.

Outputs:

configure_kubectl = "aws eks update-kubeconfig --region us-east-1 --name eks-efa"

```
</details>

> **_Note:_** If the plan apply operation fails, you can repeat `terraform plan -out tfplan` and `terraform apply tfplan`

It takes about 15 minutes to create the cluster.

## 6. Connect to EKS

Copy the value of the `configure_kubectl` output and execute it in your shell to connect to your EKS cluster.

```bash
aws eks update-kubeconfig --region us-east-1 --name eks-efa
```

Output:
```text
Updated context arn:aws:eks:us-east-1:xxxxxxxxxxxx:cluster/eks-efa in /root/.kube/config
```

Allow 5 minutes after the plan is applied for the EFA nodes to finish initializing and join the EKS cluster, then execute:

```bash
kubectl get nodes
kubectl get nodes -o yaml | grep instance-type | grep node | grep -v f:
```

Your nodes and node types will be listed:

```text
# kubectl get nodes
NAME                           STATUS   ROLES    AGE    VERSION
ip-10-11-10-103.ec2.internal   Ready    <none>   4m1s   v1.25.7-eks-a59e1f0
ip-10-11-19-28.ec2.internal    Ready    <none>   11m    v1.25.7-eks-a59e1f0
ip-10-11-2-151.ec2.internal    Ready    <none>   11m    v1.25.7-eks-a59e1f0
ip-10-11-2-18.ec2.internal     Ready    <none>   5m1s   v1.25.7-eks-a59e1f0
# kubectl get nodes -o yaml | grep instance-type | grep node | grep -v f:
      node.kubernetes.io/instance-type: g4dn.metal
      node.kubernetes.io/instance-type: m5.large
      node.kubernetes.io/instance-type: m5.large
      node.kubernetes.io/instance-type: g4dn.metal
```

You should see two EFA-enabled (in this example `g4dn.metal`) nodes in the list.
This verifies that you are connected to your EKS cluster and it is configured with EFA nodes.

## 7. Deploy Kubeflow MPI Operator

Kubeflow MPI Operator is required for running MPIJobs on EKS. We will use an MPIJob to test EFA.
To deploy the MPI operator execute the following:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubeflow/mpi-operator/v0.3.0/deploy/v2beta1/mpi-operator.yaml
```

Output:

```text
namespace/mpi-operator created
customresourcedefinition.apiextensions.k8s.io/mpijobs.kubeflow.org created
serviceaccount/mpi-operator created
clusterrole.rbac.authorization.k8s.io/kubeflow-mpijobs-admin created
clusterrole.rbac.authorization.k8s.io/kubeflow-mpijobs-edit created
clusterrole.rbac.authorization.k8s.io/kubeflow-mpijobs-view created
clusterrole.rbac.authorization.k8s.io/mpi-operator created
clusterrolebinding.rbac.authorization.k8s.io/mpi-operator created
deployment.apps/mpi-operator created
```

In addition to deploying the operator, please apply a patch to the mpi-operator clusterrole
to allow the mpi-operator service account access to `leases` resources in the `coordination.k8s.io` apiGroup.

```bash
kubectl apply -f https://raw.githubusercontent.com/aws-samples/aws-do-eks/main/Container-Root/eks/deployment/kubeflow/mpi-operator/clusterrole-mpi-operator.yaml
```

Output:

```text
clusterrole.rbac.authorization.k8s.io/mpi-operator configured
```

## 8. Test EFA

We will run two tests. The first one will show the presence of EFA adapters on our EFA-enabled nodes. The second will test EFA performance.

### 8.1. EFA Info Test

To run the EFA info test, execute the following commands:

```bash
kubectl apply -f https://raw.githubusercontent.com/aws-samples/aws-do-eks/main/Container-Root/eks/deployment/efa-device-plugin/test-efa.yaml
```

Output:

```text
mpijob.kubeflow.org/efa-info-test created
```

```bash
kubectl get pods
```

Output:

```text
NAME                           READY   STATUS      RESTARTS   AGE
efa-info-test-launcher-hckkj   0/1     Completed   2          37s
efa-info-test-worker-0         1/1     Running     0          38s
efa-info-test-worker-1         1/1     Running     0          38s
```

Once the test launcher pod enters status `Running` or `Completed`, see the test logs using the command below:

```bash
kubectl logs -f $(kubectl get pods | grep launcher | cut -d ' ' -f 1)
```

Output:

```text
Warning: Permanently added 'efa-info-test-worker-1.efa-info-test-worker.default.svc,10.11.13.224' (ECDSA) to the list of known hosts.
Warning: Permanently added 'efa-info-test-worker-0.efa-info-test-worker.default.svc,10.11.4.63' (ECDSA) to the list of known hosts.
[1,1]<stdout>:provider: efa
[1,1]<stdout>:    fabric: efa
[1,1]<stdout>:    domain: rdmap197s0-rdm
[1,1]<stdout>:    version: 116.10
[1,1]<stdout>:    type: FI_EP_RDM
[1,1]<stdout>:    protocol: FI_PROTO_EFA
[1,0]<stdout>:provider: efa
[1,0]<stdout>:    fabric: efa
[1,0]<stdout>:    domain: rdmap197s0-rdm
[1,0]<stdout>:    version: 116.10
[1,0]<stdout>:    type: FI_EP_RDM
[1,0]<stdout>:    protocol: FI_PROTO_EFA
```

This result shows that two EFA adapters are available (one for each worker pod).

Lastly, delete the test job:

```bash
kubectl delete mpijob efa-info-test
```

Output:

```text
mpijob.kubeflow.org "efa-info-test" deleted
```

### 8.2. EFA NCCL Test

To run the EFA NCCL test please execute the following kubectl command:

```bash
kubectl apply -f https://raw.githubusercontent.com/aws-samples/aws-do-eks/main/Container-Root/eks/deployment/efa-device-plugin/test-nccl-efa.yaml
```

Output:

```text
mpijob.kubeflow.org/test-nccl-efa created
```

Then display the pods in the current namespace:

```bash
kubectl get pods
```

Output:

```text
NAME                           READY   STATUS    RESTARTS      AGE
test-nccl-efa-launcher-tx47t   1/1     Running   2 (31s ago)   33s
test-nccl-efa-worker-0         1/1     Running   0             33s
test-nccl-efa-worker-1         1/1     Running   0             33s
```

Once the launcher pod enters `Running` or `Completed` state, execute the following to see the test logs:

```bash
kubectl logs -f $(kubectl get pods | grep launcher | cut -d ' ' -f 1)
```

<details>

<summary>Output:</summary>

```text
Warning: Permanently added 'test-nccl-efa-worker-1.test-nccl-efa-worker.default.svc,10.11.5.31' (ECDSA) to the list of known hosts.
Warning: Permanently added 'test-nccl-efa-worker-0.test-nccl-efa-worker.default.svc,10.11.13.106' (ECDSA) to the list of known hosts.
[1,0]<stdout>:# nThread 1 nGpus 1 minBytes 1 maxBytes 1073741824 step: 2(factor) warmup iters: 5 iters: 100 agg iters: 1 validation: 1 graph: 0
[1,0]<stdout>:#
[1,0]<stdout>:# Using devices
[1,0]<stdout>:#  Rank  0 Group  0 Pid     21 on test-nccl-efa-worker-0 device  0 [0x35] Tesla T4
[1,0]<stdout>:#  Rank  1 Group  0 Pid     21 on test-nccl-efa-worker-1 device  0 [0xf5] Tesla T4
[1,0]<stdout>:test-nccl-efa-worker-0:21:21 [0] NCCL INFO Bootstrap : Using eth0:10.11.13.106<0>
[1,0]<stdout>:test-nccl-efa-worker-0:21:21 [0] NCCL INFO NET/Plugin: Failed to find ncclCollNetPlugin_v5 symbol.
[1,0]<stdout>:test-nccl-efa-worker-0:21:21 [0] NCCL INFO NET/Plugin: Failed to find ncclCollNetPlugin_v4 symbol.
[1,0]<stdout>:test-nccl-efa-worker-0:21:21 [0] NCCL INFO NET/OFI Using aws-ofi-nccl 1.5.0aws
[1,0]<stdout>:test-nccl-efa-worker-0:21:21 [0] NCCL INFO NET/OFI Configuring AWS-specific options
[1,0]<stdout>:test-nccl-efa-worker-0:21:21 [0] NCCL INFO NET/OFI Setting NCCL_PROTO to "simple"
[1,0]<stdout>:test-nccl-efa-worker-0:21:21 [0] NCCL INFO NET/OFI Setting FI_EFA_FORK_SAFE environment variable to 1
[1,0]<stdout>:test-nccl-efa-worker-0:21:21 [0] NCCL INFO NET/OFI Selected Provider is efa (found 1 nics)
[1,0]<stdout>:test-nccl-efa-worker-0:21:21 [0] NCCL INFO Using network AWS Libfabric
[1,0]<stdout>:NCCL version 2.12.7+cuda11.4
[1,1]<stdout>:test-nccl-efa-worker-1:21:21 [0] NCCL INFO Bootstrap : Using eth0:10.11.5.31<0>
[1,1]<stdout>:test-nccl-efa-worker-1:21:21 [0] NCCL INFO NET/Plugin: Failed to find ncclCollNetPlugin_v5 symbol.
[1,1]<stdout>:test-nccl-efa-worker-1:21:21 [0] NCCL INFO NET/Plugin: Failed to find ncclCollNetPlugin_v4 symbol.
[1,1]<stdout>:test-nccl-efa-worker-1:21:21 [0] NCCL INFO NET/OFI Using aws-ofi-nccl 1.5.0aws
[1,1]<stdout>:test-nccl-efa-worker-1:21:21 [0] NCCL INFO NET/OFI Configuring AWS-specific options
[1,1]<stdout>:test-nccl-efa-worker-1:21:21 [0] NCCL INFO NET/OFI Setting NCCL_PROTO to "simple"
[1,1]<stdout>:test-nccl-efa-worker-1:21:21 [0] NCCL INFO NET/OFI Setting FI_EFA_FORK_SAFE environment variable to 1
[1,1]<stdout>:test-nccl-efa-worker-1:21:21 [0] NCCL INFO NET/OFI Selected Provider is efa (found 1 nics)
[1,1]<stdout>:test-nccl-efa-worker-1:21:21 [0] NCCL INFO Using network AWS Libfabric
[1,0]<stdout>:test-nccl-efa-worker-0:21:27 [0] NCCL INFO Setting affinity for GPU 0 to ff,ffff0000,00ffffff
[1,1]<stdout>:test-nccl-efa-worker-1:21:26 [0] NCCL INFO Setting affinity for GPU 0 to ffffff00,0000ffff,ff000000
[1,1]<stdout>:test-nccl-efa-worker-1:21:26 [0] NCCL INFO Trees [0] -1/-1/-1->1->0 [1] 0/-1/-1->1->-1
[1,0]<stdout>:test-nccl-efa-worker-0:21:27 [0] NCCL INFO Channel 00/02 :    0   1
[1,0]<stdout>:test-nccl-efa-worker-0:21:27 [0] NCCL INFO Channel 01/02 :    0   1
[1,0]<stdout>:test-nccl-efa-worker-0:21:27 [0] NCCL INFO Trees [0] 1/-1/-1->0->-1 [1] -1/-1/-1->0->1
[1,1]<stdout>:test-nccl-efa-worker-1:21:26 [0] NCCL INFO NCCL_SHM_DISABLE set by environment to 0.
[1,0]<stdout>:test-nccl-efa-worker-0:21:27 [0] NCCL INFO NCCL_SHM_DISABLE set by environment to 0.
[1,1]<stdout>:test-nccl-efa-worker-1:21:26 [0] NCCL INFO Channel 00/0 : 0[35000] -> 1[f5000] [receive] via NET/AWS Libfabric/0
[1,0]<stdout>:test-nccl-efa-worker-0:21:27 [0] NCCL INFO Channel 00/0 : 1[f5000] -> 0[35000] [receive] via NET/AWS Libfabric/0
[1,1]<stdout>:test-nccl-efa-worker-1:21:26 [0] NCCL INFO Channel 01/0 : 0[35000] -> 1[f5000] [receive] via NET/AWS Libfabric/0
[1,0]<stdout>:test-nccl-efa-worker-0:21:27 [0] NCCL INFO Channel 01/0 : 1[f5000] -> 0[35000] [receive] via NET/AWS Libfabric/0
[1,1]<stdout>:test-nccl-efa-worker-1:21:26 [0] NCCL INFO Channel 00/0 : 1[f5000] -> 0[35000] [send] via NET/AWS Libfabric/0
[1,0]<stdout>:test-nccl-efa-worker-0:21:27 [0] NCCL INFO Channel 00/0 : 0[35000] -> 1[f5000] [send] via NET/AWS Libfabric/0
[1,1]<stdout>:test-nccl-efa-worker-1:21:26 [0] NCCL INFO Channel 01/0 : 1[f5000] -> 0[35000] [send] via NET/AWS Libfabric/0
[1,0]<stdout>:test-nccl-efa-worker-0:21:27 [0] NCCL INFO Channel 01/0 : 0[35000] -> 1[f5000] [send] via NET/AWS Libfabric/0
[1,0]<stdout>:test-nccl-efa-worker-0:21:27 [0] NCCL INFO Connected all rings
[1,0]<stdout>:test-nccl-efa-worker-0:21:27 [0] NCCL INFO Connected all trees
[1,0]<stdout>:test-nccl-efa-worker-0:21:27 [0] NCCL INFO threadThresholds 8/8/64 | 16/8/64 | 8/8/512
[1,0]<stdout>:test-nccl-efa-worker-0:21:27 [0] NCCL INFO 2 coll channels, 2 p2p channels, 2 p2p channels per peer
[1,1]<stdout>:test-nccl-efa-worker-1:21:26 [0] NCCL INFO Connected all rings
[1,1]<stdout>:test-nccl-efa-worker-1:21:26 [0] NCCL INFO Connected all trees
[1,1]<stdout>:test-nccl-efa-worker-1:21:26 [0] NCCL INFO threadThresholds 8/8/64 | 16/8/64 | 8/8/512
[1,1]<stdout>:test-nccl-efa-worker-1:21:26 [0] NCCL INFO 2 coll channels, 2 p2p channels, 2 p2p channels per peer
[1,1]<stdout>:test-nccl-efa-worker-1:21:26 [0] NCCL INFO comm 0x7f9c0c000f60 rank 1 nranks 2 cudaDev 0 busId f5000 - Init COMPLETE
[1,0]<stdout>:test-nccl-efa-worker-0:21:27 [0] NCCL INFO comm 0x7fde98000f60 rank 0 nranks 2 cudaDev 0 busId 35000 - Init COMPLETE
[1,0]<stdout>:#
[1,0]<stdout>:#                                                              out-of-place                       in-place  
[1,0]<stdout>:#       size         count      type   redop    root     time   algbw   busbw #wrong     time   algbw   busbw #wrong
[1,0]<stdout>:#        (B)    (elements)                               (us)  (GB/s)  (GB/s)            (us)  (GB/s)  (GB/s)  
[1,0]<stdout>:test-nccl-efa-worker-0:21:21 [0] NCCL INFO Launch mode Parallel
[1,0]<stdout>:           0             0     float     sum      -1     6.36    0.00    0.00      0     6.40    0.00    0.00      0
[1,0]<stdout>:           0             0     float     sum      -1     6.43    0.00    0.00      0     6.35    0.00    0.00      0
[1,0]<stdout>:           4             1     float     sum      -1    65.70    0.00    0.00      0    64.84    0.00    0.00      0
[1,0]<stdout>:           8             2     float     sum      -1    64.88    0.00    0.00      0    64.18    0.00    0.00      0
[1,0]<stdout>:          16             4     float     sum      -1    64.33    0.00    0.00      0    65.02    0.00    0.00      0
[1,0]<stdout>:          32             8     float     sum      -1    65.95    0.00    0.00      0    64.78    0.00    0.00      0
[1,0]<stdout>:          64            16     float     sum      -1    65.19    0.00    0.00      0    64.66    0.00    0.00      0
[1,0]<stdout>:         128            32     float     sum      -1    65.30    0.00    0.00      0    64.76    0.00    0.00      0
[1,0]<stdout>:         256            64     float     sum      -1    65.30    0.00    0.00      0    64.90    0.00    0.00      0
[1,0]<stdout>:         512           128     float     sum      -1    65.71    0.01    0.01      0    64.75    0.01    0.01      0
[1,0]<stdout>:        1024           256     float     sum      -1    67.15    0.02    0.02      0    66.82    0.02    0.02      0
[1,0]<stdout>:        2048           512     float     sum      -1    68.22    0.03    0.03      0    67.55    0.03    0.03      0
[1,0]<stdout>:        4096          1024     float     sum      -1    70.65    0.06    0.06      0    71.20    0.06    0.06      0
[1,0]<stdout>:        8192          2048     float     sum      -1    76.15    0.11    0.11      0    75.36    0.11    0.11      0
[1,0]<stdout>:       16384          4096     float     sum      -1    87.65    0.19    0.19      0    87.87    0.19    0.19      0
[1,0]<stdout>:       32768          8192     float     sum      -1    98.94    0.33    0.33      0    98.14    0.33    0.33      0
[1,0]<stdout>:       65536         16384     float     sum      -1    115.8    0.57    0.57      0    115.7    0.57    0.57      0
[1,0]<stdout>:      131072         32768     float     sum      -1    149.3    0.88    0.88      0    148.7    0.88    0.88      0
[1,0]<stdout>:      262144         65536     float     sum      -1    195.0    1.34    1.34      0    194.0    1.35    1.35      0
[1,0]<stdout>:      524288        131072     float     sum      -1    296.9    1.77    1.77      0    291.1    1.80    1.80      0
[1,0]<stdout>:     1048576        262144     float     sum      -1    583.4    1.80    1.80      0    579.6    1.81    1.81      0
[1,0]<stdout>:     2097152        524288     float     sum      -1    983.3    2.13    2.13      0    973.9    2.15    2.15      0
[1,0]<stdout>:     4194304       1048576     float     sum      -1   1745.4    2.40    2.40      0   1673.2    2.51    2.51      0
[1,0]<stdout>:     8388608       2097152     float     sum      -1   3116.1    2.69    2.69      0   3092.6    2.71    2.71      0
[1,0]<stdout>:    16777216       4194304     float     sum      -1   5966.3    2.81    2.81      0   6008.9    2.79    2.79      0
[1,0]<stdout>:    33554432       8388608     float     sum      -1    11390    2.95    2.95      0    11419    2.94    2.94      0
[1,0]<stdout>:    67108864      16777216     float     sum      -1    21934    3.06    3.06      0    21930    3.06    3.06      0
[1,0]<stdout>:   134217728      33554432     float     sum      -1    43014    3.12    3.12      0    42619    3.15    3.15      0
[1,0]<stdout>:   268435456      67108864     float     sum      -1    85119    3.15    3.15      0    85743    3.13    3.13      0
[1,0]<stdout>:   536870912     134217728     float     sum      -1   171351    3.13    3.13      0   171823    3.12    3.12      0
[1,0]<stdout>:  1073741824     268435456     float     sum      -1   344981    3.11    3.11      0   344454    3.12    3.12      0
[1,1]<stdout>:test-nccl-efa-worker-1:21:21 [0] NCCL INFO comm 0x7f9c0c000f60 rank 1 nranks 2 cudaDev 0 busId f5000 - Destroy COMPLETE
[1,0]<stdout>:test-nccl-efa-worker-0:21:21 [0] NCCL INFO comm 0x7fde98000f60 rank 0 nranks 2 cudaDev 0 busId 35000 - Destroy COMPLETE
[1,0]<stdout>:# Out of bounds values : 0 OK
[1,0]<stdout>:# Avg bus bandwidth    : 1.15327
[1,0]<stdout>:#
[1,0]<stdout>:
```
</details>


The following section from the beginning of the log, indicates that the test is being performed using EFA:

```text
[1,0]<stdout>:test-nccl-efa-worker-0:21:21 [0] NCCL INFO NET/OFI Selected Provider is efa (found 1 nics)
[1,0]<stdout>:test-nccl-efa-worker-0:21:21 [0] NCCL INFO Using network AWS Libfabric
[1,0]<stdout>:NCCL version 2.12.7+cuda11.4
```

Columns 8 and 12 in the output table show the in-place and out-of-place bus bandwidth calculated for the data size listed in column 1. In this case it is 3.13 and 3.12 GB/s respectively.
Your actual results may be slightly different. The calculated average bus bandwidth is displayed at the bottom of the log when the test finishes after it reaches the max data size,
specified in the mpijob manifest. In this result the average bus bandwidth is 1.15 GB/s.

```
[1,0]<stdout>:#       size         count      type   redop    root     time   algbw   busbw #wrong     time   algbw   busbw #wrong
[1,0]<stdout>:#        (B)    (elements)                               (us)  (GB/s)  (GB/s)            (us)  (GB/s)  (GB/s)  
...
[1,0]<stdout>:      262144         65536     float     sum      -1    195.0    1.34    1.34      0    194.0    1.35    1.35      0
[1,0]<stdout>:      524288        131072     float     sum      -1    296.9    1.77    1.77      0    291.1    1.80    1.80      0
[1,0]<stdout>:     1048576        262144     float     sum      -1    583.4    1.80    1.80      0    579.6    1.81    1.81      0
[1,0]<stdout>:     2097152        524288     float     sum      -1    983.3    2.13    2.13      0    973.9    2.15    2.15      0
[1,0]<stdout>:     4194304       1048576     float     sum      -1   1745.4    2.40    2.40      0   1673.2    2.51    2.51      0
...
[1,0]<stdout>:# Avg bus bandwidth    : 1.15327
```

Finally, delete the test mpi job:

```bash
kubectl delete mpijob test-nccl-efa
```

Output:

```text
mpijob.kubeflow.org "test-nccl-efa" deleted
```

## 9. Cleanup

```bash
terraform destroy
```

<details>
<summary>Output:</summary>

```text
...
 # module.eks.module.self_managed_node_group["efa"].aws_iam_role.this[0] will be destroyed
...

Plan: 0 to add, 0 to change, 80 to destroy.

Changes to Outputs:
  - configure_kubectl = "aws eks update-kubeconfig --region us-east-1 --name eks-efa" -> null

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes
  ...
  module.eks.aws_iam_role.this[0]: Destruction complete after 1s
module.eks.aws_security_group_rule.node["ingress_self_coredns_udp"]: Destruction complete after 2s
module.eks.aws_security_group_rule.node["ingress_cluster_9443_webhook"]: Destruction complete after 3s
module.eks.aws_security_group_rule.node["ingress_cluster_443"]: Destruction complete after 3s
module.eks.aws_security_group_rule.node["egress_all"]: Destruction complete after 2s
module.eks.aws_security_group_rule.node["egress_self_all"]: Destruction complete after 3s
module.eks.aws_security_group_rule.node["ingress_nodes_ephemeral"]: Destruction complete after 3s
module.eks.aws_security_group_rule.node["ingress_cluster_8443_webhook"]: Destruction complete after 3s
module.eks.aws_security_group_rule.node["ingress_self_coredns_tcp"]: Destruction complete after 4s
module.eks.aws_security_group.cluster[0]: Destroying... [id=sg-05516650e2f2ed6c1]
module.eks.aws_security_group.node[0]: Destroying... [id=sg-0e421877145f36d48]
module.eks.aws_security_group.cluster[0]: Destruction complete after 1s
module.eks.aws_security_group.node[0]: Destruction complete after 1s
module.vpc.aws_vpc.this[0]: Destroying... [id=vpc-04677b1ab4eac3ca7]
module.vpc.aws_vpc.this[0]: Destruction complete after 0s
╷
│ Warning: EC2 Default Network ACL (acl-0932148c7d86482e0) not deleted, removing from state
╵

Destroy complete! Resources: 80 destroyed.
```

</details>

The cleanup process takes about 15 minutes.

# Conclusion

With this example, we have demonstrated how AWS EKS Blueprints can be used to create an EKS cluster with an
EFA-enabled nodegroup. Futhermore, we have shown how to run MPI Jobs to validate that EFA works and check its performance.
Use this example as a starting point to bootstrap your own infrastructure-as-code terraform projects that require use
of high-performance networking on AWS with Elastic Fabric Adapter.
