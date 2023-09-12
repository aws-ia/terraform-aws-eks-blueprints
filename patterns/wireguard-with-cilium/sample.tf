################################################################################
# Sample Application
################################################################################

resource "kubernetes_pod_v1" "server" {
  metadata {
    name = "server"
    labels = {
      blog = "wireguard"
      name = "server"
    }
  }

  spec {
    container {
      image = "nginx"
      name  = "server"
    }

    topology_spread_constraint {
      max_skew           = 1
      topology_key       = "kubernetes.io/hostname"
      when_unsatisfiable = "DoNotSchedule"

      label_selector {
        match_expressions {
          key      = "blog"
          operator = "In"
          values   = ["wireguard"]
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "server" {
  metadata {
    name = "server"
  }
  spec {
    selector = {
      name = kubernetes_pod_v1.server.metadata[0].labels.name
    }

    session_affinity = "ClientIP"

    port {
      port = 80
    }
  }
}

resource "kubernetes_pod_v1" "client" {
  metadata {
    name = "client"
    labels = {
      blog = "wireguard"
      name = "client"
    }
  }

  spec {
    container {
      image   = "busybox"
      name    = "client"
      command = ["watch", "wget", "server"]
    }

    topology_spread_constraint {
      max_skew           = 1
      topology_key       = "kubernetes.io/hostname"
      when_unsatisfiable = "DoNotSchedule"

      label_selector {
        match_expressions {
          key      = "blog"
          operator = "In"
          values   = ["wireguard"]
        }
      }
    }
  }
}
