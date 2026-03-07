# Minikube Setup: Deep Analysis & Next Steps

This document provides an analysis of the current OpenTofu + FluxCD Minikube (`dev`) environment and offers a prioritized list of actionable steps to improve developer experience, reliability, and security.

## Current State Analysis

The current setup provides a solid foundation for GitOps-driven local development:

- **Infrastructure as Code (IaC):** OpenTofu handles the cluster connection and FluxCD bootstrapping.
- **GitOps Engine:** FluxCD reconciles `flux/clusters/dev` and `flux/clusters/prod`.
- **Core Infrastructure:** Observability (Prometheus, Grafana, Loki, Alloy) and Ingress (HAProxy with Gateway API) are deployed.
- **Secrets Management:** Mozilla SOPS with Age encryption securely decrypts sensitive data before applying to the cluster.
- **Optimizations:** Local DNS mapping and resource optimizations are completed to adapt to Minikube constraints.

## Prioritized Next Steps (Security & App Dev)

### 1. Enable Local Image Registry Integration

Pushing to a remote registry during the local dev loop is slow.
**Action:** Enable the Minikube registry addon (`minikube addons enable registry`). Update the dev environment configurations to allow Flux to pull images directly from the minikube internal registry endpoint.

### 2. Scaffold the Application Workload Directory

The core `infra` is ready, but there are no actual business applications being deployed.
**Action:** Create a new root directory like `flux/apps/dev`. Add a Kustomization in `flux/clusters/dev/apps.yaml` pointing to it. Create a sample "Hello World" deployment to validate the end-to-end GitOps flow for application code.

### 3. Setup Flux Image Automation

To achieve a true continuous deployment experience locally, Flux should automatically update deployments when new container images are built.
**Action:** Install Flux image-reflector and image-automation controllers. Configure `ImageRepository` and `ImagePolicy` manifests to watch your dev registry and auto-commit tag updates.

### 4. Implement Strict Network Policies (Default Deny)

Currently, all cross-namespace communication is permitted by default.
**Action:** Implement `NetworkPolicy` strict default-deny policies in all namespaces, whitelisting only essential service-to-service communication.

### 5. Implement OpenTofu Remote State Management

The OpenTofu state for bootstrapping likely resides locally.
**Action:** Migrate the local `terraform.tfstate` to a remote, encrypted backend (e.g., GCS or S3) with state locking to prevent accidental corruption.

### 6. Enforce Pod Security Standards (PSS)

**Action:** Enable Kubernetes Pod Security Admission controller to enforce the `Restricted` or `Baseline` profile. This prevents pods from running as root or mounting sensitive host paths.

### 7. Integrate Image Vulnerability Scanning

**Action:** Integrate a container security scanner (such as Trivy) into the CI pipeline to block images with critical CVEs from being deployed by FluxCD.

### 8. Audit and Restrict RBAC Permissions

**Action:** Review all `ClusterRoleBindings` and `RoleBindings`. Limit cluster-admin access strictly to CI/CD controllers and apply the Principle of Least Privilege across service accounts.
