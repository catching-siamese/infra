locals {
  cert_common_name = "dev.local"
  environment = "dev"
  cert_secret_name = "argocd_dev"
  argocd_version = "10.9.2"
  url = "argocd.dev.local"
}

module "argocd" {
  source = "../../modules/argocd"

  # domain = local.environment
  environment = local.environment
  argocd_version = local.argocd_version
  url = local.url
}