data helm_repository lifen {
  name = "lifen"
  url  = "https://honestica.github.io/lifen-charts"
}

resource kubernetes_namespace ansible {
  metadata {

    name = "ansible"
  }
}

resource helm_release awx {
  chart      = "lifen/awx"
  name       = "awx"
  namespace  = kubernetes_namespace.ansible.metadata[0].name
  repository = data.helm_repository.lifen.metadata[0].name
  version    = "1.1.0"
}
