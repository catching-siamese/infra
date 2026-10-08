variable "environment" {
  type        = string
  description = "Target deployment environment (e.g., 'dev', 'staging', 'prod')"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "argocd_version" {
  type        = string
  description = "ArgoCD helm chart version"
  default     = "10.9.2"

  validation {
    condition = can(regex("^\\d+.\\d+.\\d+", var.argocd_version))
    error_message = "Version number must be in a format of X.X.X. eg. 10.9.2"
  }
}

variable "url" {
  type = string
  description = "ArgoCD url name"
  validation {
    condition = can(regex("^[A-Za-z0-9-.]+$", var.url))
    error_message = "Url can only contains A-Za-z0-9.-"
  }
}