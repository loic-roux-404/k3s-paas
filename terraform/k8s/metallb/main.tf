resource "kubernetes_namespace" "metallb_system" {
   metadata {
      name = "metallb-system"
      labels = {
         app = "metallb"
      }
   }
}

provider "kubernetes-alpha" {
  config_path = "/etc/rancher/k3s/k3s.yaml"
}

resource "kubernetes_manifest" "metallb_ip_address_pool" {
   provider = kubernetes-alpha

   manifest = {
      apiVersion = "metallb.io/v1beta1"
      kind = "IPAddressPool"
      metadata = {
         name = "kind-pool"
         namespace = "${kubernetes_namespace.metallb_system.id}"
      }
      spec = {
         addresses = [var.metallb_ip_range]
      }
   }
}

resource "kubernetes_manifest" "metallb_l2_advertisement" {
   provider = kubernetes-alpha

   manifest = {
      apiVersion = "metallb.io/v1beta1"
      kind = "L2Advertisement"
      metadata = {
          name = "kind-l2"
          namespace = "${kubernetes_namespace.metallb_system.id}"
      }
   }
}

# resource "kubernetes_manifest" "speaker_daemonset" {
#   provider = kubernetes-alpha
  
#   # Assuming that the spect for speaker_daemonset is available in
#   # the file 'speaker_daemonset.yaml'
#   manifest = yamldecode(file("${path.module}/speaker_daemonset.yaml"))

#   wait_for = {
#     fields = {
#       "status.numberAvailable" = 3 # Change this to the appropriate value
#     }
#   }
# }