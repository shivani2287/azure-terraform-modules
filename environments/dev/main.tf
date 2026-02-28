terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = { source = "hashicorp/azurerm"; version = "~> 3.85" }
  }

  # Store state remotely (swap for your storage account)
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

locals {
  environment = "dev"
  location    = "uksouth"
  common_tags = {
    Environment = local.environment
    ManagedBy   = "Terraform"
    Owner       = "Shivani Sharma"
    Project     = "Portfolio Demo"
  }
}

# ── Resource Group ─────────────────────────────────────────────────────────
resource "azurerm_resource_group" "main" {
  name     = "rg-portfolio-${local.environment}"
  location = local.location
  tags     = local.common_tags
}

# ── Log Analytics ──────────────────────────────────────────────────────────
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-portfolio-${local.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.common_tags
}

# ── Service Bus ────────────────────────────────────────────────────────────
module "servicebus" {
  source              = "../../modules/azure-servicebus"
  name                = "portfolio"
  environment         = local.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = local.location
  sku                 = "Standard"
  tags                = local.common_tags

  topics = ["order-created", "order-status-changed"]

  subscriptions = [
    { topic = "order-created",        name = "notification-sub", max_delivery_count = 5 },
    { topic = "order-created",        name = "inventory-sub",    max_delivery_count = 5 },
    { topic = "order-status-changed", name = "audit-sub",        max_delivery_count = 10 }
  ]
}

# ── Azure SQL ──────────────────────────────────────────────────────────────
module "sql" {
  source              = "../../modules/azure-sql"
  name                = "portfolio"
  environment         = local.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = local.location
  admin_username      = var.sql_admin_username
  admin_password      = var.sql_admin_password
  aad_admin_username  = var.aad_admin_username
  aad_admin_object_id = var.aad_admin_object_id
  sku_name            = "S1"
  max_size_gb         = 10
  tags                = local.common_tags
}

# ── Container App (Order Service) ──────────────────────────────────────────
module "order_service" {
  source                     = "../../modules/azure-container-app"
  name                       = "order-service"
  environment                = local.environment
  resource_group_name        = azurerm_resource_group.main.name
  location                   = local.location
  container_image            = "${var.acr_login_server}/order-microservice:latest"
  acr_login_server           = var.acr_login_server
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  min_replicas               = 1
  max_replicas               = 5
  tags                       = local.common_tags

  env_vars = {
    ASPNETCORE_ENVIRONMENT             = "Production"
    ConnectionStrings__SqlServer       = module.sql.connection_string
  }
}

# ── Outputs ────────────────────────────────────────────────────────────────
output "order_service_url" { value = module.order_service.container_app_url }
output "sql_server_fqdn"   { value = module.sql.server_fqdn }
