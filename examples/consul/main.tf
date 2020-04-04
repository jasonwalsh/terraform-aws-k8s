data helm_repository stable {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource helm_release consul {
  chart      = "consul"
  name       = "consul"
  repository = data.helm_repository.stable.metadata[0].name

  set {
    name  = "uiService.type"
    value = "LoadBalancer"
  }

  version = "3.9.5"
}
