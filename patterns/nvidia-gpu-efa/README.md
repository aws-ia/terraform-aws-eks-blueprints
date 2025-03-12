# EKS Cluster w/ NVIDIA GPUs and EFA for Machine Learning

This pattern demonstrates an Amazon EKS Cluster with an EFA-enabled nodegroup that utilizes `p5.48xlarge` instances with H100 NVIDIA GPUs used in distributed, multi-node machine learning.

The following components are demonstrated in this pattern:

- A "default" node group that supports addons and components that do not require GPUs nor EFA devices. Any pods that do not tolerate the taints of the GPU node group will be scheduled on instances within this node group.
- A node group of `p5.48xlarge` instances with:
    - all x32 [EFA network interfaces](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/efa.html) enabled
    - provisioned within a placement group so that the instances are provisioned close to one another in a single availability zone that supports the instance type
    - a common NVIDIA taint of `"nvidia.com/gpu:NoSchedule"` to ensure only the intended applications are allowed to run on the nodes created
    - two labels to identify that this nodegroup supports NVIDIA GPUs and EFA devices and allow pods to use node selectors with these labels
    - the NVME instance store volumes are mounted in a RAID-0 array to provide a single, large, high-performance storage volume for the GPU workloads
    - kubelet and containerd are configured to utilize the RAID-0 volume, allowing kubelet to discover the additional storage as ephemeral storage that can be utilized by pods
