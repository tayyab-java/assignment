# Merge the kind cluster kubeconfig into the default Windows kubeconfig for Lens/kubectl.
# Run after terraform apply or make verify recreates the cluster.

$ErrorActionPreference = "Stop"

$kubeDir = Join-Path $env:USERPROFILE ".kube"
$mainConfig = Join-Path $kubeDir "config"
$kindConfig = Join-Path $PSScriptRoot "devops-local.kubeconfig"
$contextName = "kind-devops-local"

if (-not (Test-Path $kindConfig)) {
    Write-Error "Kubeconfig not found: $kindConfig`nRun 'make apply' or 'make verify' first."
}

if (-not (Test-Path $kubeDir)) {
    New-Item -ItemType Directory -Path $kubeDir -Force | Out-Null
}

$lockFile = "$mainConfig.lock"
if (Test-Path $lockFile) {
    Remove-Item $lockFile -Force
}

function Invoke-KubectlQuiet {
    param([string[]]$Args)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = "SilentlyContinue"
    & kubectl @Args 2>$null | Out-Null
    $ErrorActionPreference = $prev
}

function Remove-StaleKindEntries {
    param([string]$ConfigPath)

    $env:KUBECONFIG = $ConfigPath

    $contexts = kubectl config get-contexts -o name 2>$null |
        Where-Object { $_ -match "^kind-devops-local" }

    foreach ($ctx in $contexts) {
        $ctx = $ctx.TrimStart('*').Trim()
        Invoke-KubectlQuiet delete-context $ctx
        Write-Host "Removed stale context: $ctx"
    }

    Invoke-KubectlQuiet delete-cluster $contextName
    Invoke-KubectlQuiet delete-user $contextName
    Invoke-KubectlQuiet config prune -f
}

if (Test-Path $mainConfig) {
    $backup = "$mainConfig.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item $mainConfig $backup -Force
    Write-Host "Backed up existing config to $backup"
    Remove-StaleKindEntries -ConfigPath $mainConfig
    $env:KUBECONFIG = "$kindConfig;$mainConfig"
} else {
    $env:KUBECONFIG = $kindConfig
}

kubectl config view --flatten | Set-Content -Path $mainConfig -Encoding utf8
$env:KUBECONFIG = $mainConfig
kubectl config use-context $contextName | Out-Null

Write-Host "Merged $kindConfig into $mainConfig"
Write-Host "Active context: $contextName"
Write-Host ""
kubectl get nodes
