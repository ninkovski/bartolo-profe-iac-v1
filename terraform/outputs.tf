output "resource_group_id" {
  description = "ID del Resource Group"
  value       = azurerm_resource_group.main.id
}

output "key_vault_id" {
  description = "ID del Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  description = "URI del Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "key_vault_name" {
  description = "Nombre del Key Vault"
  value       = azurerm_key_vault.main.name
}

output "managed_identity_id" {
  description = "ID de la Managed Identity compartida"
  value       = azurerm_user_assigned_identity.functions_identity.id
}

output "managed_identity_client_id" {
  description = "Client ID de la Managed Identity"
  value       = azurerm_user_assigned_identity.functions_identity.client_id
}

output "process_sale_function_id" {
  description = "ID de la Function ProcessSale"
  value       = azurerm_linux_function_app.process_sale.id
}

output "process_sale_default_hostname" {
  description = "Hostname de la Function ProcessSale"
  value       = azurerm_linux_function_app.process_sale.default_hostname
}

output "process_sale_function_url" {
  description = "URL de la Function ProcessSale"
  value       = "https://${azurerm_linux_function_app.process_sale.default_hostname}"
}

output "process_payment_function_id" {
  description = "ID de la Function ProcessPayment"
  value       = azurerm_linux_function_app.process_payment.id
}

output "process_payment_default_hostname" {
  description = "Hostname de la Function ProcessPayment"
  value       = azurerm_linux_function_app.process_payment.default_hostname
}

output "process_payment_function_url" {
  description = "URL de la Function ProcessPayment"
  value       = "https://${azurerm_linux_function_app.process_payment.default_hostname}"
}

output "storage_account_name" {
  description = "Nombre de la Storage Account"
  value       = azurerm_storage_account.main.name
}

output "service_plan_id" {
  description = "ID del App Service Plan"
  value       = azurerm_service_plan.main.id
}
