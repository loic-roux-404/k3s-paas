locals {
  cert_manager_acme_url = var.letsencrypt_envs[var.cert_manager_letsencrypt_env]
  cert_manager_acme_ca_url = var.letsencrypt_envs_ca_certs[var.cert_manager_letsencrypt_env]
  ingress_hosts_internals = [local.dex_hostname, var.waypoint_hostname]
  dex_hostname = "dex.${var.waypoint_base_domain}"
  waypoint_hostname = "waypoint.${var.waypoint_base_domain}"
  api_waypoint_hostname = "api.${local.waypoint_hostname}"
}

module "qemu_instance" {
  source = "./qemu-nixos-vm"
  qemu_working_dir = "${path.module}/.."
}

module "pebble" {
  source = "./mocks/pebble"
}

data "http" "waypoint_internal_acme_ca" {
  url = local.cert_manager_acme_ca_url
  count = local.cert_manager_acme_ca_url != null ? 1 : 0
  insecure = var.cert_manager_letsencrypt_env == "local"
  depends_on = [ module.pebble ]
  retry {
    attempts = 4
    min_delay_ms = 2000
  }
}

module "metallb" {
  source = "./k8s/metallb"
  metallb_ip_range = var.metallb_ip_range
}

module "nginx_ingress" {
  source = "./k8s/nginx-ingress"
  count = var.waypoint_k8s_ingress_class == "nginx" ? 1 : 0
  waypoint_internal_acme_host = "acme-internal.${var.waypoint_base_domain}"
  waypoint_internal_acme_network_ip = module.qemu_instance.host_ip
  ingress_hosts_internals = local.ingress_hosts_internals
}

module "cert_manager" {
  source = "./k8s/cert-manager"
  waypoint_internal_acme_network_ip = module.qemu_instance.ip
  waypoint_internal_acme_ca_content = length(data.http.waypoint_internal_acme_ca) > 0 ? data.http.waypoint_internal_acme_ca[0].body : null
  cert_manager_acme_url = local.cert_manager_acme_ca_url
}


