# Minikube Setup: Deep Analysis & Next Steps

This document provides an analysis of the current OpenTofu + FluxCD Minikube (`dev`) environment and offers 10 actionable suggestions to improve the developer experience, reliability, and parity with production.

## Current State Analysis

The current setup provides a solid foundation for GitOps-driven local development:

- **Infrastructure as Code (IaC):** OpenTofu handles the cluster connection and FluxCD bootstrapping securely via TLS and GitHub deploy keys.
- **GitOps Engine:** FluxCD is configured to reconcile from the `flux/clusters/dev` directory.
- **Core Infrastructure:** Essential observability (Prometheus, Grafana Alloy) and ingress (HAProxy) controllers are deployed via declarative HelmReleases.

However, the setup is currently a "vanilla" deployment. It lacks environment-specific tuning, secrets management, and typical local-development optimizations.

## 10 Suggested Next Steps for Improvement

### 1. Implement Secrets Management (SOPS / External Secrets)

Currently, there is no encrypted way to store secrets (like database passwords or API keys) in the Git repository.
**Action:** Deploy Mozilla SOPS with Age encryption or the External Secrets Operator (ESO) as part of the `infra` stack. Configure Flux to automatically decrypt secrets before applying them to the cluster.

### 2. Optimize HelmRelease Values for Local Dev

The community and Grafana charts are deployed with their defaults, which are often resource-heavy.
**Action:** Add inline `values` to the `HelmRelease` manifests in `flux/infra/base/` (or override them in `flux/infra/dev/`) to reduce resource footprints for Minikube. For example, reduce Prometheus metrics retention time and disable high-availability (replica counts > 1) settings.

### 3. Configure Local DNS Resolution

HAProxy is installed, but testing ingress requires hitting IP addresses or using `curl -H "Host: ..."`.
**Action:** Document or automate the setup of local DNS (e.g., using `dnsmasq`, `systemd-resolved`, or a script to update `/etc/hosts`) to map a local domain like `*.watcher.local` to the `minikube ip`.

### 4. Enable Local Image Registry Integration

Pushing to a remote registry during the local dev loop is slow. Minikube provides an addon for a local registry.
**Action:** Enable the Minikube registry addon (`minikube addons enable registry`). Update the dev environment configurations to allow Flux (or your application deployments) to pull images directly from `localhost:5000` or the minikube internal registry endpoint.

### 5. Add Resource Requests and Limits

If the `infra` components consume too much CPU/Memory, Minikube might crash or become unresponsive.
**Action:** Explicitly define Kubernetes `requests` and `limits` within the `HelmRelease` configurations to ensure predictable performance and prevent resource starvation for future application workloads.

### 6. Setup Flux Image Automation

To achieve a true continuous deployment experience locally, Flux should automatically update deployments when new container images are built.
**Action:** Install the Flux image-reflector-controller and image-automation-controller. Configure `ImageRepository` and `ImagePolicy` manifests to watch your dev image registry and auto-commit image tag updates back to the `dev` cluster manifests.

### 7. Define Network Policies

Production (GKE) should have strict network segmentation. Dev should simulate this to catch connectivity issues early.
**Action:** Implement basic Kubernetes `NetworkPolicy` resources that restrict cross-namespace traffic by default, explicitly allowing only necessary ingress/egress routes (e.g., allowing Prometheus to scrape metrics from the application namespace).

### 8. Implement OpenTofu State Management

Currently, the OpenTofu state for the Minikube bootstrap likely resides locally in `terraform.tfstate`.
**Action:** Even for local environments, configuring a remote backend (like a local Postgres DB, or simply standardizing a dedicated git-ignored state directory with locking mechanisms) prevents accidental state corruption or loss if the local machine environment changes.

### 9. Configure Default Dashboards and Alerts

Prometheus and Alloy are running, but without predefined alerts or a visual frontend for the developer to use immediately.
**Action:** Deploy Grafana (the dashboard UI) alongside Alloy, or configure Alloy to forward to a central test backend. Add a `ConfigMap` containing default Dashboards and configure `PrometheusRule` Custom Resources for basic cluster health alerts.

### 10. Scaffold the Application Workload Directory

The infrastructure `infra` is ready, but there are no actual applications being deployed.
**Action:** Create a new root directory like `flux/apps/dev`. Add a Kustomization in `flux/clusters/dev/apps.yaml` pointing to it. Create a sample "Hello World" deployment in that directory to validate the entire end-to-end GitOps flow for application code.
