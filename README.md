# Proyecto 1 – CI/CD + Docker + Terraform + Seguridad + Observabilidad

Este proyecto implementa una aplicación Flask muy simple, containerizada con Docker,
desplegada mediante un pipeline de GitHub Actions a una instancia en AWS gestionada
con Terraform. Además, incluye monitoreo con Prometheus + Grafana y controles de
seguridad en el pipeline (linter, tests, SBOM y Snyk).

## 1. Componentes principales

- **Aplicación**: `app.py` (Flask) con:
  - Ruta `/` con mensaje de bienvenida.
  - Ruta `/health` para health-check.
  - Ruta `/metrics` exponiendo métricas en formato Prometheus mediante `prometheus_client`.
- **Tests**: `test_app.py` con pruebas de:
  - `/`
  - `/health`
  - `/metrics`
- **Dependencias**: `requirements.txt`
- **Contenedor**: `Dockerfile`
- **Monitoreo local**: `docker-compose.yml` + `monitoring/prometheus.yml`
- **Infraestructura**: `terraform/main.tf` + `terraform/install_docker.sh`
- **Pipeline CI/CD**: `.github/workflows/main.yml`

## 2. Cómo ejecutar la app localmente

```bash
# Crear y activar entorno virtual (opcional)
python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt

# Ejecutar la app
python app.py
# La app quedará escuchando en http://localhost:5001
```

## 3. Ejecutar tests

```bash
pip install -r requirements.txt
pytest
```

## 4. Construir y correr el contenedor localmente

```bash
# Construir la imagen
docker build -t proyecto-diplomatura:local .

# Correr el contenedor
docker run --rm -p 5001:5001 proyecto-diplomatura:local
```

Luego podés acceder a:

- `http://localhost:5001/` → página principal
- `http://localhost:5001/health` → health-check
- `http://localhost:5001/metrics` → métricas Prometheus

## 5. Monitoreo con Prometheus + Grafana (local)

El archivo `docker-compose.yml` ya define los servicios:

- `prometheus` (puerto 9090)
- `grafana` (puerto 3000)

Para levantarlos:

```bash
docker-compose up -d
```

- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (usuario/password por defecto: `admin` / `admin`)

Asegurate de que la app Flask esté corriendo en el host en el puerto 5001 para que
Prometheus pueda scrapear `host.docker.internal:5001`.

## 6. Infraestructura con Terraform (AWS)

En la carpeta `terraform/`:

- `main.tf`: define el proveedor AWS y una instancia EC2 (web_server) con Docker instalado.
- `install_docker.sh`: script que prepara el servidor con Docker.

Uso:

```bash
cd terraform

# Inicializa los plugins
terraform init

# Muestra el plan
terraform plan

# Aplica los cambios (crea la infraestructura)
terraform apply
```

Al finalizar, Terraform mostrará:

- `public_ip`: IP pública del servidor.
- `terraform_account_id`: ID de la cuenta AWS.

## 7. Pipeline CI/CD en GitHub Actions

El workflow principal está en `.github/workflows/main.yml` y tiene 3 etapas:

1. **Job `probar-y-lintear` (CI)**  
   - Instala dependencias (`requirements.txt`).
   - Corre `flake8` para linting.
   - Corre `pytest`.

2. **Job `seguridad` (nuevo)**  
   - Genera un SBOM en formato CycloneDX (`sbom.json`).
   - Publica el SBOM como artefacto de workflow.
   - Ejecuta un escaneo con Snyk sobre las dependencias Python.

3. **Job `construir-y-desplegar` (CD)**  
   - Construye y pushea la imagen a Docker Hub.
   - Se conecta por SSH al servidor en AWS.
   - Crea/actualiza `monitoring/prometheus.yml`.
   - Crea/actualiza `docker-compose.yml` con:
     - Servicio `mi-app` (Flask).
     - Servicio `prometheus`.
     - Servicio `grafana`.
   - Ejecuta `docker-compose up -d`.

Dependencias entre jobs:

```yaml
probar-y-lintear  ->  seguridad  ->  construir-y-desplegar
```

> **Importante:** para que el pipeline funcione, tenés que configurar estos *Secrets*
en tu repositorio de GitHub:
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`
- `AWS_SERVER_IP`
- `AWS_SERVER_USER`
- `AWS_SSH_PRIVATE_KEY`
- `SNYK_TOKEN` (para el job de seguridad)

## 8. Seguridad

La sección de seguridad del pipeline incluye:

- Linter (`flake8`) → buenas prácticas de código.
- Tests (`pytest`) → validación funcional.
- SBOM (CycloneDX) → inventario de dependencias en `sbom.json`.
- Snyk → análisis de vulnerabilidades en dependencias (SCA).

## 9. Entregables según la consigna

- **Workflow GitHub Actions (.yml)**  
  - `.github/workflows/main.yml`

- **Archivos Terraform (.tf)**  
  - `terraform/main.tf`
  - `terraform/install_docker.sh`

- **Dockerfile e imagen**  
  - `Dockerfile` (imagen build/push desde el pipeline)

- **SBOM**  
  - `sbom.json` generado por el job de seguridad (publicado como artefacto).

- **Dashboard de métricas**  
  - Prometheus + Grafana via `docker-compose.yml` y `monitoring/prometheus.yml`.
  - Captura de pantalla a ser agregada al README por el alumno.

## 10. Cómo empaquetar para entregar

Desde la raíz del proyecto:

```bash
cd ..
zip -r "Proyecto1_EquipoX.zip" proyecto-diplomatura
```

Asegurate de incluir:
- Código fuente
- Terraform
- Dockerfile
- Workflow de GitHub Actions
- README
- Capturas de Prometheus/Grafana
