resource "helm_release" "nginx_ingress" {
  repository =  "https://charts.bitnami.com/bitnami"
  name       = "ingress-nginx"
  namespace  = "kube-system"
  chart      = "bitnami/nginx-ingress-controller"
  version    = "9.5.1"

  set {
    name  = "fullnameOverride"
    value = "nginx-ingress-controller"
  }

  set {
    name  = "extraArgs.v"
    value = "3"
  }

  set {
    name  = "kind"
    value = "DaemonSet"
  }

  set {
    name  = "useHostPort"
    value = "true"
  }

  set {
    name  = "defaultBackend.service.ports.http"
    value = "8080"
  }
}

data "kubernetes_service" "ingress_service" {
  metadata {
    name      = var.ingress_expected_svc
    namespace = "kube-system"
  }
  depends_on = [
    helm_release.nginx_ingress,
  ]
}

locals {
  ingress_resources_length = length(data.kubernetes_service.ingress_service)
}

output "ingress_resources_length" {
  value = local.ingress_resources_length
}

locals {
  waypoint_ingress_controller_ip = data.kubernetes_service.ingress_service.spec.0.cluster_ip
  ingress_hosts_internals_joined = join(" ", var.ingress_hosts_internals)
}

output "waypoint_ingress_controller_ip" {
  value = local.waypoint_ingress_controller_ip
}

resource "kubernetes_config_map" "coredns-custom" {
  count = var.waypoint_internal_acme_network_ip != null ? 1 : 0
  metadata {
    name      = "coredns-custom"
    namespace = "kube-system"
  }

  data = {
    "ingress-hosts.server" = <<EOF
    ${local.ingress_hosts_internals_joined} {
      hosts {
        ${local.waypoint_ingress_controller_ip} ${local.ingress_hosts_internals_joined}
        fallthrough
      }
      whoami
    }
    EOF

    "acme-internal.server" = <<EOF
    ${var.waypoint_internal_acme_host} {
      hosts {
        ${var.waypoint_internal_acme_network_ip} ${var.waypoint_internal_acme_host}
        fallthrough
      }
      whoami
    }
    EOF
  }
}