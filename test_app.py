import pytest
from app import app as flask_app  # (2 espacios antes del comentario)


@pytest.fixture
def client():
    """Configura un cliente de prueba de Flask."""
    with flask_app.test_client() as client:
        yield client


def test_home(client):
    """Prueba que la ruta principal '/' funcione y devuelva el mensaje."""
    # (2 líneas en blanco antes de la función)
    rv = client.get('/')
    assert rv.status_code == 200
    # (Usamos 'in' para ser flexibles con tildes y mayúsculas)
    assert "proyecto 1" in rv.data.decode('utf-8').lower()


def test_health(client):
    """Prueba que la ruta '/health' devuelva 'OK' y un 200."""
    # (2 líneas en blanco antes de la función)
    rv = client.get('/health')
    assert rv.status_code == 200
    assert b"OK" in rv.data


def test_metrics(client):
    """Prueba que la ruta '/metrics' devuelva las métricas."""
    # (2 líneas en blanco antes de la función)
    rv = client.get('/metrics')
    assert rv.status_code == 200
    # Verificamos que nuestro contador de visitas esté en la respuesta
    assert b"home_visits_total" in rv.data
