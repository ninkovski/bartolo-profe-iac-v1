# ✅ Validación Pre-Despliegue

Antes de correr Terraform, verifica que TODO esté en su lugar.

---

## 📋 Checklist: Archivos Requeridos

### Carpeta: `terraform/`

- [ ] ✅ `main.tf` - Configuración de Azure (Resource Group, Storage, Plan)
- [ ] ✅ `keyvault.tf` - Key Vault vacío + Managed Identity
- [ ] ✅ `functions.tf` - Definición de 2 Azure Functions
- [ ] ✅ `variables.tf` - Variables de Terraform (no-sensibles)
- [ ] ✅ `outputs.tf` - Outputs para capturar URLs y nombres
- [ ] ✅ `terraform.tfvars` - Valores de variables
- [ ] ✅ `QUICK-START.md` - Guía rápida de despliegue
- [ ] ✅ `README.md` - Documentación técnica

### Carpeta: `terraform/scripts/`

- [ ] ✅ `deploy.ps1` - Script PowerShell para Terraform init/plan/apply
- [ ] ✅ `add-secrets.ps1` - Script para agregar secretos a Key Vault

### Carpeta: `function-process-sale/`

- [ ] ✅ `index.js` - 410+ líneas con lógica n8n homóloga
- [ ] ✅ `package.json` - Dependencias (axios, nodemailer, airtable, etc.)
- [ ] ✅ `function.json` - Configuración de trigger HTTP
- [ ] ✅ `host.json` - Configuración de runtime

### Carpeta: `function-process-payment/`

- [ ] ✅ `index.js` - Webhook handler para Mercado Pago
- [ ] ✅ `package.json` - Dependencias (airtable, nodemailer, googleapis)
- [ ] ✅ `function.json` - Trigger HTTP con ruta `webhook/{ventaid}`
- [ ] ✅ `host.json` - Configuración de runtime

### Carpeta: `el-profe-bartolo/`

- [ ] ✅ `index.html` - Landing page con botones de rutas separadas
- [ ] ✅ `fremium-form.html` - Formulario para contenido gratuito
- [ ] ✅ `premium-form.html` - Formulario para compra premium
- [ ] ✅ `success.html` - Página de éxito
- [ ] ✅ `failure.html` - Página de error
- [ ] ✅ `style.css` - Estilos

### Raíz del Proyecto

- [ ] ✅ `NEXT-STEPS.md` - Guía de 6 pasos
- [ ] ✅ `DEPLOYMENT-GUIDE.md` - Documentación de despliegue
- [ ] ✅ `entrega-contenido (1).json` - Flujo n8n de referencia
- [ ] ✅ `venta-digital (1).json` - Flujo n8n de referencia

---

## 🔍 Checklist: Validación del Código

### ProcessSale Function (index.js)

Verifica que el archivo contiene:

- [ ] ✅ Función `parseTriggers()` que extrae email, nombre, contenido, dni, premium
- [ ] ✅ Función `enviarEmailFremium()` para enviar contenido gratuito
- [ ] ✅ Función `enviarEmailCobro()` para enviar enlace de Mercado Pago
- [ ] ✅ Stages 1-4 matching n8n workflow
- [ ] ✅ Lookup en tabla `variables` para URLs de premium
- [ ] ✅ Validación de `verificado = true` para clientes premium
- [ ] ✅ Creación de registro en tabla `leads`
- [ ] ✅ Creación de registro en tabla `ventas` si es premium
- [ ] ✅ Referencias a Key Vault: `process.env.KEY_VAULT_*`

```javascript
// Verifica que contiene
const airtable = require('airtable');
const axios = require('axios');
const nodemailer = require('nodemailer');

// Y tiene estas constantes:
const AIRTABLE_BASE_ID = "appEwnUyMa7SRu54V";
const TABLES = {
  leads: "tblHJcHG0xImtad3x",
  ventas: "tblxIiu45LFrqw9Ky",
  variables: "tblR41MvFQ7hqyCPO"
};
```

