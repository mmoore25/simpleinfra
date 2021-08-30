output "postgresql_server" {
  value = azurerm_postgresql_server.dbserver.fqdn
}



# output "timestamp" {
#   value = formatdate("YYYYMMDD", timestamp())
# }

output "Connect_UI_URL"{
  value = azurerm_dns_cname_record.connectui_DNS.fqdn
}

output "Identity_URL"{
  value = azurerm_dns_cname_record.identity_DNS.fqdn
}

output "Core_API_URL"{
  value = azurerm_dns_cname_record.coreapi_DNS.fqdn
}

output "Pathway_URL"{
  value = azurerm_dns_cname_record.admin_DNS.fqdn
}