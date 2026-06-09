variable "cluster_name" {
  description = "kind cluster name"
  type        = string
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
}

variable "git_repo_url" {
  description = "Public Git repository URL for ArgoCD"
  type        = string
}

variable "kubeconfig_dir" {
  description = "Path to kubeconfig file for the kind cluster"
  type        = string
}
