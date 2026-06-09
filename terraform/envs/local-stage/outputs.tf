output "kubeconfig_path" {
  description = "Path to the kind cluster kubeconfig"
  value       = module.cluster.kubeconfig_path
}
