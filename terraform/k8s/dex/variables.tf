variable "dex_namespace" {
  default = "dex"
}

variable "dex_hostname" {
  description = "Hostname for DEX"
  type        = string
}

variable "dex_github_client_id" {
  description = "GitHub client ID for DEX"
  type        = string
}

variable "dex_github_client_secret" {
  description = "GitHub client secret for DEX"
  type        = string
}

variable "dex_github_orgs" {
  description = "Github Orgs for Dex OIDC Connector"
  type        = list(object({
    name = string
    teams    = list(string)
  }))
  default     = []
}

variable "dex_client_id" {
  description = "Client ID for DEX"
  type        = string
}

variable "waypoint_hostname" {
  description = "Hostname for Waypoint"
  type        = string
}

variable "dex_client_secret" {
  description = "Client secret for DEX"
  type        = string
}

variable "waypoint_k8s_ingress_class" {
  description = "Kubernetes Ingress class for Waypoint"
  type        = string
  default = "nginx-ingress-controller"
}
