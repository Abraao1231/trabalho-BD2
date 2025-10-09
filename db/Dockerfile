# Usar uma imagem base do Python
FROM python:3.9-slim

# Definir o diretório de trabalho dentro do contêiner
WORKDIR /app

# Copiar o arquivo de requerimentos para o contêiner
COPY requirements.txt .

# Instalar as bibliotecas listadas no requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copiar o script de população do banco para o contêiner
COPY populate_db.py .

# Comando que será executado quando o contêiner iniciar
CMD ["python", "populate_db.py"]