# Guía Rápida: Desplegar con Key Vault vacío

## 1️⃣ Ejecutar Terraform (crea infraestructura vacía)

```powershell
cd terraform

# Inicializar
terraform init

# Validar
terraform validate

# Desplegar
terraform apply
```

Terraform creará:
- ✅ Resource Group
- ✅ Storage Account
- ✅ App Service Plan (Y1 - Consumption)
- ✅ 2 Azure Functions
- ✅ Key Vault **vacío**
- ✅ Managed Identity

---

## 2️⃣ Obtener el nombre del Key Vault

Después que Terraform termine:

```powershell
# Ver outputs
terraform output

# Copiar el nombre del Key Vault, será algo como:
# kv-bartolo-profe-app-dev-5432
```

---

## 3️⃣ Agregar secretos al Key Vault (en Azure Portal o CLI)

### Opción A: Desde Azure Portal
1. Abre Azure Portal (portal.azure.com)
2. Busca tu Key Vault (ej: `kv-bartolo-profe-app-dev-5432`)
3. En el menú izquierdo: **Secretos**
4. Click en **+ Generar/Importar**
5. Crea estos secretos:

| Nombre | Valor |
|--------|-------|
| `smtp-server` | `smtp.gmail.com` |
| `smtp-username` | `tu-email@gmail.com` |
| `smtp-password` | `tu-app-password` |
| `airtable-api-key` | `pat.....` |
| `airtable-base-id` | `appEwnUyMa7SRu54V` |
| `mercado-pago-token` | `APP_USR-.....` |
| `google-service-account-key` | `{JSON completo del Service Account}` |

### Opción B: Desde Azure CLI

```powershell
$KV_NAME = "kv-bartolo-profe-app-dev-5432"  # REEMPLAZA con tu nombre

# SMTP
az keyvault secret set --vault-name $KV_NAME --name "smtp-server" --value "smtp.gmail.com"
az keyvault secret set --vault-name $KV_NAME --name "smtp-username" --value "tu-email@gmail.com"
az keyvault secret set --vault-name $KV_NAME --name "smtp-password" --value "tu-app-password"

# Airtable
az keyvault secret set --vault-name $KV_NAME --name "airtable-api-key" --value "pat........................"
az keyvault secret set --vault-name $KV_NAME --name "airtable-base-id" --value "appEwnUyMa7SRu54V"

# Mercado Pago
az keyvault secret set --vault-name $KV_NAME --name "mercado-pago-token" --value "APP_USR-........................"

# Google Service Account (JSON en una línea)
az keyvault secret set --vault-name $KV_NAME --name "google-service-account-key" --value '{"type":"service_account","project_id":"..."}'

# Verificar
az keyvault secret list --vault-name $KV_NAME --output table
```

---

## 4️⃣ Las Functions ya están configuradas para leer del Key Vault

No necesitas cambiar nada en el código. Las Functions buscarán automáticamente:
- `@Microsoft.KeyVault(SecretUri=.../.../smtp-server/)`
- `@Microsoft.KeyVault(SecretUri=.../.../smtp-password/)`
- etc.

---

## 5️⃣ Probar las Functions

Una vez agregados los secretos:

```powershell
# Ver URLs
terraform output function_sale_url
terraform output function_payment_url

# Probar con curl (EJEMPLO):
$SALE_URL = terraform output -raw function_sale_url
curl -X POST $SALE_URL `
  -H "Content-Type: application/json" `
  -d '{
    "email": "test@example.com",
    "nombre": "Test User",
    "contenido": "recXXXXXXXXXXXX",
    "premium": "false"
  }'
```

---

## 📝 Resumen

| Paso | Qué hace |
|------|----------|
| 1️⃣ `terraform apply` | Crea infraestructura + Key Vault vacío |
| 2️⃣ `terraform output` | Obtiene nombres de recursos |
| 3️⃣ Azure Portal/CLI | Añades secretos manualmente |
| 4️⃣ Esperar 30s | Las Functions cargan los secretos |
| 5️⃣ Probar | Prueba con curl/Postman |

---

## 🔑 Nombres esperados de secretos en Key Vault

Las Functions esperan estos exactos:
```
- smtp-server
- smtp-username
- smtp-password
- airtable-api-key
- airtable-base-id
- mercado-pago-token
- google-service-account-key
```

Si pones otro nombre, las Functions no los encontrarán.

---

## ❌ Troubleshooting

### Las Functions devuelven error de secretos
→ Verifica que los secretos estén en el Key Vault con los nombres exactos

### Error "Permission Denied" al agregar secretos
→ Asegúrate de tener el Managed Identity con permisos de lectura (ya está en keyvault.tf)

### Key Vault name already exists
→ Usa el nombre que Terraform generó (con sufijo aleatorio)
