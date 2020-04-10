resource kubernetes_cluster_role_binding auth_delegator {
  metadata {
    name = "metrics-server:system:auth-delegator"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.metrics_server.metadata[0].name
    namespace = kubernetes_service_account.metrics_server.metadata[0].namespace
  }
}
