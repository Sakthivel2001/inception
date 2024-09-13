terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
    }
    google = {
      source  = "hashicorp/google"
    }
  }
}

provider "google" {
  credentials = file("C:\\Users\\nachi\\Downloads\\cedar-fragment-434517-s5-7339baf8044b.json")
  project     = "cedar-fragment-434517-s5"
  region      = "us-east1"
}

data "google_secret_manager_secret_version" "databricks_host" {
  secret  = "host"
  project = "cedar-fragment-434517-s5"
}

data "google_secret_manager_secret_version" "databricks_token" {
  secret  = "token"
  project = "cedar-fragment-434517-s5"
}

provider "databricks" {
  host  = data.google_secret_manager_secret_version.databricks_host.secret_data
  token = data.google_secret_manager_secret_version.databricks_token.secret_data
}


resource "databricks_user" "new_user" {
  count = var.user_count

  user_name = var.user_email[count.index]
  display_name = var.user_display_name[count.index]
  active = true
  allow_cluster_create = var.allow_cluster_create[count.index]
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
