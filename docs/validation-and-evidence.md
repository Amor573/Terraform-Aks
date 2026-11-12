# AKS + Datadog Terraform — proof and safety plan

**Status:** source-only reference architecture; no successful Azure deployment or Datadog chart installation is claimed.

## Architecture

```text
Terraform root
 ├─ azurerm_resource_group
 ├─ modules/aks
 │   └─ azurerm_kubernetes_cluster
 │       └─ system node pool (lab default: 2 Standard_B2s VMs)
 └─ modules/helm
     ├─ kubernetes_namespace: datadog
     ├─ kubernetes_secret: datadog API key
     └─ helm_release: datadog chart
```

The CI workflow only installs providers and performs **static validation**. It does not run `terraform plan`, `apply` or contact Azure; GitHub Actions should not be given production cloud credentials to test this reference.

## Evidence required before claiming a live deployment

1. Record the Terraform CLI and provider versions from a successful `terraform init`.
2. Run `terraform fmt -check -recursive` and `terraform validate` successfully.
3. Use a dedicated, disposable Azure subscription/resource group, verify the intended region and expected charges, and review a redacted `terraform plan`.
4. After an authorized apply, verify `az aks show`, `kubectl get nodes`, `kubectl get pods -n datadog`, and `helm status datadog -n datadog`.
5. Prove observability with a non-sensitive test metric and a Datadog view; a running pod alone is not integration proof.
6. Capture sanitized evidence and tear down the lab after reviewing destructive changes.

## Known gaps to resolve

- Provider-configuration ordering: Kubernetes/Helm providers depend on a cluster not yet present during the first plan; consider separating cluster provisioning and monitoring installation into distinct Terraform states/pipelines.
- Do not pass the Datadog API key directly through committed tfvars; marking a variable `sensitive` does **not** keep the secret out of Terraform state.
- Prefer Azure Workload Identity to certificate-based cluster administration where feasible, and avoid outputting kubeconfig certificate material.
- The code uses an older AzureRM major version, and the Datadog chart is pinned to an older version. Validate compatibility and migrate in a controlled test subscription.
- Add network isolation, remote state encryption, secret rotation, resource tagging, budget monitoring and cleanup checks before suggesting production use.

Never publish Terraform state, kubeconfigs, Datadog keys, subscription IDs, private hostnames or account screenshots without redaction.