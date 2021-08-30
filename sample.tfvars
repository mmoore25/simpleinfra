################### BASE INPUTS ##################
location                    = "East US"               # All instances location
basename                    = "sample001"                # basename that the all services instance and components will be derived from
tags                        = { SupportGroup = "mmoore25@gmail.com", Environment = "Development" }



#############################################################################
# VARIABLES
#############################################################################
# corenetwork_name            = "CoreNetwork"              # VNET name
# corenetwork_RG              = "CoreNetwork-RG"           # VNET resource group
 

# frontend_subnet_name        = "${var.basename}-springpath-public-subnet"
# frontendnsg                 = "${var.basename}-Frontend-NSG"

# backend_subnet_name         = "${var.basename}-springpath-backend-subnet"   
# backendnsg                  = "${var.basename}-Backend-NSG"

# database_subnet_name        = "${var.basename}-springpath-database-subnet"   # Name of database server subnet (PRIVATE Subnet) provided by NetEng
# databasensg                 = "${var.basename}-Database-NSG"  # NSG Name where new rules for database

#############################################################################
# DATABASE VARIABLES
#############################################################################
dbserversku                 = "GP_Gen5_2"             # Database SKU size, Standard is needed for VNet integration
dbservername                = "psl-springpath"
administrator_login         = "psklqladminun"
administrator_login_password= "H@Sh1CoR3lksdw3r!"
dbname                      = "DB-springpath"

#############################################################################
# App Service Plan VARIABLES
#############################################################################
appsvcplanname              = "ASP-springpath"

#############################################################################
# Azure Key Vault VARIABLES
#############################################################################
aksname                     = "AKS-SP"

#############################################################################
# Connect UI VARIABLES
#############################################################################
connectwebappname           = "APP-springpath-connectui"

#############################################################################
# API VARIABLES
#############################################################################
apiwebappname                = "APP-springpath-core-api"

#############################################################################
# Identity VARIABLES
#############################################################################
identitywebappname           = "APP-springpath-identity"

#############################################################################
# Pathway VARIABLES
#############################################################################
adminwebappname              = "APP-springpath-pathway"

#############################################################################
# Storage account  VARIABLES
#############################################################################
storageaccountname           = "astspringpath"
storageaccounttier           = "Standard"
