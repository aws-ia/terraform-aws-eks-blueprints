# Serverless Amazon EKS Cluster

This pattern demonstrates an Amazon EKS Cluster that utilizes Fargate profiles for a serverless data plane.

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

## Validate

1. List the nodes in in the cluster; you should see Fargate instances:

    ```sh
    kubectl get nodes
    ```

    ```text
    NAME                                                STATUS   ROLES    AGE   VERSION
    fargate-ip-10-0-17-17.us-west-2.compute.internal    Ready    <none>   25m   v1.26.3-eks-f4dc2c0
    fargate-ip-10-0-20-244.us-west-2.compute.internal   Ready    <none>   71s   v1.26.3-eks-f4dc2c0
    fargate-ip-10-0-41-143.us-west-2.compute.internal   Ready    <none>   25m   v1.26.3-eks-f4dc2c0
    fargate-ip-10-0-44-95.us-west-2.compute.internal    Ready    <none>   25m   v1.26.3-eks-f4dc2c0
    fargate-ip-10-0-45-153.us-west-2.compute.internal   Ready    <none>   77s   v1.26.3-eks-f4dc2c0
    fargate-ip-10-0-47-31.us-west-2.compute.internal    Ready    <none>   75s   v1.26.3-eks-f4dc2c0
    fargate-ip-10-0-6-175.us-west-2.compute.internal    Ready    <none>   25m   v1.26.3-eks-f4dc2c0
    ```

2. List the pods. All the pods should reach a status of `Running` after approximately 60 seconds:

    ```sh
    kubectl get pods -A
    ```

    ```text
    NAMESPACE       NAME                                            READY   STATUS    RESTARTS   AGE
    app-2048        app-2048-65bd744dfb-7g9rx                       1/1     Running   0          2m34s
    app-2048        app-2048-65bd744dfb-nxcbm                       1/1     Running   0          2m34s
    app-2048        app-2048-65bd744dfb-z4b6z                       1/1     Running   0          2m34s
    kube-system     aws-load-balancer-controller-6cbdb58654-fvskt   1/1     Running   0          26m
    kube-system     aws-load-balancer-controller-6cbdb58654-sc7dk   1/1     Running   0          26m
    kube-system     coredns-7b7bddbc85-jmbv6                        1/1     Running   0          26m
    kube-system     coredns-7b7bddbc85-rgmzq                        1/1     Running   0          26m
    ```

3. Validate the `aws-logging` configMap for Fargate Fluentbit was created:

    ```sh
    kubectl -n aws-observability get configmap aws-logging -o yaml
    ```

    ```yaml
    apiVersion: v1
    data:
      filters.conf: |
        [FILTER]
          Name parser
          Match *
          Key_Name log
          Parser regex
          Preserve_Key True
          Reserve_Data True
      flb_log_cw: "true"
      output.conf: |
        [OUTPUT]
          Name cloudwatch_logs
          Match *
          region us-west-2
          log_group_name /fargate-serverless/fargate-fluentbit-logs20230509014113352200000006
          log_stream_prefix fargate-logs-
          auto_create_group true
      parsers.conf: |
        [PARSER]
          Name regex
          Format regex
          Regex ^(?<time>[^ ]+) (?<stream>[^ ]+) (?<logtag>[^ ]+) (?<message>.+)$
          Time_Key time
          Time_Format %Y-%m-%dT%H:%M:%S.%L%z
          Time_Keep On
          Decode_Field_As json message
    immutable: false
    kind: ConfigMap
    metadata:
      creationTimestamp: "2023-05-08T21:14:52Z"
      name: aws-logging
      namespace: aws-observability
      resourceVersion: "1795"
      uid: d822bcf5-a441-4996-857e-7fb1357bc07e
    ```

    You can also validate if the CloudWatch LogGroup was created accordingly, and LogStreams were populated:

    ```sh
    aws logs describe-log-groups \
        --log-group-name-prefix "/fargate-serverless/fargate-fluentbit"
    ```

    ```json
    {
        "logGroups": [
            {
                "logGroupName": "/fargate-serverless/fargate-fluentbit-logs20230509014113352200000006",
                "creationTime": 1683580491652,
                "retentionInDays": 90,
                "metricFilterCount": 0,
                "arn": "arn:aws:logs:us-west-2:111222333444:log-group:/fargate-serverless/fargate-fluentbit-logs20230509014113352200000006:*",
                "storedBytes": 0
            }
        ]
    }
    ```

    ```sh
    aws logs describe-log-streams \
        --log-group-name "/fargate-serverless/fargate-fluentbit-logs20230509014113352200000006" \
        --log-stream-name-prefix fargate-logs --query 'logStreams[].logStreamName'
    ```

    ```json
    [
        "fargate-logs-flblogs.var.log.fluent-bit.log",
        "fargate-logs-kube.var.log.containers.aws-load-balancer-controller-7f989fc6c-grjsq_kube-system_aws-load-balancer-controller-feaa22b4cdaa71ecfc8355feb81d4b61ea85598a7bb57aef07667c767c6b98e4.log",
        "fargate-logs-kube.var.log.containers.aws-load-balancer-controller-7f989fc6c-wzr46_kube-system_aws-load-balancer-controller-69075ea9ab3c7474eac2a1696d3a84a848a151420cd783d79aeef960b181567f.log",
        "fargate-logs-kube.var.log.containers.coredns-7b7bddbc85-8cxvq_kube-system_coredns-9e4f3ab435269a566bcbaa606c02c146ad58508e67cef09fa87d5c09e4ac0088.log",
        "fargate-logs-kube.var.log.containers.coredns-7b7bddbc85-gcjwp_kube-system_coredns-11016818361cd68c32bf8f0b1328f3d92a6d7b8cf5879bfe8b301f393cb011cc.log"
    ]
    ```

### Example

1. Create an ingress resource using the AWS load balancer controller deployed, pointing to our application service:

    ```sh
    kubectl get svc -n app-2048
    ```

    ```text
    NAME       TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
    app-2048   NodePort   172.20.33.217   <none>        80:32568/TCP   2m48s
    ```

    ```sh
    kubectl -n app-2048 create ingress app-2048 --class alb --rule="/*=app-2048:80" \
    --annotation alb.ingress.kubernetes.io/scheme=internet-facing \
    --annotation alb.ingress.kubernetes.io/target-type=ip
    ```

    ```sh
    kubectl -n app-2048 get ingress
    ```

    ```text
    NAME       CLASS   HOSTS   ADDRESS                                                                 PORTS   AGE
    app-2048   alb     *       k8s-app2048-app2048-6d9c5e92d6-1234567890.us-west-2.elb.amazonaws.com   80      4m9s
    ```

2. Open the browser to access the application via the URL address shown in the last output in the ADDRESS column.

    In our example: `k8s-app2048-app2048-6d9c5e92d6-1234567890.us-west-2.elb.amazonaws.com`

    !!! info
        You might need to wait a few minutes, and then refresh your browser.
        If your Ingress isn't created after several minutes, then run this command to view the AWS Load Balancer Controller logs:

    ```sh
    kubectl logs -n kube-system deployment.apps/aws-load-balancer-controller
    ```

## Destroy

{%
   include-markdown "../../docs/_partials/destroy.md"
%}
