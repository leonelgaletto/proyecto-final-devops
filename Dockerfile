FROM python:3.9-slim-buster

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiamos el resto del código de nuestra app
COPY . .

EXPOSE 5001

CMD ["python3", "app.py"]

HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD curl -f http://localhost:5001/health || exit 1
