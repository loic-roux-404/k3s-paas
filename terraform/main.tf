locals {
  cert_manager_acme_url = var.letsencrypt_envs[var.cert_manager_letsencrypt_env]
  cert_manager_acme_ca_url = var.letsencrypt_envs_ca_certs[var.cert_manager_letsencrypt_env]
  ingress_hosts_internals = [local.dex_hostname, var.waypoint_hostname]
  dex_hostname = "dex.${var.waypoint_base_domain}"
  waypoint_hostname = "waypoint.${var.waypoint_base_domain}"
  api_waypoint_hostname = "api.${local.waypoint_hostname}"
}

module "pebble" {
  source = "./pebble"
  enable = local.cert_manager_acme_ca_url != null
}

data "http" "waypoint_internal_acme_ca" {
  depends_on = [ module.pebble ]
  url = local.cert_manager_acme_ca_url
  count = local.cert_manager_acme_ca_url != null ? 1 : 0
  insecure = var.cert_manager_letsencrypt_env == "local"
  retry {
    attempts = 4
    min_delay_ms = 2000
  }
}

module "metallb" {
  source = "./k8s/metallb"
  metallb_ip_range = var.metallb_ip_range
  for_each = var.metallb_ip_range != null ? toset(["metallb"]) : toset([])
}

module "nginx_ingress" {
  depends_on = [module.metallb[0]]
  source = "./k8s/nginx-ingress"
  count = var.waypoint_k8s_ingress_class == "nginx" ? 1 : 0
  waypoint_internal_acme_host = "acme-internal.${var.waypoint_base_domain}"
  waypoint_internal_acme_network_ip = var.vm_ip
  ingress_hosts_internals = local.ingress_hosts_internals
}

module "cert_manager" {
  depends_on = [module.nginx_ingress]
  source = "./k8s/cert-manager"
  waypoint_internal_acme_network_ip = var.vm_ip
  waypoint_internal_acme_ca_content = length(data.http.waypoint_internal_acme_ca) > 0 ? data.http.waypoint_internal_acme_ca[0].response_body : null
  cert_manager_acme_url = local.cert_manager_acme_ca_url
}

module "dex" {
  depends_on = [
    module.cert_manager.cert_manager_metadata_name,
    module.cert_manager.reflector_metadata_name
  ]
  source = "./k8s/dex"
  dex_namespace = var.dex_namespace
  dex_hostname = local.dex_hostname
  dex_client_id = var.dex_client_id
  dex_client_secret = var.dex_client_secret
  dex_github_client_id = var.dex_github_client_id
  dex_github_client_secret = var.dex_github_client_secret
  dex_github_orgs = var.dex_github_orgs
  waypoint_k8s_ingress_class = var.waypoint_k8s_ingress_class
  waypoint_hostname = local.waypoint_hostname
}

module "waypoint" {
  depends_on = [module.dex]
  source = "./k8s/waypoint"
  waypoint_namespace = var.waypoint_namespace
  waypoint_hostname = local.waypoint_hostname
  waypoint_k8s_ingress_class = var.waypoint_k8s_ingress_class
}
