locals {
  env          = get_env("ENV_NAME", "prod")
  dependencies = read_terragrunt_config(find_in_parent_folders("dependencies.hcl"))
  secret_vars  = yamldecode(sops_decrypt_file(find_in_parent_folders("secrets/${local.env}.yaml")))
  input_vars = {
    paas_base_domain             = local.secret_vars.paas_base_domain
    cert_manager_letsencrypt_env = local.env
    cert_manager_email           = local.secret_vars.cert_manager_email
    github_token                 = local.secret_vars.github_token
    github_client_id             = local.secret_vars.github_client_id
    github_client_secret         = local.secret_vars.github_client_secret
    k3s_config                   = local.dependencies.dependency.network.outputs.k3s_config
    k3s_endpoint                 = local.dependencies.dependency.network.outputs.k3s_endpoint
  }
}