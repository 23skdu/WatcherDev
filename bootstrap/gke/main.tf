# GKE Cluster Definition
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.gcp_zone

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/14"
    services_ipv4_cidr_block = "/20"
  }
  
  release_channel {
    channel = "REGULAR"
  }
}

# Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.cluster_name}-node-pool"
  location   = var.gcp_zone
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

# Generate a TLS private key for Flux to access the Git repository
resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

# Add the deploy key to the GitHub repository
resource "github_repository_deploy_key" "flux" {
  title      = "FluxCD GKE Prod Deploy Key"
  repository = var.github_repository
  key        = tls_private_key.flux.public_key_openssh
  read_only  = "false"
}

# Bootstrap FluxCD
resource "flux_bootstrap_git" "this" {
  depends_on = [
    github_repository_deploy_key.flux,
    google_container_node_pool.primary_nodes
  ]

  path = var.target_path
}
