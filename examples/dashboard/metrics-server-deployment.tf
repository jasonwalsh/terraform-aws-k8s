resource kubernetes_service_account metrics_server {
  metadata {
    name      = "metrics-server"
    namespace = "kube-system"
  }
}

resource kubernetes_deployment metrics_server {
  metadata {
    labels = {
      k8s-app = "metrics-server"
    }

    name      = "metrics-server"
    namespace = "kube-system"
  }

  spec {
    selector {
      match_labels = {
        k8s-app = "metrics-server"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = "metrics-server"
        }

        name = "metrics-server"
      }

      spec {
        automount_service_account_token = true

        container {
          image             = "k8s.gcr.io/metrics-server-amd64:v0.3.6"
          image_pull_policy = "Always"
          name              = "metrics-server"

          volume_mount {
            mount_path = "/tmp"
            name       = "tmp-dir"
          }
        }

        service_account_name = kubernetes_service_account.metrics_server.metadata[0].name

        volume {
          empty_dir {}
          name = "tmp-dir"
        }
      }
    }
  }
}
