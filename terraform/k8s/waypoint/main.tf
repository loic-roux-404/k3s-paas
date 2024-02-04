# Import values from the template file
data "template_file" "values" {
    template = file("${path.module}/values.yaml.tmpl")
    vars = {
        waypoint_hostname = var.waypoint_hostname
        waypoint_namespace = var.waypoint_namespace
        waypoint_k8s_ingress_class = var.waypoint_k8s_ingress_class
    }
}

# Create a Certificate
resource "kubernetes_manifest" "cert" {
    provider = kubernetes
    manifest = {
        apiVersion = "cert-manager.io/v1"
        kind = "Certificate"
        metadata = {
            name = "${var.waypoint_hostname}-tls"
            namespace = var.waypoint_namespace
        }
        spec = {
            dnsNames = [
                var.waypoint_hostname
            ]
            issuerRef = {
                kind = "ClusterIssuer"
                name = "letsencrypt-acme-issuer"
            }
            secretName = "${var.waypoint_hostname}-tls"
        }
    }
}

# Install the Helm chart
resource "helm_release" "waypoint" {
    name = "waypoint"
    repository = "https://helm.releases.hashicorp.com"
    chart = "waypoint"
    version = "0.1.18"
    namespace = "kube-system"
    values = [data.template_file.values.rendered]
    set {
        name = "targetNamespace"
        value = var.waypoint_namespace
    }
}