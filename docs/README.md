
# 🎬 Projeto BD2: Data Lakehouse de Lançamentos de Filmes

Este projeto implementa uma arquitetura de Data Lakehouse para processar e analisar dados de lançamentos comerciais de filmes por distribuidoras. Utilizamos um pipeline **ETL** (Extract, Transform, Load) para mover os dados da camada bruta (`raw`/Bronze) para a camada limpa (`silver`) e, em seguida, carregá-los em um banco de dados **PostgreSQL** dentro de um ambiente Dockerizado.

---

## 1. Estrutura do Repositório e Camadas de Dados

O projeto segue uma estrutura organizada em camadas de dados (Bronze, Silver) e contém a infraestrutura de banco de dados.

```

trabalho-BD2/
├── db/                       \# Arquivos para construção e população do BD
│   ├── Dockerfile            \# Configuração da imagem do serviço 'populate'
│   ├── init.sql              \# Script para criação das tabelas no BD
│   ├── populate\_db.py       \# Script Py que lê camada silver e popula BD
│   └── requirements.txt      \# Dependências do script de população
├── docs/                     \# Documentação, diagramas e relatórios
├── raw/                      \# Camada Bronze: dados brutos e originais
│   └── lancamentos-comerciais-por-distribuidoras.csv
├── silver/                   \# Camada Silver: dados limpos e processados 
│   ├── etl.ipynb             \# Notebook Py com código de transformação (T)
│   ├── lancamentos-comerciais-processed.csv
│   └── lista-insucesso-processed.csv
└── docker-compose.yml        \# Orquestração dos serviços Docker 

````

## 2. Ponto de Controle 1 (PC1) - Entregas Realizadas

O Ponto de Controle 1 (PC1) focou no estabelecimento da infraestrutura básica e do pipeline completo de movimentação de dados (ETL), conforme o planejamento inicial.

| Entrega do PC1 | Status | Detalhes no Projeto |
| :--- | :--- | :--- |
| **Job ETL (Raw -> Silver)** | ✔️ Concluído | O processo de transformação foi implementado no `silver/etl.ipynb`. |
| **Banco de Dados Dockerizado** | ✔️ Concluído | O serviço `db` utiliza a imagem `postgres:13` na porta **`5433`**. |
| **População Automática do BD** | ✔️ Concluído | O serviço `populate` lê a camada `silver` e carrega os dados no `filmes_db` automaticamente quando o Docker é iniciado. |

---

## 3. Documentação do Processo ETL (Raw -> Silver)

O processo ETL (implementado em `silver/etl.ipynb`) é responsável por limpar, padronizar e enriquecer os dados antes de salvá-los na camada Silver.

### A. Etapa de Extração (Extract)
O processo inicia lendo o arquivo CSV bruto da camada `raw/` utilizando o separador **ponto e vírgula** (`;`).

### B. Etapa de Transformação (Transform)

1.  **Padronização de Schema:** As colunas são renomeadas para o padrão *snake\_case* (ex: `DATA_LANCAMENTO_OBRA` para `data_lancamento`) e textos são convertidos para **minúsculas**.
2.  **Tratamento de Dados Numéricos e Data:**
    * **`data_lancamento`:** Convertida para o tipo **datetime** (`YYYY-MM-DD`). Registros com falha de conversão de data são movidos para a lista de insucesso.
    * **`renda_total`:** Limpeza de caracteres monetários (`R$`, `.`) e conversão para **float**.
3.  **Enriquecimento (Feature Engineering):** Criação das colunas **`ano_lancamento`**, **`mes_lancamento`** e **`dia_lancamento`**.
4.  **Qualidade de Dados:** Adição da coluna booleana **`is_outlier`**, que identifica registros com valores extremos de público e renda através do método **IQR** ($Q3 + 1.5 \times IQR$).

### C. Etapa de Carga (Load)
Os resultados são salvos na camada `silver/` em dois arquivos:
* `lancamentos-comerciais-processed.csv` (Sucesso)
* `lista-insucesso-processed.csv` (Insucesso)

---

## 4. Como Rodar o Projeto e Acessar o Banco de Dados

### Pré-requisitos
* **Docker** e **Docker Compose** instalados.

### Passos de Execução
1.  **Navegue até o diretório principal:**
    ```bash
    cd trabalho-BD2/
    ```

2.  **Inicie os containers:** Este comando constrói e inicia o banco de dados e executa o script de população de dados em segundo plano.
    ```bash
    docker-compose up --build -d
    ```

### Dados de Conexão com o Banco (PostgreSQL)

Para acessar e verificar os dados no `filmes_db` (que deve estar populado após a inicialização do Docker):

| Parâmetro | Valor |
| :--- | :--- |
| **db_host** | `db` |
| **db_port** | **`"5433:5432"`** |
| **db_name** | **`filmes_db`** |
| **db_user** | **`user`** |
| **db_password** | **`password`** |
````
