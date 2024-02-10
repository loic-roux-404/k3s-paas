resource "kubernetes_namespace" "metallb_system" {
   metadata {
      name = "metallb-system"
      labels = {
         app = "metallb"
      }
   }
}

resource "kubernetes_manifest" "metallb_ip_address_pool" {
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
   manifest = {
      apiVersion = "metallb.io/v1beta1"
      kind = "L2Advertisement"
      metadata = {
          name = "kind-l2"
          namespace = "${kubernetes_namespace.metallb_system.id}"
      }
   }
}

resource "kubernetes_manifest" "speaker_daemonset" {  
  # Assuming that the spect for speaker_daemonset is available in
  # the file 'speaker_daemonset.yaml'
  manifest = {
    apiVersion = "apps/v1"
    kind = "DaemonSet"
    namespace = "${kubernetes_namespace.metallb_system.id}"
    metadata = {
      name = "speaker"
    }
  }

  wait {
    fields = {
      "status.numberAvailable" = 3 # Change this to the appropriate value
    }
  }
}
