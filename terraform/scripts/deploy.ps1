# Script para desplegar Terraform y agregar secretos
# Ejecutar en: Azure Cloud Shell (PowerShell)

param(
    [Parameter(Mandatory=$false)]
    [string]$Action = "plan",
    [Parameter(Mandatory=$false)]
    [string]$Environment = "dev"
)

# Variables
$RESOURCE_GROUP = "rg-bartolo-profe-app-dev"
$LOCATION = "eastus"
$PROJECT_NAME = "bartolo-profe-app"

Write-Host "=== Bartolo Profe App - Terraform Deployment ===" -ForegroundColor Cyan
Write-Host "Acción: $Action" -ForegroundColor Green
Write-Host "Environment: $Environment" -ForegroundColor Green

# Verificar Azure CLI
try {
    $account = az account show --output none
    Write-Host "✅ Autenticado en Azure" -ForegroundColor Green
} catch {
    Write-Host "❌ No autenticado en Azure. Ejecuta: az login" -ForegroundColor Red
    exit 1
}

# Verificar Terraform
try {
    terraform --version | out-null
    Write-Host "✅ Terraform instalado" -ForegroundColor Green
} catch {
    Write-Host "❌ Terraform no instalado" -ForegroundColor Red
    exit 1
}

# Crear Resource Group si no existe
Write-Host "`n=== Verificando Resource Group ===" -ForegroundColor Cyan
$rgExists = az group exists --name $RESOURCE_GROUP | ConvertFrom-Json
if (-not $rgExists) {
    Write-Host "Creando Resource Group: $RESOURCE_GROUP" -ForegroundColor Yellow
    az group create --name $RESOURCE_GROUP --location $LOCATION
} else {
    Write-Host "✅ Resource Group ya existe: $RESOURCE_GROUP" -ForegroundColor Green
}

# Ir a carpeta terraform
$TERRAFORM_DIR = "./terraform"
if (-not (Test-Path $TERRAFORM_DIR)) {
    Write-Host "❌ Carpeta terraform no encontrada" -ForegroundColor Red
    exit 1
}

Push-Location $TERRAFORM_DIR

try {
    switch ($Action) {
        "init" {
            Write-Host "`n=== Inicializando Terraform ===" -ForegroundColor Cyan
            terraform init
            Write-Host "✅ Terraform inicializado" -ForegroundColor Green
        }
        
        "plan" {
            Write-Host "`n=== Plan de ejecución ===" -ForegroundColor Cyan
            terraform plan -out=tfplan
            Write-Host "`n✅ Plan guardado en: tfplan" -ForegroundColor Green
        }
        
        "apply" {
            Write-Host "`n=== Aplicando configuración ===" -ForegroundColor Cyan
            if (Test-Path "tfplan") {
                terraform apply tfplan
            } else {
                Write-Host "Creando nuevo plan..." -ForegroundColor Yellow
                terraform plan -out=tfplan
                terraform apply tfplan
            }
            Write-Host "`n✅ Infraestructura desplegada" -ForegroundColor Green
            
            # Obtener outputs
            Write-Host "`n=== Outputs ===" -ForegroundColor Cyan
            terraform output
            
            # Obtener nombre del Key Vault
            $KV_NAME = terraform output -raw keyvault_name
            Write-Host "`n=== Key Vault Creado ===" -ForegroundColor Cyan
            Write-Host "Nombre: $KV_NAME" -ForegroundColor Yellow
            Write-Host "URL: https://portal.azure.com/#resource/subscriptions/$(az account show -q id)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KV_NAME" -ForegroundColor Cyan
        }
        
        "destroy" {
            Write-Host "`n=== DESTRUYENDO INFRAESTRUCTURA ===" -ForegroundColor Red
            $confirm = Read-Host "¿Estás seguro? (s/n)"
            if ($confirm -eq "s") {
                terraform destroy -auto-approve
                Write-Host "✅ Infraestructura destruida" -ForegroundColor Green
            } else {
                Write-Host "Cancelado" -ForegroundColor Yellow
            }
        }
        
        "output" {
            Write-Host "`n=== Outputs ===" -ForegroundColor Cyan
            terraform output
        }
        
        default {
            Write-Host "Acciones disponibles:" -ForegroundColor Yellow
            Write-Host "  init     - Inicializar Terraform"
            Write-Host "  plan     - Ver cambios que se harán"
            Write-Host "  apply    - Desplegar infraestructura"
            Write-Host "  destroy  - Eliminar infraestructura"
            Write-Host "  output   - Ver outputs"
            Write-Host ""
            Write-Host "Uso: .\deploy.ps1 -Action init" -ForegroundColor Cyan
        }
    }
} finally {
    Pop-Location
}

Write-Host "`n=== Completado ===" -ForegroundColor Green
