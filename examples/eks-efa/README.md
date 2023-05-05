# EKS Blueprint Example with Elastic Fabric Adapter

## Table of content

- [EKS Blueprint Example with Elastic Fabric Adapter](#eks-blueprint-example-with-elastic-fabric-adapter)
  - [Table of content](#table-of-content)
  - [Elastic Fabric Adapter Overview](#elastic-fabric-adapter-overview)
  - [Setup Details](setup-details)
- [Terraform Doc](#terraform-doc)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
- [Example Walkthrough](#example-walkthrough)
  - [1. Clone Repository](#clone-repository)
  - [2. Configure Terraform Plan](#configure-terraform-plan)
  - [3. Initialize Terraform Plan](#initialize-terraform-plan)
  - [4. Create Terraform Plan](#create-terraform-plan)
  - [5. Apply Terraform Plan](#apply-terraform-plan)
  - [6. Test EFA](#test-efa)
  - [7. Cleanup](#cleanup)

## Elastic Fabric Adapter Overview

[Elastic Fabric Adapter (EFA)](https://aws.amazon.com/hpc/efa/) is a network interface supported by [some Amazon EC2 instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/efa.html#efa-instance-types) that provides high-performance network communications at scale on AWS. Commonly, high-performance computing, simulation, and large AI model training jobs require EFA, in order to minimize the time to job completion. This example provides a blueprint for deploying an [Amazon EKS](https://aws.amazon.com/eks/) cluster with EFA-enabled nodes, which can be used to run such jobs.

## Setup Details

There are three requirements that need to be satisfied, in order for EFA to work:

1. The EC2 instance type must support EFA and the EFA adapter must be enabled.
2. The EFA software must be installed
3. The security group attached to the EC2 instance must allow all incoming and outgoing traffic to itself

In the provided Terraform EKS Blueprint example here, these requirements are satisfied automatically.  

# Terraform Doc

See [main.tf](main.tf)

## Requirements

## Providers

See [providers.tf](providers.tf)

## Modules

## Resources

## Inputs

## Outputs

See [outputs.tf](outputs.tf)


# Example Walkthrough

## 1. Clone Repository

```bash
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
cd terraform-aws-eks-bluerpints
```

## 2. Configure Terraform Plan

Edit `variables.tf` and the locals section of `main.tf` as needed.

## 3. Initialize Terraform Plan

```bash
terraform init
```

## 4. Create Terraform Plan

```bash
terraform plan -out tfplan
```
  
## 5. Apply Terraform Plan

```bash
terraform apply tfplan
```

## 6. Test EFA

```bash
kubectl apply -f https://raw.githubusercontent.com/aws-samples/aws-do-eks/main/Container-Root/eks/deployment/efa-device-plugin/test-nccl-efa.yaml
```

<details>

<summary>Output:</summary>

```txt
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

## 7. Cleanup

```bash
terraform destroy
```