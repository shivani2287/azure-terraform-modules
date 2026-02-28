# ── Azure SQL Module ───────────────────────────────────────────────────────
# Creates an Azure SQL Server + Database with security best practices.

resource "azurerm_mssql_server" "this" {
  name                          = "sql-${var.name}-${var.environment}"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "12.0"
  administrator_login           = var.admin_username
  administrator_login_password  = var.admin_password
  minimum_tls_version           = "1.2"

  # Disable public network access in prod
  public_network_access_enabled = var.environment != "prod"

  azuread_administrator {
    login_username = var.aad_admin_username
    object_id      = var.aad_admin_object_id
  }

  tags = var.tags
}

resource "azurerm_mssql_database" "this" {
  name         = "sqldb-${var.name}-${var.environment}"
  server_id    = azurerm_mssql_server.this.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  sku_name     = var.sku_name
  max_size_gb  = var.max_size_gb

  # Enable short-term backup retention
  short_term_retention_policy {
    retention_days           = var.environment == "prod" ? 35 : 7
    backup_interval_in_hours = 12
  }

  tags = var.tags
}

# Firewall rule — allow Azure services (for Container Apps)
resource "azurerm_mssql_firewall_rule" "azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

output "server_fqdn"    { value = azurerm_mssql_server.this.fully_qualified_domain_name }
output "database_name"  { value = azurerm_mssql_database.this.name }
output "server_id"      { value = azurerm_mssql_server.this.id }
output "connection_string" {
  value     = "Server=${azurerm_mssql_server.this.fully_qualified_domain_name};Database=${azurerm_mssql_database.this.name};Authentication=Active Directory Default;"
  sensitive = false
}
