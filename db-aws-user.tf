terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
    #   version = "1.12.0"  # You can specify the version you need
    }
  }
}

provider "aws" {
  region = "us-east-1"  # Specify your AWS region
}

# Retrieve secrets from AWS Secrets Manager
data "aws_secretsmanager_secret" "databricks_credentials" {
  arn = "arn:aws:secretsmanager:us-east-1:474227982336:secret:Databricks_Credentials-Ty2Bp8"
}

data "aws_secretsmanager_secret_version" "databricks_credentials_version" {
  secret_id = data.aws_secretsmanager_secret.databricks_credentials.id
}

locals {
  secrets = jsondecode(data.aws_secretsmanager_secret_version.databricks_credentials_version.secret_string)
}

provider "databricks" {
  host  = local.secrets["databricks_host"]
  token = local.secrets["databricks_token"]
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

