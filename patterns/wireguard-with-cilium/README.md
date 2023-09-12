# Transparent Encryption with Cilium and Wireguard

This pattern demonstrates Cilium configured in CNI chaining mode with the VPC CNI and with Wireguard transparent encryption enabled on an Amazon EKS cluster.

- [Cilium CNI Chaining Documentation](https://docs.cilium.io/en/stable/installation/cni-chaining-aws-cni/)
- [Cilium Wireguard Encryption Documentation](https://docs.cilium.io/en/stable/security/network/encryption-wireguard/)

## Areas of Interest

- `eks.tf` contains the cluster configuration and the deployment of Cilium.
    - There are no specific requirements from an EKS perspective, other than the Linux Kernel version used by the OS must be 5.10+.
        On Amazon EKS, this is available starting with EKS 1.24, or users can utilize the Bottlerocket OS for EKS < 1.23
- `sample.tf` provides a sample application used to demonstrate the encrypted connectivity. This is optional and not required for the pattern.

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

## Validate

1. Get the Cilium status from one of the Cilium pods.

    Under the `Encryption` field, it should state `Wireguard` with a PubKey.
    `NodeEncryption: Disabled` is expected since `NodeEncryption` was not enabled
    via the Helm values provided.

    ```sh
    kubectl -n kube-system exec -ti ds/cilium -- cilium status
    ```

    ```text
    Defaulted container "cilium-agent" out of: cilium-agent, config (init), mount-cgroup (init), apply-sysctl-overwrites (init), mount-bpf-fs (init), clean-cilium-state (init), install-cni-binaries (init)
    KVStore:                 Ok   Disabled
    Kubernetes:              Ok   1.27+ (v1.27.4-eks-2d98532) [linux/amd64]
    Kubernetes APIs:         ["EndpointSliceOrEndpoint", "cilium/v2::CiliumClusterwideNetworkPolicy", "cilium/v2::CiliumEndpoint", "cilium/v2::CiliumNetworkPolicy", "cilium/v2::CiliumNode", "cilium/v2alpha1::CiliumCIDRGroup", "core/v1::Namespace", "core/v1::Pods", "core/v1::Service", "networking.k8s.io/v1::NetworkPolicy"]
    KubeProxyReplacement:    False   [eth0 10.0.45.128 (Direct Routing), eth1 10.0.40.206]
    Host firewall:           Disabled
    CNI Chaining:            aws-cni
    Cilium:                  Ok   1.14.1 (v1.14.1-c191ef6f)
    NodeMonitor:             Listening for events on 2 CPUs with 64x4096 of shared memory
    Cilium health daemon:    Ok
    IPAM:                    IPv4: 1/254 allocated from 10.0.1.0/24,
    IPv4 BIG TCP:            Disabled
    IPv6 BIG TCP:            Disabled
    BandwidthManager:        Disabled
    Host Routing:            Legacy
    Masquerading:            Disabled
    Controller Status:       20/20 healthy
    Proxy Status:            No managed proxy redirect
    Global Identity Range:   min 256, max 65535
    Hubble:                  Ok          Current/Max Flows: 4095/4095 (100.00%), Flows/s: 1.58   Metrics: Disabled
    Encryption:              Wireguard   [NodeEncryption: Disabled, cilium_wg0 (Pubkey: Es25c2idJtRzE0/FKAOvKPJ7ybRmZ23KrufK3HOuZTY=, Port: 51871, Peers: 1)]
    Cluster health:                      Probe disabled
    ```

2. Open a shell inside the cilium container

    ```sh
    kubectl -n kube-system exec -ti ds/cilium -- bash
    ```

3. Install [`tcpdump`](https://www.tcpdump.org/)

    ```sh
    apt-get update
    apt-get install -y tcpdump
    ```

4. Start a packet capture on `cilium_wg0` and verify you see payload in clear text, it means the traffic is encrypted with wireguard

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

5. Deploy the Cilium connectivity resources to check and evaluate connectivity:

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

6. View the logs of any of the connectivity tests to view the results:

    ```sh
    kubectl logs echo-a-6575c98b7d-xknsv -n cilium-test
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
