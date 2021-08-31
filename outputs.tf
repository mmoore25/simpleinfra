output "Creation_date_and_time" {
  value = formatdate("YYYYMMDD  hh:mm", timestamp())
}

output "Connect_UI_URL"{
  value = azurerm_app_service.connectUI.default_site_hostname
}

output "Identity_URL"{
  value = azurerm_app_service.Identity.default_site_hostname
}

output "Core_API_URL"{
  value = azurerm_app_service.API.default_site_hostname
}

output "Pathway_URL"{
  value = azurerm_app_service.Admin.default_site_hostname
}

output "postgresql_server" {
  value = azurerm_postgresql_server.dbserver.fqdn
}