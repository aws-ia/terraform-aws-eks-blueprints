# Transparent Encryption with Cilium and Wireguard

This pattern demonstrates Cilium configured in CNI chaining mode with the VPC CNI and with Wireguard transparent encryption enabled on an Amazon EKS cluster.

- [Cilium CNI Chaining Documentation](https://docs.cilium.io/en/stable/installation/cni-chaining-aws-cni/)
- [Cilium Wireguard Encryption Documentation](https://docs.cilium.io/en/stable/security/network/encryption-wireguard/)

## Focal Points

- `eks.tf` contains the cluster configuration and the deployment of Cilium.
    - There are no specific requirements from an EKS perspective, other than the Linux Kernel version used by the OS must be 5.10+
- `example.yaml` provides a sample application used to demonstrate the encrypted connectivity. This is optional and not required for the pattern.

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

## Validate

1. Deploy the example pods:

    ```sh
    kubectl apply -f example.yaml
    ```

    ```text
    pod/server created
    service/server created
    pod/client created
    ```

2. Get the Cilium status from one of the Cilium pods.

    Under the `Encryption` field, it should state `Wireguard` with a PubKey.
    `NodeEncryption: Disabled` is expected since `NodeEncryption` was not enabled
    via the Helm values provided.

    ```sh
    kubectl -n kube-system exec -ti ds/cilium -- cilium status
    ```

    ```text
    Defaulted container "cilium-agent" out of: cilium-agent, config (init), mount-cgroup (init), apply-sysctl-overwrites (init), mount-bpf-fs (init), clean-cilium-state (init), install-cni-binaries (init)
    KVStore:                 Ok   Disabled
    Kubernetes:              Ok   1.28+ (v1.28.1-eks-43840fb) [linux/amd64]
    Kubernetes APIs:         ["EndpointSliceOrEndpoint", "cilium/v2::CiliumClusterwideNetworkPolicy", "cilium/v2::CiliumEndpoint", "cilium/v2::CiliumNetworkPolicy", "cilium/v2::CiliumNode", "cilium/v2alpha1::CiliumCIDRGroup", "core/v1::Namespace", "core/v1::Pods", "core/v1::Service", "networking.k8s.io/v1::NetworkPolicy"]
    KubeProxyReplacement:    False   [eth0 10.0.21.109 (Direct Routing), eth1 10.0.27.0]
    Host firewall:           Disabled
    CNI Chaining:            aws-cni
    Cilium:                  Ok   1.14.2 (v1.14.2-a6748946)
    NodeMonitor:             Listening for events on 2 CPUs with 64x4096 of shared memory
    Cilium health daemon:    Ok
    IPAM:                    IPv4: 1/254 allocated from 10.0.0.0/24,
    IPv4 BIG TCP:            Disabled
    IPv6 BIG TCP:            Disabled
    BandwidthManager:        Disabled
    Host Routing:            Legacy
    Masquerading:            Disabled
    Controller Status:       24/24 healthy
    Proxy Status:            No managed proxy redirect
    Global Identity Range:   min 256, max 65535
    Hubble:                  Ok          Current/Max Flows: 410/4095 (10.01%), Flows/s: 1.59   Metrics: Disabled
    Encryption:              Wireguard   [NodeEncryption: Disabled, cilium_wg0 (Pubkey: /yuqsZyG91AzVIkZ3AIq8qjQ0gGKQd6GWcRYh4LYpko=, Port: 51871, Peers: 1)]
    Cluster health:                      Probe disabled
    ```

3. Open a shell inside the cilium container

    ```sh
    kubectl -n kube-system exec -ti ds/cilium -- bash
    ```

4. Install [`tcpdump`](https://www.tcpdump.org/)

    ```sh
    apt-get update
    apt-get install -y tcpdump
    ```

5. Start a packet capture on `cilium_wg0` and verify you see payload in clear text, it means the traffic is encrypted with wireguard

    ```sh
    tcpdump -A -c 40 -i cilium_wg0 | grep "Welcome to nginx!"
    ```

    ```text
    tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
    listening on cilium_wg0, link-type RAW (Raw IP), snapshot length 262144 bytes
    <title>Welcome to nginx!</title>
    <h1>Welcome to nginx!</h1>
    40 packets captured
    40 packets received by filter
    0 packets dropped by kernel
    ```

    !!! info "Exit"
        Exit the container shell by typing `exit` before continuing to next step

6. Deploy the Cilium connectivity resources to check and evaluate connectivity:

    ```sh
    kubectl create ns cilium-test
    kubectl apply -n cilium-test -f https://raw.githubusercontent.com/cilium/cilium/v1.14.1/examples/kubernetes/connectivity-check/connectivity-check.yaml
    ```

    ```text
    deployment.apps/echo-a created
    deployment.apps/echo-b created
    deployment.apps/echo-b-host created
    deployment.apps/pod-to-a created
    deployment.apps/pod-to-external-1111 created
    deployment.apps/pod-to-a-denied-cnp created
    deployment.apps/pod-to-a-allowed-cnp created
    deployment.apps/pod-to-external-fqdn-allow-google-cnp created
    deployment.apps/pod-to-b-multi-node-clusterip created
    deployment.apps/pod-to-b-multi-node-headless created
    deployment.apps/host-to-b-multi-node-clusterip created
    deployment.apps/host-to-b-multi-node-headless created
    deployment.apps/pod-to-b-multi-node-nodeport created
    deployment.apps/pod-to-b-intra-node-nodeport created
    service/echo-a created
    service/echo-b created
    service/echo-b-headless created
    service/echo-b-host-headless created
    ciliumnetworkpolicy.cilium.io/pod-to-a-denied-cnp created
    ciliumnetworkpolicy.cilium.io/pod-to-a-allowed-cnp created
    ciliumnetworkpolicy.cilium.io/pod-to-external-fqdn-allow-google-cnp created
    ```

7. View the logs of any of the connectivity tests to view the results:

    ```sh
    kubectl logs <cilium test pod> -n cilium-test
    ```

    ```text
    \{^_^}/ hi!

    Loading /default.json
    Done

    Resources
    http://:8080/private
    http://:8080/public

    Home
    http://:8080

    Type s + enter at any time to create a snapshot of the database
    Watching...

    GET /public 200 7.063 ms - 57
    GET /public 200 3.126 ms - 57
    GET /public 200 3.039 ms - 57
    GET /public 200 2.776 ms - 57
    GET /public 200 3.087 ms - 57
    GET /public 200 2.781 ms - 57
    GET /public 200 2.977 ms - 57
    GET /public 200 2.596 ms - 57
    GET /public 200 2.991 ms - 57
    GET /public 200 2.708 ms - 57
    GET /public 200 3.066 ms - 57
    GET /public 200 2.616 ms - 57
    GET /public 200 2.875 ms - 57
    GET /public 200 2.689 ms - 57
    GET /public 200 2.800 ms - 57
    GET /public 200 2.556 ms - 57
    GET /public 200 3.238 ms - 57
    GET /public 200 2.538 ms - 57
    GET /public 200 2.890 ms - 57
    GET /public 200 2.666 ms - 57
    GET /public 200 2.729 ms - 57
    GET /public 200 2.580 ms - 57
    GET /public 200 2.919 ms - 57
    GET /public 200 2.630 ms - 57
    GET /public 200 2.857 ms - 57
    GET /public 200 2.716 ms - 57
    GET /public 200 1.693 ms - 57
    GET /public 200 2.715 ms - 57
    GET /public 200 2.729 ms - 57
    GET /public 200 2.655 ms - 57
    ```

## Destroy

{%
   include-markdown "../../docs/_partials/destroy.md"
%}
