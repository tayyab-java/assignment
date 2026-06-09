# DevOps Engineering Technical Exercise

Local GitOps platform on kind: Terraform provisions the cluster and platform Helm charts, ArgoCD syncs application manifests from this repository, Kyverno enforces admission policies, and External Secrets Operator syncs a demo secret into the sample app.

## How to run

```bash
make setup
make verify
```

Use `KEEP=1 make verify` while iterating to keep the cluster running. Run `make destroy` when finished.

### Toolchain install (Ubuntu / WSL)

```bash
bash install-tools.sh
```

Requires Docker with at least 6 GB RAM and 4 CPUs.

## Architecture

Terraform modules `kind-cluster` and `argocd-app` are composed in `terraform/envs/local` and `terraform/envs/local-stage`. The local environment creates a kind cluster, installs cert-manager, ArgoCD, External Secrets Operator, and Kyverno, then bootstraps the root ArgoCD Application. The root app watches `argocd/apps/` and deploys the sample application, Kyverno policies, and the stage app configuration.

Secrets are sourced from a Kubernetes Secret in the `default` namespace via a local `ClusterSecretStore`. An `ExternalSecret` in `sample-app` materialises `sample-app-env`, which the Helm overlay mounts into the pod.

## Module interface

### `terraform/modules/kind-cluster`

| Input | Description |
|---|---|
| `cluster_name` | DNS-1123 kind cluster name |
| `node_count` | Worker nodes (1–5) |
| `kubeconfig_path` | Where kubeconfig is written |

| Output | Description |
|---|---|
| `kubeconfig_path` | Kubeconfig file path |
| `cluster_endpoint` | API server endpoint |
| `cluster_ca_certificate` | Cluster CA cert |

### `terraform/modules/argocd-app`

| Input | Description |
|---|---|
| `app_name` | Application name |
| `project_name` | AppProject name |
| `repo_url` | Git repository URL |
| `target_namespace` | Destination namespace |
| `source_path` | Repo path to sync |
| `helm_value_files` | Optional Helm value files |
| `sync_options` | Optional sync options |
| `create_application` | Create Application resource (default `true`) |

| Output | Description |
|---|---|
| `application_name` | Application name |
| `project_name` | AppProject name |

## Trade-offs

- ESO uses the in-cluster Kubernetes provider instead of a cloud secret manager to keep the exercise fully local.
- Kyverno policies target Pods directly with autogen disabled to avoid ArgoCD drift on generated rules.
- Only `envs/local` is exercised by `make verify`; `local-stage` demonstrates environment separation with the same modules.

## AI tools used

Used Cursor to draft Terraform modules, ArgoCD manifests, Kyverno policies, and CI workflows. Reviewed the configuration against the exercise PDF and the shipped `verify/` harness before submitting.

## Verify output

Run `make verify` and paste the successful output into `verify-output.txt` before submission.
