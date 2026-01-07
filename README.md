# Guía de Despliegue - Bartolo Profe App en Azure

## Pre-requisitos

1. **Azure CLI instalado y autenticado**
   ```powershell
   az --version
   az login
   az account show
   ```

2. **Terraform instalado**
   ```powershell
   terraform --version
   ```

3. **Suscripción de Azure activa**
   ```powershell
   az account list --output table
   az account set --subscription "TU_SUBSCRIPTION_ID"
   ```

## Secretos necesarios antes de comenzar

Reúne los siguientes valores:

### 1. Airtable
- **AIRTABLE_API_KEY**: Token personal de Airtable (desde https://airtable.com/account)
- **AIRTABLE_BASE_ID**: `appEwnUyMa7SRu54V` (ya configurado en n8n)

### 2. Mercado Pago
- **MERCADO_PAGO_TOKEN**: Access Token de tu cuenta de Mercado Pago
  - Obtener en: https://www.mercadopago.com.pe/developers/panel/credentials

### 3. SMTP (Email)
- **SMTP_SERVER**: Servidor SMTP (ej: `smtp.gmail.com`, `smtp-mail.outlook.com`)
- **SMTP_USERNAME**: Tu email completo
- **SMTP_PASSWORD**: 
  - Para Gmail: App Password (https://myaccount.google.com/apppasswords)
  - Para Outlook: Contraseña normal o App Password

### 4. Google Drive (Service Account)
- **GOOGLE_SERVICE_ACCOUNT_KEY**: JSON completo de Service Account
  - Crear en: https://console.cloud.google.com/iam-admin/serviceaccounts
  - Habilitar Google Drive API
  - Crear Key tipo JSON

## Paso 1: Configurar variables de Terraform

Crea el archivo `terraform/environments/dev.tfvars`:

```hcl
# terraform/environments/dev.tfvars
environment         = "dev"
project_name        = "bartolo-profe"
location            = "eastus"
resource_group_name = "rg-bartolo-profe-dev"

# Secrets - REEMPLAZAR CON TUS VALORES
smtp_server              = "smtp.gmail.com"
smtp_username            = "tu-email@gmail.com"
smtp_password            = "tu-app-password-aqui"
airtable_api_key         = "pat......."
airtable_base_id         = "appEwnUyMa7SRu54V"
mercado_pago_token       = "APP_USR-....."
google_service_account   = "{\"type\":\"service_account\",\"project_id\":\"...\"}"

tags = {
  Environment = "Development"
  Project     = "Bartolo Profe"
  ManagedBy   = "Terraform"
}
```

## Paso 2: Inicializar Terraform

```powershell
cd terraform
terraform init
```

Esto descargará los providers necesarios (azurerm).

## Paso 3: Validar configuración

```powershell
terraform validate
```

## Paso 4: Plan de ejecución (preview)

```powershell
terraform plan -var-file="environments/dev.tfvars" -out=tfplan
```

Esto mostrará todos los recursos que se crearán:
- 1 Resource Group
- 1 Storage Account
- 1 App Service Plan (Consumption Y1)
- 2 Function Apps (ProcessSale, ProcessPayment)
- 1 Key Vault
- 1 Managed Identity
- Secrets en Key Vault

## Paso 5: Aplicar infraestructura

```powershell
terraform apply tfplan
```

Confirma con `yes` cuando se solicite.

⏱️ **Tiempo estimado**: 3-5 minutos

## Paso 6: Verificar recursos creados

```powershell
# Ver outputs
terraform output

# Listar recursos en Azure
az resource list --resource-group rg-bartolo-profe-dev --output table
```

Deberías ver:
- ✅ Key Vault: `kv-bartolo-profe-dev-XXXXX`
- ✅ Storage Account: `stbartoloprofedev`
- ✅ App Service Plan: `asp-bartolo-profe-dev`
- ✅ Function App 1: `func-bartolo-profe-sale-dev`
- ✅ Function App 2: `func-bartolo-profe-payment-dev`
- ✅ Managed Identity: `id-bartolo-profe-dev`

## Paso 7: Verificar secretos en Key Vault

```powershell
# Obtener nombre del Key Vault
$KV_NAME = terraform output -raw keyvault_name

# Listar secretos
az keyvault secret list --vault-name $KV_NAME --output table

# Ver un secreto (ejemplo)
az keyvault secret show --vault-name $KV_NAME --name airtable-api-key --query value -o tsv
```

## Paso 8: Obtener URLs de las Functions

```powershell
# Function ProcessSale
terraform output function_sale_url

# Function ProcessPayment  
terraform output function_payment_url
```

Guarda estas URLs, las necesitarás para:
- Configurar los formularios HTML
- Configurar Mercado Pago webhook

## Siguiente paso

Una vez confirmado que la infraestructura está creada, procederemos a:
1. Desplegar el código de las Functions
2. Probar las Functions con curl/Postman
3. Actualizar los formularios HTML con las URLs reales

---

## Comandos útiles

### Ver logs de una Function
```powershell
az functionapp log tail --name func-bartolo-profe-sale-dev --resource-group rg-bartolo-profe-dev
```

### Reiniciar una Function
```powershell
az functionapp restart --name func-bartolo-profe-sale-dev --resource-group rg-bartolo-profe-dev
```

### Destruir todo (cleanup)
```powershell
terraform destroy -var-file="environments/dev.tfvars"
```

---

## CI/CD con GitHub Actions (Estandarizado)

- Workflows añadidos:
  - `.github/workflows/terraform-fmt.yml`: Formatea Terraform y auto-commitea en push.
  - `.github/workflows/terraform.yml`: 
    - Valida/planifica en cualquier rama (incluye `feature/*`).
    - Aplica automáticamente en `develop` (ambiente dev).
    - En `main`, despliegue manual vía “Run workflow” (`workflow_dispatch`).
  - `.github/workflows/release-tag-notify.yml`: Genera tags `RC_YYYYMMDD-HH` en `main`/`develop`.

- Requisitos de secrets (Settings → Secrets and variables → Actions):
  - `AZURE_CREDENTIALS` (JSON):
    ```json
    {"clientId":"<guid>","clientSecret":"<secret>","tenantId":"<guid>","subscriptionId":"<guid>"}
    ```
  - Opcionales para backend remoto (con defaults): `TF_BACKEND_RG`, `TF_BACKEND_STORAGE_ACCOUNT`, `TF_BACKEND_CONTAINER`, `TF_BACKEND_KEY`.
  - Opcional: `TF_VAR_LOCATION` (por defecto `eastus`).

- Backend remoto:
  - El workflow crea/usa `tfstate-rg`/`iaccoretfstate`/`tfstate` y fija la clave por repo y entorno.

- Entornos mapeados:
  - `develop` → `TF_VAR_environment=dev` (auto-apply)
  - `main` → `TF_VAR_environment=prod` (manual apply)

Nota: Se añadió `key_vault_name` a `terraform/outputs.tf` para facilitar integraciones posteriores (p.ej., sincronización de secretos).

## Troubleshooting

### Error: Key Vault name already exists
El nombre del Key Vault debe ser único globalmente. Si falla, Terraform regenerará uno automático.

### Error: Insufficient permissions
Asegúrate de tener permisos de Contributor en la suscripción:
```powershell
az role assignment list --assignee $(az account show --query user.name -o tsv) --output table
```

### Error: Provider registration
Si faltan providers, regístralos:
```powershell
az provider register --namespace Microsoft.KeyVault
az provider register --namespace Microsoft.Web
az provider register --namespace Microsoft.Storage
```
