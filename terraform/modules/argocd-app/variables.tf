variable "app_name" {
  description = "ArgoCD Application name"
  type        = string

  validation {
    condition     = var.app_name != "default" && length(var.app_name) > 0
    error_message = "app_name must be set and cannot be 'default'."
  }
}

variable "project_name" {
  description = "ArgoCD AppProject name"
  type        = string
}

variable "repo_url" {
  description = "Git repository URL"
  type        = string
}

variable "target_namespace" {
  description = "Destination namespace for the application"
  type        = string
}

variable "source_path" {
  description = "Path within the repository"
  type        = string
}

variable "target_revision" {
  description = "Git revision to sync"
  type        = string
  default     = "main"
}

variable "automated_prune" {
  description = "Enable automated prune"
  type        = bool
  default     = true
}

variable "automated_self_heal" {
  description = "Enable automated self heal"
  type        = bool
  default     = true
}

variable "helm_value_files" {
  description = "Helm value files relative to the chart path"
  type        = list(string)
  default     = []
}

variable "sync_options" {
  description = "ArgoCD sync options"
  type        = list(string)
  default     = []
}

variable "depends_on_resources" {
  description = "Resources this module depends on"
  type        = any
  default     = []
}

variable "create_application" {
  description = "Whether to create the ArgoCD Application resource"
  type        = bool
  default     = true
}