### ProcessPayment Function (index.js)

Verifica que contiene:

- [ ] ✅ Endpoint POST con ruta `webhook/{ventaid}`
- [ ] ✅ Función `getVenta()` para obtener datos de venta
- [ ] ✅ Función `registrarPago()` para actualizar estado a "pagado"
- [ ] ✅ Función `sendEmailPremium()` para enviar URL de contenido
- [ ] ✅ Función `registrarEntrega()` para marcar como "entregado"
- [ ] ✅ Función `compartirDrive()` para compartir carpeta con cliente
- [ ] ✅ Validación de Mercado Pago webhook

```javascript
// Verifica que contiene
const airtable = require('airtable');
const nodemailer = require('nodemailer');
const { google } = require('googleapis');

const AIRTABLE_BASE_ID = "appEwnUyMa7SRu54V";
const TABLES = {
  ventas: "tblxIiu45LFrqw9Ky",
  contactos: "tbl7pT1jVNI7Yjp19"
};
```

### HTML Forms

#### fremium-form.html

- [ ] ✅ Campos: Correo, Nombre, Curso (selector)
- [ ] ✅ Campo oculto: `premium = false`
- [ ] ✅ Submit a ProcessSale Function
- [ ] ✅ Validación de email

#### premium-form.html

- [ ] ✅ Campos: Correo, Nombre, DNI, Curso (selector)
- [ ] ✅ Campo oculto: `premium = true`
- [ ] ✅ Submit a ProcessSale Function
- [ ] ✅ Validación de DNI

#### index.html

- [ ] ✅ Botón "Contenido gratuito" → `/fremium-form.html?contenido={id}`
- [ ] ✅ Botón "Comprar" → `/premium-form.html?contenido={id}`

---

## 🔐 Checklist: Configuración de Variables

### terraform/variables.tf

Debe contener SOLO estas variables (no-sensibles):

```hcl
variable "project_name"        # bartolo-profe-app
variable "environment"         # dev
variable "location"            # centralus
variable "resource_group_name" # rg-bartolo-profe-app-dev
variable "tags"                # map de tags
```

**NO debe contener**:
- ❌ `smtp_server`
- ❌ `smtp_username`
- ❌ `smtp_password`
- ❌ `airtable_api_key`
- ❌ `airtable_base_id`
- ❌ `mercado_pago_token`
- ❌ `google_service_account_key`

- [ ] ✅ Verificado

### terraform/terraform.tfvars

Debe contener:

```hcl
environment         = "dev"
project_name        = "bartolo-profe-app"
location            = "eastcentralusus"
resource_group_name = "rg-bartolo-profe-app-dev"
tags = { ... }
```

**NO debe contener secretos**:
- [ ] ✅ Sin contraseñas
- [ ] ✅ Sin API keys
- [ ] ✅ Sin tokens

---

## 🏗️ Checklist: Configuración de Terraform

### keyvault.tf

- [ ] ✅ Define `azurerm_key_vault` con nombre único (random_integer)
- [ ] ✅ **NO contiene** `azurerm_key_vault_secret` resources
- [ ] ✅ Define `azurerm_user_assigned_identity`
- [ ] ✅ Define access policy para Managed Identity con `secret_permissions = ["Get", "List"]`
- [ ] ✅ Define access policy para tu usuario con permisos totales
- [ ] ✅ Purge protection deshabilitada (para desarrollo)

### functions.tf

ProcessSale:

- [ ] ✅ Usa `azurerm_linux_function_app`
- [ ] ✅ Runtime: Node.js 20
- [ ] ✅ Identity: UserAssigned (referencia a Managed Identity)
- [ ] ✅ App settings incluyen: `KEY_VAULT_URL`, `KEY_VAULT_SMTP_*`, `KEY_VAULT_AIRTABLE_*`, `KEY_VAULT_MERCADO_PAGO_*`
- [ ] ✅ Referencias de Key Vault con formato: `@Microsoft.KeyVault(SecretUri=...secrets/smtp-server/)`
- [ ] ✅ CORS: `allowed_origins = ["*"]`

