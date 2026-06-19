# =============================================================================
# main.tf — AVM-based Terraform configuration
#
# Resources provisioned:
#   1. Azure Resource Group  — AVM module: avm-res-resources-resourcegroup
#   2. Azure Storage Account — AVM module: avm-res-storage-storageaccount
#
# NOTE: Both AVM modules are backed by the AzAPI provider, not azurerm.
# azurerm ~> 4.0 is pinned in required_providers as requested and is available
# for any direct azurerm resources you add later.
# =============================================================================

terraform {
  # Minimum version required by the storage account AVM module (0.7.x)
  required_version = ">= 1.10.0"

  required_providers {
    # azurerm: pinned as requested; configure storage_use_azuread for Entra ID
    # data-plane access when using AVM storage module with shared_access_key_enabled=false
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    # azapi: required by both AVM resource modules (resource group + storage account)
    # avm-res-resources-resourcegroup ~> 0.4 requires azapi ~> 2.4
    # avm-res-storage-storageaccount  ~> 0.7 requires azapi ~> 2.8
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.8"
    }
  }

  # No backend block is included — configuration is validation-ready locally.
  # Add a backend block (e.g. "azurerm") before deploying to a shared environment.
}

# -----------------------------------------------------------------------------
# Provider configuration
# -----------------------------------------------------------------------------

provider "azurerm" {
  features {}

  # When shared_access_key_enabled = false on the storage module, all data-plane
  # access from azurerm resources (e.g. azurerm_storage_blob) must use Entra ID.
  storage_use_azuread = true
}

# azapi is used internally by both AVM modules; no extra configuration needed.
provider "azapi" {}

# -----------------------------------------------------------------------------
# Local values — naming conventions and shared tags
# -----------------------------------------------------------------------------

locals {
  # Naming prefix:  <app_name>-<environment>-<location_short>
  # Example result: myapp-dev-eus
  name_prefix = "${var.application_name}-${var.environment}-${var.location_short}"

  # Storage account names must be 3-24 chars, lowercase letters and numbers only.
  # We strip hyphens, lowercase everything, and truncate at 24 characters.
  storage_account_name = substr(
    lower(replace("${var.application_name}${var.environment}${var.location_short}sa", "-", "")),
    0,
    24
  )

  # Common tags applied to every resource; merged with caller-supplied tags.
  common_tags = merge(var.tags, {
    environment = var.environment
    managed_by  = "terraform"
    avm_module  = "true"
  })
}

# -----------------------------------------------------------------------------
# Resource Group
#
# AVM module : Azure/avm-res-resources-resourcegroup/azurerm
# GitHub     : https://github.com/Azure/terraform-azurerm-avm-res-resources-resourcegroup
# Registry   : https://registry.terraform.io/modules/Azure/avm-res-resources-resourcegroup/azurerm
# Version    : 0.4.0 (azapi ~> 2.4)
#
# Required inputs : location, name
# -----------------------------------------------------------------------------
module "resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "~> 0.4"

  # Required inputs
  name     = "${local.name_prefix}-rg"
  location = var.location

  tags = local.common_tags

  # Set to false to opt out of Microsoft's anonymous telemetry collection.
  enable_telemetry = var.enable_telemetry
}

# -----------------------------------------------------------------------------
# Storage Account
#
# AVM module : Azure/avm-res-storage-storageaccount/azurerm
# GitHub     : https://github.com/Azure/terraform-azurerm-avm-res-storage-storageaccount
# Registry   : https://registry.terraform.io/modules/Azure/avm-res-storage-storageaccount/azurerm
# Version    : 0.7.2 (azapi ~> 2.8 — azurerm provider not required in 0.7.x)
#
# Required inputs : location, name, parent_id
#
# Security baseline applied below:
#   - HTTPS-only traffic enforced
#   - Minimum TLS 1.2
#   - Infrastructure (double) encryption enabled
#   - Shared-key access disabled (Entra ID authentication only)
#   - Public network access disabled
#   - Network rules default to Deny (only AzureServices bypass)
#   - No anonymous public blob access
# -----------------------------------------------------------------------------
module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "~> 0.7"

  # Required inputs
  name = local.storage_account_name

  location = var.location

  # parent_id: full ARM resource ID of the parent resource group.
  # Format: /subscriptions/{sub_id}/resourceGroups/{rg_name}
  parent_id = module.resource_group.resource_id

  # Account type: StorageV2 is the recommended general-purpose v2 account.
  account_kind     = "StorageV2"
  account_sku_name = var.storage_account_sku

  # ---------------------------------------------------------------------------
  # Encryption settings
  # ---------------------------------------------------------------------------

  # Reject any HTTP connections; only HTTPS is accepted.
  https_traffic_only_enabled = true

  # Require TLS 1.2 as the minimum protocol version.
  min_tls_version = "TLS1_2"

  # Enable infrastructure (double) encryption for an additional layer of
  # encryption at rest managed by the Azure platform.
  infrastructure_encryption_enabled = true

  # Disable shared-key (SAS) access. All requests must be authorised
  # using Azure Active Directory / Entra ID identities.
  shared_access_key_enabled = false

  # ---------------------------------------------------------------------------
  # Network security settings
  # ---------------------------------------------------------------------------

  # Disable the public endpoint; access via private endpoints or trusted services only.
  public_network_access_enabled = false

  # Network rules: deny all public traffic; allow only Azure service bypass.
  # Default value ({}) already applies default_action="Deny" + bypass=["AzureServices"],
  # but we set it explicitly for clarity and auditability.
  network_rules = {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }

  # Prevent any nested blob or container from being made publicly accessible.
  allow_nested_items_to_be_public = false

  # Hot access tier for general-purpose, frequently accessed workloads.
  access_tier = "Hot"

  tags = local.common_tags

  # Set to false to opt out of Microsoft's anonymous telemetry collection.
  enable_telemetry = var.enable_telemetry
}
