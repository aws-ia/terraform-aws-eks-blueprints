locals {
  name = "app-2048"
}

resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = local.name
  }
}

resource "kubernetes_deployment_v1" "this" {
  metadata {
    name      = local.name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        "app.kubernetes.io/name" = local.name
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = local.name
        }
      }

      spec {
        container {
          image = "public.ecr.aws/l6m2t8p7/docker-2048:latest"
          # image_pull_policy = "Always"
          name = local.name

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "this" {
  metadata {
    name      = local.name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = local.name
    }


    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "NodePort"
  }
}

resource "kubernetes_ingress_v1" "this" {
  metadata {
    name      = local.name
    namespace = kubernetes_namespace_v1.this.metadata[0].name

    annotations = {
      "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = local.name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
