provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
    }
  }
}

provider "grafana" {
  url  = var.grafana_endpoint
  auth = var.grafana_api_key
}

data "aws_availability_zones" "available" {}

locals {
  name   = basename(path.cwd)
  region = var.aws_region

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------

module "eks_blueprints" {
  source = "../../.."

  cluster_name    = local.name
  cluster_version = "1.22"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  managed_node_groups = {
    t3_l = {
      node_group_name = "managed-ondemand"
      instance_types  = ["t3.large"]
      min_size        = 2
      subnet_ids      = module.vpc.private_subnets
    }
  }

  tags = local.tags
}

module "eks_blueprints_kubernetes_addons" {
  source = "../../../modules/kubernetes-addons"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  # enable AWS Managed EKS add-on for ADOT
  enable_amazon_eks_adot = true
  # or enable a customer-managed OpenTelemetry operator
  # enable_opentelemetry_operator = true
  enable_adot_collector_java = false


  amazon_prometheus_workspace_endpoint = module.managed_prometheus.workspace_prometheus_endpoint
  amazon_prometheus_workspace_region   = local.region

  tags = local.tags
}

#---------------------------------------------------------------
# Observability Resources
#---------------------------------------------------------------

module "managed_grafana" {
  source  = "terraform-aws-modules/managed-service-grafana/aws"
  version = "~> 1.3"

  # Workspace
  name              = local.name
  stack_set_name    = local.name
  data_sources      = ["PROMETHEUS"]
  associate_license = false

  # # Role associations
  # Pending https://github.com/hashicorp/terraform-provider-aws/issues/24166
  # role_associations = {
  #   "ADMIN" = {
  #     "group_ids" = []
  #     "user_ids"  = []
  #   }
  #   "EDITOR" = {
  #     "group_ids" = []
  #     "user_ids"  = []
  #   }
  # }

  tags = local.tags
}

resource "grafana_data_source" "prometheus" {
  type       = "prometheus"
  name       = "amp"
  is_default = true
  url        = module.managed_prometheus.workspace_prometheus_endpoint

  json_data {
    http_method     = "GET"
    sigv4_auth      = true
    sigv4_auth_type = "workspace-iam-role"
    sigv4_region    = local.region
  }
}

resource "grafana_folder" "this" {
  title = "Observability"
}

# Grafana Dashboards

resource "grafana_dashboard" "alertmanager" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/alertmanager.json")
}

resource "grafana_dashboard" "workloads" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/workloads.json")
}

resource "grafana_dashboard" "scheduler" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/scheduler.json")
}

resource "grafana_dashboard" "proxy" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/proxy.json")
}

resource "grafana_dashboard" "prometheus" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/prometheus.json")
}

resource "grafana_dashboard" "podnetwork" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/pods-networking.json")
}

resource "grafana_dashboard" "pods" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/pods.json")
}

resource "grafana_dashboard" "pv" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/pesistentvolumes.json")
}

resource "grafana_dashboard" "nodes" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/nodes.json")
}

resource "grafana_dashboard" "necluster" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/nodeexpoter-use-cluster.json")
}

resource "grafana_dashboard" "nenodeuse" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/nodeexporter-use-node.json")
}

resource "grafana_dashboard" "nenode" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/nodeexporter-nodes.json")
}

resource "grafana_dashboard" "nwworload" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/networking-workloads.json")
}

resource "grafana_dashboard" "nsworkload" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/namespace-workloads.json")
}

resource "grafana_dashboard" "nspods" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/namespace-pods.json")
}

resource "grafana_dashboard" "nsnwworkload" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/namespace-nw-workloads.json")
}

resource "grafana_dashboard" "nsnw" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/namespace-networking.json")
}

resource "grafana_dashboard" "macos" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/macos.json")
}

resource "grafana_dashboard" "kubelet" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/kubelet.json")
}

resource "grafana_dashboard" "grafana" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/grafana.json")
}

resource "grafana_dashboard" "etcd" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/etcd.json")
}

resource "grafana_dashboard" "coredns" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/coredns.json")
}

resource "grafana_dashboard" "controller" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/controller.json")
}

resource "grafana_dashboard" "clusternw" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/cluster-networking.json")
}

resource "grafana_dashboard" "cluster" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/cluster.json")
}

resource "grafana_dashboard" "apis" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/apiserver.json")
}


module "managed_prometheus" {
  source  = "terraform-aws-modules/managed-service-prometheus/aws"
  version = "~> 2.1"

  workspace_alias = local.name

  alert_manager_definition = <<-EOT
  alertmanager_config: |
    route:
      receiver: 'default'
    receivers:
      - name: 'default'
  EOT

