# Multi-Node Inference w/ vLLM

This pattern demonstrates an Amazon EKS Cluster with an EFA-enabled nodegroup that support multi-node inference using vLLM, and lws (LeaderWorkerSet).

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
- A Dockerfile that demonstrates how to build a container image with the necessary collective communication libraries for multi-node inference with EFA. An ECR repository is created as part of the deployment to store the container image.

## Code

### Cluster

```terraform hl_lines="30-32 50-97"
{% include  "../../patterns/multi-node-vllm/eks.tf" %}
```

### Helm Charts

```terraform hl_lines="39-56"
{% include  "../../patterns/multi-node-vllm/helm.tf" %}
```

### Dockerfile

```dockerfile hl_lines="6-69 75-80"
{% include  "../../patterns/multi-node-vllm/Dockerfile" %}
```

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

!!! warning
    This example provisions two `g6e.8xlarge` instances, which will require at lest 64 vCPU in the `Running On-Demand G and VT instances` EC2 service quota (Maximum number of vCPUs assigned to the Running On-Demand G and VT instances). If you fail to see the `g6e.8xlarge` instances provision, and the following error in the Autoscaling events log, please navigate to the Service Quotas section in the AWS console and request a quota increase for `Running On-Demand G and VT instances` to at least 64.

    > Could not launch On-Demand Instances. VcpuLimitExceeded - You have requested more vCPU capacity than your current vCPU limit of 0 allows for the instance bucket that the specified instance type belongs to. Please visit http://aws.amazon.com/contact-us/ec2-request to request an adjustment to this limit. Launching EC2 instance failed.

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

2. Verify that the lws, EFA device plugin, and NVIDIA device plugin pods are running:

    ```sh
    kubectl get pods -A
    ```

    ```text
    NAMESPACE              NAME                                     READY   STATUS    RESTARTS   AGE
    kube-system            aws-efa-k8s-device-plugin-9jxp9          1/1     Running   0          56m
    kube-system            aws-efa-k8s-device-plugin-hrwfm          1/1     Running   0          6h34m
    kube-system            aws-efa-k8s-device-plugin-lzpfs          1/1     Running   0          6h34m
    kube-system            aws-efa-k8s-device-plugin-z5j46          1/1     Running   0          56m
    kube-system            aws-node-9hph2                           2/2     Running   0          7h6m
    kube-system            aws-node-ddwr5                           2/2     Running   0          7h5m
    kube-system            aws-node-g9zgq                           2/2     Running   0          7h6m
    kube-system            aws-node-ldtsd                           2/2     Running   0          56m
    kube-system            aws-node-w7mwb                           2/2     Running   0          56m
    kube-system            aws-node-xlxnw                           2/2     Running   0          7h5m
    kube-system            coredns-6b94694fcb-88wzs                 1/1     Running   0          7h5m
    kube-system            coredns-6b94694fcb-zw4wt                 1/1     Running   0          7h5m
    kube-system            kube-proxy-h6p9k                         1/1     Running   0          7h5m
    kube-system            kube-proxy-j4q5f                         1/1     Running   0          7h5m
    kube-system            kube-proxy-r7rq4                         1/1     Running   0          7h5m
    kube-system            kube-proxy-t8rp4                         1/1     Running   0          56m
    kube-system            kube-proxy-vtd9k                         1/1     Running   0          56m
    kube-system            kube-proxy-whdws                         1/1     Running   0          7h5m
    lws-system             lws-controller-manager-fbb6489f9-9n98v   1/1     Running   0          7h7m
    lws-system             lws-controller-manager-fbb6489f9-z8x4k   1/1     Running   0          7h7m
    nvidia-device-plugin   nvidia-device-plugin-pjt52               1/1     Running   0          56m
    nvidia-device-plugin   nvidia-device-plugin-s9pt5               1/1     Running   0          6h34m
    nvidia-device-plugin   nvidia-device-plugin-sv2qg               1/1     Running   0          56m
    nvidia-device-plugin   nvidia-device-plugin-xqbv8               1/1     Running   0          6h34m
    ```

3. Build and push the provided Dockerfile as a container image into ECR (the `build.sh` file is created as part of `terraform apply`):

    ```sh
    ./build.sh
    ```

    !!! warning
        Building and pushing the Docker image will take a considerable amount of resources and time. Building and pushing this image took 26 minutes on a system without any prior images/layers cached; this was on an AMD Ryzen Threadripper 1900X 8-core 4.2 GHz CPU with 128GB of RAM and a 500GB NVMe SSD. The resultant image is roughly 7.6GB in size (unpacked).

4. Update the provided `lws.yaml` file with your HuggingFace token that will be used to pull down the `meta-llama/Llama-3.3-70B-Instruct` model used in this example.

5. Deploy the LeaderWorkerSet and its associated K8s service:

    ```sh
    kubectl apply -f lws.yaml
    kubectl get pods
    ```

    ```text
    NAME       READY   STATUS    RESTARTS   AGE
    vllm-0     1/1     Running   0          24m
    vllm-0-1   1/1     Running   0          24m
    vllm-0-2   1/1     Running   0          24m
    vllm-0-3   1/1     Running   0          24m
    ```

6. Verify that the distributed tensor-parallel inference works:

    ```sh
    kubectl logs vllm-0 |grep -i "Loading model weights took"
    ```

    Should get an output similar to this:

    ```text
    INFO 03-10 22:53:24 model_runner.py:1115] Loading model weights took 33.8639 GB
    (RayWorkerWrapper pid=208, ip=10.0.45.39) INFO 03-10 22:53:10 model_runner.py:1115] Loading model weights took 33.8639 GB
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
        "model": "meta-llama/Llama-3.3-70B-Instruct",
        "prompt": "San Francisco is a",
        "max_tokens": 7,
        "temperature": 0
    }' | jq
    ```

    The output should be similar to the following

    ```json
    {
        "id": "cmpl-48e678b2dacf4db9ac7f32dffa32c913",
        "object": "text_completion",
        "created": 1741483804,
        "model": "meta-llama/Llama-3.3-70B-Instruct",
        "choices": [
            {
            "index": 0,
            "text": " top destination for travelers, with its",
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
