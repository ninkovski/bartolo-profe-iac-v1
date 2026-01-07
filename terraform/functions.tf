# Azure Function 1: ProcessSale
resource "azurerm_linux_function_app" "process_sale" {
  name                       = "func-${var.project_name}-process-sale-${var.environment}"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  service_plan_id            = azurerm_service_plan.main.id
  storage_account_name       = azurerm_storage_account.main.name
  storage_account_access_key = azurerm_storage_account.main.primary_access_key

  # Identidad gestionada asignada
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.functions_identity.id]
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"     = 1
    "FUNCTIONS_WORKER_RUNTIME"     = "node"
    "WEBSITE_NODE_DEFAULT_VERSION" = "20"
    "AzureWebJobsFeatureFlags"     = "EnableWorkerIndexing"

    # Variables para acceder a Key Vault
    "KEY_VAULT_URL"                = azurerm_key_vault.main.vault_uri
    "KEY_VAULT_SMTP_SERVER"        = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.main.vault_uri}secrets/smtp-server/)"
    "KEY_VAULT_SMTP_USERNAME"      = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.main.vault_uri}secrets/smtp-username/)"
    "KEY_VAULT_SMTP_PASSWORD"      = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.main.vault_uri}secrets/smtp-password/)"
    "KEY_VAULT_AIRTABLE_API_KEY"   = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.main.vault_uri}secrets/airtable-api-key/)"
    "KEY_VAULT_AIRTABLE_BASE_ID"   = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.main.vault_uri}secrets/airtable-base-id/)"
    "KEY_VAULT_MERCADO_PAGO_TOKEN" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.main.vault_uri}secrets/mercado-pago-token/)"
  }

  site_config {
    application_stack {
      node_version = "20"
    }
    cors {
      allowed_origins = ["*"]
    }
  }

  tags = merge(var.tags, {
    Function = "ProcessSale"
  })
}

# Azure Function 2: ProcessPayment
resource "azurerm_linux_function_app" "process_payment" {
  name                       = "func-${var.project_name}-process-payment-${var.environment}"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  service_plan_id            = azurerm_service_plan.main.id
  storage_account_name       = azurerm_storage_account.main.name
  storage_account_access_key = azurerm_storage_account.main.primary_access_key

  # Identidad gestionada asignada (COMPARTIDA)
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.functions_identity.id]
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"     = 1
    "FUNCTIONS_WORKER_RUNTIME"     = "node"
    "WEBSITE_NODE_DEFAULT_VERSION" = "20"
    "AzureWebJobsFeatureFlags"     = "EnableWorkerIndexing"

    # Variables para acceder a Key Vault
    "KEY_VAULT_URL"                        = azurerm_key_vault.main.vault_uri
    "KEY_VAULT_SMTP_SERVER"                = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.main.vault_uri}secrets/smtp-server/)"
    "KEY_VAULT_SMTP_USERNAME"              = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.main.vault_uri}secrets/smtp-username/)"
    "KEY_VAULT_SMTP_PASSWORD"              = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.main.vault_uri}secrets/smtp-password/)"
    "KEY_VAULT_AIRTABLE_API_KEY"           = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.main.vault_uri}secrets/airtable-api-key/)"
    "KEY_VAULT_AIRTABLE_BASE_ID"           = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.main.vault_uri}secrets/airtable-base-id/)"
    "KEY_VAULT_GOOGLE_SERVICE_ACCOUNT_KEY" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.main.vault_uri}secrets/google-service-account-key/)"
  }

  site_config {
    application_stack {
      node_version = "20"
    }
    cors {
      allowed_origins = ["*"]
    }
  }

  tags = merge(var.tags, {
    Function = "ProcessPayment"
  })
}
