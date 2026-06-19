# =============================================================================
# variable.tf — Input variables for the AVM-based Terraform configuration
# =============================================================================

# -----------------------------------------------------------------------------
# Required inputs
# -----------------------------------------------------------------------------

variable "location" {
  type        = string
  description = "Required. Azure region where all resources will be deployed (e.g. 'eastus', 'westeurope')."

  validation {
    condition     = length(var.location) > 0
    error_message = "location must be a non-empty Azure region string."
  }
}

variable "application_name" {
  type        = string
  description = "Required. Short application or workload name used as the base for resource naming (e.g. 'myapp'). Use lowercase letters and hyphens only."

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,12}$", var.application_name))
    error_message = "application_name must be 2-13 lowercase alphanumeric characters or hyphens, starting with a letter."
  }
}

variable "environment" {
  type        = string
  description = "Required. Deployment environment identifier. Used in resource names and tags."

  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, test, staging, prod."
  }
}

variable "location_short" {
  type        = string
  description = "Required. Short abbreviation for the Azure region used in resource names (e.g. 'eus' for East US, 'weu' for West Europe). Must be 2-5 lowercase letters."

  validation {
    condition     = can(regex("^[a-z]{2,5}$", var.location_short))
    error_message = "location_short must be 2-5 lowercase letters."
  }
}

# -----------------------------------------------------------------------------
# Optional inputs with secure defaults
# -----------------------------------------------------------------------------

variable "storage_account_sku" {
  type        = string
  description = "Optional. Storage account SKU name. Defaults to Standard_LRS for development; use Standard_ZRS or Standard_GRS for production workloads."
  default     = "Standard_LRS"

  validation {
    condition     = contains(["Standard_LRS", "Standard_ZRS", "Standard_GRS", "Standard_RAGRS", "Standard_GZRS", "Standard_RAGZRS", "Premium_LRS", "Premium_ZRS"], var.storage_account_sku)
    error_message = "storage_account_sku must be a valid Azure Storage SKU (e.g. Standard_LRS, Standard_ZRS, Standard_GRS)."
  }
}

variable "tags" {
  type        = map(string)
  description = "Optional. Additional tags to apply to all resources. Merged with module-generated tags (environment, managed_by, avm_module)."
  default     = {}
}

variable "enable_telemetry" {
  type        = bool
  description = "Optional. Controls whether AVM modules send anonymous telemetry to Microsoft. Set to false to opt out. See https://aka.ms/avm/telemetryinfo."
  default     = true
}
