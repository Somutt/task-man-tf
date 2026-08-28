resource "kubernetes_namespace" "monitoring" {
  depends_on = [null_resource.k3d_cluster]
  metadata {
    name = "monitoring"
  }
}

# Loki e Promtail
resource "helm_release" "loki" {
  depends_on = [kubernetes_namespace.monitoring]
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  namespace  = "monitoring"

  set {
    name  = "promtail.enabled"
    value = "true" # Garante que os logs de todos os pods sejam capturados automaticamente
  }
}

# Prometheus e Grafana
resource "helm_release" "prometheus" {
  depends_on = [helm_release.loki]
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"

  timeout = 900 

  values = [
    <<EOF
grafana:
  additionalDataSources:
    - name: Loki
      type: loki
      url: http://loki:3100
      access: proxy
  sidecar:
    dashboards:
      enabled: false
alertmanager:
  enabled: false
EOF
  ]
}