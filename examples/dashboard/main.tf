provider kubernetes {}

locals {
  labels = {
    k8s-app = "kubernetes-dashboard"
  }

  name      = "kubernetes-dashboard"
  namespace = kubernetes_namespace.dashboard.metadata[0].name
}

resource kubernetes_namespace dashboard {
  metadata {
    name = local.name
  }
}

resource kubernetes_service_account dashboard {
  metadata {
    labels    = local.labels
    name      = local.name
    namespace = local.namespace
  }
}

resource kubernetes_service dashboard {
  metadata {
    labels    = local.labels
    name      = local.name
    namespace = local.namespace
  }

  spec {
    port {
      port        = 443
      target_port = 8443
    }

    selector = {
      k8s-app = local.name
    }
  }
}

resource kubernetes_secret dashboard_certs {
  metadata {
    labels    = local.labels
    name      = format("%s-%s", local.name, "certs")
    namespace = local.namespace
  }

  type = "Opaque"
}

resource kubernetes_secret dashboard_csrf {
  data = {
    csrf = ""
  }

  metadata {
    labels    = local.labels
    name      = format("%s-%s", local.name, "csrf")
    namespace = local.namespace
  }

  type = "Opaque"
}

resource kubernetes_secret dashboard_key_holder {
  metadata {
    labels    = local.labels
    name      = format("%s-%s", local.name, "key-holder")
    namespace = local.namespace
  }

  type = "Opaque"
}

resource kubernetes_config_map dashboard {
  metadata {
    labels    = local.labels
    name      = local.name
    namespace = local.namespace
  }
}

resource kubernetes_role dashboard {
  metadata {
    labels    = local.labels
    name      = local.name
    namespace = local.namespace
  }

  // Allow Dashboard to get, update and delete Dashboard exclusive secrets.
  rule {
    api_groups = [""]
    resources  = ["secrets"]

    resource_names = [
      kubernetes_secret.dashboard_certs.metadata[0].name,
      kubernetes_secret.dashboard_csrf.metadata[0].name,
      kubernetes_secret.dashboard_key_holder.metadata[0].name
    ]

    verbs = ["get", "delete", "update"]
  }

  // Allow Dashboard to get and update 'kubernetes-dashboard-settings' config map.
  rule {
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = [kubernetes_config_map.dashboard.metadata[0].name]
    verbs          = ["get", "update"]
  }

  // Allow Dashboard to get metrics.
  rule {
    api_groups = [""]
    resources  = ["services"]

    resource_names = [
      "heapster",
      kubernetes_service.dashboard_metrics_scraper.metadata[0].name
    ]

    verbs = ["proxy"]
  }

  rule {
    api_groups = [""]
    resources  = ["services/proxy"]

    resource_names = [
      "heapster",
      "http:heapster:",
      "https:heapster:",
      kubernetes_service.dashboard_metrics_scraper.metadata[0].name,
      format("http:%s", kubernetes_service.dashboard_metrics_scraper.metadata[0].name)
    ]

    verbs = ["get"]
  }
}

resource kubernetes_cluster_role dashboard {
  metadata {
    labels = local.labels
    name   = local.name
  }

  rule {
    api_groups = ["metrics.k8s.io"]
    resources  = ["nodes", "pods"]
    verbs      = ["get", "list", "watch"]
  }
}

resource kubernetes_role_binding dashboard {
  metadata {
    labels    = local.labels
    name      = local.name
    namespace = local.name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.dashboard.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.dashboard.metadata[0].name
    namespace = kubernetes_service_account.dashboard.metadata[0].namespace
  }
}

resource kubernetes_cluster_role_binding dashboard {
  metadata {
    labels = local.labels
    name   = local.name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.dashboard.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.dashboard.metadata[0].name
    namespace = kubernetes_service_account.dashboard.metadata[0].namespace
  }
}

resource kubernetes_deployment dashboard {
  metadata {
    labels    = local.labels
    name      = local.name
    namespace = local.namespace
  }

  spec {
    replicas               = 1
    revision_history_limit = 10

    selector {
      match_labels = local.labels
    }

    template {
      metadata {
        labels = local.labels
      }

      spec {
        automount_service_account_token = true

        container {
          args = [
            "--auto-generate-certificates",
            format("--namespace=%s", local.namespace)
          ]

          image             = "kubernetesui/dashboard:v2.0.0-beta8"
          image_pull_policy = "Always"

          liveness_probe {
            http_get {
              path   = "/"
              port   = 8443
              scheme = "HTTPS"
            }

            initial_delay_seconds = 30
            timeout_seconds       = 30
          }

          name = local.name

          port {
            container_port = 8443
            protocol       = "TCP"
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_user                = 1001
            run_as_group               = 2001
          }

          volume_mount {
            mount_path = "/certs"
            name       = "kubernetes-dashboard-certs"
          }

          // Create on-disk volume to store exec logs
          volume_mount {
            mount_path = "/tmp"
            name       = "tmp-volume"
          }
        }

        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }

        service_account_name = kubernetes_service_account.dashboard.metadata[0].name

        toleration {
          effect = "NoSchedule"
          key    = "node-role.kubernetes.io/master"
        }

        volume {
          name = "kubernetes-dashboard-certs"

          secret {
            secret_name = kubernetes_secret.dashboard_certs.metadata[0].name
          }
        }

        volume {
          empty_dir {}

          name = "tmp-volume"
        }
      }
    }
  }
}

resource kubernetes_service dashboard_metrics_scraper {
  metadata {
    labels = {
      k8s-app = "dashboard-metrics-scraper"
    }

    name      = "dashboard-metrics-scraper"
    namespace = local.namespace
  }

  spec {
    port {
      port        = 8000
      target_port = 8000
    }

    selector = {
      k8s-app = "dashboard-metrics-scraper"
    }
  }
}

resource kubernetes_deployment dashboard_metrics_scraper {
  metadata {
    labels = {
      k8s-app = "dashboard-metrics-scraper"
    }

    name      = "dashboard-metrics-scraper"
    namespace = local.namespace
  }

  spec {
    replicas               = 1
    revision_history_limit = 10

    selector {
      match_labels = {
        k8s-app = "dashboard-metrics-scraper"
      }
    }

    template {
      metadata {
        annotations = {
          "seccomp.security.alpha.kubernetes.io/pod" = "runtime/default"
        }

        labels = {
          k8s-app = "dashboard-metrics-scraper"
        }
      }

      spec {
        automount_service_account_token = true

        container {
          image = "kubernetesui/metrics-scraper:v1.0.1"

          liveness_probe {
            http_get {
              path   = "/"
              port   = 8000
              scheme = "HTTP"
            }

            initial_delay_seconds = 30
            timeout_seconds       = 30
          }

          name = "dashboard-metrics-scraper"

          port {
            container_port = 8000
            protocol       = "TCP"
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_user                = 1001
            run_as_group               = 2001
          }

          volume_mount {
            mount_path = "/tmp"
            name       = "tmp-volume"
          }
        }

        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }

        service_account_name = kubernetes_service.dashboard.metadata[0].name

        toleration {
          effect = "NoSchedule"
          key    = "node-role.kubernetes.io/master"
        }

        volume {
          empty_dir {}

          name = "tmp-volume"
        }
      }
    }
  }
}

resource kubernetes_service_account eks_admin {
  metadata {
    name      = "eks-admin"
    namespace = "kube-system"
  }
}

resource kubernetes_cluster_role_binding eks_admin {
  metadata {
    name = "eks-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.eks_admin.metadata[0].name
    namespace = kubernetes_service_account.eks_admin.metadata[0].namespace
  }
}
