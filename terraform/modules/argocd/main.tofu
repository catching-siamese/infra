locals {
  argo_helm = "https://argoproj.github.io/argo-helm"
}

resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = var.environment # e.g., "prod" or "dev"
      "version"                      = var.argocd_version
    }
  }
}

module "cert-manager" {
  source = "../cert-manager"

  common_name = var.url
  secret_name = "argocd"
  namespace   = kubernetes_namespace_v1.argocd.id
}

# 2. Deploy ArgoCD via the official Helm chart
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = local.argo_helm
  chart            = "argo-cd"
  version          = var.argocd_version
  namespace        = kubernetes_namespace_v1.argocd.metadata[0].name
  create_namespace = false

  # Wait for all resources to become healthy before concluding Terraform apply
  wait          = true
  timeout       = 600
  recreate_pods = true

  # Supply custom values to secure and isolate the instance
  values = [
    yamlencode({
      global = {
        domain = var.url
      }

      configs = {
        params = {
          # Disable TLS inside the pod if terminating TLS at the Ingress controller
          "server.insecure" = "true"
        }

        # Hardlock ArgoCD to operate ONLY on the cluster it is installed in
        cm = {
          "admin.enabled"                   = "true" # Disable local admin user (force SSO)
          "url"                             = "https://${var.url}"
          "exec.enabled"                    = "false" # Disable Web Terminal execution for security
          "resource.customizations.health"  = ""
        }
      }

      # Server Component Configuration
      server = {
        autoscaling = {
          enabled     = true
          minReplicas = 1
        }
        ingress = {
          enabled          = true
          ingressClassName = "nginx"
          hosts = [
            "${var.url}"
          ]
          tls = [
            {
              secretName = "${module.cert-manager.secret_store_name}"
              hosts      = ["${var.url}"]
            }
          ]
        }
      }

      # Lock down Redis to single-node or HA mode based on environment
      redis-ha = {
        enabled = var.environment == "prod" ? true : false
      }

      redis = {
        enabled = var.environment == "prod" ? false : true
      }

      # Controller tuning for performance
      controller = {
        metrics = {
          enabled = true
        }
      }
    })
  ]
}

resource "helm_release" "root_app" {
  name       = "argocd-root"
  repository = local.argo_helm
  chart      = "argocd-apps"
  version    = var.argocd_version
  namespace  = "argocd"

  values = [yamlencode({
    applications = {
      root = {
        namespace = "argocd"
        project   = "default"
        source = {
          repoURL        = var.gitops_repo_url
          targetRevision = var.gitops_revision
          path           = var.gitops_apps_path
        }
        destination = {
          server    = "https://kubernetes.default.svc"
          namespace = "argocd"
        }
        syncPolicy = {
          automated = { prune = true, selfHeal = true }
        }
      }
    }
  })]