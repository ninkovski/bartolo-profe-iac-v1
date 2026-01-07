#!/bin/bash

# Script para apagar/encender entorno DEV manualmente

RESOURCE_GROUP="rg-bartolo-profe-app-dev"
FUNCTION_SALE="func-bartolo-profe-app-process-sale-dev"
FUNCTION_PAYMENT="func-bartolo-profe-app-process-payment-dev"

case "$1" in
  stop)
    echo "🛑 Apagando entorno DEV..."
    az functionapp stop --name $FUNCTION_SALE --resource-group $RESOURCE_GROUP
    az functionapp stop --name $FUNCTION_PAYMENT --resource-group $RESOURCE_GROUP
    echo "✅ Entorno DEV apagado (no consumirá recursos)"
    ;;
  start)
    echo "🚀 Iniciando entorno DEV..."
    az functionapp start --name $FUNCTION_SALE --resource-group $RESOURCE_GROUP
    az functionapp start --name $FUNCTION_PAYMENT --resource-group $RESOURCE_GROUP
    echo "✅ Entorno DEV iniciado"
    ;;
  status)
    echo "📊 Estado entorno DEV:"
    az functionapp show --name $FUNCTION_SALE --resource-group $RESOURCE_GROUP --query "state" -o tsv
    az functionapp show --name $FUNCTION_PAYMENT --resource-group $RESOURCE_GROUP --query "state" -o tsv
    ;;
  *)
    echo "Uso: $0 {start|stop|status}"
    exit 1
    ;;
esac
