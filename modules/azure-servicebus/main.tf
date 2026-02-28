# ── Azure Service Bus Module ───────────────────────────────────────────────
# Creates a Service Bus namespace with configurable topics and subscriptions.

resource "azurerm_servicebus_namespace" "this" {
  name                = "sb-${var.name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  minimum_tls_version = "1.2"

  # Enable zone redundancy for prod
  zone_redundant = var.environment == "prod" ? true : false

  tags = var.tags
}

# ── Topics ─────────────────────────────────────────────────────────────────
resource "azurerm_servicebus_topic" "topics" {
  for_each = toset(var.topics)

  name                 = each.value
  namespace_id         = azurerm_servicebus_namespace.this.id
  max_size_in_megabytes = 1024
  default_message_ttl  = "P14D" # 14 days

  # Enable dead lettering
  requires_duplicate_detection          = true
  duplicate_detection_history_time_window = "PT10M"
}

# ── Subscriptions (per topic) ──────────────────────────────────────────────
resource "azurerm_servicebus_subscription" "subscriptions" {
  for_each = {
    for sub in var.subscriptions :
    "${sub.topic}-${sub.name}" => sub
  }

  name                                 = each.value.name
  topic_id                             = azurerm_servicebus_topic.topics[each.value.topic].id
  max_delivery_count                   = each.value.max_delivery_count
  dead_lettering_on_message_expiration = true
  lock_duration                        = "PT1M"
}
