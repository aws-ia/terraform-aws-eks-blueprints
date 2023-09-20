# AWS for FluentBit with ContainerInsights and Kubelet monitoring.

This pattern demonstrates an Amazon EKS Cluster deployment using AWS for FluentBit integration with ContainerInsights and Kubelet monitoring to send logs to Amazon CloudWatch Logs.

- [Container Insights on Amazon EKS and Kubernetes](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-EKS-quickstart.html#Container-Insights-setup-EKS-quickstart-FluentBit)
- [Use_Kubelet feature](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights-use-kubelet.html)

## Areas of Interest

Here is the configuration block under the `eks_blueprints_addons` module that customizes the AWS for FluentBit addon in order to enable ContainerInsights and Kubelet monitoring feature.

https://github.com/rodrigobersa/terraform-aws-eks-blueprints/blob/97ea696788fcace8d5fa0ee91927efd4b8a549df/patterns/fluentbit-containerinsights/main.tf#L99-L125

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

## Validate

1. List all the Pods in the cluster; you should see `aws-for-fluentbit-` Pods running on `kube-system` Namespace. All the Pods should reach a status of `Running` after approximately 60 seconds:

```bash
$ kubectl get pods -A
```
```bash
NAMESPACE          NAME                             READY   STATUS    RESTARTS   AGE
amazon-guardduty   aws-guardduty-agent-2bkb8        1/1     Running   0          4m28s
amazon-guardduty   aws-guardduty-agent-mdj2q        1/1     Running   0          4m28s
amazon-guardduty   aws-guardduty-agent-vxkvg        1/1     Running   0          4m28s
kube-system        aws-for-fluent-bit-54lmh         1/1     Running   0          4m34s
kube-system        aws-for-fluent-bit-89wbv         1/1     Running   0          4m33s
kube-system        aws-for-fluent-bit-nt2qr         1/1     Running   0          4m34s
kube-system        aws-node-q55f2                   1/1     Running   0          4m25s
kube-system        aws-node-tx5s8                   1/1     Running   0          4m8s
kube-system        aws-node-vlgpr                   1/1     Running   0          4m16s
kube-system        coredns-6c45d94f67-dvmvf         1/1     Running   0          8m51s
kube-system        coredns-6c45d94f67-xfb97         1/1     Running   0          8m51s
kube-system        kube-proxy-5qcdm                 1/1     Running   0          4m42s
kube-system        kube-proxy-9hksp                 1/1     Running   0          4m41s
kube-system        kube-proxy-c2hcx                 1/1     Running   0          4m42s
kube-system        metrics-server-8794b9cdf-l7hzq   1/1     Running   0          6m8s
```

2. Validate the `aws-for-fluent-bit` configMap was created correctly in the `kube-system` Namespace. Make sure that the configMap has the `application-log.conf`,  `dataplane-log.conf`, `host-log.conf`, and `fluent-bit.conf` definitions. Also, check the parameters `Use_Kubelet On` and `Kubelet_Port 10250` are set!

```bash
$ kubectl get cm -n kube-system aws-for-fluent-bit -o yaml  
```
```yaml
apiVersion: v1
data:
  application-log.conf: |
    [INPUT]
        Name tail
        Tag application.*
        Exclude_Path /var/log/containers/cloudwatch-agent*, /var/log/containers/fluent-bit*, /var/log/containers/aws-node*, /var/log/containers/kube-proxy*
        Path /var/log/containers/*.log
        multiline.parser docker, cri
        DB /var/fluent-bit/state/flb_container.db
        Mem_Buf_Limit 50MB
        Skip_Long_Lines On
        Refresh_Interval 10
        Rotate_Wait 30
        storage.type filesystem
        Read_from_Head Off

    [INPUT]
        Name tail
        Tag application.*
        Path /var/log/containers/fluent-bit*
        multiline.parser docker, cri
        DB /var/fluent-bit/state/flb_log.db
        Mem_Buf_Limit 5MB
        Skip_Long_Lines On
        Refresh_Interval 10
        Read_from_Head Off

    [INPUT]
        Name tail
        Tag application.*
        Path /var/log/containers/cloudwatch-agent*
        multiline.parser docker, cri
        DB /var/fluent-bit/state/flb_cwagent.db
        Mem_Buf_Limit 5MB
        Skip_Long_Lines On
        Refresh_Interval 10
        Read_from_Head Off

    [FILTER]
        Name kubernetes
        Match application.*
        Kube_URL https://kubernetes.default.svc:443
        Kube_Tag_Prefix application.var.log.containers.
        Merge_Log On
        Merge_Log_Key log_processed
        K8S-Logging.Parser On
        K8S-Logging.Exclude Off
        Labels Off
        Annotations Off
        Use_Kubelet On
        Kubelet_Port 10250
        Buffer_Size 0

    [OUTPUT]
        Name cloudwatch_logs
        Match application.*
        region us-west-2
        log_group_name /aws/containerinsights/fluentbit-containerinsights/application
        log_stream_prefix ${HOSTNAME}-
        auto_create_group true
        extra_user_agent container-insights
        workers 1
  dataplane-log.conf: |
    [INPUT]
        Name systemd
        Tag dataplane.systemd.*
        Systemd_Filter _SYSTEMD_UNIT=docker.service
        Systemd_Filter _SYSTEMD_UNIT=containerd.service
        Systemd_Filter _SYSTEMD_UNIT=kubelet.service
        DB /var/fluent-bit/state/systemd.db
        Path /var/log/journal
        Read_From_Tail On

    [INPUT]
        Name tail
        Tag dataplane.tail.*
        Path /var/log/containers/aws-node*, /var/log/containers/kube-proxy*
        multiline.parser docker, cri
        DB /var/fluent-bit/state/flb_dataplane_tail.db
        Mem_Buf_Limit 50MB
        Skip_Long_Lines On
        Refresh_Interval 10
        Rotate_Wait 30
        storage.type filesystem
        Read_from_Head Off

    [FILTER]
        Name modify
        Match dataplane.systemd.*
        Rename _HOSTNAME hostname
        Rename _SYSTEMD_UNIT systemd_unit
        Rename MESSAGE message
        Remove_regex ^((?!hostname|systemd_unit|message).)*$

    [FILTER]
        Name aws
        Match dataplane.*
        imds_version v2

    [OUTPUT]
        Name cloudwatch_logs
        Match dataplane.*
        region us-west-2
        log_group_name /aws/containerinsights/fluentbit-containerinsights/dataplane
        log_stream_prefix ${HOSTNAME}-
        auto_create_group true
        extra_user_agent container-insights
  fluent-bit.conf: |
    [SERVICE]
      Flush 5
      Grace 30
      Log_Level info
      Daemon off
      Parsers_File parsers.conf
      HTTP_Server On
      HTTP_Listen 0.0.0.0
      HTTP_Port 2020
      storage.path /var/fluent-bit/state/flb-storage/
      storage.sync normal
      storage.checksum off
      storage.backlog.mem_limit 5M

    @INCLUDE application-log.conf
    @INCLUDE dataplane-log.conf
    @INCLUDE host-log.conf
  host-log.conf: |
    [INPUT]
        Name tail
        Tag host.dmesg
        Path /var/log/dmesg
        Key message
        DB /var/fluent-bit/state/flb_dmesg.db
        Mem_Buf_Limit 5MB
        Skip_Long_Lines On
        Refresh_Interval 10
        Read_from_Head Off

    [INPUT]
        Name tail
        Tag host.messages
        Path /var/log/messages
        Parser syslog
        DB /var/fluent-bit/state/flb_messages.db
        Mem_Buf_Limit 5MB
        Skip_Long_Lines On
        Refresh_Interval 10
        Read_from_Head Off

    [INPUT]
        Name tail
        Tag host.secure
        Path /var/log/secure
        Parser syslog
        DB /var/fluent-bit/state/flb_secure.db
        Mem_Buf_Limit 5MB
        Skip_Long_Lines On
        Refresh_Interval 10
        Read_from_Head Off

    [FILTER]
        Name aws
        Match host.*
        imds_version v2

    [OUTPUT]
        Name cloudwatch_logs
        Match host.*
        region us-west-2
        log_group_name /aws/containerinsights/fluentbit-containerinsights/host
        log_stream_prefix ${HOSTNAME}.
        auto_create_group true
        extra_user_agent container-insights
  parsers.conf: |
    [PARSER]
        Name syslog
        Format regex
        Regex ^(?<time>[^ ]* {1,2}[^ ]* [^ ]*) (?<host>[^ ]*) (?<ident>[a-zA-Z0-9_\/\.\-]*)(?:\[(?<pid>[0-9]+)\])?(?:[^\:]*\:)? *(?<message>.*)$
        Time_Key time
        Time_Format %b %d %H:%M:%S

    [PARSER]
        Name container_firstline
        Format regex
        Regex (?<log>(?<="log":")\S(?!\.).*?)(?<!\\)".*(?<stream>(?<="stream":").*?)".*(?<time>\d{4}-\d{1,2}-\d{1,2}T\d{2}:\d{2}:\d{2}\.\w*).*(?=})
        Time_Key time
        Time_Format %Y-%m-%dT%H:%M:%S.%LZ

    [PARSER]
        Name cwagent_firstline
        Format regex
        Regex (?<log>(?<="log":")\d{4}[\/-]\d{1,2}[\/-]\d{1,2}[ T]\d{2}:\d{2}:\d{2}(?!\.).*?)(?<!\\)".*(?<stream>(?<="stream":").*?)".*(?<time>\d{4}-\d{1,2}-\d{1,2}T\d{2}:\d{2}:\d{2}\.\w*).*(?=})
        Time_Key time
        Time_Format %Y-%m-%dT%H:%M:%S.%LZ
kind: ConfigMap
metadata:
  annotations:
    meta.helm.sh/release-name: aws-for-fluent-bit
    meta.helm.sh/release-namespace: kube-system
  labels:
    app.kubernetes.io/instance: aws-for-fluent-bit
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: aws-for-fluent-bit
    app.kubernetes.io/version: 2.31.11
    helm.sh/chart: aws-for-fluent-bit-0.1.30
  name: aws-for-fluent-bit
  namespace: kube-system
```

3. Validate if all the Amazon CloudWatch LogGroups were created, and LogStreams were populated:

```sh
$ aws logs describe-log-groups --query 'logGroups[].logGroupName'
```
```sh
[
    [
        "/aws/containerinsights/complete/application",
    ],
    [
        "/aws/containerinsights/complete/dataplane",
    ],
    [
        "/aws/containerinsights/complete/host",
    ],
    [
        "/aws/eks/fluentbit-containerinsights/cluster",
    ]
]
```
```sh
$ aws logs describe-log-streams --log-group-name /aws/containerinsights/complete/application --query 'logStreams[].logStreamName' | head -n10
```
```sh
[
    "aws-for-fluent-bit-56zs7-application.var.log.containers.aws-for-fluent-bit-56zs7_kube-system_aws-for-fluent-bit-81eb3c6215a7c144fa5feb359cf26252979b0682d43b82f2f893ad718891f36b.log",
    "aws-for-fluent-bit-56zs7-application.var.log.containers.aws-guardduty-agent-dc5z8_amazon-guardduty_aws-guardduty-agent-a8dcd25a72ab0700176ebfd1dd15e3c3b74d5fed716c517133f6075b8da30a10.log",
    "aws-for-fluent-bit-56zs7-application.var.log.containers.coredns-7f8587b949-xhwr2_kube-system_coredns-d54d649c4a6cbe7dae1124261e4db1dfd1d84e546389c2c480b8ed767782e201.log",
    "aws-for-fluent-bit-56zs7-application.var.log.containers.ebs-csi-controller-755bb8bf7d-h8wtk_kube-system_csi-attacher-b079f4121abf981da1a9704cdf6f5e100b10676e0cec985e11a1bcee6da8e0ca.log",
    "aws-for-fluent-bit-56zs7-application.var.log.containers.ebs-csi-controller-755bb8bf7d-h8wtk_kube-system_csi-provisioner-22a618a4f52b059d07dc56b478346556a4f064508602a6ad25dc006c77f0b374.log",
    "aws-for-fluent-bit-56zs7-application.var.log.containers.ebs-csi-controller-755bb8bf7d-h8wtk_kube-system_csi-resizer-7b8bb7f351ab256adf1347aba89b976caaecadc753137ef3acc7736c019bec3f.log",
    "aws-for-fluent-bit-56zs7-application.var.log.containers.ebs-csi-controller-755bb8bf7d-h8wtk_kube-system_csi-snapshotter-b7db45dee9e23e1363b96438a243aa40f046ba3f476640cbb5b7e13bce7ae66b.log",
    "aws-for-fluent-bit-56zs7-application.var.log.containers.ebs-csi-controller-755bb8bf7d-h8wtk_kube-system_ebs-plugin-9167e1768b9a14daa3b5a80e275230c1687b9d430c079c5e7fdf17fbad9b4a5b.log",
    "aws-for-fluent-bit-56zs7-application.var.log.containers.ebs-csi-controller-755bb8bf7d-h8wtk_kube-system_liveness-probe-110b3f7842736d9eb7dedc5a8a42651719b08d2135bb04ec3872e0a0316fdef5.log",
```
```sh
$ aws logs describe-log-streams --log-group-name /aws/containerinsights/complete/host --query 'logStreams[].logStreamName' | head -n10
```
```sh
[
    "aws-for-fluent-bit-56zs7.host.messages",
    "aws-for-fluent-bit-5m7wb.host.messages",
    "aws-for-fluent-bit-9hzck.host.messages",
    "aws-for-fluent-bit-cmbxm.host.messages",
    "aws-for-fluent-bit-jpmtt.host.messages",
    "aws-for-fluent-bit-l75lh.host.messages"
]
```
```sh
$ aws logs describe-log-streams --log-group-name /aws/containerinsights/complete/dataplane --query 'logStreams[].logStreamName' | head -n10
```
```sh
[
    "aws-for-fluent-bit-56zs7-dataplane.systemd.containerd.service",
    "aws-for-fluent-bit-56zs7-dataplane.systemd.kubelet.service",
    "aws-for-fluent-bit-56zs7-dataplane.tail.var.log.containers.aws-node-5mtfw_kube-system_aws-eks-nodeagent-b42903c593896412fedf67272c4b7e29bde11cec24804169cd0c0d363c7087de.log",
    "aws-for-fluent-bit-56zs7-dataplane.tail.var.log.containers.aws-node-5mtfw_kube-system_aws-node-bfa0dea8c5d2503245ac4cb5a8bfd3ab88d579e768270aed07f7b78d7aea2c16.log",
    "aws-for-fluent-bit-56zs7-dataplane.tail.var.log.containers.aws-node-5mtfw_kube-system_aws-vpc-cni-init-5a7503b8bbb2610e8ddbe27a30d19dab0ac685fbd18b262b40c5b71a350e9828.log",
    "aws-for-fluent-bit-56zs7-dataplane.tail.var.log.containers.kube-proxy-d795v_kube-system_kube-proxy-1bfefe55272af690b7b511b74081eb540e8bd48d08caeba7e0640e64ccb07d9d.log",
    "aws-for-fluent-bit-56zs7-dataplane.tail.var.log.containers.kube-proxy-gfwkn_kube-system_kube-proxy-5098463fbb0f192a598d20a582330d1311f333b69c6d606aff08e59c0c67dde9.log",
    "aws-for-fluent-bit-5m7wb-dataplane.systemd.containerd.service",
    "aws-for-fluent-bit-5m7wb-dataplane.systemd.kubelet.service",
]
```

This can be done via AWS Console using this deep link: [Amazon CloudWatch Console](https://console.aws.amazon.com/cloudwatch/home?#logsV2:log-groups)

4. You can also validate if all the `aws-for-fluentbit-` Pods are running without any errors to make sure the `Use_Kubelet` feature is working properly.

```sh
$ kubectl -n kube-system logs -l app.kubernetes.io/name=aws-for-fluent-bit
```

## Destroy

{%
   include-markdown "../../docs/_partials/destroy.md"
%}
