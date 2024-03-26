k3s_disable_services = ["traefik", "servicelb"]
#metallb_ip_range = "172.29.0.20-172.29.0.50"

dex_github_orgs = [
  {
    name = "esgi-immo-scanner"
    teams = ["ops-team"]
  }
]

cert_manager_letsencrypt_env = "local"

dex_github_client_id     = "4257d291e956ada11306"
dex_github_client_secret = "ad4613aae3803b72fcd919a5e0f4a0acbb10686c"
cert_manager_email       = "loic.roux.404@gmail.com"
