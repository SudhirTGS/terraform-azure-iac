variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant (directory) ID"
}

variable "client_id" {
  type        = string
  description = "Service principal application (client) ID"
}

variable "client_secret" {
  type        = string
  description = "Service principal client secret"
  sensitive   = true
}


