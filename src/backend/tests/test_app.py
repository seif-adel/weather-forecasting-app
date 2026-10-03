from fastapi.testclient import TestClient
from fastapi import HTTPException

import app as backend_app


client = TestClient(backend_app.app)


class FakeWeatherClient:
    def __init__(self, payload=None, exception=None):
        self.payload = payload
        self.exception = exception

    def get_city_weather(self, city: str):
        if self.exception is not None:
            raise self.exception
        return self.payload


def test_health_check() -> None:
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_weather_success(monkeypatch) -> None:
    payload = {
        "name": "Cairo",
        "weather": [{"main": "Clear", "description": "clear sky"}],
        "main": {"temp": 301.15, "humidity": 20},
        "wind": {"speed": 4.4},
    }
    monkeypatch.setattr(backend_app, "weather_client", FakeWeatherClient(payload=payload))

    response = client.get("/api/weather", params={"city": "Cairo"})

    assert response.status_code == 200
    assert response.json()["name"] == "Cairo"


def test_weather_wrong_city(monkeypatch) -> None:
    monkeypatch.setattr(
        backend_app,
        "weather_client",
        FakeWeatherClient(exception=HTTPException(status_code=404, detail="City not found")),
    )

    response = client.get("/api/weather", params={"city": "UnknownNoCity"})

    assert response.status_code == 404
    assert response.json() == {"detail": "City not found"}
