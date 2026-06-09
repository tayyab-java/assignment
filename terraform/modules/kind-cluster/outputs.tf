output "kubeconfig_path" {
  description = "Path to the kind cluster kubeconfig"
  value       = kind_cluster.this.kubeconfig_path
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = kind_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate"
  value       = kind_cluster.this.cluster_ca_certificate
}
