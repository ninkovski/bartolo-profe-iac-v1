# Infraestructura Terraform - Bartolo Profe App

Migración de flujos n8n a Azure Functions con Terraform IaC.

## 📋 Arquitectura

```
Key Vault (Secrets gestionadas)
    ↓
Managed Identity (Identidad compartida)
    ↓
Azure Functions (2 funciones)
    ├── ProcessSale (Webhook formulario)
    └── ProcessPayment (Webhook pago)
    ↓
Storage Account (Logs y archivos)
```

## 🔑 Características Clave

✅ **Managed Identity Compartida**: Ambas Functions usan la misma identidad para acceder a Key Vault
✅ **Key Vault**: Gestión centralizada de secrets (SMTP, Airtable, Mercado Pago, Google Drive)
✅ **Azure Functions Serverless**: Consumo bajo, escalabilidad automática
✅ **Terraform IaC**: Infraestructura versionable y reproducible

## 📦 Estructura

```
terraform/
├── main.tf                 # Recursos principales (RG, Storage, App Service Plan)
├── keyvault.tf            # Key Vault + Managed Identity + Secrets
├── functions.tf           # 2 Azure Functions
├── variables.tf           # Variables de entrada
├── outputs.tf             # Salidas (URLs, IDs)
├── terraform.tfvars.example  # Ejemplo de valores (copia a terraform.tfvars)
└── .gitignore            # Archivos a ignorar en git
```

## 🚀 Requisitos

- Terraform >= 1.0
- Azure CLI configurado (`az login`)
- Acceso a suscripción de Azure
- Secrets listos: SMTP, Airtable, Mercado Pago, Google Drive

## 📝 Configuración

### 1. Crear archivo terraform.tfvars

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Edita y rellena con tus valores:
- `smtp_server` - Tu servidor SMTP (ej: smtp.gmail.com)
- `smtp_username` - Tu email
- `smtp_password` - Contraseña o app-password
- `airtable_api_key` - Token de Airtable
- `airtable_base_id` - ID de tu base (ya en código)
- `mercado_pago_token` - Token de API
- `google_service_account_key` - JSON de Google Service Account

### 2. Validar Terraform

```bash
cd terraform
terraform init
terraform validate
```

### 3. Ver plan de cambios

```bash
terraform plan
```

### 4. Desplegar

```bash
terraform apply -auto-approve
```

## 📍 Outputs

Después de desplegar, obtdrás:

- **Function URLs**:
  - ProcessSale: `https://func-bartolo-profe-app-process-sale-dev.azurewebsites.net`
  - ProcessPayment: `https://func-bartolo-profe-app-process-payment-dev.azurewebsites.net`
  
- **Key Vault URI**: Para acceder a secrets desde las Functions
- **Managed Identity ID**: Para validar permisos RBAC

## 🔐 Seguridad

### Managed Identity
- Las Functions usan identidad asignada (no keys en env vars)
- Acceso a Key Vault automático sin credenciales

### Key Vault Policies
- ✅ Soft delete habilitado (7 días)
- ✅ Acceso limitado a la Managed Identity
- ✅ Acceso de lectura solo a secrets (no eliminación)

### Secretos en Azure
- Almacenados encriptados en Key Vault
- NO aparecen en logs de Functions
- Referencias en App Settings: `@Microsoft.KeyVault(SecretUri=...)`

## 🔄 Ciclo de vida

Para **actualizar secrets**:
```bash
# Cambiar valor en terraform.tfvars
terraform apply -auto-approve
```

Para **destruir** (cuidado - elimina TODO):
```bash
terraform destroy -auto-approve
```

## 📊 Costos Estimados

| Servicio | Estimado |
|----------|----------|
| Functions (consumo bajo) | $10-20/mes |
| Key Vault | $0.6/mes |
| Storage | $0.5-1/mes |
| **Total** | **~$11-21/mes** |

(Basado en <1000 invocaciones/mes)

## 🛠️ Variables de Entorno en las Functions

Las Functions acceden a los secrets mediante:

```python
import os

smtp_server = os.getenv('KEY_VAULT_SMTP_SERVER')
airtable_key = os.getenv('KEY_VAULT_AIRTABLE_API_KEY')
# etc...
```

## 📚 Próximos Pasos

1. ✅ Desplegar Terraform
2. ⬜ Crear código de las 2 Functions
3. ⬜ Conectar webhooks (formularios, Mercado Pago)
4. ⬜ Testing e3 integración
5. ⬜ Documentar en portafolio

## 📖 Documentación Azure

- [Azure Functions](https://learn.microsoft.com/es-es/azure/azure-functions/)
- [Managed Identity](https://learn.microsoft.com/es-es/azure/active-directory/managed-identities-azure-resources/)
- [Key Vault](https://learn.microsoft.com/es-es/azure/key-vault/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/)
