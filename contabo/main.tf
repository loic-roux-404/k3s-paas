############
# Accounts
############
resource "github_team" "opsteam" {
  name        = var.github_team
  description = "This is the production team"
  privacy     = "closed"
}

resource "github_team_membership" "opsteam_members" {
  for_each = data.github_membership.all_admin
  team_id  = github_team.opsteam.id
  username = each.value.username
  role     = "maintainer"
}

############
# Security
############

# Dex oidc client
resource "random_password" "dex_client_id" {
  length  = 16
  special = false
}

resource "random_password" "dex_client_secret" {
  length  = 24
  special = false
}

locals {
  ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key)))
  final_ansible_secrets = merge(
    var.ansible_secrets,
    {
      dex_client_id = random_password.dex_client_id.result
      dex_client_secret = random_password.dex_client_secret.result
    }
  )
}

resource "contabo_secret" "paas_instance_ssh_key" {
  name  = "paas_instance_ssh_key"
  type  = "ssh"
  value = local.ssh_public_key
}

resource "contabo_secret" "paas_instance_password" {
  name  = "paas_instance_password"
  type  = "password"
  value = var.ssh_password
}

############
# Vm
############

locals {
  iso_version_file = "ubuntu-${var.ubuntu_release_info.name}-${var.ubuntu_release_info.version}.${var.ubuntu_release_info.format}"
}

resource "contabo_image" "paas_instance" {
  name        = var.ubuntu_release_info.name
  image_url   = "${var.ubuntu_release_info.url}/${var.ubuntu_release_info.iso_version_tag}/${local.iso_version_file}"
  os_type     = "Linux"
  version     = var.ubuntu_release_info.iso_version_tag
  description = "generated PaaS vm image with packer"
}

resource "namedotcom_record" "dns_zone" {
  for_each    = toset(["", "*"])
  domain_name = var.domain
  host        = each.key
  record_type = "A"
  answer      = data.contabo_instance.paas_instance.ip_config[0].v4[0].ip
}

locals {
  ansible_vars = merge(
    local.final_ansible_secrets,
    {
      dex_hostname                 = "dex.${var.domain}"
      waypoint_hostname            = "waypoint.${var.domain}"
      dex_github_client_org        = data.github_organization.org.orgname
      dex_github_client_team       = github_team.opsteam.name
      cert_manager_letsencrypt_env = var.cert_manager_letsencrypt_env
    }
  )
}

resource "contabo_instance" "paas_instance" {
  display_name  = "ubuntu-k3s-paas"
  image_id = contabo_image.paas_instance.id
  ssh_keys = [contabo_secret.paas_instance_ssh_key.id]
  user_data = jsonencode(templatefile(
    "${path.root}/user-data.yaml.tmpl",
    {
      iso_version_tag = var.ubuntu_release_info.iso_version_tag
      ssh_username = var.ssh_username
      ssh_password = var.ssh_password
      ssh_password_hash = var.ssh_password_hash
      ssh_public_key = local.ssh_public_key
      ansible_vars = [
        for k, v in local.ansible_vars : "${k}=${v}"
      ]
    }
  ))
  depends_on = [
    namedotcom_record.dns_zone,
    github_team_membership.opsteam_members,
  ]
}
