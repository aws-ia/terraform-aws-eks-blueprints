# Transparent Encryption with Cilium and Wireguard

This pattern demonstrates Cilium configured in CNI chaining mode with VPC CNI and with Wireguard transparent encryption enabled on an Amazon EKS cluster.

- [Cilium CNI Chaining Documentation](https://docs.cilium.io/en/v1.12/gettingstarted/cni-chaining-aws-cni/)
- [Cilium Wireguard Encryption Documentation](https://docs.cilium.io/en/v1.12/gettingstarted/encryption-wireguard/)

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/getting-started/#prerequisites) for the prerequisites required to deploy this pattern and steps to deploy.

## Validate

1. List the daemonsets

    ```sh
    kubectl get ds -n kube-system

    # Output should look something similar
    NAME         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
    aws-node     2         2         2       2            2           <none>                   156m
    cilium       2         2         2       2            2           kubernetes.io/os=linux   152m
    kube-proxy   2         2         2       2            2           <none>                   156m
    ```

2. Open a shell inside the cilium container

    ```sh
    kubectl -n kube-system exec -ti ds/cilium -- bash
    ```

3. Verify Encryption is enabled

    ```sh
    cilium status | grep Encryption

    # Output should look something similar
    Encryption:              Wireguard   [cilium_wg0 (Pubkey: b2krgbHgaCsVWALMnFLiS/RekhhcE36PXEjQ7T8+mW0=, Port: 51871, Peers: 1)]
    ```

4. Install [`tcpdump`](https://www.tcpdump.org/)

    ```sh
    apt-get update
    apt-get install -y tcpdump
    ```

5. Start a packet capture on `cilium_wg0` and verify you see payload in clear text, it means the traffic is encrypted with wireguard

    ```sh
    tcpdump -A -c 40 -i cilium_wg0 | grep "Welcome to nginx!"

    # Output should look similar below

    <title>Welcome to nginx!</title>
    <h1>Welcome to nginx!</h1>
    ...

    40 packets captured
    40 packets received by filter
    0 packets dropped by kernel
    ```

## Destroy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/getting-started/#destroy) for steps to clean up the resources created.
