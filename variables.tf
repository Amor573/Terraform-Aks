variable "resource_group" {
  description = "Name of the resource group to create"
  type        = string
}

variable "location" {
  description = "Azure region for the resources"
  type        = string
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "datadog_api_key" {
  description = "API key for Datadog agent installation"
  type        = string
  sensitive   = true
}
