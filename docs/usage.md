# Usage Guide

This guide describes how to use the OpenTofu bootstrap scripts to set up FluxCD on Minikube and GKE, and how the FluxCD source tree is structured to deploy infrastructure components.

## Prerequisites

- [OpenTofu](https://opentofu.org/) installed.
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed.
- [Flux CLI](https://fluxcd.io/flux/installation/) (optional, but recommended).
- A GitHub Personal Access Token (PAT) with `repo` permissions.

## Minikube Bootstrap

The Minikube bootstrap script installs FluxCD into an existing Minikube cluster and configures it to sync with this repository.

1. Ensure Minikube is running:

   ```bash
   minikube start
   ```

2. Navigate to the bootstrap directory:

   ```bash
   cd bootstrap/minikube
   ```

3. Initialize OpenTofu:

   ```bash
   tofu init
   ```

4. Apply the configuration (provide your GitHub token and repository details):

   ```bash
   tofu apply -var="github_token=$GITHUB_TOKEN" -var="github_owner=your-github-username" -var="github_repository=WatcherDev"
   ```

## GKE Bootstrap

The GKE bootstrap script creates a GKE cluster in Google Cloud and bootstraps FluxCD into it.

1. Configure your Google Cloud credentials.

2. Navigate to the bootstrap directory:

   ```bash
   cd bootstrap/gke
   ```

3. Initialize OpenTofu:

   ```bash
   tofu init
   ```

4. Apply the configuration:

   ```bash
   tofu apply -var="project_id=your-gcp-project-id" -var="github_token=$GITHUB_TOKEN" -var="github_owner=your-github-username" -var="github_repository=WatcherDev"
   ```

## FluxCD Structure

The `flux/` directory is organized into `clusters` and `infra`:

- `flux/clusters/`: Contains cluster-specific configurations.
  - `dev/`: Configuration for the Minikube (development) cluster.
  - `prod/`: Configuration for the GKE (production) cluster.
- `flux/infra/`: Contains common infrastructure components.
  - `base/`: Base manifests for Prometheus, Grafana Alloy, HAProxy Ingress, Loki, and Blackbox Exporter.
  - `dev/` and `prod/`: Environment-specific overlays for the infrastructure components.

### Infrastructure Components

The following components are deployed as part of the `infra` stack:

- **Prometheus**: Using the `kube-prometheus-stack` Helm chart for metrics collection and Grafana.
- **Grafana Alloy**: OpenTelemetry collector for gathering metrics and logs.
- **HAProxy Ingress**: Ingress controller for routing external traffic.
- **Loki**: Log aggregation system.
- **Blackbox Exporter**: Probes endpoints (ICMP, DNS) for availability.

### Automatic Datasources

Grafana is automatically configured with the following datasources:

- **Prometheus**: Default datasource.
- **Loki**: Configured to point to the internal Loki service.
- **Alloy**: Enabled for log/metric ingestion.

## Secret Management with SOPS & Age

The `infra` stack is configured to automatically decrypt secrets managed by Mozilla SOPS using an Age key pair. To add a new secret or modify an existing one:

1. Ensure the `age.agekey` private key is present in `~/.config/sops/age/keys.txt`.
2. Create your unencrypted Kubernetes Secret YAML (e.g., `my-secret.yaml`).
3. Encrypt the secret in place using SOPS (it uses the `.sops.yaml` configuration to find the public key and only target data fields):

   ```bash
   sops --encrypt --in-place my-secret.yaml
   ```

4. Commit the encrypted file to the repository. Flux will decrypt it using the `sops-age` secret residing in the `flux-system` namespace.

## Verification

To verify the setup, you can check the status of FluxCD and the deployed pods:

```bash
flux get kustomizations
flux get helmreleases -A
kubectl get pods -A
```
