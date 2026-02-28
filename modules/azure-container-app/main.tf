# ── Azure Container App Module ─────────────────────────────────────────────
# Deploys a Container App within a Container Apps Environment.
# Supports autoscaling, managed identity, and custom env vars.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85"
    }
  }
}

# ── Container Apps Environment ─────────────────────────────────────────────
resource "azurerm_container_app_environment" "this" {
  name                       = "cae-${var.name}-${var.environment}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = var.log_analytics_workspace_id

  tags = var.tags
}

# ── Container App ──────────────────────────────────────────────────────────
resource "azurerm_container_app" "this" {
  name                         = "ca-${var.name}-${var.environment}"
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  # Managed Identity — use this for Key Vault, ACR, SQL access (no secrets!)
  identity {
    type = "SystemAssigned"
  }

  # Container Registry authentication via managed identity
  registry {
    server   = var.acr_login_server
    identity = "System"
  }

  template {
    container {
      name   = var.name
      image  = var.container_image
      cpu    = var.cpu
      memory = var.memory

      # Environment variables from map
      dynamic "env" {
        for_each = var.env_vars
        content {
          name  = env.key
          value = env.value
        }
      }

      # Secrets injected as env vars (from Key Vault references)
      dynamic "env" {
        for_each = var.secret_env_vars
        content {
          name        = env.key
          secret_name = env.value
        }
      }

      # Liveness probe
      liveness_probe {
        path      = "/health"
        port      = var.port
        transport = "HTTP"
        initial_delay          = 10
        interval_seconds       = 30
        failure_count_threshold = 3
      }
    }

    # HTTP autoscaling rule
    dynamic "http_scale_rule" {
      for_each = var.enable_http_scaling ? [1] : []
      content {
        name                = "http-scaling"
        concurrent_requests = var.http_concurrent_requests
      }
    }

    min_replicas = var.min_replicas
    max_replicas = var.max_replicas
  }

  ingress {
    external_enabled = var.external_ingress
    target_port      = var.port
    transport        = "http"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  tags = var.tags
}
