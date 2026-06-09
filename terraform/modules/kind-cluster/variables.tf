variable "cluster_name" {
  description = "kind cluster name (DNS-1123 compatible)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.cluster_name)) && length(var.cluster_name) <= 32
    error_message = "cluster_name must be lowercase DNS-1123 and at most 32 characters."
  }
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 1

  validation {
    condition     = var.node_count >= 1 && var.node_count <= 5
    error_message = "node_count must be between 1 and 5."
  }
}

variable "kubeconfig_path" {
  description = "Path where the kind kubeconfig is written"
  type        = string
}
