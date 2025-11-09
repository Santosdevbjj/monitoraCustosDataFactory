#!/bin/bash
RESOURCE_GROUP="rg-monitoramento"

echo "Configurando alertas de custo..."
az monitor budget create \
  --name "orcamentoMensal" \
  --resource-group $RESOURCE_GROUP \
  --amount 50 \
  --category cost \
  --time-grain monthly \
  --start-date 2025-11-01 \
  --end-date 2026-11-01 \
  --notifications-enabled true \
  --contact-emails "seuemail@exemplo.com"
