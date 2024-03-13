# EKS Cluster w/ Elastic Fabric Adapter

This pattern demonstrates an Amazon EKS Cluster with an EFA-enabled nodegroup.

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

## Validate

!!! note

    The following steps are shown with `g5.8xlarge` due to cost and availability. Values shown below will change based on the instance type selected (i.e. - `p5.48xlarge` has 8 GPUs and 32 EFA interfaces)

1. List the nodes by instance type:

    ```sh
    kubectl get nodes -o yaml | grep instance-type | grep node | grep -v f:
    ```

    ```text
    node.kubernetes.io/instance-type: g5.8xlarge
    node.kubernetes.io/instance-type: m5.large
    node.kubernetes.io/instance-type: m5.large
    node.kubernetes.io/instance-type: g5.8xlarge
    ```

    You should see two EFA-enabled (in this example `g5.8xlarge`) nodes in the list.

2. Deploy Kubeflow MPI Operator

    Kubeflow MPI Operator is required for running MPIJobs on EKS. We will use an MPIJob to test EFA.
    To deploy the MPI operator execute the following:

    ```sh
    kubectl apply -f https://raw.githubusercontent.com/kubeflow/mpi-operator/v0.3.0/deploy/v2beta1/mpi-operator.yaml
    ```

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

    ```sh
    kubectl apply -f https://raw.githubusercontent.com/aws-samples/aws-do-eks/main/Container-Root/eks/deployment/kubeflow/mpi-operator/clusterrole-mpi-operator.yaml
    ```

    ```text
    clusterrole.rbac.authorization.k8s.io/mpi-operator configured
    ```

3. EFA test

    The results should shown that two EFA adapters are available (one for each worker pod)

    ```sh
    kubectl apply -f https://raw.githubusercontent.com/aws-samples/aws-do-eks/main/Container-Root/eks/deployment/efa-device-plugin/test-efa.yaml
    ```

    ```text
    mpijob.kubeflow.org/efa-info-test created
    ```

    Once the test launcher pod enters status `Running` or `Completed`, see the test logs using the command below:

    ```sh
    kubectl logs -f $(kubectl get pods | grep launcher | cut -d ' ' -f 1)
    ```

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

4. EFA NCCL test

    To run the EFA NCCL test please execute the following kubectl command:

    ```sh
    kubectl apply -f https://raw.githubusercontent.com/aws-samples/aws-do-eks/main/Container-Root/eks/deployment/efa-device-plugin/test-nccl-efa.yaml
    ```

    ```text
    mpijob.kubeflow.org/test-nccl-efa created
    ```

    Once the launcher pod enters `Running` or `Completed` state, execute the following to see the test logs:

    ```sh
    kubectl logs -f $(kubectl get pods | grep launcher | cut -d ' ' -f 1)
    ```

    ```text
    [1,0]<stdout>:test-nccl-efa-worker-0:21:21 [0] NCCL INFO NET/OFI Selected Provider is efa (found 1 nics)
    [1,0]<stdout>:test-nccl-efa-worker-0:21:21 [0] NCCL INFO Using network AWS Libfabric
    [1,0]<stdout>:NCCL version 2.12.7+cuda11.4
    ```

    Columns 8 and 12 in the output table show the in-place and out-of-place bus bandwidth calculated for the data size listed in column 1. In this case it is 3.13 and 3.12 GB/s respectively.
    Your actual results may be slightly different. The calculated average bus bandwidth is displayed at the bottom of the log when the test finishes after it reaches the max data size,
    specified in the mpijob manifest. In this result the average bus bandwidth is 1.15 GB/s.

    ```text
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

## Destroy

{%
   include-markdown "../../docs/_partials/destroy.md"
%}
