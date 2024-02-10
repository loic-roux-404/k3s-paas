resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = var.dex_namespace
  }
}

resource "helm_release" "dex" {
  repository = "https://charts.dexidp.io"
  name       = "dex"
  namespace  = kubernetes_namespace.cert-manager.metadata[0].name
  chart      = "dex"

  values = [
    templatefile("${path.module}/values.yaml.tmpl", {
      dex_hostname = var.dex_hostname, 
      dex_github_client_id = var.dex_github_client_id, 
      dex_github_client_secret = var.dex_github_client_secret, 
      dex_github_orgs = jsonencode(var.dex_github_orgs), 
      dex_client_id = var.dex_client_id,
      waypoint_hostname = var.waypoint_hostname,
      dex_client_secret = var.dex_client_secret,
      waypoint_k8s_ingress_class = var.waypoint_k8s_ingress_class 
    })
  ]
}
