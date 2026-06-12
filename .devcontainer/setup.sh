#!/usr/bin/env bash
# Install the Kubernetes toolbox inside the codespace, robustly.
#
# Why not the kubectl-helm-minikube devcontainer feature? Its Helm install
# verifies the download against a public GPG keyserver that is frequently
# unreachable; when it is, the whole container build fails and Codespaces
# drops you into a recovery container with no tools. Official binaries +
# sha256 checksums have no such external dependency.
set -euo pipefail

echo "== kubectl =="
KUBECTL_VERSION="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
curl -fsSLo /tmp/kubectl     "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
curl -fsSLo /tmp/kubectl.sha "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"
echo "$(cat /tmp/kubectl.sha)  /tmp/kubectl" | sha256sum --check
sudo install -m 0755 /tmp/kubectl /usr/local/bin/kubectl

echo "== helm =="
# The official get-helm-3 script verifies its tarball with sha256, not a keyserver.
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "== kind =="
curl -fsSLo /tmp/kind https://kind.sigs.k8s.io/dl/v0.32.0/kind-linux-amd64
sudo install -m 0755 /tmp/kind /usr/local/bin/kind

rm -f /tmp/kubectl /tmp/kubectl.sha /tmp/kind
echo "== toolbox ready =="
docker --version
kind version
kubectl version --client | head -1
helm version --short