ProcessPayment:

- [ ] ✅ Similar a ProcessSale
- [ ] ✅ Incluye `KEY_VAULT_GOOGLE_SERVICE_ACCOUNT_KEY`

---

## 🔑 Checklist: Airtable Setup

Verifica en tu base de Airtable:

- [ ] ✅ Base ID: `appEwnUyMa7SRu54V`
- [ ] ✅ Tabla `contenidos`: ID `tbljF2fnQGYL1evT4`
- [ ] ✅ Tabla `contactos`: ID `tbl7pT1jVNI7Yjp19`
- [ ] ✅ Tabla `leads`: ID `tblHJcHG0xImtad3x`
- [ ] ✅ Tabla `ventas`: ID `tblxIiu45LFrqw9Ky`
- [ ] ✅ Tabla `variables`: ID `tblR41MvFQ7hqyCPO`
- [ ] ✅ API Key generada y lista para Key Vault

### Tabla `variables`

- [ ] ✅ Campo `nombre` = nombre del contenido (ej: "Python Básico")
- [ ] ✅ Campo `url` = URL de descarga o Google Drive
- [ ] ✅ Al menos un record por contenido premium

### Tabla `ventas`

- [ ] ✅ Campos: email, nombre, contenido_id, precio, estado
- [ ] ✅ Estados esperados: "pendiente", "pagado", "entregado"

### Tabla `leads`

- [ ] ✅ Campos: email, nombre, contenido_id, fecha_creacion

---

## 🌐 Checklist: Servicios Externos

### Mercado Pago

- [ ] ✅ Cuenta creada
- [ ] ✅ App API creada
- [ ] ✅ Access Token obtenido
- [ ] ✅ Webhook URL ready para: `https://.../api/webhook/{ventaid}`

### Google Drive + Service Account

- [ ] ✅ Google Cloud Project creado
- [ ] ✅ Google Drive API habilitada
- [ ] ✅ Service Account creado
- [ ] ✅ JSON credential descargado (listo para Key Vault)
- [ ] ✅ Carpetas creadas para contenido (una por contenido)
- [ ] ✅ Permisos: Service Account puede leer y compartir

### SMTP (Gmail)

- [ ] ✅ Gmail account listo
- [ ] ✅ 2FA habilitado
- [ ] ✅ App Password generada
- [ ] ✅ Email y contraseña listos para Key Vault

---

## 🚀 Checklist: Pre-Deploy

Antes de ejecutar `terraform apply`:

- [ ] ✅ Azure CLI instalado: `az --version`
- [ ] ✅ Terraform instalado: `terraform --version`
- [ ] ✅ Autenticado en Azure: `az login`
- [ ] ✅ Subscription correcta: `az account show`
- [ ] ✅ Archivos `.tf` validados: `terraform validate`
- [ ] ✅ Plan generado sin errores: `terraform plan`
- [ ] ✅ Todos los secretos anotados en un lugar seguro (no en Git)

---

## ✨ Resultado Esperado

Después de completar TODO:

```
✅ Infraestructura en Azure
   - Resource Group
   - Storage Account
   - App Service Plan (Y1 - Consumption)
   - 2 Azure Functions (con código deployado)
   - Key Vault (con 7 secretos)

✅ Código Desplegado
   - ProcessSale Function operativa
   - ProcessPayment Function operativa
   - HTML forms apuntando a URLs correctas

✅ Integraciones Funcionales
   - SMTP enviando emails
   - Airtable recibiendo registros
   - Mercado Pago procesando pagos
   - Google Drive compartiendo contenido

✅ End-to-End
   - Usuario completa formulario
   - Email recibido al instante
   - Flujo de pago funcional (premium)
   - Contenido compartido al pagar
```

---

**Status**: Si todas las casillas están marcadas ✅, estás **100% listo** para desplegar.

Siguiente paso: Lee `NEXT-STEPS.md` y ejecuta los 6 pasos.
