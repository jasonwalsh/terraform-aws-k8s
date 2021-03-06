resource kubernetes_service metrics_server {
  metadata {
    labels = {
      "kubernetes.io/cluster-service" = true
      "kubernetes.io/name"            = "Metrics-server"
    }

    name      = "metrics-server"
    namespace = "kube-system"
  }

  spec {
    port {
      port        = 443
      protocol    = "TCP"
      target_port = 443
    }

    selector = {
      k8s-app = "metrics-server"
    }
  }
}
