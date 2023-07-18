data "local_file" "metrics_server_values" {
  filename = "${path.cwd}/eks/helm/metrics_server/values.yaml"
}

resource "helm_release" "metrics-server" {
  create_namespace = false
  namespace        = "kube-system"
  name             = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  timeout          = 120
  version          = "v3.10.0"

  values = [data.local_file.metrics_server_values.content]

}
