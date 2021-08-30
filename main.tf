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
  name     = "RG-${var.basename}"
  location = var.location
  tags     = var.tags
}

#############################################################################
# Azure Key vault creation
#############################################################################

data "azurerm_client_config" "current" {}



resource "azurerm_key_vault" "akv" {
  name                        = "${var.aksname}-${var.basename}"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.mainrg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

#############################################################################
# Diagnostic Storage Account
#############################################################################
resource "azurerm_storage_account" "diagstorage" {
  name                     = "${var.storageaccountname}${var.basename}"
  resource_group_name      = azurerm_resource_group.mainrg.name
  location                 = azurerm_resource_group.mainrg.location
  account_tier             = var.storageaccounttier
  account_replication_type = "LRS"

  tags = var.tags
}

#############################################################################
# Create the App Service Plan
#############################################################################
resource "azurerm_app_service_plan" "main-asp" {
  name                = "${var.appsvcplanname}-${var.basename}"
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
  name                = "${var.connectwebappname}-${var.basename}"
  location            = azurerm_resource_group.mainrg.location
  resource_group_name = azurerm_resource_group.mainrg.name
  app_service_plan_id = azurerm_app_service_plan.main-asp.id

  
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.connectuiInsights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.connectuiInsights.connection_string
  }


  site_config {
    dotnet_framework_version = "v5.0"
    always_on = true
  }

  tags = var.tags
} 

resource "azurerm_application_insights" "connectuiInsights" {
  name                = "${var.connectwebappname}-${var.basename}"
  location            = azurerm_resource_group.mainrg.location
  resource_group_name = azurerm_resource_group.mainrg.name
  application_type    = "web"
  
  tags = var.tags
}

#############################################################################
# Create the API Web App
#############################################################################
resource "azurerm_app_service" "API" {
  name                = "${var.apiwebappname}-${var.basename}"
  location            = azurerm_resource_group.mainrg.location
  resource_group_name = azurerm_resource_group.mainrg.name
  app_service_plan_id = azurerm_app_service_plan.main-asp.id

  site_config {
    dotnet_framework_version = "v5.0"
    always_on = true
  }


  identity {
    type = "SystemAssigned"
  }
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.apiInsights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.apiInsights.connection_string
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }  
  
  tags = var.tags
} 

resource "azurerm_application_insights" "apiInsights" {
  name                = "${var.apiwebappname}-${var.basename}"
  location            = azurerm_resource_group.mainrg.location
  resource_group_name = azurerm_resource_group.mainrg.name
  application_type    = "web"
  
  tags = var.tags
}


#############################################################################
# Create the Identity Web App
#############################################################################
resource "azurerm_app_service" "Identity" {
  name                = "${var.identitywebappname}-${var.basename}"
  location            = azurerm_resource_group.mainrg.location
  resource_group_name = azurerm_resource_group.mainrg.name
  app_service_plan_id = azurerm_app_service_plan.main-asp.id
  depends_on          = [ azurerm_postgresql_database.db ]

  identity {
    type = "SystemAssigned"
  }

  site_config {
    dotnet_framework_version = "v5.0"
    always_on = true
  }

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.identityapiInsights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.identityapiInsights.connection_string
  }
 

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
  
  tags = var.tags
} 
resource "azurerm_application_insights" "identityapiInsights" {
  name                = "${var.identitywebappname}-${var.basename}"
  location            = azurerm_resource_group.mainrg.location
  resource_group_name = azurerm_resource_group.mainrg.name
  application_type    = "web"
  
  tags = var.tags
}

#############################################################################
# Create the Admin Web App  -- comment out if not needed
#############################################################################
resource "azurerm_app_service" "Admin" {
  name                = "${var.adminwebappname}-${var.basename}"
  location            = azurerm_resource_group.mainrg.location
  resource_group_name = azurerm_resource_group.mainrg.name
  app_service_plan_id = azurerm_app_service_plan.main-asp.id

  site_config {
    dotnet_framework_version = "v5.0"
    always_on = true
  }


  identity {
    type = "SystemAssigned"
  }
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.apiInsights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.apiInsights.connection_string
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }  
  
  tags = var.tags
} 

resource "azurerm_application_insights" "apiInsights" {
  name                = "${var.adminwebappname}-${var.basename}"
  location            = azurerm_resource_group.mainrg.location
  resource_group_name = azurerm_resource_group.mainrg.name
  application_type    = "web"
  
  tags = var.tags
}




#############################################################################
# add the Postgresql server
#############################################################################
resource "azurerm_postgresql_server" "dbserver" {
  name                = "${var.dbservername}-${var.basename}"
  location            = azurerm_resource_group.mainrg.location
  resource_group_name = azurerm_resource_group.mainrg.name

  sku_name = "GP_Gen5_2"

  storage_mb                   = 51200
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password
  version                      = "11"
  public_network_access_enabled= true
  ssl_enforcement_enabled      = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
  
   tags = var.tags
}


#############################################################################
# Add the database on the Server
#############################################################################
resource "azurerm_postgresql_database" "db" {
  name                = "${var.dbname}"
  resource_group_name = azurerm_resource_group.mainrg.name
  server_name         = azurerm_postgresql_server.dbserver.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}
