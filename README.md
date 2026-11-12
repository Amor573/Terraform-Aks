# Azure Kubernetes Service (AKS) with Terraform

Infrastructure-as-code reference for provisioning an **Azure Kubernetes Service cluster** and configuring a **Datadog agent integration** using the Terraform AzureRM, Kubernetes, and Helm providers.

> **Portfolio status:** The code in this repository demonstrates the intended infrastructure architecture. Deployment, provider compatibility and chart installation have **not been independently verified in a live Azure subscription**. Review the notes below before applying.

## Architecture

```text
Terraform
 ├── Azure resource group
 ├── modules/aks
 │    └── AKS cluster (2-node default pool; Azure CNI; system-assigned identity)
 └── modules/helm
      ├── Kubernetes namespace: datadog
      ├── Kubernetes Secret for Datadog API key
      └── Datadog Helm chart
```

## What's in the repository

| Path | Purpose |
| --- | --- |
| `main.tf` | Resource group and module composition |
| `providers.tf` | Provider requirements and Kubernetes/Helm connectivity |
| `variables.tf` | Required deployment inputs |
| `modules/aks/` | AKS cluster and exported cluster connection values |
| `modules/helm/` | Datadog namespace, Secret and Helm release |

## Prerequisites

- An Azure subscription with permissions to provision AKS, networking, and resource groups
- Azure CLI with an authenticated identity (`az login`)
- Terraform CLI
- A Datadog API key (treat as a secret)
- Cost awareness: AKS worker nodes, networking and monitoring can incur charges

## Deployment workflow

1. Inspect the provider and chart versions. **Validate compatibility with your installed Terraform and provider versions before applying.**
2. Authenticate and choose the intended Azure subscription.
3. Supply required variables securely (environment variables, a secret manager, or a local untracked `.tfvars` file).
4. Initialize and validate the configuration.
5. Review the plan carefully before applying.

```bash
az login
az account show
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
# Only after reviewing the intended billable resources:
terraform apply tfplan
```

Required inputs: `resource_group`, `location`, `cluster_name`, `dns_prefix`, and `datadog_api_key`.

## Verification and cleanup

```bash
az aks show --resource-group <resource-group> --name <aks-name> --query provisioningState -o tsv
az aks get-credentials --resource-group <resource-group> --name <aks-name>
kubectl get nodes -o wide
kubectl get pods -n datadog
helm list -n datadog
# Review planned removals before proceeding:
terraform plan -destroy
```

## Engineering considerations / known limitations

- The `datadog_api_key` variable is marked sensitive, but **Terraform state can still store secret values**. Use encrypted remote state with tightly limited access; never commit a state file or secret-bearing plan.
- The code uses an older AzureRM major-version constraint and a specific Datadog chart version. Confirm supported Helm provider syntax and chart values before upgrading or executing.
- Datadog site is currently configured as `us5.datadoghq.com` in the Helm module; change to your organization's site if necessary.
- The AKS node pool is configured for two `Standard_B2s` VMs as a demonstration, not production capacity guidance.
- For production hardening, evaluate Azure Workload Identity, remote state, networking boundaries, monitoring cost, resource tags, key rotation and policy checks.
- This repository is a **reference implementation**, not proof of a successful live deployment.

## Next enhancements

- Automated `terraform fmt` / `validate` checks and security scanning
- Remote state and workload identity
- Environment-specific variables and protected release workflow
- Screenshot-free, sanitized evidence of an actual test deployment

**Related expertise:** Azure • Terraform • Kubernetes • Helm • Observability • Infrastructure as Code.

## Static CI and validation evidence

[![Terraform static validation](https://github.com/Amor573/Terraform-Aks/actions/workflows/terraform-validation.yml/badge.svg)](https://github.com/Amor573/Terraform-Aks/actions/workflows/terraform-validation.yml)

GitHub Actions now runs `terraform init -backend=false` and `terraform validate` on Terraform changes, without Azure credentials or billable resources. A green static check is **not a successful live apply**. See [architecture, security constraints and the proof checklist](docs/validation-and-evidence.md).
