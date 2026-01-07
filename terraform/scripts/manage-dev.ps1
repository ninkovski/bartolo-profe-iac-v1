# Script PowerShell para manejar entorno DEV en Windows

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("start", "stop", "status")]
    [string]$Action
)

$RESOURCE_GROUP = "bartolo-profe-rg-dev"
$FUNCTION_SALE = "func-bartolo-profe-app-process-sale-dev"
$FUNCTION_PAYMENT = "func-bartolo-profe-app-process-payment-dev"

switch ($Action) {
    "stop" {
        Write-Host "🛑 Apagando entorno DEV..." -ForegroundColor Yellow
        az functionapp stop --name $FUNCTION_SALE --resource-group $RESOURCE_GROUP
        az functionapp stop --name $FUNCTION_PAYMENT --resource-group $RESOURCE_GROUP
        Write-Host "✅ Entorno DEV apagado (no consumirá recursos)" -ForegroundColor Green
    }
    "start" {
        Write-Host "🚀 Iniciando entorno DEV..." -ForegroundColor Cyan
        az functionapp start --name $FUNCTION_SALE --resource-group $RESOURCE_GROUP
        az functionapp start --name $FUNCTION_PAYMENT --resource-group $RESOURCE_GROUP
        Write-Host "✅ Entorno DEV iniciado" -ForegroundColor Green
    }
    "status" {
        Write-Host "📊 Estado entorno DEV:" -ForegroundColor Cyan
        $saleStat = az functionapp show --name $FUNCTION_SALE --resource-group $RESOURCE_GROUP --query "state" -o tsv
        $paymentStat = az functionapp show --name $FUNCTION_PAYMENT --resource-group $RESOURCE_GROUP --query "state" -o tsv
        Write-Host "ProcessSale: $saleStat" -ForegroundColor White
        Write-Host "ProcessPayment: $paymentStat" -ForegroundColor White
    }
}
