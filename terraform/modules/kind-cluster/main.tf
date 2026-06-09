resource "kind_cluster" "this" {
  name            = var.cluster_name
  wait_for_ready  = true
  kubeconfig_path = var.kubeconfig_path

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
    }

    dynamic "node" {
      for_each = range(var.node_count - 1)
      content {
        role = "worker"
      }
    }
  }
}

resource "null_resource" "unprivileged_ports" {
  depends_on = [kind_cluster.this]

  provisioner "local-exec" {
    command = "docker exec ${var.cluster_name}-control-plane sysctl -w net.ipv4.ip_unprivileged_port_start=0"
  }
}
