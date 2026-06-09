#!/usr/bin/env bash
set -euo pipefail

BIN="$HOME/.local/bin"
mkdir -p "$BIN"
export PATH="$BIN:$PATH"

install_zip_bin() {
  local url="$1" zipname="$2" binary="$3"
  if command -v "$binary" >/dev/null 2>&1; then return; fi
  curl -fsSL "$url" -o "/tmp/$zipname"
  python3 -c "import zipfile; zipfile.ZipFile('/tmp/$zipname').extractall('/tmp')"
  install -m 0755 "/tmp/$binary" "$BIN/$binary" 2>/dev/null || mv "/tmp/$binary" "$BIN/$binary"
}

install_zip_bin "https://releases.hashicorp.com/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip" "tf.zip" "terraform"
install_zip_bin "https://github.com/terraform-linters/tflint/releases/download/v0.55.0/tflint_linux_amd64.zip" "tflint.zip" "tflint"

if ! command -v kind >/dev/null; then
  curl -Lo /tmp/kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
  install -m 0755 /tmp/kind "$BIN/kind"
fi

if ! command -v helm >/dev/null; then
  curl -fsSL https://get.helm.sh/helm-v3.16.3-linux-amd64.tar.gz | tar xz -C /tmp
  install -m 0755 /tmp/linux-amd64/helm "$BIN/helm"
fi

if ! command -v conftest >/dev/null; then
  curl -fsSL https://github.com/open-policy-agent/conftest/releases/download/v0.56.0/conftest_0.56.0_Linux_x86_64.tar.gz | tar xz -C /tmp
  install -m 0755 /tmp/conftest "$BIN/conftest"
fi

pip3 install --user checkov -q 2>/dev/null || pip3 install --user checkov -q --break-system-packages

grep -q '.local/bin' "$HOME/.bashrc" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"

terraform version
kind version
helm version --short
conftest --version
tflint --version
checkov --version | head -1
