# Criando um Monitoramento de Custos no Data Factory 


![Azure_Databricks01](https://github.com/user-attachments/assets/35aa3648-d90d-4d8a-9d95-69b5248f1956)


**Bootcamp Microsoft AI for Tech - Azure Databricks.**

---

**DESCRIÇÃO:**
Neste projeto, é apresentada uma visão prática do ambiente Azure a partir da criação de recursos com uma conta gratuita de estudante. 

O foco está em configurar o Azure Data Factory e preparar o ambiente para monitorar o uso e os custos dos recursos implantados. 

São abordados temas como: estruturação de assinaturas, criação de grupos de recursos, boas práticas de nomenclatura, personalização de dashboards, utilização de métricas e alertas de custo. 

Também é demonstrada a criação de templates de infraestrutura como código (ARM Templates) e a utilização do Azure Cloud Shell para automações via linha de comando. 

O projeto oferece um passo a passo completo desde a criação do recurso até a visualização dos dados de consumo, promovendo uma compreensão clara sobre o controle de custos e a organização de recursos dentro do Azure.


---



**Monitoramento de Custos no Azure Data Factory**

Este projeto demonstra como configurar o Azure Data Factory para monitorar o uso e os custos dos recursos em uma conta gratuita de estudante.

Utilizamos automações com ARM Templates e Azure Cloud Shell, boas práticas de nomenclatura, dashboards personalizados e alertas de custo para garantir controle e eficiência no ambiente Azure.

---

🧰 **Tecnologias Utilizadas**

- **Microsoft Azure:** Plataforma de nuvem para criação e gerenciamento de recursos.
- **Azure Data Factory:** Serviço de integração de dados e orquestração de pipelines.
- **Azure Cost Management:** Ferramenta para monitoramento e controle de gastos.
- **ARM Templates:** Infraestrutura como código para provisionamento automatizado.
- **Azure CLI / Cloud Shell:** Interface de linha de comando para automações.
- **GitHub:** Versionamento e hospedagem do projeto.

---



💻 **Requisitos de Hardware e Software**

- Conta gratuita de estudante no Microsoft Azure
- Navegador moderno (Edge, Chrome, Firefox)
- Git instalado para clonar o repositório
- Azure CLI (opcional, pode usar o Cloud Shell no portal)
- Editor de código (VS Code recomendado)

---

🚀 **Como Executar o Projeto**

**1. Clone o repositório**
   ```bash
   git clone https://github.com/Santosdevbjj/monitoraCustosDataFactory.git
   cd monitoraCustosDataFactory
   ```

**2. Abra o Azure Cloud Shell no portal Azure.**

**3. Execute os scripts na ordem abaixo:**
   ```bash
   bash scripts/create-resourcegroup.sh
   bash scripts/deploy-arm.sh
   bash scripts/setup-monitoring.sh
   ```

**4. Importe o pipeline no Data Factory**
   - Acesse o recurso df-monitoramento no portal.
   - Vá em "Author" > "Import Pipeline".
   - Selecione o arquivo datafactory/pipeline-monitoramento.json.

**5. Visualize o dashboard**
   - Acesse "Cost Management + Billing" > "Dashboards".
   - Veja o exemplo em dashboards/custo-dashboard.png.

---


📁 **Estrutura de Pastas e Arquivos**

<img width="1017" height="1182" alt="Screenshot_20251109-072647" src="https://github.com/user-attachments/assets/01927ddc-02d7-4ba7-8dd6-0f761df5186e" />


---



🔍 **Explicação dos Arquivos**

📊 **dashboards/custo-dashboard.png**
Imagem ilustrativa de um dashboard personalizado com métricas de custo por serviço e alertas configurados.

🧱 **infra/arm-template.json**
Template ARM que define a criação do recurso Azure Data Factory com parâmetros dinâmicos.

⚙️ **infra/parameters.json**
Arquivo de parâmetros para o ARM Template, contendo nome do recurso e localização.

🛠️ **scripts/create-resourcegroup.sh**
Script para criar o grupo de recursos rg-monitoramento na região eastus.

🚀 **scripts/deploy-arm.sh**
Script para implantar o Data Factory usando os arquivos ARM.

🔔 **scripts/setup-monitoring.sh**
Script para configurar alertas de custo mensais com limite de R$50 e envio de e-mail.

📘 **docs/guia-criacao-recursos.md**
Guia passo a passo para criar e configurar os recursos no Azure.

📗 **docs/nomenclatura-boas-praticas.md**
Documento com padrões de nomenclatura recomendados para organização dos recursos.

🔄 **datafactory/pipeline-monitoramento.json**
Pipeline JSON que realiza uma chamada à API de custos do Azure para monitoramento automatizado.

---



📌 **Links Úteis**

- Portal Azure
- Azure para Estudantes
- Documentação Azure Data Factory
- Documentação Azure Cost Management

---

📬 **Contato**
Autor: Sergio Santos 

Caso tenha dúvidas ou sugestões, entre em contato pelo GitHub Issues.

---

**Contato:**

[![Portfólio Sérgio Santos](https://img.shields.io/badge/Portfólio-Sérgio_Santos-111827?style=for-the-badge&logo=githubpages&logoColor=00eaff)](https://santosdevbjj.github.io/portfolio/)
[![LinkedIn Sérgio Santos](https://img.shields.io/badge/LinkedIn-Sérgio_Santos-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/santossergioluiz) 


---


