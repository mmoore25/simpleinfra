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
# User System Assigned Identity
#############################################################################
locals {
  timestamp = "${timestamp()}"
  timestamp_sanitized = "${replace("${local.timestamp}", "/[-| |T|Z|:]/", "")}"

}

resource "azurerm_user_assigned_identity" "uai" {
  resource_group_name = azurerm_resource_group.mainrg.name
  location            = azurerm_resource_group.mainrg.location

  name = "MID-springpath-${var.basename}"
  tags = var.tags
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
    tier = var.tier
    size = var.size
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
    type = "UserAssigned"
    identity_ids = [ azurerm_user_assigned_identity.uai.id ]
  }

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.apiInsights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.apiInsights.connection_string
  }

  connection_string {
    name  = "Database"
    type  = "PostgreSQL"
    value = "Database=${var.dbname}; Port=5432; Data Source=${azurerm_postgresql_server.dbserver.fqdn}; User Id=${var.administrator_login}@${azurerm_postgresql_server.dbserver.name}; Password=${var.administrator_login_password}"
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
    type = "UserAssigned"
    identity_ids = [ azurerm_user_assigned_identity.uai.id ]
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
    type  = "PostgreSQL"
    value = "Database=${var.dbname}; Port=5432; Data Source=${azurerm_postgresql_server.dbserver.fqdn}; User Id=${var.administrator_login}@${azurerm_postgresql_server.dbserver.name}; Password=${var.administrator_login_password}"
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
    type = "UserAssigned"
    identity_ids = [ azurerm_user_assigned_identity.uai.id ]
  }
  
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.adminInsights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.adminInsights.connection_string
  }

  connection_string {
    name  = "Database"
    type  = "PostgreSQL"
    value = "Database=${var.dbname}; Port=5432; Data Source=${azurerm_postgresql_server.dbserver.fqdn}; User Id=${var.administrator_login}@${azurerm_postgresql_server.dbserver.name}; Password=${var.administrator_login_password}"
  }   
  
  tags = var.tags
} 

resource "azurerm_application_insights" "adminInsights" {
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



#############################################################################
# Get the DNS Zone record
#############################################################################

# commented out until Azure bug for Custom Domain binding App Service can be resolved

# data "azurerm_resource_group" "dnszonerg" {
#   name = var.dnszonergname
# }

# data "azurerm_dns_zone" "dnszone" {
#   name                = var.dnszonename
#   resource_group_name = data.azurerm_resource_group.dnszonerg.name
# }


#############################################################################
# create the CNAME record for each app service
#############################################################################

# commented out until Azure bug for Custom Domain binding App Service can be resolved

# resource "azurerm_dns_cname_record" "connectui_DNS" {
#   name                = "${var.basename}-connect"
#   zone_name           = data.azurerm_dns_zone.dnszone.name
#   resource_group_name = data.azurerm_resource_group.dnszonerg.name
#   ttl                 = 300
#   record              = azurerm_app_service.connectUI.default_site_hostname
# }

# resource "azurerm_dns_txt_record" "connectui_txt" {
#   name                = "asuid.${var.basename}-connect"
#   zone_name           = data.azurerm_dns_zone.dnszone.name
#   resource_group_name = data.azurerm_resource_group.dnszonerg.name
#   ttl                 = 300

#   record {
#     value = azurerm_app_service.connectUI.custom_domain_verification_id
#   }
# }

# resource "azurerm_dns_cname_record" "coreapi_DNS" {
#   name                = "${var.basename}-coreapi"
#   zone_name           = data.azurerm_dns_zone.dnszone.name
#   resource_group_name = data.azurerm_resource_group.dnszonerg.name
#   ttl                 = 300
#   record              = azurerm_app_service.API.default_site_hostname
# }

# resource "azurerm_dns_txt_record" "coreapi_txt" {
#   name                = "asuid.${var.basename}-coreapi"
#   zone_name           = data.azurerm_dns_zone.dnszone.name
#   resource_group_name = data.azurerm_resource_group.dnszonerg.name
#   ttl                 = 300

#   record {
#     value = azurerm_app_service.API.custom_domain_verification_id
#   }
# }
# resource "azurerm_dns_cname_record" "identity_DNS" {
#   name                = "${var.basename}-identity"
#   zone_name           = data.azurerm_dns_zone.dnszone.name
#   resource_group_name = data.azurerm_resource_group.dnszonerg.name
#   ttl                 = 300
#   record              = azurerm_app_service.Identity.default_site_hostname
# }

# resource "azurerm_dns_txt_record" "identity_txt" {
#   name                = "asuid.${var.basename}-identity"
#   zone_name           = data.azurerm_dns_zone.dnszone.name
#   resource_group_name = data.azurerm_resource_group.dnszonerg.name
#   ttl                 = 300

#   record {
#     value = azurerm_app_service.Identity.custom_domain_verification_id
#   }
# }


# resource "azurerm_dns_cname_record" "admin_DNS" {
#   name                = "${var.basename}-pathway"
#   zone_name           = data.azurerm_dns_zone.dnszone.name
#   resource_group_name = data.azurerm_resource_group.dnszonerg.name
#   ttl                 = 300
#   record              = azurerm_app_service.Admin.default_site_hostname  
# }

# resource "azurerm_dns_txt_record" "admin_txt" {
#   name                = "asuid.${var.basename}-pathway"
#   zone_name           = data.azurerm_dns_zone.dnszone.name
#   resource_group_name = data.azurerm_resource_group.dnszonerg.name
#   ttl                 = 300

#   record {
#     value = azurerm_app_service.Admin.custom_domain_verification_id
#   }
# }