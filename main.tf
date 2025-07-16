# Create the resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location
}



# Deploy the AKS cluster
module "aks" {
  source              = "./modules/aks"
  cluster_name        = var.cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix
}



module "helm" {
  source          = "./modules/helm"
  datadog_api_key = var.datadog_api_key

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  depends_on = [
    module.aks
  ]
}




