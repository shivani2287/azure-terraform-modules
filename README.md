# 🏗️ Terraform Azure Modules

Production-grade **Terraform modules** for deploying a complete microservices infrastructure on Azure — including Container Apps, Service Bus, SQL Database, Storage, and Event Grid.

## 📐 Infrastructure Diagram

```
                          ┌─────────────────────────────────┐
                          │         Resource Group          │
                          │                                 │
  ┌───────────┐           │  ┌─────────────────────────┐   │
  │  GitHub   │──CI/CD───▶│  │   Container Apps Env    │   │
  │  Actions  │           │  │  ┌────────┐ ┌────────┐  │   │
  └───────────┘           │  │  │ Order  │ │  Auth  │  │   │
                          │  │  │  API   │ │  API   │  │   │
  ┌───────────┐           │  │  └───┬────┘ └────────┘  │   │
  │ Terraform │──deploy──▶│  └─────│───────────────────┘   │
  │   Cloud   │           │        │                        │
  └───────────┘           │  ┌─────▼──────┐  ┌──────────┐  │
                          │  │Service Bus │  │Event Grid│  │
                          │  └─────┬──────┘  └──────────┘  │
                          │        │                        │
                          │  ┌─────▼──────┐  ┌──────────┐  │
                          │  │ Azure SQL  │  │  Blob    │  │
                          │  │  Database  │  │ Storage  │  │
                          │  └────────────┘  └──────────┘  │
                          └─────────────────────────────────┘
```

## 📁 Module Structure

```
modules/
├── azure-container-app/   # Container Apps + Environment
├── azure-servicebus/      # Service Bus namespace + topics
└── azure-sql/             # SQL Server + Database

environments/
├── dev/                   # Dev environment config
└── prod/                  # Prod environment config
```

## 🚀 Quick Start

```bash
# Prerequisites: Azure CLI + Terraform >= 1.6

az login
cd environments/dev
terraform init
terraform plan
terraform apply
```

## 🔧 Module Usage

```hcl
module "container_app" {
  source              = "../../modules/azure-container-app"
  name                = "order-service"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  container_image     = "myacr.azurecr.io/order-service:latest"
  min_replicas        = 1
  max_replicas        = 10
  env_vars = {
    ASPNETCORE_ENVIRONMENT = "Production"
  }
}
```

## 👩‍💻 Author

**Shivani Sharma** — Technical Architect (Azure / .NET)
- Email: shivanish.net@gmail.com

---
*Part of my cloud architecture portfolio.*
*[order-microservice](https://github.com/yourusername/order-microservice) · [azure-functions-starter](https://github.com/yourusername/azure-functions-starter)*
