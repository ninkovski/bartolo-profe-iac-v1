# Managed Identity compartida para ambas Functions
resource "azurerm_user_assigned_identity" "functions_identity" {
  name                = "identity-${var.project_name}-functions"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

# Key Vault
resource "azurerm_key_vault" "main" {
  name                        = "kv-${var.project_name}-${var.environment}"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enabled_for_disk_encryption = true
  purge_protection_enabled    = false
  soft_delete_retention_days  = 7
  tags                        = var.tags
}

# Access Policy para Managed Identity
resource "azurerm_key_vault_access_policy" "functions" {
  key_vault_id       = azurerm_key_vault.main.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_user_assigned_identity.functions_identity.principal_id
  secret_permissions = ["Get", "List"]
}

# Access Policy para tu usuario (permite gestionar secrets en desarrollo)
resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id       = azurerm_key_vault.main.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = data.azurerm_client_config.current.object_id
  secret_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
}
