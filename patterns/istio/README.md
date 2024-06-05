# Amazon EKS Cluster w/ Istio

## Amazon EKS Deployment Modes

Starting with Istio 1.20, Istio now offers two deployment models: traditional (called `sidecar`) and resource-savvy (called `ambient`).

### Traditional Deployment (`sidecar`)

The `sidecar` deployment mode reflects the conventional approach to Istio deployment. In this mode, each workload container is accompanied by an Istio sidecar container, facilitating the interception and management of traffic within the service mesh.

### Resource-Savvy Deployment (`ambient`)

In contrast, the `ambient` deployment mode, introduced recently, offers a resource-optimized strategy tailored for efficient utilization within Amazon EKS environments. This mode prioritizes resource efficiency while maintaining the functionalities of Istio's service mesh.

This example provides `sidecar` setup out of the box. By uncommenting Ambient info in `main.tf` you can enable deployment of Istio in `Ambient` mode

- Deploy an EKS Cluster with one managed node group in a VPC.
- Add node_security_group rules for port access required for Istio communication.
- Install Istio using Helm resources in Terraform.
- Install Istio Ingress Gateway using Helm resources in Terraform. This step deploys a Service of type `LoadBalancer` that creates an AWS Network Load Balancer.
- Deploy/Validate Istio communication using a sample application.

