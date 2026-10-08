output "secret_store_name" {
  description = "Self signed certificate secret store name"
  value       = kubernetes_secret_v1.tls_secret.metadata[0].name
}