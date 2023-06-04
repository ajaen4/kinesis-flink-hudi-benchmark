resource "kubernetes_namespace" "locust" {
  metadata {
    name = "locust"
  }
}

resource "kubernetes_config_map" "eks_loadtest_locustfile" {
  metadata {
    name      = "eks-loadtest-locustfile"
    namespace = kubernetes_namespace.locust.metadata.0.name
  }

  data = {
    "locustfile.py" = file("${path.cwd}/../event_generation/locustfile.py")
    "config.py"     = file("${path.cwd}/../event_generation/config.py")
    "tickers.py"    = file("${path.cwd}/../event_generation/tickers.py")
    ".env"          = file("${path.cwd}/../event_generation/.env")
  }
}

data "local_file" "locust_values" {
  filename = "${path.cwd}/eks/templates/locust.yaml"
}

resource "helm_release" "locust" {
  namespace        = kubernetes_namespace.locust.metadata.0.name
  create_namespace = false
  name             = "locust"
  repository       = "https://charts.deliveryhero.io/"
  chart            = "locust"
  timeout          = 120

  values = [data.local_file.locust_values.content]

  set {
    name  = "loadtest.locust_locustfile_configmap"
    value = kubernetes_config_map.eks_loadtest_locustfile.metadata.0.name
  }

}

data "kubernetes_service" "locust_service" {
  metadata {
    name      = "locust"
    namespace = "locust"
  }
}
