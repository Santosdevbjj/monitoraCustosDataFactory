# Monitoramento de Custos no Azure Data Factory

<p align="center">
  <img src="dashboards/custo-dashboard.png" alt="Custos no Azure Data Factory" width="600"/>
</p>


### Governança Financeira • Infraestrutura como Código • Azure Cost Management • DataOps

![Azure_Databricks01](https://github.com/user-attachments/assets/35aa3648-d90d-4d8a-9d95-69b5248f1956)

**Bootcamp Microsoft AI for Tech — Azure Databricks**

---

## 1. Problema de Negócio

Ambientes Azure sem monitoramento de custos são uma armadilha silenciosa. Pipelines do Data Factory que parecem simples no desenho podem gerar cobranças inesperadas por execuções desnecessárias, recursos ociosos ou chamadas de API em loop. Em contextos corporativos, o custo de nuvem descontrolado é um risco financeiro — e em muitas empresas, a área de dados é a primeira a ser questionada quando a fatura do Azure chega acima do esperado.

O problema concreto é este: **sem alertas, orçamentos e dashboards configurados desde o início, o engenheiro de dados só descobre o estouro de custo depois que ele acontece**. E nesse ponto, o dano já está feito.

Este projeto resolve esse problema implementando uma camada completa de governança financeira — alertas automáticos, dashboard de custos, pipeline de consulta à API de Consumption e infraestrutura provisionada como código — antes que qualquer pipeline de dados entre em produção.

---

## 2. Contexto

O Azure Cost Management é frequentemente tratado como uma responsabilidade do time de Cloud ou FinOps, não da Engenharia de Dados. Esse distanciamento é um erro: quem cria os pipelines é quem melhor entende o comportamento de custo de cada execução, e quem deveria ser o primeiro a configurar os guardrails financeiros.

Este projeto foi desenvolvido durante o Bootcamp Microsoft AI for Tech — Azure Databricks com um objetivo claro: demonstrar que governança de custos não é burocracia — é parte da engenharia de dados responsável.

A solução cobre três dimensões complementares: infraestrutura provisionada via ARM Templates (reproduzível e auditável), alertas de orçamento configurados via Azure CLI (automáticos e sem dependência de ação humana), e um pipeline ADF que consulta diretamente a API de Consumption do Azure para monitoramento programático do custo real.

---

## 3. Premissas da Análise

As seguintes premissas foram adotadas para o desenho desta solução:

- O **orçamento mensal de referência é R$ 50** — valor configurado no script `setup-monitoring.sh` como ponto de partida para ambientes de estudo e desenvolvimento. Em produção, esse valor deve refletir o budget aprovado pela área financeira
- O **grupo de recursos `rg-monitoramento`** concentra todos os recursos do projeto, facilitando controle de custos por escopo e limpeza do ambiente após o uso
- A **região `East US`** foi escolhida por combinar disponibilidade dos serviços necessários com menor custo entre as regiões principais — decisão registrada em `infra/parameters.json` para auditoria e replicação
- O pipeline `pipeline-monitoramento.json` consulta custos do tipo `ActualCost` — valores já incorridos, não previsões. Alertas preventivos são responsabilidade dos orçamentos configurados via CLI
- **ARM Templates** são a camada de IaC adotada em vez de Terraform, por integração nativa com o Azure e menor fricção em contextos de bootcamp e ambientes 100% Azure — trade-off documentado
- A **nomenclatura de recursos** segue padrão definido em `docs/nomenclatura-boas-praticas.md`, com prefixos por tipo (`rg-`, `df-`, `st`, `db-`), letras minúsculas e sem caracteres especiais

---

## 4. Estratégia da Solução

A solução foi estruturada em quatro camadas que se complementam na ordem de execução:

**Camada 1 — Infraestrutura como Código (ARM Templates)**

O `arm-template.json` define o recurso `Microsoft.DataFactory/factories` com parâmetros dinâmicos (`dataFactoryName`, `location`). O `parameters.json` registra os valores padrão (`df-monitoramento`, `East US`). Essa separação entre template e parâmetros é uma prática deliberada: o mesmo template pode ser reutilizado para outros ambientes (dev, homolog, prod) apenas trocando o arquivo de parâmetros.

**Camada 2 — Automação via Shell Scripts**

Três scripts Bash cobrem o ciclo completo de provisionamento:

1. `create-resourcegroup.sh`: cria `rg-monitoramento` em `eastus` — isolamento de recursos por projeto
2. `deploy-arm.sh`: implanta o Data Factory via `az deployment group create`, referenciando o template e os parâmetros locais
3. `setup-monitoring.sh`: cria o budget `orcamentoMensal` com limite de R$ 50, granularidade mensal, vigência de 12 meses e notificação automática por e-mail via `az monitor budget create`

A execução é sequencial e reproduzível — qualquer pessoa pode recriar o ambiente completo em minutos via Azure Cloud Shell, sem instalações locais.

**Camada 3 — Pipeline de Monitoramento Programático (ADF + Cost Management API)**

O `pipeline-monitoramento.json` implementa uma `WebActivity` que realiza uma chamada `POST` à API `Microsoft.CostManagement/query` com o body `{ "type": "ActualCost" }`. Essa atividade consulta os custos reais acumulados da subscription diretamente via REST, sem depender de dashboards manuais. A autenticação é gerenciada pelo linked service `AzureBlobStorageLinkedService`, que delega a identidade do Data Factory para a chamada — eliminando credenciais hardcoded no pipeline.

**Camada 4 — Governança e Documentação Operacional**

`docs/guia-criacao-recursos.md` documenta o passo a passo reproduzível de criação e configuração. `docs/nomenclatura-boas-praticas.md` define o padrão de nomenclatura em tabela, com exemplos reais para cada tipo de recurso Azure. `dashboards/custo-dashboard.png` registra a evidência visual do monitoramento ativo.

---

## 5. Insights do Projeto

A implementação revelou decisões que não eram óbvias no início:

**Por que ARM Templates e não Terraform?**
Terraform oferece maior flexibilidade multi-cloud, mas adiciona uma dependência de estado externo (`.tfstate`) e uma curva de aprendizado adicional. Em um ambiente 100% Azure, os ARM Templates têm integração nativa, menor overhead de configuração e são aceitos diretamente pelo `az deployment group create` sem ferramentas adicionais. O trade-off foi documentado conscientemente — não por desconhecimento do Terraform.

**Por que o pipeline consulta a API de Consumption em vez de usar apenas o dashboard?**
Dashboards do Azure Cost Management são ótimos para visualização humana, mas não são acionáveis programaticamente. Um pipeline que consulta a API de Consumption pode ser encadeado com lógicas de alerta, envio de relatórios ou suspensão de recursos — abrindo caminho para automação de resposta a custos, não apenas observação.

**O maior desafio técnico: autenticação na API de Consumption**
A `WebActivity` do ADF não autentica automaticamente em APIs do Azure Resource Manager. A solução foi usar o linked service com Managed Identity do Data Factory, delegando ao ADF a responsabilidade de obter o token de acesso — sem segredos em código. Esse desafio de autenticação exigiu leitura detalhada da documentação da API `2021-10-01` do Cost Management e iterações de teste antes de funcionar corretamente.

**Por que separar `arm-template.json` de `parameters.json`?**
Templates ARM com valores hardcoded são uma armadilha de replicação. Separar o template dos parâmetros garante que o mesmo artefato de IaC sirva múltiplos ambientes sem modificação — prática padrão em pipelines de CI/CD para infraestrutura.

**Por que documentar nomenclatura em um arquivo separado?**
Recursos mal nomeados no Azure acumulam dívida operacional: fica difícil saber o que desligar, o que monitorar e o que fatura. O `nomenclatura-boas-praticas.md` com tabela de padrões é um ativo de governança — não apenas um documento de estilo.

---

## 6. Resultados

Este projeto entrega uma solução completa de governança financeira para ambientes Azure Data Factory, com:

- **Infraestrutura reproduzível** via ARM Templates — qualquer membro do time pode recriar o ambiente completo em minutos, sem dependência de configuração manual
- **Alerta automático de orçamento** configurado via CLI — notificação por e-mail quando o custo mensal se aproxima do limite definido, sem intervenção humana
- **Monitoramento programático via pipeline ADF** — consulta direta à API de Consumption com `ActualCost`, base para automações de resposta a custos
- **Governança documentada** — guia de criação de recursos e padrão de nomenclatura que podem ser adotados como baseline em projetos corporativos reais
- **Ambiente de custo controlado** — todos os recursos concentrados em `rg-monitoramento`, facilitando limpeza e evitando cobranças residuais após o projeto

Do ponto de vista de portfólio, o projeto demonstra que engenharia de dados responsável não termina no pipeline — inclui governança financeira, infraestrutura como código e automação de monitoramento.

---

## 7. Próximos Passos

- Integrar o dashboard de custos ao **Power BI** para visualização avançada com histórico e projeções de tendência
- Adicionar **notificações via Microsoft Teams ou Slack** usando Logic Apps como intermediário entre o budget alert e os canais de comunicação do time
- Evoluir o pipeline para consultar custos **por serviço e por tag**, permitindo granularidade por projeto, squad ou ambiente
- Criar **templates ARM adicionais** para Storage Account, Key Vault e Databricks, completando a cobertura de IaC para toda a plataforma de dados
- Automatizar **relatórios semanais de consumo** via Python + Azure Functions, com envio programado por e-mail

---

## Estrutura do Repositório

```
monitoraCustosDataFactory/
│
├── datafactory/
│   └── pipeline-monitoramento.json     # Pipeline ADF: consulta à API ActualCost via WebActivity
│
├── infra/
│   ├── arm-template.json               # ARM Template: provisiona o Azure Data Factory
│   └── parameters.json                 # Parâmetros: df-monitoramento, região East US
│
├── scripts/
│   ├── create-resourcegroup.sh         # Cria o grupo de recursos rg-monitoramento em eastus
│   ├── deploy-arm.sh                   # Implanta o Data Factory via ARM Template
│   └── setup-monitoring.sh             # Cria budget mensal de R$50 com alerta por e-mail
│
├── docs/
│   ├── guia-criacao-recursos.md        # Guia passo a passo de provisionamento via CLI
│   └── nomenclatura-boas-praticas.md   # Tabela de padrões de nomenclatura para recursos Azure
│
├── dashboards/
│   └── custo-dashboard.png             # Evidência visual do dashboard de custos configurado
│
└── README.md
```

---

## Descrição das Pastas e Arquivos

| Arquivo / Pasta | Função |
|---|---|
| `datafactory/pipeline-monitoramento.json` | Pipeline principal do projeto. Implementa uma `WebActivity` chamada `VerificarCustos` que faz `POST` à API `Microsoft.CostManagement/query` (versão `2021-10-01`) com body `{ "type": "ActualCost" }`. Consulta os custos reais incorridos na subscription. A autenticação é delegada ao Managed Identity do Data Factory via linked service — sem credenciais em código. Timeout configurado em 7 dias para cobrir execuções longas. |
| `infra/arm-template.json` | Template ARM que define o recurso `Microsoft.DataFactory/factories` com API version `2018-06-01`. Aceita `dataFactoryName` e `location` como parâmetros dinâmicos, tornando o template reutilizável para qualquer ambiente sem modificação. Schema baseado no padrão `2019-04-01/deploymentTemplate`. |
| `infra/parameters.json` | Arquivo de parâmetros separado do template — prática intencional de IaC. Define `dataFactoryName: df-monitoramento` e `location: East US`. A separação permite usar o mesmo `arm-template.json` para ambientes distintos (dev, homolog, prod) apenas trocando este arquivo. |
| `scripts/create-resourcegroup.sh` | Script Bash que executa `az group create --name rg-monitoramento --location eastus`. Isola todos os recursos do projeto em um único grupo, facilitando controle de custo por escopo, auditoria e limpeza do ambiente após o uso. |
| `scripts/deploy-arm.sh` | Script Bash que executa `az deployment group create` referenciando `infra/arm-template.json` e `infra/parameters.json`. Automatiza a implantação do Data Factory — reproduzível em qualquer máquina com Azure CLI ou via Azure Cloud Shell sem instalações adicionais. |
| `scripts/setup-monitoring.sh` | Script Bash que executa `az monitor budget create` criando o orçamento `orcamentoMensal`: limite de R$ 50, categoria `cost`, granularidade mensal, vigência de 12 meses (nov/2025 a nov/2026) e notificação automática por e-mail. É o guardrail financeiro do projeto — acionado antes de qualquer execução de pipeline. |
| `docs/guia-criacao-recursos.md` | Guia operacional com os quatro passos de provisionamento: criar grupo de recursos, implantar Data Factory via ARM, configurar monitoramento e importar pipeline. Inclui os comandos CLI exatos — funciona como runbook para replicação do ambiente. |
| `docs/nomenclatura-boas-praticas.md` | Tabela de padrões de nomenclatura para quatro tipos de recursos Azure: Grupo de Recursos (`rg-`), Data Factory (`df-`), Storage Account (`st`), Dashboard (`db-`). Inclui regras gerais: prefixos por tipo, letras minúsculas, sem caracteres especiais, propósito no nome. Ativo de governança reutilizável em projetos corporativos. |
| `dashboards/custo-dashboard.png` | Captura de tela do dashboard de custos configurado no Azure Cost Management. Evidência visual do monitoramento ativo, com métricas de custo por serviço e alertas configurados. Documento de referência para apresentações e revisões de governança. |

---

## Requisitos de Hardware e Software

### Hardware

Este projeto não tem requisitos de hardware locais. Toda a execução pode ser feita diretamente no **Azure Cloud Shell**, acessível pelo navegador no portal Azure — sem instalação de nada na máquina local.

| Recurso | Mínimo |
|---|---|
| Máquina local | Qualquer dispositivo com navegador moderno |
| Rede | Acesso à internet (portal.azure.com e management.azure.com) |
| Armazenamento local | Apenas para clonar o repositório (~1 MB) |

### Software

| Requisito | Versão | Observação |
|---|---|---|
| Navegador | Edge, Chrome ou Firefox (versão recente) | Para acesso ao Azure Portal e Cloud Shell |
| Git | Qualquer recente | Para clonar o repositório localmente |
| Azure CLI | 2.x | Opcional — substituível pelo Azure Cloud Shell integrado ao portal |
| VS Code | Qualquer | Recomendado para edição dos arquivos JSON e Shell scripts |

### Recursos Azure

| Recurso | Obrigatório | Função no Projeto |
|---|---|---|
| Azure Subscription (estudante ou trial) | ✅ | Base para todos os recursos — conta gratuita de estudante é suficiente |
| Azure Data Factory (V2) | ✅ | Hospeda e executa o `pipeline-monitoramento` |
| Azure Cost Management + Billing | ✅ | API de Consumption consultada pelo pipeline; dashboard de custos |
| Azure Monitor (Budgets) | ✅ | Orçamento mensal com alerta por e-mail configurado via `setup-monitoring.sh` |
| Azure Cloud Shell | ✅ (recomendado) | Execução dos scripts Bash sem instalação local — disponível no portal |

> **Custo estimado:** usando conta de estudante Azure e encerrando os recursos após o projeto, o custo real tende a zero. O próprio projeto configura o budget de R$ 50 como proteção — sinal de que governança financeira começa na primeira linha de código.

---

## Como Executar o Projeto

**1. Clonar o repositório**
```bash
git clone https://github.com/Santosdevbjj/monitoraCustosDataFactory.git
cd monitoraCustosDataFactory
```

**2. Abrir o Azure Cloud Shell**

Acesse [portal.azure.com](https://portal.azure.com) → clique no ícone de terminal `>_` no topo. O Cloud Shell já tem Azure CLI configurado — não é necessário instalar nada.

**3. Executar os scripts na ordem**
```bash
bash scripts/create-resourcegroup.sh    # Cria o grupo rg-monitoramento em eastus
bash scripts/deploy-arm.sh              # Implanta df-monitoramento via ARM Template
bash scripts/setup-monitoring.sh        # Configura budget mensal de R$50 com alerta por e-mail
```

**4. Importar o pipeline no Data Factory**
```
Portal Azure → df-monitoramento → Author → Import Pipeline
Selecionar: datafactory/pipeline-monitoramento.json
```

**5. Visualizar o dashboard de custos**
```
Portal Azure → Cost Management + Billing → Dashboards
Referência visual: dashboards/custo-dashboard.png
```

---

## Aprendizados

- A autenticação em APIs do Azure Resource Manager a partir de pipelines ADF não é trivial — o uso de Managed Identity via linked service foi a solução que eliminou credenciais hardcoded e funcionou em ambiente de estudo sem Service Principal dedicado
- A separação entre `arm-template.json` e `parameters.json` não é apenas organização: é a diferença entre um template reutilizável e um template descartável — esse princípio se aplica a qualquer IaC, não só ARM
- Configurar o budget **antes** de provisionar o Data Factory muda a mentalidade de desenvolvimento: você para de pensar "vou verificar o custo depois" e passa a tratar governança financeira como parte do setup inicial, não como revisão posterior
- O Azure Cost Management tem uma API rica e pouco explorada pela comunidade de dados — a `WebActivity` que consulta `ActualCost` abre portas para automações que vão muito além de dashboards estáticos
- Documentar nomenclatura em uma tabela com exemplos reais (não apenas regras abstratas) torna o padrão adotável por qualquer membro do time — a diferença entre uma convenção que existe e uma que é seguida

---

## Autor

**Sergio Santos**

[![Portfólio Sérgio Santos](https://img.shields.io/badge/Portfólio-Sérgio_Santos-111827?style=for-the-badge&logo=githubpages&logoColor=00eaff)](https://portfoliosantossergio.vercel.app)
[![LinkedIn Sérgio Santos](https://img.shields.io/badge/LinkedIn-Sérgio_Santos-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/santossergioluiz)
