from flask import Flask
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

# --- MÉTRICAS DE PROMETHEUS ---
# Creamos un "contador" para rastrear las visitas a la página principal
# (¡Debe tener 2 espacios antes del comentario!)
home_visits_counter = Counter(
    'home_visits', 'Número de visitas a la página principal'
)

# Creamos nuestra aplicación Flask
app = Flask(__name__)


# --- RUTAS DE LA APLICACIÓN ---

@app.route('/')
def home():
    """Ruta principal que muestra el mensaje de bienvenida."""
    # Incrementamos el contador cada vez que alguien visita la página
    home_visits_counter.inc()
    return "¡Hola! Esta es la aplicación base del Proyecto 1."


@app.route('/health')
def health_check():
    """Ruta de 'health check' para monitoreo."""
    # (2 líneas en blanco antes de la función)
    return "OK", 200


@app.route('/metrics')
def metrics():
    """Ruta para exponer las métricas de Prometheus."""
    # (2 líneas en blanco antes de la función)
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}


# --- PUNTO DE ENTRADA ---
# (2 líneas en blanco antes de esto)
if __name__ == '__main__':
    # Corremos la app en el puerto 5001, accesible desde cualquier IP
    app.run(debug=False, host='0.0.0.0', port=5001)
