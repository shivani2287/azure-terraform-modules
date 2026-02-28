output "container_app_id"          { value = azurerm_container_app.this.id }
output "container_app_fqdn"        { value = azurerm_container_app.this.ingress[0].fqdn }
output "container_app_url"         { value = "https://${azurerm_container_app.this.ingress[0].fqdn}" }
output "principal_id"              { value = azurerm_container_app.this.identity[0].principal_id; description = "Managed Identity principal ID — use to grant RBAC roles" }
output "environment_id"            { value = azurerm_container_app_environment.this.id }
