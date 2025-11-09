#!/bin/bash
RESOURCE_GROUP="rg-monitoramento"

echo "Implantando Data Factory via ARM Template..."
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file infra/arm-template.json \
  --parameters @infra/parameters.json
