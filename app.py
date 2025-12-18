from flask import Flask
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

home_visits_counter = Counter(
    'home_visits', 'Número de visitas a la página principal'
)

app = Flask(__name__)


@app.route('/')
def home():
    """Ruta principal que muestra el mensaje de bienvenida."""
    home_visits_counter.inc()
    return "¡Hola! Esta es la aplicación base del Proyecto 1. v2"


@app.route('/health')
def health_check():
    """Ruta de 'health check' para monitoreo."""
    return "OK", 200


@app.route('/metrics')
def metrics():
    """Ruta para exponer las métricas de Prometheus."""
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}


if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0', port=5001)
