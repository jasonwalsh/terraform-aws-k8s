locals {
  extension = "tar.gz"

  flags = [
    "--directory",
    local.output,
    "--strip-components",
    "1"
  ]

  output      = "/tmp/metrics-server"
  tarball_url = jsondecode(data.http.release.body)["tarball_url"]
}

data http release {
  url = "https://api.github.com/repos/kubernetes-sigs/metrics-server/releases/latest"
}

data http dashboard {
  url = "https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml"
}

resource local_file dashboard {
  content  = data.http.dashboard.body
  filename = "/tmp/recommended.yaml"
}

resource null_resource metrics {
  triggers = {
    uuid = uuid()
  }

  provisioner local-exec {
    command = format("curl -Ls %s -o %s.%s", local.tarball_url, local.output, local.extension)
  }

  provisioner local-exec {
    command    = format("mkdir %s", local.output)
    on_failure = continue
  }

  provisioner local-exec {
    command = format("tar xzf %s.%s %s", local.output, local.extension, join(" ", local.flags))
  }

  provisioner local-exec {
    command = format("kubectl apply -f %s/deploy/1.8+/", local.output)
  }

  provisioner local-exec {
    command = format("kubectl apply -f %s", local_file.dashboard.filename)
  }

  provisioner local-exec {
    command = "kubectl apply -f files/eks-admin-service-account.yaml"
  }
}
