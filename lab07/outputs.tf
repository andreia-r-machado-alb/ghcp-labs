# =============================================================================
# outputs.tf — Exported values from the AVM-based Terraform configuration
# =============================================================================

# -----------------------------------------------------------------------------
# Resource Group outputs
# Source: module.resource_group (Azure/avm-res-resources-resourcegroup/azurerm)
# -----------------------------------------------------------------------------

output "resource_group_id" {
  description = "The full ARM resource ID of the provisioned resource group."
  value       = module.resource_group.resource_id
}

output "resource_group_name" {
  description = "The name of the provisioned resource group."
  value       = module.resource_group.name
}

output "resource_group_location" {
  description = "The Azure region where the resource group was deployed."
  value       = module.resource_group.location
}

# -----------------------------------------------------------------------------
# Storage Account outputs
# Source: module.storage_account (Azure/avm-res-storage-storageaccount/azurerm)
# -----------------------------------------------------------------------------

output "storage_account_id" {
  description = "The full ARM resource ID of the provisioned storage account."
  value       = module.storage_account.resource_id
}

output "storage_account_name" {
  description = "The name of the provisioned storage account."
  value       = module.storage_account.name
}

output "storage_account_primary_blob_fqdn" {
  description = "The fully qualified domain name of the primary blob endpoint. Null if blob service is not enabled."
  value       = try(module.storage_account.fqdn.blob.primary, null)
}
