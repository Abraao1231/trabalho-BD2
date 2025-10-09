import pandas as pd
from sqlalchemy import create_engine
import time
import os

print("Script de população iniciado. Aguardando o banco de dados...")
# Pausa de 10 segundos para garantir que o PostgreSQL esteja pronto para receber conexões
time.sleep(10)

try:
    # Configurações do banco de dados (padrão do docker-compose)
    db_user = 'user'
    db_password = 'password'
    db_host = 'db'  # 'db' é o nome do serviço no docker-compose
    db_port = '5432'
    db_name = 'filmes_db'

    # String de conexão do SQLAlchemy
    engine_string = f'postgresql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}'
    engine = create_engine(engine_string)
    
    print("Conexão com o banco de dados estabelecida.")

    # Caminho do arquivo CSV da camada Silver
    csv_path = 'silver/lancamentos-comerciais-processed.csv'

    # Carregar os dados de sucesso
    df_sucesso = pd.read_csv(csv_path, sep=';')
    
    print(f"Lendo {len(df_sucesso)} registros do arquivo CSV.")

    # Enviar os dados para a tabela 'lancamentos' no banco de dados
    # if_exists='append' adiciona os dados sem apagar a tabela que o init.sql criou
    df_sucesso.to_sql('lancamentos', engine, if_exists='append', index=False)

    print("Banco de dados populado com sucesso!")

except Exception as e:
    print(f"Ocorreu um erro: {e}")