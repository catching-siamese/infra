variable "environment" {
    type        = string
    description = "Target deployment environment (e.g., 'dev', 'staging', 'prod')"
    default     = "prod"

    validation {
        condition     = contains(["dev", "staging", "prod"], var.environment)
        error_message = "Environment must be one of: dev, staging, prod."
    }
}

variable "common_name" {
    type        = string
    description = "Certificate common name"

    validation {
        condition = can(regex("\\w+.\\w+$", var.common_name))
        error_message = "Invalid domain name."
    }
}

variable "secret_name" {
    type        = string
    description = "Secret store name"

    validation {
        condition = can(regex("^[a-zA-Z0-9_]+$", var.secret_name))
        error_message = "Secret name has invalid character/s."
    }
}

variable "namespace" {
    type = string
    description = "Create the certificate in this namespace"
}