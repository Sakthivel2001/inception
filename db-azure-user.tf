terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "54c92dd1-44bb-4598-ae8e-748dcd21114c"
}

# Retrieve secrets from Azure Key Vault
data "azurerm_key_vault" "example" {
  name                = "DatabricksCredentials"  # Replace with your Key Vault name
  resource_group_name = "az-db"  # Replace with your resource group name
}

data "azurerm_key_vault_secret" "databricks_host" {
  name         = "databricks-host-url"
  key_vault_id = data.azurerm_key_vault.example.id
}

data "azurerm_key_vault_secret" "databricks_token" {
  name         = "databricks-token"
  key_vault_id = data.azurerm_key_vault.example.id
}

provider "databricks" {
  host  = data.azurerm_key_vault_secret.databricks_host.value
  token = data.azurerm_key_vault_secret.databricks_token.value
}

resource "databricks_user" "new_user" {
  count = var.user_count

  user_name               = var.user_email[count.index]
  display_name            = var.user_display_name[count.index]
  active                  = true
  allow_cluster_create    = var.allow_cluster_create[count.index]
  allow_instance_pool_create = var.allow_instance_pool_create[count.index]
}

variable "user_count" {
  description = "Number of users to create"
  type        = number
}

variable "user_display_name" {
  description = "The display name of the user to be created in Databricks"
  type        = list(string)
}

variable "user_email" {
  description = "The email address of the user to be created in Databricks"
  type        = list(string)
}

variable "allow_cluster_create" {
  description = "Whether the user is allowed to create clusters"
  type        = list(bool)
}

variable "allow_instance_pool_create" {
  description = "Whether the user is allowed to create instance pools"
  type        = list(bool)
}