- A Helm chart deployment for the [NVIDIA device plugin](https://github.com/NVIDIA/k8s-device-plugin) to expose and mount the GPUs provided by the instances to the pods that request them
- A Helm chart deployment for the EFA device plugin to expose and mount the EFA network interfaces provided by the instances to the pods that request them. Since the EFA network interfaces are only found on the instances that provide NVIDIA GPUs in this pattern, we do not apply an additional taint for the EFA network interfaces to avoid over-constraining.

## Code

### Cluster

```terraform hl_lines="32-35 40-86"
{% include  "../../patterns/nvidia-gpu-efa/eks.tf" %}
```

### Device Plugins

```terraform hl_lines="5-33"
{% include  "../../patterns/nvidia-gpu-efa/helm.tf" %}
```

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

## Validate

!!! note
    Desired instance type can be specified in [eks.tf](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/d5ddd10afef9b4fd3e0cbba865645f0f522992ac/patterns/nvidia-gpu-efa/eks.tf#L38).
    Values shown below will change based on the instance type selected (i.e. - `p5.48xlarge` has 8 GPUs and 32 EFA interfaces).
    A list of EFA-enabled instance types is available [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/efa.html#efa-instance-types).
    If you are using an on-demand capacity reservation (ODCR) for your instance type, please uncomment the `capacity_reservation_specification` block in `eks.tf`
    and specify a capacity_reservation_id. Please ensure that the region and availability zone of your ODCR match the ones used in `main.tf`.

1. List the nodes and their instance type:

    ```sh
    kubectl get nodes -L node.kubernetes.io/instance-type
    ```

    ```text
    NAME                                        STATUS   ROLES    AGE   VERSION               INSTANCE-TYPE
    ip-10-0-1-16.us-east-2.compute.internal     Ready    <none>   12h   v1.32.0-eks-ae9a62a   p5.48xlarge
    ip-10-0-12-113.us-east-2.compute.internal   Ready    <none>   14h   v1.32.0-eks-ae9a62a   m5.large
    ip-10-0-12-201.us-east-2.compute.internal   Ready    <none>   12h   v1.32.0-eks-ae9a62a   p5.48xlarge
    ip-10-0-46-217.us-east-2.compute.internal   Ready    <none>   14h   v1.32.0-eks-ae9a62a   m5.large

    ```

    You should see two EFA-enabled (in this example `p5.48xlarge`) nodes in the list.

2. Deploy Kubeflow MPI Operator

    Kubeflow MPI Operator is required for running MPIJobs on EKS. We will use an MPIJob to test EFA.
    To deploy the MPI operator execute the following:

    ```sh
    kubectl apply --server-side -f https://raw.githubusercontent.com/kubeflow/mpi-operator/v0.6.0/deploy/v2beta1/mpi-operator.yaml
    ```

    ```text
    namespace/mpi-operator serverside-applied
    customresourcedefinition.apiextensions.k8s.io/mpijobs.kubeflow.org serverside-applied
    serviceaccount/mpi-operator serverside-applied
    clusterrole.rbac.authorization.k8s.io/kubeflow-mpijobs-admin serverside-applied
    clusterrole.rbac.authorization.k8s.io/kubeflow-mpijobs-edit serverside-applied
    clusterrole.rbac.authorization.k8s.io/kubeflow-mpijobs-view serverside-applied
    clusterrole.rbac.authorization.k8s.io/mpi-operator serverside-applied
    clusterrolebinding.rbac.authorization.k8s.io/mpi-operator serverside-applied
    deployment.apps/mpi-operator serverside-applied
    ```

3. EFA info test

    This test prints a list of available EFA interfaces by using the `/opt/amazon/efa/bin/fi_info` utility.
    The script [generate-efa-info-test.sh](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/patterns/nvidia-gpu-efa/generate-efa-info-test.sh) creates an MPIJob manifest file named `efa-info-test.yaml`. It assumes that there are two cluster nodes with 8 GPU's per node and 32 EFA adapters. If you are not using `p5.48xlarge` instances in your cluster, you may adjust the settings in the script prior to running it.

    `NUM_WORKERS` - number of nodes you want to run the test on
    `GPU_PER_WORKER` - number of GPUs available on each node
    `EFA_PER_WORKER` - number of EFA interfaces available on each node

    ```sh
    ./generate-efa-info-test.sh
    ```

    To start the test apply the generated manifest to the cluster:

    ```sh
    kubectl apply --server-side -f ./efa-info-test.yaml
    ```

    ```text
    mpijob.kubeflow.org/efa-info-test created
    ```

    Observe the pods in the current namespace. You should see a launcher pod and worker pods.
    It is normal for the launcher pod to restart a few times until the worker pods are fully running.

    ```sh
    watch kubectl get pods
    ```

    ```log
    NAME                           READY   STATUS             RESTARTS      AGE
    efa-info-test-launcher-wm8pm   0/1     CrashLoopBackOff   1 (16s ago)   19s
    efa-info-test-worker-0         1/1     Running            0             19s
    efa-info-test-worker-1         1/1     Running            0             19s
    ```

    ```log
    NAME                           READY   STATUS    RESTARTS      AGE
    efa-info-test-launcher-wm8pm   1/1     Running   2 (18s ago)   21s
    efa-info-test-worker-0         1/1     Running   0             21s
    efa-info-test-worker-1         1/1     Running   0             21s
    ```

    ```log
    NAME                           READY   STATUS      RESTARTS   AGE
    efa-info-test-launcher-wm8pm   0/1     Completed   2          5m20s
    ```

    Once the test launcher pod enters status `Running` or `Completed`,
    see the test logs using the command below:

    ```sh
    kubectl logs -f $(kubectl get pods | grep launcher | cut -d ' ' -f 1)
    ```

    ```log
    Warning: Permanently added 'efa-info-test-worker-1.efa-info-test.default.svc' (ED25519) to the list of known hosts.
    Warning: Permanently added 'efa-info-test-worker-0.efa-info-test.default.svc' (ED25519) to the list of known hosts.
    [1,1]<stdout>:provider: efa
    [1,1]<stdout>:    fabric: efa
    [1,1]<stdout>:    domain: rdmap79s0-rdm
    [1,1]<stdout>:    version: 120.10
    [1,1]<stdout>:    type: FI_EP_RDM
    [1,1]<stdout>:    protocol: FI_PROTO_EFA

    ...

    [1,0]<stdout>:provider: efa
    [1,0]<stdout>:    fabric: efa
    [1,0]<stdout>:    domain: rdmap201s0-rdm
    [1,0]<stdout>:    version: 120.10
    [1,0]<stdout>:    type: FI_EP_RDM
    [1,0]<stdout>:    protocol: FI_PROTO_EFA
    ```

    Finally, remove the job:

    ```sh
    kubectl delete -f ./efa-info-test.yaml
    ```

4. EFA NCCL test

    The EFA NCCL test is used to measure network bandwidth by running the `/opt/nccl-tests/build/all_reduce_perf` utility.
    Create an MPIjob manifest by executing the script below:

    ```sh
    ./generate-efa-nccl-test.sh
    ```

    This script creates a file named `efa-nccl-test.yaml`. Apply the manifest to start the EFA nccl test.

    ```sh
    kubectl apply --server-side -f ./efa-nccl-test.yaml

    ```text
    mpijob.kubeflow.org/efa-nccl-test created
    ```

    Similarly to the EFA info test, a launcher and worker pods will be created. The launcher pod will be
    in CrashLoopBackoff mode until the worker pods enter Running state.
    As soon as the launcher pod enters Running state as well, execute the following command to see the test logs:

    ```sh
    kubectl logs -f $(kubectl get pods | grep launcher | cut -d ' ' -f 1)
    ```

    ```text
    ...
    [1,0]<stdout>:#                                                              out-of-place                       in-place
    [1,0]<stdout>:#       size         count      type   redop    root     time   algbw   busbw #wrong     time   algbw   busbw #wrong
    [1,0]<stdout>:#        (B)    (elements)                               (us)  (GB/s)  (GB/s)            (us)  (GB/s)  (GB/s)
    [1,0]<stdout>:           8             2     float     sum      -1    87.96    0.00    0.00      0    78.05    0.00    0.00      0
    [1,0]<stdout>:          16             4     float     sum      -1    76.83    0.00    0.00      0    77.15    0.00    0.00      0
    [1,0]<stdout>:          32             8     float     sum      -1    77.37    0.00    0.00      0    75.38    0.00    0.00      0
    [1,0]<stdout>:          64            16     float     sum      -1    77.60    0.00    0.00      0    79.80    0.00    0.00      0
    [1,0]<stdout>:         128            32     float     sum      -1    77.20    0.00    0.00      0    77.78    0.00    0.00      0
    [1,0]<stdout>:         256            64     float     sum      -1    78.46    0.00    0.01      0    80.39    0.00    0.01      0
    [1,0]<stdout>:         512           128     float     sum      -1    77.56    0.01    0.01      0    78.00    0.01    0.01      0
    [1,0]<stdout>:        1024           256     float     sum      -1    76.98    0.01    0.02      0    78.52    0.01    0.02      0
    [1,0]<stdout>:        2048           512     float     sum      -1    77.92    0.03    0.05      0    78.64    0.03    0.05      0
    [1,0]<stdout>:        4096          1024     float     sum      -1    83.26    0.05    0.09      0    83.16    0.05    0.09      0
    [1,0]<stdout>:        8192          2048     float     sum      -1    88.46    0.09    0.17      0    86.32    0.09    0.18      0
    [1,0]<stdout>:       16384          4096     float     sum      -1    97.22    0.17    0.32      0    94.82    0.17    0.32      0
    [1,0]<stdout>:       32768          8192     float     sum      -1    98.84    0.33    0.62      0    99.85    0.33    0.62      0
    [1,0]<stdout>:       65536         16384     float     sum      -1    101.1    0.65    1.22      0    96.80    0.68    1.27      0
    [1,0]<stdout>:      131072         32768     float     sum      -1    100.5    1.30    2.44      0    99.13    1.32    2.48      0
    [1,0]<stdout>:      262144         65536     float     sum      -1    104.5    2.51    4.70      0    102.2    2.57    4.81      0
    [1,0]<stdout>:      524288        131072     float     sum      -1    108.8    4.82    9.04      0    109.8    4.78    8.96      0
    [1,0]<stdout>:     1048576        262144     float     sum      -1    119.1    8.81   16.51      0    121.5    8.63   16.18      0
    [1,0]<stdout>:     2097152        524288     float     sum      -1    145.8   14.39   26.97      0    144.7   14.49   27.17      0
    [1,0]<stdout>:     4194304       1048576     float     sum      -1    163.2   25.70   48.19      0    162.4   25.82   48.42      0
    [1,0]<stdout>:     8388608       2097152     float     sum      -1    197.9   42.38   79.46      0    197.9   42.39   79.48      0
    [1,0]<stdout>:    16777216       4194304     float     sum      -1    282.3   59.43  111.43      0    290.3   57.79  108.35      0
    [1,0]<stdout>:    33554432       8388608     float     sum      -1    442.8   75.77  142.07      0    417.4   80.39  150.73      0
    [1,0]<stdout>:    67108864      16777216     float     sum      -1    597.4  112.34  210.64      0    591.6  113.43  212.68      0
    [1,0]<stdout>:   134217728      33554432     float     sum      -1    872.0  153.92  288.60      0    872.8  153.78  288.34      0
    [1,0]<stdout>:   268435456      67108864     float     sum      -1   1501.2  178.81  335.27      0   1503.1  178.59  334.86      0
    [1,0]<stdout>:   536870912     134217728     float     sum      -1   2599.4  206.54  387.26      0   2553.0  210.29  394.29      0
    [1,0]<stdout>:  1073741824     268435456     float     sum      -1   4556.5  235.65  441.85      0   5274.0  203.59  381.74      0
    [1,0]<stdout>:  2147483648     536870912     float     sum      -1   9079.2  236.53  443.49      0   9128.1  235.26  441.11      0
    [1,0]<stdout>:  4294967296    1073741824     float     sum      -1    17320  247.98  464.96      0    17270  248.70  466.31      0
    [1,0]<stdout>:  8589934592    2147483648     float     sum      -1    33611  255.57  479.19      0    34474  249.17  467.20      0
    [1,0]<stdout>: 17179869184    4294967296     float     sum      -1    66988  256.46  480.87      0    66717  257.50  482.82      0
    [1,0]<stdout>:# Out of bounds values : 0 OK
    [1,0]<stdout>:# Avg bus bandwidth    : 123.343
    ```

    Columns 9 and 13 in the output table show the in-place and out-of-place bus bandwidth calculated for the data size listed in column 2.
    In this case it is at maximum 444.31 and 444.41 GB/s respectively.
    Your actual results may be slightly different. The calculated average bus bandwidth is displayed at the end of the log.
    In this test run the average bus bandwidth was 79.9352 GB/s.

    Lastly, delete the MPIJob:

    ```sh
    kubectl delete -f ./efa-nccl-test.yaml
    ```

## Destroy

{%
   include-markdown "../../docs/_partials/destroy.md"
%}
