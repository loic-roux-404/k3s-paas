resource "helm_release" "dex" {
  repository = data.helm_repository.dexidp.metadata.0.name
  name       = "dex"
  namespace  = "kube-system"
  chart      = "dex"
  
  values = [
    templatefile("${path.module}/values.yaml.tpl", { dex_hostname = var.dex_hostname, dex_github_client_id = var.dex_github_client_id, dex_github_client_secret = var.dex_github_client_secret, dex_github_orgs = jsonencode(var.dex_github_orgs), dex_client_id = var.dex_client_id, waypoint_hostname = var.waypoint_hostname, dex_client_secret = var.dex_client_secret, waypoint_k8s_ingress_class = var.waypoint_k8s_ingress_class })
  ]
}