#############################################################################
# PROVIDERS
#############################################################################
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.72.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}


#############################################################################
# Resource group creation
#############################################################################
resource "azurerm_resource_group" "mainrg" {
  name     = "mainrg"
  location = var.location
  tags     = var.tags
}

#############################################################################
# Diagnostic Storage Account
#############################################################################
resource "azurerm_storage_account" "diagstorage" {
  name                     = "springpathdiagstor001"
  resource_group_name      = azurerm_resource_group.mainrg.name
  location                 = azurerm_resource_group.mainrg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}

#############################################################################
# Create the App Service Plan
#############################################################################
resource "azurerm_app_service_plan" "main-asp" {
  name                = "plan-springpathnet-live-${azurerm_resource_group.mainrg.location}"
  location            = azurerm_resource_group.mainrg.location
  resource_group_name = azurerm_resource_group.mainrg.name
  kind = "Windows"
  sku {
    tier = "Standard"
    size = "S1"
  }
  
  tags = var.tags
}


#############################################################################
# Create the Connect Web App
#############################################################################
resource "azurerm_app_service" "connectUI" {
  name                = "app-springpathnet-connect-${azurerm_resource_group.mainrg.location}"
  location            = azurerm_resource_group.mainrg.location
  resource_group_name = azurerm_resource_group.mainrg.name
  app_service_plan_id = azurerm_app_service_plan.main-asp.id

  site_config {
    dotnet_framework_version = "v5.0"
    always_on = true
  }

  tags = var.tags
} 


#############################################################################
# Create the API Web App
#############################################################################
resource "azurerm_app_service" "API" {
  name                = "app-springpathnet-core-api-${azurerm_resource_group.mainrg.location}"
  location            = azurerm_resource_group.mainrg.location
  resource_group_name = azurerm_resource_group.mainrg.name
  app_service_plan_id = azurerm_app_service_plan.main-asp.id

  site_config {
    dotnet_framework_version = "v5.0"
    always_on = true
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
  
  tags = var.tags
} 

resource "azurerm_application_insights" "apiInsights" {
  name                = "app-springpathnet-core-api-${azurerm_resource_group.mainrg.location}"
  location            = azurerm_resource_group.mainrg.location
  resource_group_name = azurerm_resource_group.mainrg.name
  application_type    = "web"
  
  tags = var.tags
}

#############################################################################
# Create the Identity Web App
#############################################################################
resource "azurerm_app_service" "Identity" {
  name                = "app-springpathnet-identity-${azurerm_resource_group.mainrg.location}"
  location            = azurerm_resource_group.mainrg.location
  resource_group_name = azurerm_resource_group.mainrg.name
  app_service_plan_id = azurerm_app_service_plan.main-asp.id
  depends_on          = [ azurerm_postgresql_server.dbserver.Id, azurerm_postgresql_database.db.Id  ]

  site_config {
    dotnet_framework_version = "v5.0"
    always_on = true
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
  
  tags = var.tags
} 


#############################################################################
# add the Postgresql server
#############################################################################
resource "azurerm_postgresql_server" "dbserver" {
  name                = "demopgsql2354"
  location            = azurerm_resource_group.mainrg.location
  resource_group_name = azurerm_resource_group.mainrg.name

  sku_name = "GP_Gen5_2"

  storage_mb                   = 51200
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = "psqladminun"
  administrator_login_password = "H@Sh1CoR3!"
  version                      = "11"
  ssl_enforcement_enabled      = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
  
   tags = var.tags
}


#############################################################################
# Add the database on the Server
#############################################################################
resource "azurerm_postgresql_database" "db" {
  name                = "envdb"
  resource_group_name = azurerm_resource_group.mainrg.name
  server_name         = azurerm_postgresql_server.dbserver.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
  
  tags = var.tags
}
