# Multi-Node Inference w/ vLLM

This pattern demonstrates an Amazon EKS Cluster with an EFA-enabled nodegroup that support multi-node inference using vLLM, kuberay, and lws (LeaderWorkerSet).

This example is based off the LWS example found [here](https://github.com/kubernetes-sigs/lws/tree/main/docs/examples/vllm/GPU)

The following components are demonstrated in this pattern:

- A "default" node group that supports addons and components that do not require GPUs nor EFA devices. Any pods that do not tolerate the taints of the GPU node group will be scheduled on instances within this node group.
- A node group of `g6e.8xlarge` instances with:
    - all [EFA network interfaces](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/efa.html) enabled
    - provisioned within a placement group so that the instances are provisioned close to one another in a single availability zone that supports the instance type
    - a common NVIDIA taint of `"nvidia.com/gpu:NoSchedule"` to ensure only the intended applications are allowed to run on the nodes created
    - two labels to identify that this nodegroup supports NVIDIA GPUs and EFA devices and allow pods to use node selectors with these labels
    - the NVME instance store volumes are mounted in a RAID-0 array to provide a single, large, high-performance storage volume for the GPU workloads
        - kubelet and containerd are configured to utilize the RAID-0 volume, allowing kubelet to discover the additional storage as ephemeral storage that can be utilized by pods
- A Helm chart deployment for the [NVIDIA device plugin](https://github.com/NVIDIA/k8s-device-plugin) to expose and mount the GPUs provided by the instances to the pods that request them
- A Helm chart deployment for the EFA device plugin to expose and mount the EFA network interfaces provided by the instances to the pods that request them. Since the EFA network interfaces are only found on the instances that provide NVIDIA GPUs in this pattern, we do not apply an additional taint for the EFA network interfaces to avoid over-constraining.
- Helm charts for [Kuberay and a Ray cluster](https://docs.ray.io/en/latest/cluster/kubernetes/index.html) as well as [lws (LeaderWorkerSet)](https://github.com/kubernetes-sigs/lws) to demonstrate multi-node inference using vLLM
- A Dockerfile that demonstrates how to build a container image with the necessary collective communication libraries for multi-node inference with EFA. An ECR repository is created as part of the deployment to store the container image.

## Code

### Cluster

```terraform hl_lines="32-34 52-94"
{% include  "../../patterns/multi-node-vllm/eks.tf" %}
```

### Helm Charts

```terraform
{% include  "../../patterns/multi-node-vllm/helm.tf" %}
```

### Dockerfile

```dockerfile hl_lines="6-69 75-80"
{% include  "../../patterns/multi-node-vllm/Dockerfile" %}
```

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

## Validate

1. List the nodes and their instance type:

    ```sh
    kubectl get nodes -L node.kubernetes.io/instance-type
    ```

    ```text
    NAME                                        STATUS   ROLES    AGE    VERSION               INSTANCE-TYPE
    ip-10-0-20-54.us-east-2.compute.internal    Ready    <none>   12m    v1.31.4-eks-aeac579   g6e.8xlarge
    ip-10-0-23-209.us-east-2.compute.internal   Ready    <none>   12m    v1.31.4-eks-aeac579   g6e.8xlarge
    ip-10-0-26-209.us-east-2.compute.internal   Ready    <none>   12m    v1.31.4-eks-aeac579   m7a.xlarge
    ip-10-0-40-21.us-east-2.compute.internal    Ready    <none>   12m    v1.31.4-eks-aeac579   m7a.xlarge
    ```

2. Verify that the kuberay-operator, Ray cluster, lws, EFA device plugin, and NVIDIA device plugin pods are running:

    ```sh
    kubectl get pods -A
    ```

    ```text
    NAMESPACE              NAME                                           READY   STATUS    RESTARTS   AGE
    kube-system            aws-efa-k8s-device-plugin-4b4jh                1/1     Running   0          2m
    kube-system            aws-efa-k8s-device-plugin-h2vqn                1/1     Running   0          2m
    kube-system            aws-node-rdx66                                 2/2     Running   0          2m
    kube-system            aws-node-w9d8t                                 2/2     Running   0          2m
    kube-system            aws-node-xs7wv                                 2/2     Running   0          2m
    kube-system            aws-node-xtslm                                 2/2     Running   0          2m
    kube-system            coredns-6b94694fcb-kct65                       1/1     Running   0          2m
    kube-system            coredns-6b94694fcb-tzg25                       1/1     Running   0          2m
    kube-system            kube-proxy-4znrq                               1/1     Running   0          2m
    kube-system            kube-proxy-bkzmz                               1/1     Running   0          2m
    kube-system            kube-proxy-brpt5                               1/1     Running   0          2m
    kube-system            kube-proxy-f9qvw                               1/1     Running   0          2m
    kuberay-operator       kuberay-operator-5dd6779f94-nqflv              1/1     Running   0          2m
    lws-system             lws-controller-manager-fbb6489f9-hrltq         1/1     Running   0          2m
    lws-system             lws-controller-manager-fbb6489f9-hxdpj         1/1     Running   0          2m
    nvidia-device-plugin   nvidia-device-plugin-g5lwg                     1/1     Running   0          2m
    nvidia-device-plugin   nvidia-device-plugin-v6gkj                     1/1     Running   0          2m
    ray-cluster            ray-cluster-kuberay-head-4knnz                 1/1     Running   0          2m
    ray-cluster            ray-cluster-kuberay-workergroup-worker-h5brb   1/1     Running   0          2m
    ```

3. Build and push the provided Dockerfile as a container image into ECR (the `build.sh` file is created as part of `terraform apply`):

    ```sh
    ./build.sh
    ```

4. Update the provided `lws.yaml` file with your HuggingFace token that will be used to pull down the `meta-llama/Llama-3.1-8B-Instruct` model used in this example.

5. Deploy the LeaderWorkerSet and its associated K8s service:

    ```sh
    kubectl apply -f lws.yaml
    kubectl apply -f service.yaml
    kubectl get pods
    ```

    ```text
    NAME       READY   STATUS    RESTARTS   AGE
    vllm-0     1/1     Running   0          1m
    vllm-0-1   1/1     Running   0          1m
    ```

6. Verify that the distributed tensor-parallel inference works:

    ```sh
    kubectl logs vllm-0 |grep -i "Loading model weights took"
    ```

    Should get an output similar to this:

    ```text
    INFO 01-30 11:53:52 model_runner.py:1115] Loading model weights took 7.5100 GB
    (RayWorkerWrapper pid=263, ip=10.0.16.95) INFO 01-30 11:53:53 model_runner.py:1115] Loading model weights took 7.5100 GB
    ```

7. Use kubectl port-forward to forward local port 8080:

    ```sh
    kubectl port-forward svc/vllm-leader 8080:8080
    ```

8. Open another terminal and send a request to the model:

    ```sh
    curl -s http://localhost:8080/v1/completions \
    -H "Content-Type: application/json" \
    -d '{
        "model": "meta-llama/Llama-3.1-8B-Instruct",
        "prompt": "San Francisco is a",
        "max_tokens": 7,
        "temperature": 0
    }' | jq
    ```

    The output should be similar to the following

    ```json
    {
        "id": "cmpl-7b171b2a1a5b4f56805e721a60b923f4",
        "object": "text_completion",
        "created": 1738278714,
        "model": "meta-llama/Llama-3.1-8B-Instruct",
        "choices": [
            {
            "index": 0,
            "text": " top tourist destination, and for good",
            "logprobs": null,
            "finish_reason": "length",
            "stop_reason": null,
            "prompt_logprobs": null
            }
        ],
        "usage": {
            "prompt_tokens": 5,
            "total_tokens": 12,
            "completion_tokens": 7,
            "prompt_tokens_details": null
        }
    }
    ```

## Destroy

{%
   include-markdown "../../docs/_partials/destroy.md"
%}
