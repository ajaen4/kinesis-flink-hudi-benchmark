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
  filename = "${path.cwd}/eks/helm/locust/values.yaml"
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

  set {
    name  = "worker.serviceAccountAnnotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_assumable_role_locust.iam_role_arn
  }

  set {
    name  = "master.resources.requests.cpu"
    value = "200m"
  }

  set {
    name  = "master.resources.limits.cpu"
    value = "500m"
  }

  set {
    name  = "worker.resources.requests.cpu"
    value = "200m"
  }

  set {
    name  = "worker.resources.limits.cpu"
    value = "500m"
  }

}

data "kubernetes_service" "locust_service" {
  depends_on = [helm_release.locust]
  metadata {
    name      = "locust"
    namespace = kubernetes_namespace.locust.metadata.0.name
  }
}

module "iam_assumable_role_locust" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.7.0"
  create_role                   = true
  role_name                     = "locust-controller-${local.name}"
  provider_url                  = module.eks.cluster_oidc_issuer_url
  oidc_fully_qualified_subjects = ["system:serviceaccount:${kubernetes_namespace.locust.metadata.0.name}:locust-worker"]
}

resource "aws_iam_role_policy" "locust_controller" {
  name = "locust-policy-${local.name}"
  role = module.iam_assumable_role_locust.iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["kinesis:*"]
        Effect = "Allow"
        Resource = [
          "*"
        ]
      },
      {
        Action = [
          "logs:*",
          "cloudwatch:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
