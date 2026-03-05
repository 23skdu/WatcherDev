variable "gcp_project_id" {
  type        = string
  description = "Google Cloud Project ID"
}

variable "gcp_region" {
  type        = string
  description = "Google Cloud Region"
  default     = "us-central1"
}

variable "gcp_zone" {
  type        = string
  description = "Google Cloud Zone"
  default     = "us-central1-a"
}

variable "cluster_name" {
  type        = string
  description = "GKE Cluster Name"
  default     = "prod-cluster"
}

variable "machine_type" {
  type        = string
  description = "GCP Machine Type for GKE nodes"
  default     = "e2-standard-4"
}

variable "node_count" {
  type        = number
  description = "Number of nodes in the managed node pool"
  default     = 3
}

variable "github_owner" {
  type        = string
  description = "GitHub owner or organization"
}

variable "github_repository" {
  type        = string
  description = "GitHub repository name"
}

variable "github_token" {
  type        = string
  description = "GitHub personal access token"
  sensitive   = true
}

variable "target_path" {
  type        = string
  description = "Path relative to the repository root for the Flux manifests"
  default     = "flux/clusters/prod"
}
