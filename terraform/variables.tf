variable "platform" {
  description = "The platform to deploy the infrastructure"
  default     = "libvirt"
}

variable "waypoint_base_domain" {
  default = "k3s.test"
}

variable "k3s_disable_services" {
  type = list(string)
  default = ["traefik"]
}

variable "cert_manager_letsencrypt_env" {
  default = "prod"
}

variable "cert_manager_namespace" {
  default = "cert-manager"
}

variable "cert_manager_email" {
  default = "toto@k3s.local"
}

variable "cert_manager_private_key_secret" {
  default = "test_secret"
}

variable "cert_manager_is_internal" {
  default = false
}

variable "dex_namespace" {
  default = "dex"
}

variable "dex_client_id" {
  default = "waypoint"
}

variable "dex_client_secret" {
  default = "ZXhhbXBsZS1hcHAtc2VjcmV0"
}

variable "dex_github_client_id" {}

variable "dex_github_client_secret" {}

variable "dex_github_orgs" {
  description = "Github Orgs for Dex OIDC Connector"
  type        = list(object({
    name = string
    teams    = list(string)
  }))
  default     = []
}

variable "waypoint_namespace" {
  default = "default"
}

variable "waypoint_hostname" {
  default = "waypoint.k3s.test"
}

variable "api_waypoint_hostname" {
  default = "api.k3s.test"
}

variable "waypoint_k8s_ingress_class" {
  default = "nginx"
}

variable "letsencrypt_envs" {
  description = "Letsencrypt Envs"
  type        = object({
    local  = string
    staging = string
    prod    = string
  })
  default = {
    local = "https://localhost:14000/dir"
    staging =  "https://acme-v02.api.letsencrypt.org/directory"
    prod    = "https://acme-staging-v02.api.letsencrypt.org/directory"
  }
}

variable "letsencrypt_envs_ca_certs" {
  description = "Letsencrypt Envs CA Certs"
  type        = object({
    local  = string
    staging = string
    prod    = string
  })
  default = {
    local = "https://localhost:15000/roots/0"
    staging = "https://letsencrypt.org/certs/staging/letsencrypt-stg-root-x1.pem"
    prod = null
  }
}

variable "waypoint_internal_acme_ca_file" {
  default = "/etc/ssl/certs/acmeca.crt"
}

variable "metallb_ip_range" {
  type = string
  description = "value of the ip range"
  default = null
}

variable "metallb_manifests" {
  description = "Metallb Manifests"
  type        = list(object({
    url_manifest = object({
      url      = string
      filename = string
    })
    deploy = optional(string)
    ns     = optional(string)
  }))
  default = [
    {
      url_manifest = {
        url      = "https://raw.githubusercontent.com/metallb/metallb/v0.13.5/config/manifests/metallb-native.yaml"
        filename = "metallb-native.yaml"
      }
      deploy = "controller"
      ns     = "metallb-system"
    },
    {
      url_manifest = {
        url      = "https://raw.githubusercontent.com/metallb/metallb/v0.13.5/config/manifests/metallb-frr.yaml"
        filename = "metallb-frr.yaml"
      }
    }
  ]
}

variable "ingress_expected_svc" {
  type = string
  default = "nginx-ingress-controller"
}