Refer to the [Istio documentation](https://istio.io/latest/docs/concepts/) for detailed explanations of Istio concepts.

## Deploy

Refer to the [prerequisites](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) and run the following command to deploy this pattern:

```sh
terraform init
terraform apply --auto-approve
```

for Ambient mode set `enable_ambient_mode` variable to `true` when running `apply` command:

```sh
terraform apply -var="enable_ambient_mode=true" --auto-approve
```

Once the resources have been provisioned, you will need to replace the `istio-ingress` pods due to a [`istiod` dependency issue](https://github.com/istio/istio/issues/35789). Use the following command to perform a rolling restart of the `istio-ingress` pods:

```sh
kubectl rollout restart deployment istio-ingress -n istio-ingress
```

### Observability Add-ons

Use the following code snippet to add the Istio Observability Add-ons on the EKS
cluster with deployed Istio.

```sh
for ADDON in kiali jaeger prometheus grafana
do
    ADDON_URL="https://raw.githubusercontent.com/istio/istio/release-1.22/samples/addons/$ADDON.yaml"
    kubectl apply -f $ADDON_URL
done
```

## Validate

1. List out all pods and services in the `istio-system` namespace:

    ```sh
    kubectl get pods,svc -n istio-system
    kubectl get pods,svc -n istio-ingress
    ```

    ```text
    NAME                             READY   STATUS    RESTARTS   AGE
    pod/grafana-7d4f5589fb-4xj9m     1/1     Running   0          4m14s
    pod/istiod-ff577f8b8-18ssk       1/1     Running   0          4m40s
    pod/jaeger-58c79c85cd-37bkx      1/1     Running   0          4m14s
    pod/kiali-749d76d7bb-8kjg7       1/1     Running   0          4m14s
    pod/prometheus-5d5d6d6fc-11txl   2/2     Running   0          4m15s

    NAME                       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                                 AGE
    service/grafana            ClusterIP   172.20.141.12    <none>        3000/TCP                                4m14s
    service/istiod             ClusterIP   172.20.172.70    <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP   4m40s
    service/jaeger-collector   ClusterIP   172.20.223.28    <none>        14268/TCP,14250/TCP,9411/TCP            4m15s
    service/kiali              ClusterIP   172.20.182.231   <none>        20001/TCP,9090/TCP                      4m15s
    service/prometheus         ClusterIP   172.20.89.64     <none>        9090/TCP                                4m14s
    service/tracing            ClusterIP   172.20.253.201   <none>        80/TCP,16685/TCP                        4m14s
    service/zipkin             ClusterIP   172.20.221.157   <none>        9411/TCP                                4m15s

    NAME                                 READY   STATUS    RESTARTS   AGE
    pod/istio-ingress-6f7c5dffd8-11szr   1/1     Running   0          4m28s

    NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP                                                                     PORT(S)                                      AGE
    service/istio-ingress   LoadBalancer   172.20.104.27   k8s-istioing-istioing-844c89b6c2-875b8c9a4b4e9365.elb.us-west-2.amazonaws.com   15021:32760/TCP,80:31496/TCP,443:32534/TCP   4m28s
    ```

    In Ambient mode:

    ```text
    NAME                              READY   STATUS    RESTARTS   AGE
    pod/grafana-657df88ffd-89nxn      1/1     Running   0          16s
    pod/istio-cni-node-42mjk          1/1     Running   0          22m
    pod/istio-cni-node-24ctm          1/1     Running   0          22m
    pod/istiod-6768c599c5-6rwd9       1/1     Running   0          23m
    pod/jaeger-697d898d6-32gsr        1/1     Running   0          22s
    pod/kiali-5899548ff7-1xx5h        1/1     Running   0          24s
    pod/prometheus-777db476b6-3gvg7   2/2     Running   0          18s
    pod/ztunnel-56s7h                 1/1     Running   0          22m
    pod/ztunnel-7wbr5                 1/1     Running   0          22m

    NAME                       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                                          AGE
    service/grafana            ClusterIP   172.20.79.2      <none>        3000/TCP                                         16s
    service/istiod             ClusterIP   172.20.90.17     <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP            23m
    service/jaeger-collector   ClusterIP   172.20.221.206   <none>        14268/TCP,14250/TCP,9411/TCP,4317/TCP,4318/TCP   21s
    service/kiali              ClusterIP   172.20.241.225   <none>        20001/TCP,9090/TCP                               24s
    service/prometheus         ClusterIP   172.20.39.12     <none>        9090/TCP                                         18s
    service/tracing            ClusterIP   172.20.195.31    <none>        80/TCP,16685/TCP                                 22s
    service/zipkin             ClusterIP   172.20.92.216    <none>        9411/TCP                                         22s
    NAME                                READY   STATUS    RESTARTS   AGE
    pod/istio-ingress-94f46b75b-w5pch   1/1     Running   0          22m

    NAME                    TYPE           CLUSTER-IP       EXTERNAL-IP                                                                     PORT(S)                                      AGE
    service/istio-ingress   LoadBalancer   172.20.249.189   k8s-istioing-istioing-21ba5f8e50-56515edc7fdae5d5.elb.us-west-2.amazonaws.com   15021:32477/TCP,80:32556/TCP,443:32006/TCP   23m
    ```

2. Verify all the Helm releases installed in the `istio-system` and `istio-ingress` namespaces:

    ```sh
    helm list -n istio-system
    ```

    ```text
    NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART               APP VERSION
    istio-base      istio-system    1               2024-06-03 16:53:08.15008046 -0700 PDT  deployed        base-1.22.0         1.22.0
    istiod          istio-system    1               2024-06-03 16:56:50.331042567 -0700 PDT deployed        istiod-1.22.0       1.22.0
    ```

    In Ambient mode:

    ```text
    NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART               APP VERSION
    istio-base      istio-system    1               2024-06-03 15:49:08.443242104 -0700 PDT deployed        base-1.22.0         1.22.0
    istio-cni       istio-system    1               2024-06-03 15:49:02.186964057 -0700 PDT deployed        cni-1.22.0          1.22.0
    istiod          istio-system    1               2024-06-03 15:49:07.609140674 -0700 PDT deployed        istiod-1.22.0       1.22.0
    ztunnel         istio-system    1               2024-06-03 15:49:11.624277009 -0700 PDT deployed        ztunnel-1.22.0      1.22.0
    ```

    ```sh
    helm list -n istio-ingress
    ```

    ```text
    NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART               APP VERSION
    istio-ingress   istio-ingress   1               2024-06-03 16:52:57.609474723 -0700 PDT deployed        gateway-1.22.0      1.22.0
    ```

### Observability Add-ons

Validate the setup of the observability add-ons by running the following commands
and accessing each of the service endpoints using this URL of the form
[http://localhost:\<port>](http://localhost:<port>) where `<port>` is one of the
port number for the corresponding service.

```sh
# Visualize Istio Mesh console using Kiali
kubectl port-forward svc/kiali 20001:20001 -n istio-system

# Get to the Prometheus UI
kubectl port-forward svc/prometheus 9090:9090 -n istio-system

# Visualize metrics in using Grafana
kubectl port-forward svc/grafana 3000:3000 -n istio-system

# Visualize application traces via Jaeger
kubectl port-forward svc/tracing 16686:80 -n istio-system
```

### Example

1. Create the `sample` namespace and enable the sidecar injection on it

    ```sh
    kubectl create namespace sample
    kubectl label namespace sample istio-injection=enabled
    ```
    for Ambient mode use:
    ```sh
    kubectl label namespace sample istio.io/dataplane-mode=ambient
    ```

    ```text
    namespace/sample created
    namespace/sample labeled
    ```

2. Deploy `helloworld` app

    ```sh
    cat <<EOF | kubectl apply -n sample -f -
    apiVersion: v1
    kind: Service
    metadata:
      name: helloworld
      labels:
        app: helloworld
        service: helloworld
    spec:
      ports:
      - port: 5000
        name: http
      selector:
        app: helloworld
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: helloworld-v1
      labels:
        app: helloworld
        version: v1
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: helloworld
          version: v1
      template:
        metadata:
          labels:
            app: helloworld
            version: v1
        spec:
          containers:
          - name: helloworld
            image: docker.io/istio/examples-helloworld-v1
            resources:
              requests:
                cpu: "100m"
            imagePullPolicy: IfNotPresent #Always
            ports:
            - containerPort: 5000
    EOF
    ```

    ```text
    service/helloworld created
    deployment.apps/helloworld-v1 created
    ```

3. Deploy `sleep` app that we will use to connect to `helloworld` app

    ```sh
    cat <<EOF | kubectl apply -n sample -f -
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: sleep
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: sleep
      labels:
        app: sleep
        service: sleep
    spec:
      ports:
      - port: 80
        name: http
      selector:
        app: sleep
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: sleep
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: sleep
      template:
        metadata:
          labels:
            app: sleep
        spec:
          terminationGracePeriodSeconds: 0
          serviceAccountName: sleep
          containers:
          - name: sleep
            image: curlimages/curl
            command: ["/bin/sleep", "infinity"]
            imagePullPolicy: IfNotPresent
            volumeMounts:
            - mountPath: /etc/sleep/tls
              name: secret-volume
          volumes:
          - name: secret-volume
            secret:
              secretName: sleep-secret
              optional: true
    EOF
    ```

    ```text
    serviceaccount/sleep created
    service/sleep created
    deployment.apps/sleep created
    ```

4. Check all the pods in the `sample` namespace

    ```sh
    kubectl get pods -n sample
    ```

    ```text
    NAME                           READY   STATUS    RESTARTS   AGE
    helloworld-v1-b6c45f55-3x2xk   2/2     Running   0          50s
    sleep-9454cc476-22zxr          2/2     Running   0          15s
    ```
    In Ambient mode:

    ```text
    NAME                             READY   STATUS    RESTARTS   AGE
    helloworld-v1-64674bb6c8-5szqq   1/1     Running   0          26s
    sleep-5577c64d7c-htrf8           1/1     Running   0          10s
    ```
5. Connect to `helloworld` app from `sleep` app and verify if the connection uses envoy proxy

    ```sh
    kubectl exec -n sample -c sleep \
        "$(kubectl get pod -n sample -l \
        app=sleep -o jsonpath='{.items[0].metadata.name}')" \
        -- curl -sv helloworld.sample:5000/hello
    ```

    ```text
    * Host helloworld.sample:5000 was resolved.
    ...
    * Connection #0 to host helloworld.sample left intact
    Hello version: v1, instance: helloworld-v1-64674bb6c8-43qfx
    ```

## Destroy

The AWS Load Balancer Controller add-on asynchronously reconciles resource deletions.
During stack destruction, the istio ingress resource and the load balancer controller
add-on are deleted in quick succession, preventing the removal of some of the AWS
resources associated with the ingress gateway load balancer like, the frontend and the
backend security groups.
This causes the final `terraform destroy -auto-approve` command to timeout and fail with VPC dependency errors like below:

```text
│ Error: deleting EC2 VPC (vpc-XXXX): operation error EC2: DeleteVpc, https response error StatusCode: 400, RequestID: XXXXX-XXXX-XXXX-XXXX-XXXXXX, api error DependencyViolation: The vpc 'vpc-XXXX' has dependencies and cannot be deleted.
```

A possible workaround is to manually uninstall the `istio-ingress` helm chart.

```sh
terraform destroy -target='module.eks_blueprints_addons.helm_release.this["istio-ingress"]' -auto-approve
```

Once the chart is uninstalled move on to destroy the stack.

{%
   include-markdown "../../docs/_partials/destroy.md"
%}
