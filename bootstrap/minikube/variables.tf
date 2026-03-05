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
  default     = "flux/clusters/dev"
}

variable "kubeconfig_path" {
  type        = string
  description = "Path to the kubeconfig file"
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  type        = string
  description = "Kubernetes context to use"
  default     = "minikube"
}