  rule_group_namespaces = {
    node-rules = {
      name = "noderules"
      data = <<-EOT
      groups:
        - name: noderules-01
          rules:
            - record: "node_namespace_pod:kube_pod_info:"
              expr: topk by(cluster, namespace, pod) (1, max by(cluster, node, namespace, pod) (label_replace(kube_pod_info{job="kube-state-metrics",node!=""}, "pod", "$1", "pod", "(.*)")))
        - name: noderules-02
          rules:
            - record: node:node_num_cpu:sum
              expr: count by(cluster, node) (sum by(node, cpu) (node_cpu_seconds_total{job="node-exporter"} * on(namespace, pod) group_left(node) topk by(namespace, pod) (1, node_namespace_pod:kube_pod_info:)))
        - name: noderules-03
          rules:
            - record: :node_memory_MemAvailable_bytes:sum
              expr: sum by(cluster) (node_memory_MemAvailable_bytes{job="node-exporter"} or (node_memory_Buffers_bytes{job="node-exporter"} + node_memory_Cached_bytes{job="node-exporter"} + node_memory_MemFree_bytes{job="node-exporter"} + node_memory_Slab_bytes{job="node-exporter"}))
        - name: noderules-04
          rules:
            - record: cluster:node_cpu:ratio_rate5m
              expr: sum(rate(node_cpu_seconds_total{job="node-exporter",mode!="idle",mode!="iowait",mode!="steal"}[5m])) / count(sum by(cluster, instance, cpu) (node_cpu_seconds_total{job="node-exporter"}))            
      EOT      
    }
    node-nw = {
      name = "nodenw-rules"
      data = <<-EOT
      groups:
        - name: nodenw-01
          rules:
            - alert: NodeNetworkInterfaceFlapping
              expr: changes(node_network_up{device!~"veth.+",job="node-exporter"}[2m]) > 2
              for: 2m
              labels:
                 severity: warning
              annotations:
                description: Network interface "{{ $labels.device }}" changing its up status often on node-exporter {{ $labels.namespace }}/{{ $labels.pod }}
                summary: Network interface is often changing its status
      EOT             
    }
    node-exporter-rules = {
      name = "ne-rules"
      data = <<-EOT
      groups:
        - name: nerules-01
          rules:
            - record: instance:node_num_cpu:sum
              expr: count without(cpu, mode) (node_cpu_seconds_total{job="node-exporter",mode="idle"})
        - name: nerules-02
          rules:
            - record: instance:node_cpu_utilisation:rate5m
              expr: 1 - avg without(cpu) (sum without(mode) (rate(node_cpu_seconds_total{job="node-exporter",mode=~"idle|iowait|steal"}[5m])))
        - name: nerules-03
          rules:
            - record: instance:node_load1_per_cpu:ratio
              expr: (node_load1{job="node-exporter"} / instance:node_num_cpu:sum{job="node-exporter"})
        - name: nerules-04
          rules:
            - record: instance:node_memory_utilisation:ratio
              expr: 1 - ((node_memory_MemAvailable_bytes{job="node-exporter"} or (node_memory_Buffers_bytes{job="node-exporter"} + node_memory_Cached_bytes{job="node-exporter"} + node_memory_MemFree_bytes{job="node-exporter"} + node_memory_Slab_bytes{job="node-exporter"})) / node_memory_MemTotal_bytes{job="node-exporter"})
        - name: nerules-05
          rules:
            - record: instance:node_vmstat_pgmajfault:rate5m
              expr: rate(node_vmstat_pgmajfault{job="node-exporter"}[5m])
        - name: nerules-06
          rules:
            - record: instance_device:node_disk_io_time_seconds:rate5m
              expr: rate(node_disk_io_time_seconds_total{device=~"mmcblk.p.+|nvme.+|rbd.+|sd.+|vd.+|xvd.+|dm-.+|dasd.+",job="node-exporter"}[5m])
        - name: nerules-07
          rules:
            - record: instance_device:node_disk_io_time_weighted_seconds:rate5m
              expr: rate(node_disk_io_time_weighted_seconds_total{device=~"mmcblk.p.+|nvme.+|rbd.+|sd.+|vd.+|xvd.+|dm-.+|dasd.+",job="node-exporter"}[5m])
        - name: nerules-08
          rules:
            - record: instance:node_network_receive_bytes_excluding_lo:rate5m
              expr: sum without(device) (rate(node_network_receive_bytes_total{device!="lo",job="node-exporter"}[5m]))
        - name: nerules-09
          rules:
            - record: instance:node_network_transmit_bytes_excluding_lo:rate5m
              expr: sum without(device) (rate(node_network_transmit_bytes_total{device!="lo",job="node-exporter"}[5m]))
        - name: nerules-10
          rules:
            - record: instance:node_network_receive_drop_excluding_lo:rate5m
              expr: sum without(device) (rate(node_network_receive_drop_total{device!="lo",job="node-exporter"}[5m]))
        - name: nerules-11
          rules:
            - record: instance:node_network_transmit_drop_excluding_lo:rate5m
              expr: sum without(device) (rate(node_network_transmit_drop_total{device!="lo",job="node-exporter"}[5m]))                                                        
      EOT        
    }
    node-exporter = {
      name = "nodeexporter-rules"
      data = <<-EOT
      groups:
        - name: nodeexp-01
          rules:
            - alert: NodeFilesystemSpaceFillingUp
              expr: (node_filesystem_avail_bytes{fstype!="",job="node-exporter"} / node_filesystem_size_bytes{fstype!="",job="node-exporter"} * 100 < 15 and predict_linear(node_filesystem_avail_bytes{fstype!="",job="node-exporter"}[6h], 24 * 60 * 60) < 0 and node_filesystem_readonly{fstype!="",job="node-exporter"} == 0)
              for: 1h
              labels:
                 severity: warning
              annotations:
                description:  Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only {{ printf "%.2f" $value }}% available space left and is filling up.
                summary: Filesystem is predicted to run out of space within the next 24 hours.
        - name: nodeexp-02
          rules:
            - alert: NodeFilesystemSpaceFillingUp
              expr: (node_filesystem_avail_bytes{fstype!="",job="node-exporter"} / node_filesystem_size_bytes{fstype!="",job="node-exporter"} * 100 < 10 and predict_linear(node_filesystem_avail_bytes{fstype!="",job="node-exporter"}[6h], 4 * 60 * 60) < 0 and node_filesystem_readonly{fstype!="",job="node-exporter"} == 0)
              for: 1h
              labels:
                 severity: critical
              annotations:
                description:  Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only {{ printf "%.2f" $value }}% available space left and is filling up fast.
                summary: Filesystem is predicted to run out of space within the next 4 hours.
        - name: nodeexp-03
          rules:
            - alert: NodeFilesystemAlmostOutOfSpace
              expr: (node_filesystem_avail_bytes{fstype!="",job="node-exporter"} / node_filesystem_size_bytes{fstype!="",job="node-exporter"} * 100 < 3 and node_filesystem_readonly{fstype!="",job="node-exporter"} == 0)
              for: 30m
              labels:
                 severity: warning
              annotations:
                description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only {{ printf "%.2f" $value }}% available space left.
                summary: Filesystem has less than 3% space left.
        - name: nodeexp-04
          rules:
            - alert: NodeFilesystemAlmostOutOfSpace
              expr: (node_filesystem_avail_bytes{fstype!="",job="node-exporter"} / node_filesystem_size_bytes{fstype!="",job="node-exporter"} * 100 < 5 and node_filesystem_readonly{fstype!="",job="node-exporter"} == 0)
              for: 30m
              labels:
                 severity: critical
              annotations:
                description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only {{ printf "%.2f" $value }}% available space left.
                summary:  Filesystem has less than 5% space left.
        - name: nodeexp-05
          rules:
            - alert: NodeFilesystemFilesFillingUp
              expr: (node_filesystem_files_free{fstype!="",job="node-exporter"} / node_filesystem_files{fstype!="",job="node-exporter"} * 100 < 40 and predict_linear(node_filesystem_files_free{fstype!="",job="node-exporter"}[6h], 24 * 60 * 60) < 0 and node_filesystem_readonly{fstype!="",job="node-exporter"} == 0)
              for: 1h
              labels:
                 severity: warning
              annotations:
                description:  Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only {{ printf "%.2f" $value }}% available inodes left and is filling up.
                summary: Filesystem is predicted to run out of inodes within the next 24 hours.
        - name: nodeexp-06
          rules:
            - alert: NodeFilesystemFilesFillingUp
              expr: (node_filesystem_files_free{fstype!="",job="node-exporter"} / node_filesystem_files{fstype!="",job="node-exporter"} * 100 < 20 and predict_linear(node_filesystem_files_free{fstype!="",job="node-exporter"}[6h], 4 * 60 * 60) < 0 and node_filesystem_readonly{fstype!="",job="node-exporter"} == 0)
              for: 1h
              labels:
                 severity: critical
              annotations:
                description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only {{ printf "%.2f" $value }}% available inodes left and is filling up fast.
                summary: Filesystem is predicted to run out of inodes within the next 4 hours.
        - name: nodeexp-07
          rules:
            - alert: NodeFilesystemAlmostOutOfFiles
              expr: (node_filesystem_files_free{fstype!="",job="node-exporter"} / node_filesystem_files{fstype!="",job="node-exporter"} * 100 < 5 and node_filesystem_readonly{fstype!="",job="node-exporter"} == 0)
              for: 1h
              labels:
                 severity: warning
              annotations:
                description:  Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only {{ printf "%.2f" $value }}% available inodes left.
                summary: Filesystem has less than 5% inodes left.
        - name: nodeexp-08
          rules:
            - alert: NodeFilesystemAlmostOutOfFiles
              expr: (node_filesystem_files_free{fstype!="",job="node-exporter"} / node_filesystem_files{fstype!="",job="node-exporter"} * 100 < 3 and node_filesystem_readonly{fstype!="",job="node-exporter"} == 0)
              for: 1h
              labels:
                 severity: critical
              annotations:
                description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only {{ printf "%.2f" $value }}% available inodes left.
                summary: Filesystem has less than 3% inodes left.
        - name: nodeexp-09
          rules:
            - alert: NodeNetworkReceiveErrs
              expr: rate(node_network_receive_errs_total[2m]) / rate(node_network_receive_packets_total[2m]) > 0.01
              for: 1h
              labels:
                 severity: warning
              annotations:
                description: The {{ $labels.instance }} interface {{ $labels.device }} has encountered {{ printf "%.0f" $value }} receive errors in the last two minutes.
                summary: Network interface is reporting many receive errors.
        - name: nodeexp-10
          rules:
            - alert: NodeNetworkTransmitErrs
              expr: rate(node_network_transmit_errs_total[2m]) / rate(node_network_transmit_packets_total[2m]) > 0.01
              for: 1h
              labels:
                 severity: warning
              annotations:
                description:  The {{ $labels.instance }} interface {{ $labels.device }} has encountered {{ printf "%.0f" $value }} transmit errors in the last two minutes.
                summary: Network interface is reporting many transmit errors.
        - name: nodeexp-11
          rules:
            - alert: NodeHighNumberConntrackEntriesUsed
              expr: (node_nf_conntrack_entries / node_nf_conntrack_entries_limit) > 0.75
              labels:
                 severity: warning
              annotations:
                description:  The {{ $value | humanizePercentage }} of conntrack entries are used.
                summary: Number of conntrack are getting close to the limit.
        - name: nodeexp-12
          rules:
            - alert: NodeTextFileCollectorScrapeError
              expr: node_textfile_scrape_error{job="node-exporter"} == 1
              labels:
                 severity: warning
              annotations:
                description: Node Exporter text file collector failed to scrape.
                summary: Node Exporter text file collector failed to scrape.
        - name: nodeexp-13
          rules:
            - alert: NodeClockSkewDetected
              expr: (node_timex_offset_seconds > 0.05 and deriv(node_timex_offset_seconds[5m]) >= 0) or (node_timex_offset_seconds < -0.05 and deriv(node_timex_offset_seconds[5m]) <= 0)
              for: 10m
              labels:
                 severity: warning
              annotations:
                description: Clock on {{ $labels.instance }} is out of sync by more than 300s. Ensure NTP is configured correctly on this host.
                summary: Clock skew detected.
        - name: nodeexp-14
          rules:
            - alert: NodeClockNotSynchronising
              expr: min_over_time(node_timex_sync_status[5m]) == 0 and node_timex_maxerror_seconds >= 16
              for: 10m
              labels:
                 severity: warning
              annotations:
                description: Clock on {{ $labels.instance }} is not synchronising. Ensure NTP is configured on this host.
                summary: Clock not synchronising.
        - name: nodeexp-15
          rules:
            - alert: NodeRAIDDegraded
              expr: node_md_disks_required - ignoring(state) (node_md_disks{state="active"}) > 0
              for: 15m
              labels:
                 severity: critical
              annotations:
                description: RAID array '{{ $labels.device }}' on {{ $labels.instance }} is in degraded state due to one or more disks failures. Number of spare drives is insufficient to fix issue automatically.
                summary: RAID Array is degraded
        - name: nodeexp-16
          rules:
            - alert: NodeRAIDDiskFailure
              expr: node_md_disks{state="failed"} > 0
              labels:
                 severity: warning
              annotations:
                description: At least one device in RAID array on {{ $labels.instance }} failed. Array '{{ $labels.device }}' needs attention and possibly a disk swap.
                summary: Failed device in RAID array
        - name: nodeexp-17
          rules:
            - alert: NodeFileDescriptorLimit
              expr: (node_filefd_allocated{job="node-exporter"} * 100 / node_filefd_maximum{job="node-exporter"} > 70)
              for: 15m
              labels:
                 severity: warning
              annotations:
                description:  File descriptors limit at {{ $labels.instance }} is currently at {{ printf "%.2f" $value }}%.
                summary: Kernel is predicted to exhaust file descriptors limit soon.
        - name: nodeexp-18
          rules:
            - alert: NodeFileDescriptorLimit
              expr: (node_filefd_allocated{job="node-exporter"} * 100 / node_filefd_maximum{job="node-exporter"} > 90)
              for: 15m
              labels:
                 severity: critical
              annotations:
                description: File descriptors limit at {{ $labels.instance }} is currently at {{ printf "%.2f" $value }}%.
                summary: Kernel is predicted to exhaust file descriptors limit soon.


      EOT      
    }
    kubesys-schdlr = {
      name = "kubesyschdlr-rules"
      data = <<-EOT
      groups:
        - name: kubesysschdlr-01
          rules:
            - alert: KubeSchedulerDown
              expr: absent(up{job="kube-scheduler"} == 1)
              for: 15m
              labels:
                 severity: critical
              annotations:
                description: KubeScheduler has disappeared from Prometheus target discovery.
                summary: Target disappeared from Prometheus target discovery.   
      EOT
    }
    kubesys-kblt = {
      name = "kubesyskblt-rules"
      data = <<-EOT
      groups:
        - name: kubesyskblt-01
          rules:
            - alert: KubeNodeNotReady
              expr: kube_node_status_condition{condition="Ready",job="kube-state-metrics",status="true"} == 0
              for: 15m
              labels:
                 severity: warning
              annotations:
                description: The {{ $labels.node }} has been unready for more than 15 minutes.
                summary: Node is not ready.
        - name: kubesyskblt-02
          rules:
            - alert: KubeNodeUnreachable
              expr: (kube_node_spec_taint{effect="NoSchedule",job="kube-state-metrics",key="node.kubernetes.io/unreachable"} unless ignoring(key, value) kube_node_spec_taint{job="kube-state-metrics",key=~"ToBeDeletedByClusterAutoscaler|cloud.google.com/impending-node-termination|aws-node-termination-handler/spot-itn"}) == 1
              for: 15m
              labels:
                 severity: warning
              annotations:
                description: The {{ $labels.node }} is unreachable and some workloads may be rescheduled.
                summary: Node is unreachable.
        - name: kubesyskblt-03
          rules:
            - alert: KubeletTooManyPods
              expr: count by(cluster, node) ((kube_pod_status_phase{job="kube-state-metrics",phase="Running"} == 1) * on(instance, pod, namespace, cluster) group_left(node) topk by(instance, pod, namespace, cluster) (1, kube_pod_info{job="kube-state-metrics"})) / max by(cluster, node) (kube_node_status_capacity{job="kube-state-metrics",resource="pods"} != 1) > 0.95
              for: 15m
              labels:
                 severity: info
              annotations:
                description: Kubelet '{{ $labels.node }}' is running at {{ $value | humanizePercentage }} of its Pod capacity.
                summary: Kubelet is running at capacity.
        - name: kubesyskblt-04
          rules:
            - alert: KubeNodeReadinessFlapping
              expr: sum by(cluster, node) (changes(kube_node_status_condition{condition="Ready",status="true"}[15m])) > 2
              for: 15m
              labels:
                 severity: warning
              annotations:
                description: The readiness status of node {{ $labels.node }} has changed {{ $value }} times in the last 15 minutes.
                summary: Node readiness status is flapping.
        - name: kubesyskblt-05
          rules:
            - alert: KubeletPlegDurationHigh
              expr: node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile{quantile="0.99"} >= 10
              for: 5m
              labels:
                 severity: warning
              annotations:
                description: The Kubelet Pod Lifecycle Event Generator has a 99th percentile duration of {{ $value }} seconds on node {{ $labels.node }}.
                summary: Kubelet Pod Lifecycle Event Generator is taking too long to relist.
        - name: kubesyskblt-06
          rules:
            - alert: KubeletPodStartUpLatencyHigh
              expr: histogram_quantile(0.99, sum by(cluster, instance, le) (rate(kubelet_pod_worker_duration_seconds_bucket{job="kubelet",metrics_path="/metrics"}[5m]))) * on(cluster, instance) group_left(node) kubelet_node_name{job="kubelet",metrics_path="/metrics"} > 60
              for: 15m
              labels:
                 severity: warning
              annotations:
                description: Kubelet Pod startup 99th percentile latency is {{ $value }} seconds on node {{ $labels.node }}.
                summary: Kubelet Pod startup latency is too high.
        - name: kubesyskblt-07
          rules:
            - alert: KubeletClientCertificateExpiration
              expr: kubelet_certificate_manager_client_ttl_seconds < 604800
              labels:
                 severity: warning
              annotations:
                description: Client certificate for Kubelet on node {{ $labels.node }} expires in {{ $value | humanizeDuration }}.
                summary: Kubelet client certificate is about to expire.
        - name: kubesyskblt-08
          rules:
            - alert: KubeletClientCertificateExpiration
              expr: kubelet_certificate_manager_client_ttl_seconds < 86400
              labels:
                 severity: critical
              annotations:
                description: Client certificate for Kubelet on node {{ $labels.node }} expires in {{ $value | humanizeDuration }}.
                summary: Kubelet client certificate is about to expire.
        - name: kubesyskblt-09
          rules:
            - alert: KubeletServerCertificateExpiration
              expr: kubelet_certificate_manager_server_ttl_seconds < 604800
              labels:
                 severity: warning
              annotations:
                description: Server certificate for Kubelet on node {{ $labels.node }} expires in {{ $value | humanizeDuration }}.
                summary: Kubelet server certificate is about to expire.
        - name: kubesyskblt-10
          rules:
            - alert: KubeletServerCertificateExpiration
              expr: kubelet_certificate_manager_server_ttl_seconds < 86400
              labels:
                 severity: critical
              annotations:
                description: Server certificate for Kubelet on node {{ $labels.node }} expires in {{ $value | humanizeDuration }}.
                summary: Kubelet server certificate is about to expire.
        - name: kubesyskblt-11
          rules:
            - alert: KubeletClientCertificateRenewalErrors
              expr: increase(kubelet_certificate_manager_client_expiration_renew_errors[5m]) > 0
              for: 15m
              labels:
                 severity: warning
              annotations:
                description: Kubelet on node {{ $labels.node }} has failed to renew its client certificate ({{ $value | humanize }} errors in the last 5 minutes).
                summary: Kubelet has failed to renew its client certificate.
        - name: kubesyskblt-12
          rules:
            - alert: KubeletServerCertificateRenewalErrors
              expr: increase(kubelet_server_expiration_renew_errors[5m]) > 0
              for: 15m
              labels:
                 severity: warning
              annotations:
                description:  Kubelet on node {{ $labels.node }} has failed to renew its server certificate ({{ $value | humanize }} errors in the last 5 minutes).
                summary: Kubelet has failed to renew its server certificate.
        - name: kubesyskblt-13
          rules:
            - alert: KubeletDown
              expr: absent(up{job="kubelet",metrics_path="/metrics"} == 1)
              for: 15m
              labels:
                 severity: critical
              annotations:
                description: Kubelet has disappeared from Prometheus target discovery.
                summary: Target disappeared from Prometheus target discovery.                                                                                                
      EOT      
    }
    kubesys-kbpxy = {
      name = "kubesyskbpxy-rules"
      data = <<-EOT
      groups:
        - name: kubesyspxy-01
          rules:
            - alert: KubeProxyDown
              expr: absent(up{job="kube-proxy"} == 1)
              for: 15m
              labels:
                 severity: critical
              annotations:
                description: KubeProxy has disappeared from Prometheus target discovery.
                summary: Target disappeared from Prometheus target discovery.
      EOT             
    }
    kubesys = {
      name = "kubesys-rules"
      data = <<-EOT
      groups:
        - name: kubesys-01
          rules:
            - alert: KubeVersionMismatch
              expr: count by(cluster) (count by(git_version, cluster) (label_replace(kubernetes_build_info{job!~"kube-dns|coredns"}, "git_version", "$1", "git_version", "(v[0-9]*.[0-9]*).*"))) > 1
              for: 15m
              labels:
                 severity: warning
              annotations:
                description: There are {{ $value }} different semantic versions of Kubernetes components running.
                summary: Different semantic versions of Kubernetes components running.
        - name: kubesys-02
          rules:
            - alert: KubeClientErrors
              expr: (sum by(cluster, instance, job, namespace) (rate(rest_client_requests_total{code=~"5.."}[5m])) / sum by(cluster, instance, job, namespace) (rate(rest_client_requests_total[5m]))) > 0.01
              for: 15m
              labels:
                 severity: warning
              annotations:
                description: Kubernetes API server client '{{ $labels.job }}/{{ $labels.instance }}' is experiencing {{ $value | humanizePercentage }} errors.'
                summary: Kubernetes API server client is experiencing errors.
      EOT             
    }
    kubesys-cm = {
      name = "kubesyscm-rules"
      data = <<-EOT
      groups:
        - name: kubesyscm-01
          rules:
            - alert: KubeControllerManagerDown
              expr: absent(up{job="kube-controller-manager"} == 1)
              for: 15m
              labels:
                 severity: critical
              annotations:
                description: KubeControllerManager has disappeared from Prometheus target discovery.
                summary: Target disappeared from Prometheus target discovery.    
      EOT  
    }
    kubesys-apiserver = {
      name = "kubesysapi-rules"
      data = <<-EOT
      groups:
        - name: kubesysapi-01
          rules:
            - alert: KubeClientCertificateExpiration
              expr: apiserver_client_certificate_expiration_seconds_count{job="apiserver"} > 0 and on(job) histogram_quantile(0.01, sum by(job, le) (rate(apiserver_client_certificate_expiration_seconds_bucket{job="apiserver"}[5m]))) < 604800
              labels:
                 severity: warning
              annotations:
                description: A client certificate used to authenticate to kubernetes apiserver is expiring in less than 7.0 days.
                summary: Client certificate is about to expire.
        - name: kubesysapi-02
          rules:
            - alert: KubeClientCertificateExpiration
              expr: apiserver_client_certificate_expiration_seconds_count{job="apiserver"} > 0 and on(job) histogram_quantile(0.01, sum by(job, le) (rate(apiserver_client_certificate_expiration_seconds_bucket{job="apiserver"}[5m]))) < 86400
              labels:
                 severity: critical
              annotations:
                description: A client certificate used to authenticate to kubernetes apiserver is expiring in less than 24.0 hours.
                summary: Client certificate is about to expire.
        - name: kubesysapi-03
          rules:
            - alert: KubeAggregatedAPIErrors
              expr: sum by(name, namespace, cluster) (increase(aggregator_unavailable_apiservice_total[10m])) > 4
              labels:
                 severity: warning
              annotations:
                description: Kubernetes aggregated API {{ $labels.name }}/{{ $labels.namespace }} has reported errors. It has appeared unavailable {{ $value | humanize }} times averaged over the past 10m.
                summary: Kubernetes aggregated API has reported errors.
        - name: kubesysapi-04
          rules:
            - alert: KubeAggregatedAPIDown
              expr: (1 - max by(name, namespace, cluster) (avg_over_time(aggregator_unavailable_apiservice[10m]))) * 100 < 85
              for: 5m
              labels:
                 severity: warning
              annotations:
                description: Kubernetes aggregated API {{ $labels.name }}/{{ $labels.namespace }} has been only {{ $value | humanize }}% available over the last 10m.
                summary: Kubernetes aggregated API is down.
        - name: kubesysapi-05
          rules:
            - alert: KubeAPIDown
              expr: absent(up{job="apiserver"} == 1)
              for: 15m
              labels:
                 severity: critical
              annotations:
                description: KubeAPI has disappeared from Prometheus target discovery.
                summary: Target disappeared from Prometheus target discovery.
        - name: kubesysapi-06
          rules:
            - alert: KubeAPITerminatedRequests
              expr: sum(rate(apiserver_request_terminations_total{job="apiserver"}[10m])) / (sum(rate(apiserver_request_total{job="apiserver"}[10m])) + sum(rate(apiserver_request_terminations_total{job="apiserver"}[10m]))) > 0.2
              for: 5m
              labels:
                 severity: warning
              annotations:
                description: The kubernetes apiserver has terminated {{ $value | humanizePercentage }} of its incoming requests.
                summary: The kubernetes apiserver has terminated {{ $value | humanizePercentage }} of its incoming requests.                                          
      EOT    
    }
    kube-storage = {
      name = "kubestorage-rules"
      data = <<-EOT
      groups:
        - name: kubestg-01
          rules:
            - alert: KubePersistentVolumeFillingUp
              expr: (kubelet_volume_stats_available_bytes{job="kubelet",metrics_path="/metrics",namespace=~".*"} / kubelet_volume_stats_capacity_bytes{job="kubelet",metrics_path="/metrics",namespace=~".*"}) < 0.03 and kubelet_volume_stats_used_bytes{job="kubelet",metrics_path="/metrics",namespace=~".*"} > 0 unless on(namespace, persistentvolumeclaim) kube_persistentvolumeclaim_access_mode{access_mode="ReadOnlyMany"} == 1 unless on(namespace, persistentvolumeclaim) kube_persistentvolumeclaim_labels{label_excluded_from_alerts="true"} == 1
              for: 1m
              labels:
                 severity: critical
              annotations:
                description: he PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} is only {{ $value | humanizePercentage }} free.
                summary: PersistentVolume is filling up.
        - name: kubestg-02
          rules:
            - alert: KubePersistentVolumeFillingUp
              expr: (kubelet_volume_stats_available_bytes{job="kubelet",metrics_path="/metrics",namespace=~".*"} / kubelet_volume_stats_capacity_bytes{job="kubelet",metrics_path="/metrics",namespace=~".*"}) < 0.15 and kubelet_volume_stats_used_bytes{job="kubelet",metrics_path="/metrics",namespace=~".*"} > 0 and predict_linear(kubelet_volume_stats_available_bytes{job="kubelet",metrics_path="/metrics",namespace=~".*"}[6h], 4 * 24 * 3600) < 0 unless on(namespace, persistentvolumeclaim) kube_persistentvolumeclaim_access_mode{access_mode="ReadOnlyMany"} == 1 unless on(namespace, persistentvolumeclaim) kube_persistentvolumeclaim_labels{label_excluded_from_alerts="true"} == 1
              for: 1h
              labels:
                 severity: warning
              annotations:
                description: Based on recent sampling, the PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} is expected to fill up within four days.
                summary: PersistentVolume is filling up.
        - name: kubestg-03
          rules:
            - alert: KubePersistentVolumeInodesFillingUp
              expr: (kubelet_volume_stats_inodes_free{job="kubelet",metrics_path="/metrics",namespace=~".*"} / kubelet_volume_stats_inodes{job="kubelet",metrics_path="/metrics",namespace=~".*"}) < 0.03 and kubelet_volume_stats_inodes_used{job="kubelet",metrics_path="/metrics",namespace=~".*"} > 0 unless on(namespace, persistentvolumeclaim) kube_persistentvolumeclaim_access_mode{access_mode="ReadOnlyMany"} == 1 unless on(namespace, persistentvolumeclaim) kube_persistentvolumeclaim_labels{label_excluded_from_alerts="true"} == 1
              for: 1m
              labels:
                 severity: critical
              annotations:
                description: The PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} only has {{ $value | humanizePercentage }} free inodes.
                summary: PersistentVolumeInodes is filling up.
        - name: kubestg-04
          rules:
            - alert: KubePersistentVolumeInodesFillingUp
              expr: (kubelet_volume_stats_inodes_free{job="kubelet",metrics_path="/metrics",namespace=~".*"} / kubelet_volume_stats_inodes{job="kubelet",metrics_path="/metrics",namespace=~".*"}) < 0.15 and kubelet_volume_stats_inodes_used{job="kubelet",metrics_path="/metrics",namespace=~".*"} > 0 and predict_linear(kubelet_volume_stats_inodes_free{job="kubelet",metrics_path="/metrics",namespace=~".*"}[6h], 4 * 24 * 3600) < 0 unless on(namespace, persistentvolumeclaim) kube_persistentvolumeclaim_access_mode{access_mode="ReadOnlyMany"} == 1 unless on(namespace, persistentvolumeclaim) kube_persistentvolumeclaim_labels{label_excluded_from_alerts="true"} == 1
              for: 1h
              labels:
                 severity: warning
              annotations:
                description: Based on recent sampling, the PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} is expected to run out of inodes within four days. Currently {{ $value | humanizePercentage }} of its inodes are free.
                summary: PersistentVolumeInodes are filling up.
        - name: kubestg-05
          rules:
            - alert: KubePersistentVolumeErrors
              expr: kube_persistentvolume_status_phase{job="kube-state-metrics",phase=~"Failed|Pending"} > 0
              for: 5m
              labels:
                 severity: critical
              annotations:
                description: The persistent volume {{ $labels.persistentvolume }} has status {{ $labels.phase }}.
                summary: PersistentVolume is having issues with provisioning.                                   

      EOT    
    }
    kube-resources = {
      name = "kuberesources-rules"
      data = <<-EOT
      groups:
        - name: kuberes-01
          rules:
            - alert: KubeCPUOvercommit
              expr: sum(namespace_cpu:kube_pod_container_resource_requests:sum) - (sum(kube_node_status_allocatable{resource="cpu"}) - max(kube_node_status_allocatable{resource="cpu"})) > 0 and (sum(kube_node_status_allocatable{resource="cpu"}) - max(kube_node_status_allocatable{resource="cpu"})) > 0
              for: 10m
              labels:
                 severity: warning
              annotations:
                description: Cluster has overcommitted CPU resource requests for Pods by {{ $value }} CPU shares and cannot tolerate node failure.
                summary: Cluster has overcommitted CPU resource requests.
        - name: kuberes-02
          rules:
            - alert: KubeMemoryOvercommit
              expr: sum(namespace_memory:kube_pod_container_resource_requests:sum) - (sum(kube_node_status_allocatable{resource="memory"}) - max(kube_node_status_allocatable{resource="memory"})) > 0 and (sum(kube_node_status_allocatable{resource="memory"}) - max(kube_node_status_allocatable{resource="memory"})) > 0
              for: 10m
              labels:
                 severity: warning
              annotations:
                description: Cluster has overcommitted memory resource requests for Pods by {{ $value | humanize }} bytes and cannot tolerate node failure.
                summary: Cluster has overcommitted memory resource requests.
        - name: kuberes-03
          rules:
            - alert: KubeCPUQuotaOvercommit
              expr: sum(min without(resource) (kube_resourcequota{job="kube-state-metrics",resource=~"(cpu|requests.cpu)",type="hard"})) / sum(kube_node_status_allocatable{job="kube-state-metrics",resource="cpu"}) > 1.5
              for: 5m
              labels:
                 severity: warning
              annotations:
                description: Cluster has overcommitted CPU resource requests for Namespaces.
                summary: Cluster has overcommitted CPU resource requests.
        - name: kuberes-04
          rules:
            - alert: KubeMemoryQuotaOvercommit
              expr: sum(min without(resource) (kube_resourcequota{job="kube-state-metrics",resource=~"(memory|requests.memory)",type="hard"})) / sum(kube_node_status_allocatable{job="kube-state-metrics",resource="memory"}) > 1.5
              for: 5m
              labels:
                 severity: warning
              annotations:
                description: Cluster has overcommitted memory resource requests for Namespaces.
                summary: Cluster has overcommitted memory resource requests.
        - name: kuberes-05
          rules:
            - alert: KubeQuotaAlmostFull
              expr: kube_resourcequota{job="kube-state-metrics",type="used"} / ignoring(instance, job, type) (kube_resourcequota{job="kube-state-metrics",type="hard"} > 0) > 0.9 < 1
              for: 15m
              labels:
                 severity: info
              annotations:
                description: Namespace {{ $labels.namespace }} is using {{ $value | humanizePercentage }} of its {{ $labels.resource }} quota.
                summary: Namespace quota is going to be full.
        - name: kuberes-06
          rules:
            - alert: KubeQuotaFullyUsed
              expr: kube_resourcequota{job="kube-state-metrics",type="used"} / ignoring(instance, job, type) (kube_resourcequota{job="kube-state-metrics",type="hard"} > 0) == 1
              for: 15m
              labels:
                 severity: info
              annotations:
                description: Namespace {{ $labels.namespace }} is using {{ $value | humanizePercentage }} of its {{ $labels.resource }} quota.
                summary: Namespace quota is fully used.
        - name: kuberes-07
          rules:
            - alert: KubeQuotaExceeded
              expr: kube_resourcequota{job="kube-state-metrics",type="used"} / ignoring(instance, job, type) (kube_resourcequota{job="kube-state-metrics",type="hard"} > 0) > 1
              for: 15m
              labels:
                 severity: warning
              annotations:
                description: Namespace {{ $labels.namespace }} is using {{ $value | humanizePercentage }} of its {{ $labels.resource }} quota.
                summary: Namespace quota has exceeded the limits.
        - name: kuberes-08
          rules:
            - alert: CPUThrottlingHigh
              expr: sum by(container, pod, namespace) (increase(container_cpu_cfs_throttled_periods_total{container!=""}[5m])) / sum by(container, pod, namespace) (increase(container_cpu_cfs_periods_total[5m])) > (25 / 100)
              for: 15m
              labels:
                 severity: info
              annotations:
                description: The {{ $value | humanizePercentage }} throttling of CPU in namespace {{ $labels.namespace }} for container {{ $labels.container }} in pod {{ $labels.pod }}.
                summary: Processes experience elevated CPU throttling.                               

      EOT                                     
    }
    kube-apps = {
      name = "kubeapps-rules"
      data = <<-EOT
      groups:
        - name: kubeapps-01
          rules:
            - alert: KubePodCrashLooping
              expr: max_over_time(kube_pod_container_status_waiting_reason{job="kube-state-metrics",namespace=~".*",reason="CrashLoopBackOff"}[5m]) >= 1
              for: 15m
              labels:
                 severity: warning
              annotations:
                description: Pod {{ $labels.namespace }}/{{ $labels.pod }} ({{ $labels.container }}) is in waiting state (reason:"CrashLoopBackOff").
                summary: Pod is crash looping.
        - name: kubeapps-02
          rules:
            - alert: KubePodNotReady
              expr: sum by(namespace, pod, cluster) (max by(namespace, pod, cluster) (kube_pod_status_phase{job="kube-state-metrics",namespace=~".*",phase=~"Pending|Unknown"}) * on(namespace, pod, cluster) group_left(owner_kind) topk by(namespace, pod, cluster) (1, max by(namespace, pod, owner_kind, cluster) (kube_pod_owner{owner_kind!="Job"}))) > 0
              for: 15m
              labels:
                 severity: warning
              annotations:
                description: Pod {{ $labels.namespace }}/{{ $labels.pod }} ({{ $labels.container }}) has been in a non-ready state for longer than 15 minutes.
                summary: Pod has been in a non-ready state for more than 15 minutes.
        - name: kubeapps-03
          rules:
            - alert: KubeDeploymentGenerationMismatch
              expr: kube_deployment_status_observed_generation{job="kube-state-metrics",namespace=~".*"} != kube_deployment_metadata_generation{job="kube-state-metrics",namespace=~".*"}
              for: 15m
              labels:
                 severity: warning
              annotations:
                description: Deployment generation for {{ $labels.namespace }}/{{ $labels.deployment }} does not match, this indicates that the Deployment has failed but has not been rolled back.
                summary: Deployment generation mismatch due to possible roll-back
        - name: kubeapps-04
          rules:
            - alert: KubeDeploymentReplicasMismatch
              expr: (kube_deployment_spec_replicas{job="kube-state-metrics",namespace=~".*"} > kube_deployment_status_replicas_available{job="kube-state-metrics",namespace=~".*"}) and (changes(kube_deployment_status_replicas_updated{job="kube-state-metrics",namespace=~".*"}[10m]) == 0)
              for: 15m
              labels:
                 severity: warning
              annotations:
                description: Deployment {{ $labels.namespace }}/{{ $labels.deployment }} has not matched the expected number of replicas for longer than 15 minutes.
                summary: Deployment has not matched the expected number of replicas.
        - name: kubeapps-05
          rules:
            - alert: KubeStatefulSetReplicasMismatch
              expr: (kube_statefulset_status_replicas_ready{job="kube-state-metrics",namespace=~".*"} != kube_statefulset_status_replicas{job="kube-state-metrics",namespace=~".*"}) and (changes(kube_statefulset_status_replicas_updated{job="kube-state-metrics",namespace=~".*"}[10m]) == 0)
              for: 15m
              labels:
                 severity: warning
              annotations:
                description: StatefulSet {{ $labels.namespace }}/{{ $labels.statefulset }} has not matched the expected number of replicas for longer than 15 minutes.
                summary: Deployment has not matched the expected number of replicas.
        - name: kubeapps-06
          rules:
            - alert: KubeStatefulSetGenerationMismatch
              expr: kube_statefulset_status_observed_generation{job="kube-state-metrics",namespace=~".*"} != kube_statefulset_metadata_generation{job="kube-state-metrics",namespace=~".*"}
              for: 15m
              labels:
                 severity: warning
              annotations:
                description: StatefulSet generation for {{ $labels.namespace }}/{{ $labels.statefulset }} does not match, this indicates that the StatefulSet has failed but has not been rolled back.
                summary: StatefulSet generation mismatch due to possible roll-back
        - name: kubeapps-07
          rules:
            - alert: KubeStatefulSetUpdateNotRolledOut
              expr: (max without(revision) (kube_statefulset_status_current_revision{job="kube-state-metrics",namespace=~".*"} unless kube_statefulset_status_update_revision{job="kube-state-metrics",namespace=~".*"}) * (kube_statefulset_replicas{job="kube-state-metrics",namespace=~".*"} != kube_statefulset_status_replicas_updated{job="kube-state-metrics",namespace=~".*"})) and (changes(kube_statefulset_status_replicas_updated{job="kube-state-metrics",namespace=~".*"}[5m]) == 0)
              for: 15m
              labels:
                 severity: warning
              annotations:
                description: StatefulSet {{ $labels.namespace }}/{{ $labels.statefulset }} update has not been rolled out.
                summary: StatefulSet update has not been rolled out.
        - name: kubeapps-08
          rules:
            - alert: KubeDaemonSetRolloutStuck
              expr: ((kube_daemonset_status_current_number_scheduled{job="kube-state-metrics",namespace=~".*"} != kube_daemonset_status_desired_number_scheduled{job="kube-state-metrics",namespace=~".*"}) or (kube_daemonset_status_number_misscheduled{job="kube-state-metrics",namespace=~".*"} != 0) or (kube_daemonset_status_updated_number_scheduled{job="kube-state-metrics",namespace=~".*"} != kube_daemonset_status_desired_number_scheduled{job="kube-state-metrics",namespace=~".*"}) or (kube_daemonset_status_number_available{job="kube-state-metrics",namespace=~".*"} != kube_daemonset_status_desired_number_scheduled{job="kube-state-metrics",namespace=~".*"})) and (changes(kube_daemonset_status_updated_number_scheduled{job="kube-state-metrics",namespace=~".*"}[5m]) == 0)
              for: 15m
              labels:
                 severity: warning
              annotations:
                description: DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset }} has not finished or progressed for at least 15 minutes.
                summary: DaemonSet rollout is stuck.
        - name: kubeapps-09
          rules:
            - alert: KubeContainerWaiting
              expr: sum by(namespace, pod, container, cluster) (kube_pod_container_status_waiting_reason{job="kube-state-metrics",namespace=~".*"}) > 0
              for: 1h
              labels:
                 severity: warning
              annotations:
                description: Pod/{{ $labels.pod }} in namespace {{ $labels.namespace }} on container {{ $labels.container}} has been in waiting state for longer than 1 hour.
                summary:  Pod container waiting longer than 1 hour
        - name: kubeapps-10
          rules:
            - alert: KubeDaemonSetNotScheduled
              expr: kube_daemonset_status_desired_number_scheduled{job="kube-state-metrics",namespace=~".*"} - kube_daemonset_status_current_number_scheduled{job="kube-state-metrics",namespace=~".*"} > 0
              for: 10m
              labels:
                 severity: warning
              annotations:
                description: The {{ $value }} Pods of DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset }} are not scheduled.
                summary: DaemonSet pods are not scheduled.
        - name: kubeapps-11
          rules:
            - alert: KubeDaemonSetMisScheduled
              expr: kube_daemonset_status_number_misscheduled{job="kube-state-metrics",namespace=~".*"} > 0
              for: 15m
              labels:
                 severity: warning
              annotations:
                description: The {{ $value }} Pods of DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset }} are running where they are not supposed to run.
                summary: DaemonSet pods are misscheduled.
        - name: kubeapps-12
          rules:
            - alert: KubeJobNotCompleted
              expr: time() - max by(namespace, job_name, cluster) (kube_job_status_start_time{job="kube-state-metrics",namespace=~".*"} and kube_job_status_active{job="kube-state-metrics",namespace=~".*"} > 0) > 43200
              labels:
                 severity: warning
              annotations:
                description: Job {{ $labels.namespace }}/{{ $labels.job_name }} is taking more than {{ "43200" | humanizeDuration }} to complete.
                summary: Job did not complete in time
        - name: kubeapps-13
          rules:
            - alert: KubeJobFailed
              expr: kube_job_failed{job="kube-state-metrics",namespace=~".*"} > 0
              for: 15m
              labels:
                 severity: warning
              annotations:
                description: Job {{ $labels.namespace }}/{{ $labels.job_name }} failed to complete. Removing failed job after investigation should clear this alert.
                summary: Job failed to complete.
        - name: kubeapps-14
          rules:
            - alert: KubeHpaReplicasMismatch
              expr: (kube_horizontalpodautoscaler_status_desired_replicas{job="kube-state-metrics",namespace=~".*"} != kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics",namespace=~".*"}) and (kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics",namespace=~".*"} > kube_horizontalpodautoscaler_spec_min_replicas{job="kube-state-metrics",namespace=~".*"}) and (kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics",namespace=~".*"} < kube_horizontalpodautoscaler_spec_max_replicas{job="kube-state-metrics",namespace=~".*"}) and changes(kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics",namespace=~".*"}[15m]) == 0
              for: 15m
              labels:
                 severity: warning
              annotations:
                description: HPA {{ $labels.namespace }}/{{ $labels.horizontalpodautoscaler }} has not matched the desired number of replicas for longer than 15 minutes.
                summary: HPA has not matched descired number of replicas.
        - name: kubeapps-15
          rules:
            - alert: KubeHpaMaxedOut
              expr: kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics",namespace=~".*"} == kube_horizontalpodautoscaler_spec_max_replicas{job="kube-state-metrics",namespace=~".*"}
              for: 15m
              labels:
                 severity: warning
              annotations:
                description: HPA {{ $labels.namespace }}/{{ $labels.horizontalpodautoscaler }} has been running at max replicas for longer than 15 minutes.
                summary: HPA is running at max replicas                                                                                                            
      EOT      
    }
    kubelet = {
      name = "kubelet-rules"
      data = <<-EOT
      groups:
        - name: kubelet-01
          rules:
            - record: node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile
              expr: histogram_quantile(0.99, sum by(cluster, instance, le) (rate(kubelet_pleg_relist_duration_seconds_bucket[5m])) * on(cluster, instance) group_left(node) kubelet_node_name{job="kubelet",metrics_path="/metrics"})
              labels:
                 quantile: 0.99
        - name: kubelet-02
          rules:
            - record: node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile
              expr: histogram_quantile(0.9, sum by(cluster, instance, le) (rate(kubelet_pleg_relist_duration_seconds_bucket[5m])) * on(cluster, instance) group_left(node) kubelet_node_name{job="kubelet",metrics_path="/metrics"})
              labels:
                 quantile: 0.9
        - name: kubelet-03
          rules:
            - record: node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile
              expr: histogram_quantile(0.5, sum by(cluster, instance, le) (rate(kubelet_pleg_relist_duration_seconds_bucket[5m])) * on(cluster, instance) group_left(node) kubelet_node_name{job="kubelet",metrics_path="/metrics"})
              labels:
                 quantile: 0.5       
      EOT           
    }
    kubestm = {
      name = "kubestm-rules"
      data = <<-EOT
      groups:
        - name: kubestm-01
          rules:
            - alert: KubeStateMetricsListErrors
              expr: (sum(rate(kube_state_metrics_list_total{job="kube-state-metrics",result="error"}[5m])) / sum(rate(kube_state_metrics_list_total{job="kube-state-metrics"}[5m]))) > 0.01
              for: 15m
              labels:
                 severity: critical
              annotations:
                description: kube-state-metrics is experiencing errors at an elevated rate in list operations. This is likely causing it to not be able to expose metrics about Kubernetes objects or at all.   
                summary: kube-state-metrics is experiencing errors in list operations.
        - name: kubestm-02
          rules:
            - alert: KubeStateMetricsWatchErrors
              expr: (sum(rate(kube_state_metrics_watch_total{job="kube-state-metrics",result="error"}[5m])) / sum(rate(kube_state_metrics_watch_total{job="kube-state-metrics"}[5m]))) > 0.01
              for: 15m
              labels:
                 severity: critical
              annotations:
                description: kube-state-metrics is experiencing errors at an elevated rate in list operations. This is likely causing it to not be able to expose metrics about Kubernetes objects or at all.   
                summary: kube-state-metrics is experiencing errors in watch operations.
        - name: kubestm-03
          rules:
            - alert: KubeStateMetricsShardingMismatch
              expr: stdvar(kube_state_metrics_total_shards{job="kube-state-metrics"}) != 0
              for: 15m
              labels:
                 severity: critical
              annotations:
                description: kube-state-metrics pods are running with different --total-shards configuration, some Kubernetes objects may be exposed multiple times or not exposed at all.   
                summary: kube-state-metrics sharding is misconfigured.
        - name: kubestm-04
          rules:
            - alert: KubeStateMetricsShardsMissing
              expr: 2 ^ max(kube_state_metrics_total_shards{job="kube-state-metrics"}) - 1 - sum(2 ^ max by(shard_ordinal) (kube_state_metrics_shard_ordinal{job="kube-state-metrics"})) != 0
              for: 15m
              labels:
                 severity: critical
              annotations:
                description: kube-state-metrics shards are missing, some Kubernetes objects are not being exposed.  
                summary: kube-state-metrics shards are missing.                     
      EOT
    }
    kubescheduler = {
      name = "kubescheduler-rules"
      data = <<-EOT
      groups:
        - name: kubeschdlr-01
          rules:
            - record: cluster_quantile:scheduler_e2e_scheduling_duration_seconds:histogram_quantile
              expr: histogram_quantile(0.99, sum without(instance, pod) (rate(scheduler_e2e_scheduling_duration_seconds_bucket{job="kube-scheduler"}[5m])))
              labels:
                 quantile: 0.99
        - name: kubeschdlr-02
          rules:
            - record: cluster_quantile:scheduler_scheduling_algorithm_duration_seconds:histogram_quantile
              expr: histogram_quantile(0.99, sum without(instance, pod) (rate(scheduler_scheduling_algorithm_duration_seconds_bucket{job="kube-scheduler"}[5m])))
              labels:
                 quantile: 0.99
        - name: kubeschdlr-03
          rules:
            - record: cluster_quantile:scheduler_binding_duration_seconds:histogram_quantile
              expr: histogram_quantile(0.99, sum without(instance, pod) (rate(scheduler_binding_duration_seconds_bucket{job="kube-scheduler"}[5m])))
              labels:
                 quantile: 0.99
        - name: kubeschdlr-04
          rules:
            - record: cluster_quantile:scheduler_e2e_scheduling_duration_seconds:histogram_quantile
              expr: histogram_quantile(0.9, sum without(instance, pod) (rate(scheduler_e2e_scheduling_duration_seconds_bucket{job="kube-scheduler"}[5m])))
              labels:
                 quantile: 0.9
        - name: kubeschdlr-05
          rules:
            - record: cluster_quantile:scheduler_scheduling_algorithm_duration_seconds:histogram_quantile
              expr: histogram_quantile(0.9, sum without(instance, pod) (rate(scheduler_scheduling_algorithm_duration_seconds_bucket{job="kube-scheduler"}[5m])))
              labels:
                 quantile: 0.9
        - name: kubeschdlr-06
          rules:
            - record: cluster_quantile:scheduler_binding_duration_seconds:histogram_quantile
              expr: histogram_quantile(0.9, sum without(instance, pod) (rate(scheduler_binding_duration_seconds_bucket{job="kube-scheduler"}[5m])))
              labels:
                 quantile: 0.9
        - name: kubeschdlr-07
          rules:
            - record: cluster_quantile:scheduler_e2e_scheduling_duration_seconds:histogram_quantile
              expr: histogram_quantile(0.5, sum without(instance, pod) (rate(scheduler_e2e_scheduling_duration_seconds_bucket{job="kube-scheduler"}[5m])))
              labels:
                 quantile: 0.5
        - name: kubeschdlr-08
          rules:
            - record: cluster_quantile:scheduler_scheduling_algorithm_duration_seconds:histogram_quantile
              expr: histogram_quantile(0.5, sum without(instance, pod) (rate(scheduler_scheduling_algorithm_duration_seconds_bucket{job="kube-scheduler"}[5m])))
              labels:
                 quantile: 0.5
        - name: kubeschdlr-09
          rules:
            - record: cluster_quantile:scheduler_binding_duration_seconds:histogram_quantile
              expr: histogram_quantile(0.5, sum without(instance, pod) (rate(scheduler_binding_duration_seconds_bucket{job="kube-scheduler"}[5m])))
              labels:
                 quantile: 0.5                                                                        

      EOT
    }
    kubeprom-noderecording = {
      name = "kubeprom-noderecording"
      data = <<-EOT
      groups:
        - name: kubepromnr-01
          rules:
            - record: instance:node_cpu:rate:sum
              expr: sum by(instance) (rate(node_cpu_seconds_total{mode!="idle",mode!="iowait",mode!="steal"}[3m]))
        - name: kubepromnr-02
          rules:
            - record: instance:node_network_receive_bytes:rate:sum
              expr: sum by(instance) (rate(node_network_receive_bytes_total[3m]))
        - name: kubepromnr-03
          rules:
            - record: instance:node_network_transmit_bytes:rate:sum
              expr: sum by(instance) (rate(node_network_transmit_bytes_total[3m]))
        - name: kubepromnr-04
          rules:
            - record: instance:node_cpu:ratio
              expr: sum without(cpu, mode) (rate(node_cpu_seconds_total{mode!="idle",mode!="iowait",mode!="steal"}[5m])) / on(instance) group_left() count by(instance) (sum by(instance, cpu) (node_cpu_seconds_total))
        - name: kubepromnr-05
          rules:
            - record: cluster:node_cpu:sum_rate5m
              expr: sum(rate(node_cpu_seconds_total{mode!="idle",mode!="iowait",mode!="steal"}[5m]))
        - name: kubepromnr-06
          rules:
            - record: cluster:node_cpu:ratio
              expr: cluster:node_cpu:sum_rate5m / count(sum by(instance, cpu) (node_cpu_seconds_total))                       
      EOT
    }
    kube-prom = {
      name = "kube-prom"
      data = <<-EOT
      groups:
        - name: kubprom-01
          rules:
            - record: count:up1
              expr: count without(instance, pod, node) (up == 1)
        - name: kubprom-02
          rules:
            - record: count:up0
              expr: count without(instance, pod, node) (up == 0)      
      EOT
    }
    api-slos = {
      name = "api-slos"
      data = <<-EOT
      groups:
        - name: apislos-01
          rules:
            - alert: KubeAPIErrorBudgetBurn
              expr: sum(apiserver_request:burnrate1h) > (14.4 * 0.01) and sum(apiserver_request:burnrate5m) > (14.4 * 0.01)
              for: 2m
              labels:
                 long: 1h
                 severity: critical
                 short: 5m
              annotations:
                description: The API server is burning too much error budget.
                summary: The API server is burning too much error budget.
        - name: apislos-02
          rules:
            - alert: KubeAPIErrorBudgetBurn
              expr: sum(apiserver_request:burnrate6h) > (6 * 0.01) and sum(apiserver_request:burnrate30m) > (6 * 0.01)
              for: 15m
              labels:
                 long: 6h
                 severity: critical
                 short: 30m
              annotations:
                description: The API server is burning too much error budget.
                summary: The API server is burning too much error budget.      
        - name: apislos-03
          rules:
            - alert: KubeAPIErrorBudgetBurn
              expr: sum(apiserver_request:burnrate1d) > (3 * 0.01) and sum(apiserver_request:burnrate2h) > (3 * 0.01)
              for: 1d
              labels:
                 long: 1d
                 severity: warning
                 short: 2h
              annotations:
                description: The API server is burning too much error budget.
                summary: The API server is burning too much error budget.  
        - name: apislos-04
          rules:
            - alert: KubeAPIErrorBudgetBurn
              expr: sum(apiserver_request:burnrate3d) > (1 * 0.01) and sum(apiserver_request:burnrate6h) > (1 * 0.01)
              for: 3h
              labels:
                 long: 3d
                 severity: warning
                 short: 6h
              annotations:
                description: The API server is burning too much error budget.
                summary: The API server is burning too much error budget.                      
      EOT    
    }
    api-histogram = {
      name = "api-histogram"
      data = <<-EOT
      groups:
        - name: apihg-01
          rules:
            - record: cluster_quantile:apiserver_request_slo_duration_seconds:histogram_quantile
              expr: histogram_quantile(0.99, sum by(cluster, le, resource) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[5m]))) > 0
              labels:
                 quantile: 0.99
                 verb: read
        - name: apihg-02
          rules:
            - record: cluster_quantile:apiserver_request_slo_duration_seconds:histogram_quantile
              expr: histogram_quantile(0.99, sum by(cluster, le, resource) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[5m]))) > 0
              labels:
                 quantile: 0.99
                 verb: write
      EOT
    }
    api-burnrate = {
      name = "api-burnrate"
      data = <<-EOT
      groups:
        - name: apibr-01
          rules:
            - record: apiserver_request:burnrate1d
              expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[1d])) - ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",scope=~"resource|",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[1d])) or vector(0)) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="5",scope="namespace",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[1d])) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="30",scope="cluster",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[1d])))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"LIST|GET"}[1d]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[1d]))
              labels:
                 verb: read
        - name: apibr-02
          rules:
            - record: apiserver_request:burnrate1h
              expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[1h])) - ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",scope=~"resource|",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[1h])) or vector(0)) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="5",scope="namespace",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[1h])) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="30",scope="cluster",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[1h])))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"LIST|GET"}[1h]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[1h]))
              labels:
                 verb: read
        - name: apibr-03
          rules:
            - record: apiserver_request:burnrate2h
              expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[2h])) - ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",scope=~"resource|",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[2h])) or vector(0)) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="5",scope="namespace",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[2h])) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="30",scope="cluster",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[2h])))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"LIST|GET"}[2h]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[2h]))
              labels:
                 verb: read
        - name: apibr-04
          rules:
            - record: apiserver_request:burnrate30m
              expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[30m])) - ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",scope=~"resource|",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[30m])) or vector(0)) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="5",scope="namespace",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[30m])) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="30",scope="cluster",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[30m])))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"LIST|GET"}[30m]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[30m]))
              labels:
                 verb: read
        - name: apibr-05
          rules:
            - record: apiserver_request:burnrate3d
              expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[3d])) - ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",scope=~"resource|",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[3d])) or vector(0)) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="5",scope="namespace",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[3d])) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="30",scope="cluster",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[3d])))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"LIST|GET"}[3d]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[3d]))
              labels:
                 verb: read
        - name: apibr-06
          rules:
            - record: apiserver_request:burnrate5m
              expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[5m])) - ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",scope=~"resource|",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[5m])) or vector(0)) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="5",scope="namespace",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[5m])) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="30",scope="cluster",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[5m])))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"LIST|GET"}[5m]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[5m]))
              labels:
                 verb: read
        - name: apibr-07
          rules:
            - record: apiserver_request:burnrate6h
              expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[6h])) - ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",scope=~"resource|",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[6h])) or vector(0)) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="5",scope="namespace",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[6h])) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="30",scope="cluster",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[6h])))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"LIST|GET"}[6h]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[6h]))
              labels:
                 verb: read
        - name: apibr-08
          rules:
            - record: apiserver_request:burnrate1d
              expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[1d])) - sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[1d]))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[1d]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[1d]))
              labels:
                 verb: read
        - name: apibr-09
          rules:
            - record: apiserver_request:burnrate1d
              expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[1d])) - ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",scope=~"resource|",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[1d])) or vector(0)) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="5",scope="namespace",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[1d])) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="30",scope="cluster",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[1d])))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"LIST|GET"}[1d]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[1d]))
              labels:
                 verb: write
        - name: apibr-10
          rules:
            - record: apiserver_request:burnrate1h
              expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[1h])) - sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[1h]))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[1h]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[1h]))
              labels:
                 verb: write
        - name: apibr-11
          rules:
            - record: apiserver_request:burnrate2h
              expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[2h])) - sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[2h]))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[2h]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[2h]))
              labels:
                 verb: write
        - name: apibr-12
          rules:
            - record: apiserver_request:burnrate30m
              expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[30m])) - sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[30m]))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[30m]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[30m]))
              labels:
                 verb: write
        - name: apibr-13
          rules:
            - record: apiserver_request:burnrate3d
              expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[3d])) - sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[3d]))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[3d]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[3d]))
              labels:
                 verb: write
        - name: apibr-14
          rules:
            - record: apiserver_request:burnrate5m
              expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[5m])) - sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[5m]))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[5m]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[5m]))
              labels:
                 verb: write
        - name: apibr-15
          rules:
            - record: apiserver_request:burnrate6h
              expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[6h])) - sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[6h]))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[6h]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[6h]))
              labels:
                 verb: write         
      EOT                                                                                                                
    }
    general = {
      name = "generic-rules"
      data = <<-EOT
      groups:
        - name: general-01
          rules:
            - alert: TargetDown
              expr: 100 * (count by(job, namespace, service) (up == 0) / count by(job, namespace, service) (up)) > 10
              for: 10m
              labels:
                 severity: warning
              annotations:
                description: The {{ printf "%.4g" $value }}% of the {{ $labels.job }}/{{ $labels.service }} targets in {{ $labels.namespace }} namespace are down.
        - name: general-02
          rules:
            - alert: Watchdog
              expr: vector(1)            
              labels:
                 severity: none
              annotations:
                description: This is an alert meant to ensure that the entire alerting pipeline is functional. This alert is always firing, therefore it should always be firing in Alertmanager and always fire against a receiver. There are integrations with various notification mechanisms that send a notification when this alert is not firing. For example the "DeadMansSnitch" integration in PagerDuty.   
        - name: general-03
          rules:
            - alert: InfoInhibitor
              expr: ALERTS{severity="info"} == 1 unless on(namespace) ALERTS{alertname!="InfoInhibitor",alertstate="firing",severity=~"warning|critical"} == 1
              labels:
                 severity: none
              annotations:
                description: This is an alert that is used to inhibit info alerts. By themselves, the info-level alerts are sometimes very noisy, but they are relevant when combined with other alerts. This alert fires whenever there's a severity="info" alert, and stops firing when another alert with a severity of 'warning' or 'critical' starts firing on the same namespace. This alert should be routed to a null receiver and configured to inhibit alerts with severity="info".
      EOT                    
    }
    etcd = {
      name = "etcd-rules"
      data = <<-EOT
      groups:
        - name: etcd-01
          rules:
            - alert: etcdInsufficientMembers
              expr: sum by(job) (up{job=~".*etcd.*"} == bool 1) < ((count by(job) (up{job=~".*etcd.*"}) + 1) / 2)
              for: 3m
              labels:
                 severity: critical
              annotations:
                message: etcd cluster "{{ $labels.job }}":insufficient members ({{ $value }}).
        - name: etcd-02   
          rules:
            - alert: etcdHighNumberOfLeaderChanges
              expr: rate(etcd_server_leader_changes_seen_total{job=~".*etcd.*"}[15m]) > 3
              for: 15m
              labels:
                 severity: warning
              annotations:
                message: etcd cluster "{{ $labels.job }}":instance {{ $labels.instance }} has seen {{ $value }} leader changes within the last hour.
        - name: etcd-03   
          rules:
            - alert: etcdNoLeader
              expr: etcd_server_has_leader{job=~".*etcd.*"} == 0
              for: 1m
              labels:
                 severity: critical
              annotations:
                message: message:etcd cluster "{{ $labels.job }}":member {{ $labels.instance }} has no leader.
        - name: etcd-04   
          rules:
            - alert: etcdHighNumberOfFailedGRPCRequests
              expr: 100 * sum by(job, instance, grpc_service, grpc_method) (rate(grpc_server_handled_total{grpc_code!="OK",job=~".*etcd.*"}[5m])) / sum by(job, instance, grpc_service, grpc_method) (rate(grpc_server_handled_total{job=~".*etcd.*"}[5m])) > 1
              for: 10m
              labels:
                 severity: warning
              annotations:
                message: etcd cluster "{{ $labels.job }}":{{ $value }}% of requests for {{ $labels.grpc_method }} failed on etcd instance {{ $labels.instance }}.
        - name: etcd-05   
          rules:
            - alert: etcdGRPCRequestsSlow
              expr: histogram_quantile(0.99, sum by(job, instance, grpc_service, grpc_method, le) (rate(grpc_server_handling_seconds_bucket{grpc_type="unary",job=~".*etcd.*"}[5m]))) > 0.15
              for: 10m
              labels:
                 severity: critical
              annotations:
                message: etcd cluster "{{ $labels.job }}":gRPC requests to {{ $labels.grpc_method }} are taking {{ $value }}s on etcd instance {{ $labels.instance }}.
        - name: etcd-06   
          rules:
            - alert: etcdMemberCommunicationSlow
              expr: histogram_quantile(0.99, rate(etcd_network_peer_round_trip_time_seconds_bucket{job=~".*etcd.*"}[5m])) > 0.15
              for: 10m
              labels:
                 severity: warning
              annotations:
                message: message:etcd cluster "{{ $labels.job }}":member communication with {{ $labels.To }} is taking {{ $value }}s on etcd instance {{ $labels.instance }}.
        - name: etcd-07   
          rules:
            - alert: etcdHighNumberOfFailedProposals
              expr: rate(etcd_server_proposals_failed_total{job=~".*etcd.*"}[15m]) > 5
              for: 15m
              labels:
                 severity: warning
              annotations:
                message: etcd cluster "{{ $labels.job }}":{{ $value }} proposal failures within the last hour on etcd instance {{ $labels.instance }}.
        - name: etcd-08   
          rules:
            - alert: etcdHighFsyncDurations
              expr: histogram_quantile(0.99, rate(etcd_disk_wal_fsync_duration_seconds_bucket{job=~".*etcd.*"}[5m])) > 0.5
              for: 10m
              labels:
                 severity: warning
              annotations:
                message: etcd cluster "{{ $labels.job }}":99th percentile fync durations are {{ $value }}s on etcd instance {{ $labels.instance }}.
        - name: etcd-09  
          rules:
            - alert: etcdHighCommitDurations
              expr: histogram_quantile(0.99, rate(etcd_disk_backend_commit_duration_seconds_bucket{job=~".*etcd.*"}[5m])) > 0.25
              for: 10m
              labels:
                 severity: warning
              annotations:
                message: etcd cluster "{{ $labels.job }}":99th percentile commit durations {{ $value }}s on etcd instance {{ $labels.instance }}.
        - name: etcd-10   
          rules:
            - alert: etcdHighNumberOfFailedHTTPRequests
              expr: sum by(method) (rate(etcd_http_failed_total{code!="404",job=~".*etcd.*"}[5m])) / sum by(method) (rate(etcd_http_received_total{job=~".*etcd.*"}[5m])) > 0.01
              for: 10m
              labels:
                 severity: warning
              annotations:
                message: The {{ $value }}% of requests for {{ $labels.method }} failed on etcd instance {{ $labels.instance }}
        - name: etcd-11   
          rules:
            - alert: etcdHighNumberOfFailedHTTPRequests
              expr: sum by(method) (rate(etcd_http_failed_total{code!="404",job=~".*etcd.*"}[5m])) / sum by(method) (rate(etcd_http_received_total{job=~".*etcd.*"}[5m])) > 0.05
              for: 10m
              labels:
                 severity: warning
              annotations:
                message: The {{ $value }}% of requests for {{ $labels.method }} failed on etcd instance {{ $labels.instance }}.
        - name: etcd-12
          rules:
            - alert: etcdHTTPRequestsSlow
              expr: histogram_quantile(0.99, rate(etcd_http_successful_duration_seconds_bucket[5m])) > 0.15
              for: 10m
              labels:
                 severity: warning
              annotations:
                message: etcd instance {{ $labels.instance }} HTTP requests to {{ $labels.method }} are slow. 
      EOT                                                                                                   
    }
    api-server = {
      name = "api-availability-rules"
      data = <<-EOT
      groups:
        - name: api-01
          rules:
            - record: code_verb:apiserver_request_total:increase30d
              expr: avg_over_time(code_verb:apiserver_request_total:increase1h[30d]) * 24 * 30
        - name: api-02
          rules:
            - record: code:apiserver_request_total:increase30d
              expr: sum by(cluster, code) (code_verb:apiserver_request_total:increase30d{verb=~"LIST|GET"})
              labels:
                 verb: read
        - name: api-03
          rules:
            - record: code:apiserver_request_total:increase30d
              expr: sum by(cluster, code) (code_verb:apiserver_request_total:increase30d{verb=~"POST|PUT|PATCH|DELETE"})
              labels:
                 verb: write
        - name: api-04
          rules:
            - record: cluster_verb_scope:apiserver_request_slo_duration_seconds_count:increase1h
              expr: sum by(cluster, verb, scope) (increase(apiserver_request_slo_duration_seconds_count[1h]))
        - name: api-05
          rules:
            - record: cluster_verb_scope:apiserver_request_slo_duration_seconds_count:increase30d
              expr: sum by(cluster, verb, scope) (avg_over_time(cluster_verb_scope:apiserver_request_slo_duration_seconds_count:increase1h[30d]) * 24 * 30)
      EOT
    }
    kube-prometheus-stack = {
      name = "General_rules"
      data = <<-EOT
      groups:
        - name: k8s-01
          rules:
            - record: node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate
              expr: sum by(cluster, namespace, pod, container) (irate(container_cpu_usage_seconds_total{image!="",job="kubelet",metrics_path="/metrics/cadvisor"}[5m])) * on(cluster, namespace, pod) group_left(node) topk by(cluster, namespace, pod) (1, max by(cluster, namespace, pod, node) (kube_pod_info{node!=""}))
        
        - name: k8s-02
          rules:
            - record: node_namespace_pod_container:container_memory_working_set_bytes
              expr: container_memory_working_set_bytes{image!="",job="kubelet",metrics_path="/metrics/cadvisor"} * on(namespace, pod) group_left(node) topk by(namespace, pod) (1, max by(namespace, pod, node) (kube_pod_info{node!=""}))
        - name: k8s-03
          rules:
            - record: node_namespace_pod_container:container_memory_rss
              expr: container_memory_rss{image!="",job="kubelet",metrics_path="/metrics/cadvisor"} * on(namespace, pod) group_left(node) topk by(namespace, pod) (1, max by(namespace, pod, node) (kube_pod_info{node!=""}))
        - name: k8s-04
          rules:
            - record: node_namespace_pod_container:container_memory_cache
              expr: container_memory_cache{image!="",job="kubelet",metrics_path="/metrics/cadvisor"} * on(namespace, pod) group_left(node) topk by(namespace, pod) (1, max by(namespace, pod, node) (kube_pod_info{node!=""}))
        - name: k8s-05
          rules:
            - record: node_namespace_pod_container:container_memory_swap
              expr: container_memory_swap{image!="",job="kubelet",metrics_path="/metrics/cadvisor"} * on(namespace, pod) group_left(node) topk by(namespace, pod) (1, max by(namespace, pod, node) (kube_pod_info{node!=""}))
        - name: k8s-06
          rules:
            - record: cluster:namespace:pod_memory:active:kube_pod_container_resource_requests
              expr: kube_pod_container_resource_requests{job="kube-state-metrics",resource="memory"} * on(namespace, pod, cluster) group_left() max by(namespace, pod, cluster) ((kube_pod_status_phase{phase=~"Pending|Running"} == 1))
        - name: k8s-07
          rules:
            - record: namespace_memory:kube_pod_container_resource_requests:sum
              expr: sum by(namespace, cluster) (sum by(namespace, pod, cluster) (max by(namespace, pod, container, cluster) (kube_pod_container_resource_requests{job="kube-state-metrics",resource="memory"}) * on(namespace, pod, cluster) group_left() max by(namespace, pod, cluster) (kube_pod_status_phase{phase=~"Pending|Running"} == 1)))
        - name: k8s-08
          rules:
            - record: cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests
              expr: kube_pod_container_resource_requests{job="kube-state-metrics",resource="cpu"} * on(namespace, pod, cluster) group_left() max by(namespace, pod, cluster) ((kube_pod_status_phase{phase=~"Pending|Running"} == 1))
        - name: k8s-09
          rules:
            - record: namespace_cpu:kube_pod_container_resource_requests:sum
              expr: sum by(namespace, cluster) (sum by(namespace, pod, cluster) (max by(namespace, pod, container, cluster) (kube_pod_container_resource_requests{job="kube-state-metrics",resource="cpu"}) * on(namespace, pod, cluster) group_left() max by(namespace, pod, cluster) (kube_pod_status_phase{phase=~"Pending|Running"} == 1)))  
        - name: k8s-10
          rules:
            - record: cluster:namespace:pod_memory:active:kube_pod_container_resource_limits
              expr: kube_pod_container_resource_limits{job="kube-state-metrics",resource="memory"} * on(namespace, pod, cluster) group_left() max by(namespace, pod, cluster) ((kube_pod_status_phase{phase=~"Pending|Running"} == 1))
        - name: k8s-11
          rules:
            - record: namespace_memory:kube_pod_container_resource_limits:sum
              expr: sum by(namespace, cluster) (sum by(namespace, pod, cluster) (max by(namespace, pod, container, cluster) (kube_pod_container_resource_limits{job="kube-state-metrics",resource="memory"}) * on(namespace, pod, cluster) group_left() max by(namespace, pod, cluster) (kube_pod_status_phase{phase=~"Pending|Running"} == 1)))
        - name: k8s-12
          rules:
            - record: cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits
              expr: kube_pod_container_resource_limits{job="kube-state-metrics",resource="cpu"} * on(namespace, pod, cluster) group_left() max by(namespace, pod, cluster) ((kube_pod_status_phase{phase=~"Pending|Running"} == 1))
        - name: k8s-13
          rules:
            - record: namespace_cpu:kube_pod_container_resource_limits:sum
              expr: sum by(namespace, cluster) (sum by(namespace, pod, cluster) (max by(namespace, pod, container, cluster) (kube_pod_container_resource_limits{job="kube-state-metrics",resource="cpu"}) * on(namespace, pod, cluster) group_left() max by(namespace, pod, cluster) (kube_pod_status_phase{phase=~"Pending|Running"} == 1)))
        - name: k8s-14
          rules:
            - record: namespace_workload_pod:kube_pod_owner:relabel
              expr: max by(cluster, namespace, workload, pod) (label_replace(label_replace(kube_pod_owner{job="kube-state-metrics",owner_kind="ReplicaSet"}, "replicaset", "$1", "owner_name", "(.*)") * on(replicaset, namespace) group_left(owner_name) topk by(replicaset, namespace) (1, max by(replicaset, namespace, owner_name) (kube_replicaset_owner{job="kube-state-metrics"})), "workload", "$1", "owner_name", "(.*)"))
              labels:
                 workload_type: deployment
        - name: k8s-15
          rules:
            - record: namespace_workload_pod:kube_pod_owner:relabel
              expr: max by(cluster, namespace, workload, pod) (label_replace(kube_pod_owner{job="kube-state-metrics",owner_kind="DaemonSet"}, "workload", "$1", "owner_name", "(.*)"))
              labels:
                 workload_type: daemonset
        - name: k8s-16
          rules:
            - record: namespace_workload_pod:kube_pod_owner:relabel
              expr: max by(cluster, namespace, workload, pod) (label_replace(kube_pod_owner{job="kube-state-metrics",owner_kind="StatefulSet"}, "workload", "$1", "owner_name", "(.*)"))
              labels:
                 workload_type: statefulset
        - name: k8s-17
          rules:
            - record: namespace_workload_pod:kube_pod_owner:relabel
              expr: max by(cluster, namespace, workload, pod) (label_replace(kube_pod_owner{job="kube-state-metrics",owner_kind="Job"}, "workload", "$1", "owner_name", "(.*)"))
              labels:
                 workload_type: job
      EOT
    }
  }

  tags = local.tags
}

#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }

  tags = local.tags
}
