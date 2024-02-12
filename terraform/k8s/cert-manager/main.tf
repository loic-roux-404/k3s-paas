resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = var.cert_manager_namespace
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = kubernetes_namespace.cert-manager.metadata[0].name

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubernetes_manifest" "issuer" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = { 
      "name" = "letsencrypt-acme-issuer" 
    }
    "spec" = {
      "acme" = {
        "skipTLSVerify" = var.waypoint_internal_acme_network_ip != null
        "email"         = var.cert_manager_email
        "server"        = var.cert_manager_acme_url
        "privateKeySecretRef" = {
          "name" = "acme-account-key"
        }
        "solvers" = [
          {
            "selector" = {}
            "http01" = {
              "ingress" = { 
                "class" = var.waypoint_k8s_ingress_class
              }
            }
          }
        ]
      }
    }
  }
}

resource "helm_release" "reflector" {
  name       = "reflector"
  namespace  = "kube-system"
  repository = "https://emberstack.github.io/helm-charts"
  chart      = "reflector"
  version    = "7.0.151"

  set {
    name  = "targetNamespace"
    value = var.cert_manager_namespace
  }

}

resource "kubernetes_config_map" "acme_internal_root_ca" {
  metadata {
    name        = "acme-internal-root-ca"
    namespace   = "kube-system"
    annotations = {
      "reflector.v1.k8s.emberstack.com/reflection-allowed"     = "true"
      "reflector.v1.k8s.emberstack.com/reflection-auto-enabled" = "true"
    }
  }

  data = {
    "ca.crt" = indent(4, var.waypoint_internal_acme_ca_content)
  }
}


output "cert_manager_metadata_name" {
  value = helm_release.cert_manager.metadata
}

output "reflector_metadata_name" {
  value = helm_release.reflector.metadata
}
