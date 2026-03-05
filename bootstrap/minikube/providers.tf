terraform {
  required_version = ">= 1.0"
  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.2.0"
    }
    github = {
      source  = "integrations/github"
      version = ">= 5.0.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
  }
}

provider "flux" {
  kubernetes = {
    config_path = var.kubeconfig_path
    config_context = var.kubeconfig_context
  }
  git = {
    url = "ssh://git@github.com/${var.github_owner}/${var.github_repository}.git"
    ssh = {
      username    = "git"
      private_key = tls_private_key.flux.private_key_pem
    }
  }
}

provider "github" {
  owner = var.github_owner
  token = var.github_token
}
