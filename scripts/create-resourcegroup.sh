#!/bin/bash
RESOURCE_GROUP="rg-monitoramento"
LOCATION="eastus"

echo "Criando grupo de recursos: $RESOURCE_GROUP"
az group create --name $RESOURCE_GROUP --location $LOCATION
