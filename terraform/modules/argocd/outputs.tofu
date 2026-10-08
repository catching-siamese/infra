output "argocd_namespace" {
  description = "The namespace where ArgoCD was installed"
  value       = kubernetes_namespace_v1.argocd.metadata[0].name
}

output "argocd_helm_version" {
  description = "Installed Helm chart version"
  value       = helm_release.argocd.version
}