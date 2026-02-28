variable "name"                { type = string }
variable "environment"         { type = string }
variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "sku"                 { type = string; default = "Standard"; description = "Basic | Standard | Premium" }
variable "tags"                { type = map(string); default = {} }

variable "topics" {
  type        = list(string)
  description = "List of topic names to create"
  default     = []
}

variable "subscriptions" {
  type = list(object({
    topic              = string
    name               = string
    max_delivery_count = number
  }))
  description = "List of subscriptions to create per topic"
  default     = []
}

output "namespace_id"          { value = azurerm_servicebus_namespace.this.id }
output "primary_connection_string" {
  value     = azurerm_servicebus_namespace.this.default_primary_connection_string
  sensitive = true
}
output "topic_ids" {
  value = { for k, v in azurerm_servicebus_topic.topics : k => v.id }
}
