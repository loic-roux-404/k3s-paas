variable "ingress_hosts_internals" {
  description = "Ingress Hosts Internals"
  type        = list(string)
}

# variable "waypoint_internal_acme_network_ip" {
#   description = "Waypoint Internal ACME Network IP"
# }

variable "waypoint_internal_acme_host" {
  description = "Waypoint Internal ACME Host"
}

variable "ingress_expected_svc" {
  description = "value of the ingress service name"
}