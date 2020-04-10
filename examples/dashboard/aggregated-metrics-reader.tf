resource kubernetes_cluster_role aggregated_metrics_reader {
  metadata {
    labels = {
      "rbac.authorization.k8s.io/aggregate-to-admin" = true
      "rbac.authorization.k8s.io/aggregate-to-edit"  = true
      "rbac.authorization.k8s.io/aggregate-to-view"  = true
    }

    name = "system:aggregated-metrics-reader"
  }

  rule {
    api_groups = ["metrics.k8s.io"]
    resources  = ["nodes", "pods"]
    verbs      = ["get", "list", "watch"]
  }
}
