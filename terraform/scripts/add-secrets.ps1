## Script para agregar secretos al Key Vault
## Uso: .\add-secrets.ps1 -KeyVaultName kv-bartolo-profe-app-dev

param(
    [Parameter(Mandatory=$true)]
    [string]$KeyVaultName
)

Write-Host "=== Agregar Secretos al Key Vault ===" -ForegroundColor Cyan

# Validar existencia de Key Vault
$vaultInfo = az keyvault show --name $KeyVaultName 2>$null
if ($null -eq $vaultInfo) {
    Write-Host "❌ Key Vault no encontrado: $KeyVaultName" -ForegroundColor Red
    Write-Host "Asegúrate de que Terraform ya creó el vault." -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Key Vault: $KeyVaultName" -ForegroundColor Green

# Lista de secretos requeridos (sin valores por defecto)
$secretNames = @(
    "smtp-server",
    "smtp-username",
    "smtp-password",
    "airtable-api-key",
    "airtable-base-id",
    "mercado-pago-token",
    "google-service-account-key"
)

Write-Host "`nModo interactivo - ingresa los valores (Enter para saltar cada uno):" -ForegroundColor Yellow

$secretsToSet = @{}
foreach ($name in $secretNames) {
    $value = Read-Host "Valor para '$name'"
    if (-not [string]::IsNullOrEmpty($value)) {
        $secretsToSet[$name] = $value
    }
}

if ($secretsToSet.Count -eq 0) {
    Write-Host "No se ingresó ningún valor. Cancelando." -ForegroundColor Yellow
    exit 0
}

Write-Host "`n=== Guardando secretos ===" -ForegroundColor Cyan
$success = 0
foreach ($kv in $secretsToSet.GetEnumerator()) {
    try {
        az keyvault secret set `
            --vault-name $KeyVaultName `
            --name $kv.Key `
            --value $kv.Value `
            --output none
        Write-Host "✅ $($kv.Key)" -ForegroundColor Green
        $success++
    } catch {
        Write-Host "❌ $($kv.Key) - Error: $_" -ForegroundColor Red
    }
}

Write-Host "`n=== Resumen ===" -ForegroundColor Cyan
Write-Host "Secretos guardados: $success/$($secretsToSet.Count)" -ForegroundColor Green

Write-Host "`n=== Secretos en el Vault ===" -ForegroundColor Cyan
az keyvault secret list --vault-name $KeyVaultName --output table

Write-Host "`n✅ Completado. Las Functions podrán leer los secretos en ~30s" -ForegroundColor Green
