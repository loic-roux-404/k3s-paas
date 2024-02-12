terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.25.2"
    }
    # contabo = {
    #   source = "contabo/contabo"
    #   version = ">= 0.1.23"
    # }
  }
}

provider "kubernetes" {
  host =  "https://${var.vm_ip}:6443"
  client_certificate     = file("${var.k3s_client_location}/client-ca.pem")
  client_key             = file("${var.k3s_client_location}/client-ca.key")
  cluster_ca_certificate = file("${var.k3s_client_location}/server-ca.crt")
}

provider "helm" {}
