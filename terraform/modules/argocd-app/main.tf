locals {
  helm_block = length(var.helm_value_files) > 0 ? {
    helm = {
      valueFiles = var.helm_value_files
    }
  } : {}
}

resource "kubectl_manifest" "project" {
  depends_on = [var.depends_on_resources]

  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = var.project_name
      namespace = "argocd"
    }
    spec = {
      sourceRepos = [var.repo_url]
      destinations = [{
        namespace = var.target_namespace
        server    = "https://kubernetes.default.svc"
      }]
      clusterResourceWhitelist = [{
        group = "*"
        kind  = "*"
      }]
      namespaceResourceWhitelist = [{
        group = "*"
        kind  = "*"
      }]
    }
  })
}

resource "kubectl_manifest" "application" {
  count = var.create_application ? 1 : 0

  depends_on = [kubectl_manifest.project]

  yaml_body = yamlencode(merge({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = var.app_name
      namespace = "argocd"
    }
    spec = {
      project = var.project_name
      source = merge({
        repoURL        = var.repo_url
        targetRevision = var.target_revision
        path           = var.source_path
      }, local.helm_block)
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.target_namespace
      }
      syncPolicy = {
        automated = {
          prune    = var.automated_prune
          selfHeal = var.automated_self_heal
        }
        syncOptions = var.sync_options
      }
    }
  }, {}))
}
