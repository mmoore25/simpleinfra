################### BASE INPUTS ##################
Databricks_sku              = "premium"               # Databricks SKU size, premium is needed for AAD integration
location                    = "East US"               # Databricks instance location
basename                    = "PR4706"                # basename that the databricks instance and components will be derived from
tags                        = { SupportGroup = "mmoore25@gmail.com", Environment = "Development" }



#############################################################################
# VARIABLES
#############################################################################
corenetwork_name            = "CoreNetwork"              # VNET name
corenetwork_RG              = "CoreNetwork-RG"           # VNET resource group
networksecuritygrpname      = "Databricks-PR4706-NSG"  # NSG Name where new rules for databricks 

mgmt_subnet_name            = "VIM-DBK-Public-Subnet"    # Databricks mgmt subnet (PUBLIC Subnet) provided by NetEng
cluster_subnet_name         = "VIM-DBK-Private-Subnet"   # Name of Databricks cluster subnet (PRIVATE Subnet) provided by NetEng

