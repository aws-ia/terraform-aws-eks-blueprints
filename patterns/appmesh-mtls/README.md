# EKS Cluster w/ AppMesh mTLS

This pattern demonstrates how to deploy and configure AppMesh mTLS on an Amazon EKS cluster.

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/getting-started/#prerequisites) for the prerequisites required to deploy this pattern and steps to deploy.

## Validate

1. List the created Resources.

    ```sh
    kubectl get pods -A

    NAMESPACE          NAME                                       READY   STATUS    RESTARTS   AGE
    appmesh-system     appmesh-controller-7c98b87bdc-q6226        1/1     Running   0          4h44m
    cert-manager       cert-manager-87f5555f-tcxj7                1/1     Running   0          4h43m
    cert-manager       cert-manager-cainjector-8448ff8ddb-wwjsc   1/1     Running   0          4h43m
    cert-manager       cert-manager-webhook-5468b675b-fvdwk       1/1     Running   0          4h43m
    kube-system        aws-node-rf4wg                             1/1     Running   0          4h43m
    kube-system        aws-node-skkwh                             1/1     Running   0          4h43m
    kube-system        aws-privateca-issuer-b6fb8c5bd-hh8q4       1/1     Running   0          4h44m
    kube-system        coredns-5f9f955df6-qhr6p                   1/1     Running   0          4h44m
    kube-system        coredns-5f9f955df6-tw8r7                   1/1     Running   0          4h44m
    kube-system        kube-proxy-q72l9                           1/1     Running   0          4h43m
    kube-system        kube-proxy-w54pc                           1/1     Running   0          4h43m
    ```

2. List the AWSPCA cluster issues:

    ```sh
    kubectl get awspcaclusterissuers.awspca.cert-manager.io
    NAME           AGE
    appmesh-mtls   4h42m
    ```

3. List & describe the example certificate:

    ```sh
    kubectl get certificate

    NAME      READY   SECRET                  AGE
    example   True    example-clusterissuer   4h12m
    ```

    ```sh
    kubectl describe secret example-clusterissuer

    Name:         example-clusterissuer
    Namespace:    default
    Labels:       controller.cert-manager.io/fao=true
    Annotations:  cert-manager.io/alt-names:
                  cert-manager.io/certificate-name: example
                  cert-manager.io/common-name: example.com
                  cert-manager.io/ip-sans:
                  cert-manager.io/issuer-group: awspca.cert-manager.io
                  cert-manager.io/issuer-kind: AWSPCAClusterIssuer
                  cert-manager.io/issuer-name: appmesh-mtls
                  cert-manager.io/uri-sans:

    Type:  kubernetes.io/tls

    Data
    ====
    ca.crt:   1785 bytes
    tls.crt:  1517 bytes
    tls.key:  1675 bytes
    ```

### Example

The full documentation for this example can be found [here](https://docs.aws.amazon.com/app-mesh/latest/userguide/getting-started-kubernetes.html#configure-app-mesh).

1. Annotate the `default` Namespace to allow Side Car Injection:

    ```sh
    kubectl label namespaces default appmesh.k8s.aws/sidecarInjectorWebhook=enabled

    namespace/default labeled
    ```

2. Create the mesh:

    ```sh
    cat <<EOF | kubectl apply -f -
    apiVersion: appmesh.k8s.aws/v1beta2
    kind: Mesh
    metadata:
      name: appmesh-example
    spec:
      namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: default
    EOF
    mesh.appmesh.k8s.aws/appmesh-example created
    ```

3. Create a virtual node:

    ```sh
    cat <<EOF | kubectl apply -f -
    apiVersion: appmesh.k8s.aws/v1beta2
    kind: VirtualNode
    metadata:
      name: appmesh-example-vn
      namespace: default
    spec:
      podSelector:
        matchLabels:
          app: appmesh-example
      listeners:
        - portMapping:
            port: 80
            protocol: http
      backendDefaults:
        clientPolicy:
          tls:
            certificate:
              sds:
                secretName: example-clusterissuer
            enforce: true
            ports: []
            validation:
              trust:
                acm:
                  certificateAuthorityARNs:
                  - arn:aws:acm-pca:us-west-2:978045894046:certificate-authority/4386d166-4d68-4347-b940-4324ac493d65
      serviceDiscovery:
        dns:
          hostname: appmesh-example-svc.default.svc.cluster.local
    EOF
    ```

4. Create a virtual router:

    ```sh
    cat <<EOF | kubectl apply -f -
    apiVersion: appmesh.k8s.aws/v1beta2
    kind: VirtualRouter
    metadata:
      namespace: default
      name: appmesh-example-vr
    spec:
      listeners:
        - portMapping:
            port: 80
            protocol: http
      routes:
        - name: appmesh-example-route
          httpRoute:
            match:
              prefix: /
            action:
              weightedTargets:
                - virtualNodeRef:
                    name: appmesh-example-vn
                  weight: 1
    EOF
    ```

5. Create a virtual service:

    ```sh
    cat <<EOF | kubectl apply -f -
    apiVersion: appmesh.k8s.aws/v1beta2
    kind: VirtualService
    metadata:
      name: appmesh-example-vs
      namespace: default
    spec:
      awsName: appmesh-example-svc.default.svc.cluster.local
      provider:
        virtualRouter:
          virtualRouterRef:
            name: appmesh-example-vr
    EOF
    ```

6. Create a deployment and a service in the `default` namespace:

    ```sh
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: Service
    metadata:
      name: appmesh-example-svc
      namespace: default
      labels:
        app: appmesh-example
    spec:
      selector:
        app: appmesh-example
      ports:
        - protocol: TCP
          port: 80
          targetPort: 80
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: appmesh-example-app
      namespace: default
      labels:
        app: appmesh-example
    spec:
      replicas: 2
      selector:
        matchLabels:
          app: appmesh-example
      template:
        metadata:
          labels:
            app: appmesh-example
        spec:
          serviceAccountName: appmesh-example-sa
          containers:
          - name: nginx
            image: nginx:1.19.0
            ports:
            - containerPort: 80
    EOF
    ```

7. Validate if the pods are in the `Running` state with 2 containers, one of them should include the AppMesh sidecar:

    ```sh
    kubectl get pods
    NAME                                   READY   STATUS    RESTARTS   AGE
    appmesh-example-app-6946cdbdf6-gnxww   2/2     Running   0          54s
    appmesh-example-app-6946cdbdf6-nx9tg   2/2     Running   0          54s
    ```

## Destroy

First, delete the example resources created via `kubectl`:

```sh
kubectl delete all --all # delete all example resources created in the default namespace
```

Finally, see [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/getting-started/#destroy) for steps to clean up the resources created.
