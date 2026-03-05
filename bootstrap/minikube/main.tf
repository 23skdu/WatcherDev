# Generate a TLS private key for Flux to access the Git repository
resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

# Add the deploy key to the GitHub repository
resource "github_repository_deploy_key" "flux" {
  title      = "FluxCD Minikube Deploy Key"
  repository = var.github_repository
  key        = tls_private_key.flux.public_key_openssh
  read_only  = "false"
}

# Bootstrap FluxCD
resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository_deploy_key.flux]

  path = var.target_path
}
