# Amazon EKS Cluster w/ Istio

This example shows how to provision an EKS cluster with Istio.

* Deploy EKS Cluster with one managed node group in an VPC
* Add node_security_group rules for port access required for Istio communication
* Install Istio using Helm resources in Terraform
* Install Istio Ingress Gateway using Helm resources in Terraform
* Deploy/Validate Istio communciation using sample application

Refer to the [documentation](https://istio.io/latest/docs/concepts/) for `Istio` concepts.

## Prerequisites:

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deploy

To provision this example:

```sh
terraform init
terraform apply
```

Enter `yes` at command prompt to apply

If you choose to customize, create a file by the name `terraform.tfvars` in the root directory of this repo with the following content, customize the content as per your needs and then run the command shown above

```
aws_region            = "us-west-2"
istio_helm_chart_version = "1.18.1"
eks_cluster_version   = "1.27
managed_node_group    = {
    node_group_name   = "managed-ondemand"
    instance_types    = ["t3.small"]
    min_size          = 1
    max_size          = 3
    desired_size      = 2  
}"
```

## Validate

The following command will update the `kubeconfig` on your local machine and allow you to interact with your EKS Cluster using `kubectl` to validate the deployment.

1. Run `update-kubeconfig` command:

```sh
aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME>
```

2. List the nodes running currently

```sh
kubectl get nodes
```

```
# Output should look like below
NAME                          STATUS   ROLES    AGE   VERSION
ip-10-0-22-173.ec2.internal   Ready    <none>   48m   v1.27.3-eks-a5565ad
```

3. List out the pods running currently:

```sh
kubectl get pods,svc -n istio-system
```

```
# Output should look like below
NAME                                 READY   STATUS    RESTARTS   AGE
pod/istio-ingress-6f7c5dffd8-chkww   1/1     Running   0          48m
pod/istiod-ff577f8b8-t9ww2           1/1     Running   0          48m

NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP                                                                     PORT(S)                                      AGE
service/istio-ingress   LoadBalancer   172.20.100.3    a59363808e78d46d59bf3378cafffcec-a12f9c78cb607b6b.elb.us-east-1.amazonaws.com   15021:32118/TCP,80:32740/TCP,443:30624/TCP   48m
service/istiod          ClusterIP      172.20.249.63   <none>                                                                          15010/TCP,15012/TCP,443/TCP,15014/TCP        48m
```

4. Verify all the helm releases installed for Istio:

```sh
helm list -n istio-system
```

```
# Output should look like below 
NAME         	NAMESPACE   	REVISION	UPDATED                             	STATUS  	CHART         	APP VERSION
istio-base   	istio-system	1       	2023-07-19 11:05:41.599921 -0700 PDT	deployed	base-1.18.1   	1.18.1
istio-ingress	istio-system	1       	2023-07-19 11:06:03.41609 -0700 PDT 	deployed	gateway-1.18.1	1.18.1
istiod       	istio-system	1       	2023-07-19 11:05:48.087616 -0700 PDT	deployed	istiod-1.18.1 	1.18.1
```

## Test
1. Create the sample namespace and enable the sidecar injecton for this namespace
```sh
kubectl create namespace sample
kubectl label namespace sample istio-injection=enabled
```
```
namespace/sample created
namespace/sample labeled
```

2. Deploy helloworld app
```sh
cat <<EOF > helloworld.yaml
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

kubectl apply -f helloworld.yaml -n sample
```

```
service/helloworld created
deployment.apps/helloworld-v1 created
```

3. Deploy sleep app that we will use to connect to helloworld app
```sh
cat <<EOF > sleep.yaml
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

kubectl apply -f sleep.yaml -n sample
```

```
serviceaccount/sleep created
service/sleep created
deployment.apps/sleep created
```

4. Check all the pods in the `sample` namespace
```sh
kubectl get pods -n sample
```
```
NAME                           READY   STATUS    RESTARTS   AGE
helloworld-v1-b6c45f55-bx2xk   2/2     Running   0          50s
sleep-9454cc476-p2zxr          2/2     Running   0          15s
```
5. Connect to helloworld app from sleep app and see the connectivity is using envoy proxy
```sh
kubectl exec -n sample -c sleep \
    "$(kubectl get pod -n sample -l \
    app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- curl -v helloworld.sample:5000/hello
```
```
* processing: helloworld.sample:5000/hello
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0*   Trying 172.20.26.38:5000...
* Connected to helloworld.sample (172.20.26.38) port 5000
> GET /hello HTTP/1.1
> Host: helloworld.sample:5000
> User-Agent: curl/8.2.0
> Accept: */*
>
< HTTP/1.1 200 OK
< server: envoy
< date: Fri, 21 Jul 2023 18:56:09 GMT
< content-type: text/html; charset=utf-8
< content-length: 58
< x-envoy-upstream-service-time: 142
<
{ [58 bytes data]
100    58  100    58  Hello version: v1, instance: helloworld-v1-b6c45f55-h592c
  0     0    392      0 --:--:-- --:--:-- --:--:--   394
* Connection #0 to host helloworld.sample left intact
```

## Destroy

To teardown and remove the resources created in this example:

```sh
terraform destroy -auto-approve
```
