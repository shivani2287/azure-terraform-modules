variable "name"                       { type = string; description = "App name (used in resource naming)" }
variable "environment"                { type = string; description = "Environment: dev | staging | prod" }
variable "resource_group_name"        { type = string; description = "Azure Resource Group name" }
variable "location"                   { type = string; description = "Azure region (e.g. uksouth, eastus)" }
variable "container_image"            { type = string; description = "Full container image URI (e.g. myacr.azurecr.io/app:v1)" }
variable "acr_login_server"           { type = string; description = "Azure Container Registry login server URL" }
variable "log_analytics_workspace_id" { type = string; description = "Log Analytics workspace resource ID" }

variable "cpu"    { type = number; default = 0.5;   description = "CPU cores allocated (0.25 | 0.5 | 1 | 2)" }
variable "memory" { type = string; default = "1Gi";  description = "Memory allocated (e.g. 1Gi, 2Gi)" }
variable "port"   { type = number; default = 8080;   description = "Container port to expose" }

variable "min_replicas" { type = number; default = 1;  description = "Minimum number of replicas" }
variable "max_replicas" { type = number; default = 10; description = "Maximum number of replicas" }

variable "external_ingress"         { type = bool; default = true; description = "Expose app externally" }
variable "enable_http_scaling"      { type = bool; default = true; description = "Enable HTTP-based autoscaling" }
variable "http_concurrent_requests" { type = number; default = 100; description = "Concurrent requests per replica before scaling" }

variable "env_vars"        { type = map(string); default = {}; description = "Plain environment variables" }
variable "secret_env_vars" { type = map(string); default = {}; description = "Secret-backed env vars (key = env name, value = secret name)" }
variable "tags"            { type = map(string); default = {}; description = "Azure resource tags" }
