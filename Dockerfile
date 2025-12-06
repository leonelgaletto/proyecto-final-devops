# Fase 1: La Base
# Usamos una imagen oficial de Python 3.9 (slim es una versión ligera).
FROM python:3.9-slim

# Fase 2: Configurar el Entorno
# Establecemos el directorio de trabajo DENTRO del contenedor.
WORKDIR /app

# Fase 3: Instalar Dependencias
# Copiamos SOLO el archivo de requisitos primero.
COPY requirements.txt .
# Instalamos las dependencias de Python
RUN pip install --no-cache-dir -r requirements.txt

# Fase 4: Copiar la Aplicación
# Copiamos el resto del código de nuestra app
COPY . .

# Fase 5: Exponer el Puerto
# Informamos a Docker que la app usará el puerto 5001 (como en app.py)
EXPOSE 5001

# Fase 6: Comando de Ejecución
# El comando para correr la app cuando el contenedor inicie.
# app.py ya está configurado para correr en el puerto 5001
CMD ["python3", "app.py"]

# Fase 7: Healthcheck para que la orquestación pueda saber si la app está viva
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD curl -f http://localhost:5001/health || exit 1
