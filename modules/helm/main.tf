
resource "kubernetes_namespace" "datadog" {
  metadata {
    name = "datadog"
  }
}

resource "kubernetes_secret" "datadog" {
  metadata {
    name      = "datadog-secret"
    namespace = kubernetes_namespace.datadog.metadata[0].name
  }

  data = {
    "api-key" = var.datadog_api_key
  }

  type = "Opaque"
}

resource "helm_release" "datadog" {
  name             = "datadog"
  repository       = "https://helm.datadoghq.com"
  chart            = "datadog"
  version          = "3.0.0"
  namespace        = kubernetes_namespace.datadog.metadata[0].name
  create_namespace = false
  wait             = false

  set = [
    {
      name  = "datadog.apiKeyExistingSecret"
      value = kubernetes_secret.datadog.metadata[0].name
    },
    {
      name  = "datadog.site"
      value = "us5.datadoghq.com"
    }
  ]

  depends_on = [
    kubernetes_secret.datadog
  ]
}
