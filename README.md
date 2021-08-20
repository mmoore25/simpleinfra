# simpleinfra



#############################################################################
# NETWORK 
#############################################################################
resource "azurerm_network_security_rule" "rule600" {
  resource_group_name        = var.corenetwork_RG
  network_security_group_name= var.networksecuritygrpname
  name                       = "databricks-worker-to-eventhub-${var.ritm}"
  priority                   = 600
  direction                  = "Outbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "9093"
  source_address_prefix      = "VirtualNetwork"
  destination_address_prefix = "EventHub"
}

resource "azurerm_network_security_rule" "rule001" {
  resource_group_name        = var.corenetwork_RG
  network_security_group_name= var.networksecuritygrpname
  name                       = "databricks-worker-to-worker-inbound-${var.ritm}"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "VirtualNetwork"
  destination_address_prefix = "*"
 }

resource "azurerm_network_security_rule" "rule100" {
  resource_group_name        = var.corenetwork_RG
  network_security_group_name= var.networksecuritygrpname
  name                       = "databricks-worker-to-databricks-webapp-${var.ritm}"
  priority                   = 100
  direction                  = "Outbound"
  access                     = "Allow"
  protocol                   = "TCP"
  source_port_range          = "*"
  destination_port_range     = "443"
  source_address_prefix      = "VirtualNetwork"
  destination_address_prefix = "AzureDatabricks"
}

resource "azurerm_network_security_rule" "rule200" {
  resource_group_name        = var.corenetwork_RG
  network_security_group_name= var.networksecuritygrpname
  name                       = "databricks-worker-to-sql-${var.ritm}"
  priority                   = 200
  direction                  = "Outbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "3306"
  source_address_prefix      = "VirtualNetwork"
  destination_address_prefix = "Sql"
}

resource "azurerm_network_security_rule" "rule300" {
  resource_group_name        = var.corenetwork_RG
  network_security_group_name= var.networksecuritygrpname
  name                       = "databricks-worker-to-storage-${var.ritm}"
  priority                   = 300
  direction                  = "Outbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "443"
  source_address_prefix      = "VirtualNetwork"
  destination_address_prefix = "Storage"
}

resource "azurerm_network_security_rule" "rule400" {
  resource_group_name        = var.corenetwork_RG
  network_security_group_name= var.networksecuritygrpname
  name                       = "databricks-worker-to-worker-outbound-${var.ritm}"
  priority                   = 400
  direction                  = "Outbound"
  access                     = "Allow"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_range     = "3306"
  source_address_prefix      = "VirtualNetwork"
  destination_address_prefix = "VirtualNetwork"
}



data "azurerm_virtual_network" "CoreNetwork" {
  name                = var.corenetwork_name
  resource_group_name = var.corenetwork_RG
}

data "azurerm_network_security_group" "Databricks-NSG" {
  name                = var.networksecuritygrpname
  resource_group_name = var.corenetwork_RG
}

data "azurerm_subnet" "Databricks-Public-Subnet" {
  name                  = var.mgmt_subnet_name
  resource_group_name   = var.corenetwork_RG
  virtual_network_name  = var.corenetwork_name 
}

data "azurerm_subnet" "Databricks-Private-Subnet" {
  name                  = var.cluster_subnet_name
  resource_group_name   = var.corenetwork_RG
  virtual_network_name  = var.corenetwork_name
}


resource "azurerm_subnet_network_security_group_association" "Databricks_Private_Subnet_Association" {
  subnet_id                 = data.azurerm_subnet.Databricks-Private-Subnet.id
  network_security_group_id = data.azurerm_network_security_group.Databricks-NSG.id
}

resource "azurerm_subnet_network_security_group_association" "Databricks_Public_Subnet_Association" {
  subnet_id                 = data.azurerm_subnet.Databricks-Public-Subnet.id
  network_security_group_id = data.azurerm_network_security_group.Databricks-NSG.id
}

