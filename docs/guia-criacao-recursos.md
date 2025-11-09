# Guia de Criação de Recursos no Azure

Este guia apresenta os passos para criar recursos no Azure usando a CLI e templates ARM.

## Etapas

1. **Criar Grupo de Recursos**
   ```bash
   az group create --name rg-monitoramento --location eastus

---

**2. Implantar Data Factory**

   ```bash
   az deployment group create \
     --resource-group rg-monitoramento \
     --template-file infra/arm-template.json \
     --parameters @infra/parameters.json
   ```

**3. Configurar Monitoramento**

   ```bash
   az monitor budget create ...
   ```

**4. Importar Pipeline**

   - Acesse o Azure Data Factory.
   - Vá em "Author" > "Import Pipeline".
   - Use o arquivo datafactory/pipeline-monitoramento.json.
`

---
