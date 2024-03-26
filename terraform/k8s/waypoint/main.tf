resource "kubernetes_namespace" "waypoint_namespace" {
  metadata {
    name = var.waypoint_namespace
  }
}

locals {
  waypoint_manifest_values = templatefile("${path.module}/values.yaml.tmpl", {
    waypoint_namespace         = kubernetes_namespace.waypoint_namespace.metadata[0].name,
    waypoint_hostname          = var.waypoint_hostname,
    waypoint_k8s_ingress_class = var.waypoint_k8s_ingress_class
  })
}

# Create a Certificate
resource "kubernetes_manifest" "cert" {
  provider = kubernetes
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "${var.waypoint_hostname}-tls"
      namespace = var.waypoint_namespace
    }
    spec = {
      dnsNames = [
        var.waypoint_hostname
      ]
      issuerRef = {
        kind = "ClusterIssuer"
        name = "letsencrypt-acme-issuer"
      }
      secretName = "${var.waypoint_hostname}-tls"
    }
  }
}

# Install the Helm chart
resource "helm_release" "waypoint" {
  name       = "waypoint"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "waypoint"
  version    = "0.1.18"
  namespace  = "kube-system"
  values     = [local.waypoint_manifest_values]
  set {
    name  = "targetNamespace"
    value = var.waypoint_namespace
  }
}
