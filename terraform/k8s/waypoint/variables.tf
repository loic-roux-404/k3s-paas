variable "waypoint_namespace" {
  description = "value of the waypoint namespace"
  default = "default"
}

variable "waypoint_hostname" {
  description = "value of the waypoint hostname"
}

variable "waypoint_k8s_ingress_class" {
  description = "value of the k8s ingress class"
  default = "nginx-ingress-controller"
}
