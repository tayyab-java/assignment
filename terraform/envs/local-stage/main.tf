module "cluster" {
  source = "../../modules/kind-cluster"

  cluster_name    = var.cluster_name
  node_count      = var.node_count
  kubeconfig_path = abspath(var.kubeconfig_dir)
}

provider "helm" {
  kubernetes {
    host                   = module.cluster.cluster_endpoint
    cluster_ca_certificate = module.cluster.cluster_ca_certificate
    config_path            = module.cluster.kubeconfig_path
  }
}

provider "kubectl" {
  host                   = module.cluster.cluster_endpoint
  cluster_ca_certificate = module.cluster.cluster_ca_certificate
  config_path            = module.cluster.kubeconfig_path
  load_config_file       = true
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.16.2"
  namespace        = "cert-manager"
  create_namespace = true
  timeout          = 600

  set {
    name  = "crds.enabled"
    value = "true"
  }

  depends_on = [module.cluster]
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.7.12"
  namespace        = "argocd"
  create_namespace = true
  timeout          = 600

  depends_on = [helm_release.cert_manager]
}

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = "0.10.5"
  namespace        = "external-secrets"
  create_namespace = true
  timeout          = 600

  depends_on = [helm_release.argocd]
}

resource "helm_release" "kyverno" {
  name             = "kyverno"
  repository       = "https://kyverno.github.io/kyverno"
  chart            = "kyverno"
  version          = "3.3.4"
  namespace        = "kyverno"
  create_namespace = true
  timeout          = 900

  depends_on = [helm_release.external_secrets]
}

module "stage_app_project" {
  source = "../../modules/argocd-app"

  app_name             = "sample-app-stage"
  project_name         = "sample-app"
  repo_url             = var.git_repo_url
  target_namespace        = "sample-app-stage"
  destination_namespaces  = ["sample-app", "sample-app-stage", "kyverno"]
  source_path             = "helm/charts/sample-app"
  helm_value_files     = ["values.local-stage.yaml"]
  sync_options         = ["CreateNamespace=true", "ServerSideApply=true"]
  create_application   = false
  depends_on_resources = [helm_release.argocd]
}

resource "kubectl_manifest" "project_root" {
  yaml_body = replace(
    file("${path.module}/../../../argocd/projects/root.yaml"),
    "<YOUR_GIT_REPO_URL>",
    var.git_repo_url
  )

  depends_on = [helm_release.argocd]
}

resource "kubectl_manifest" "root_application" {
  yaml_body = replace(
    file("${path.module}/../../../argocd/root.yaml"),
    "<YOUR_GIT_REPO_URL>",
    var.git_repo_url
  )

  depends_on = [
    helm_release.argocd,
    kubectl_manifest.project_root,
    module.stage_app_project,
  ]
}
