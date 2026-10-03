import os
from typing import Any

import httpx
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware

RAPIDAPI_BASE_URL = "https://open-weather13.p.rapidapi.com"


class RapidWeatherClient:
    def __init__(self) -> None:
        self.api_host = os.getenv("RAPIDAPI_HOST", "open-weather13.p.rapidapi.com")
        self.api_key = os.getenv("RAPIDAPI_KEY", "")

    def get_city_weather(self, city: str) -> dict[str, Any]:
        if not self.api_key:
            raise HTTPException(
                status_code=500,
                detail="RAPIDAPI_KEY is not configured on the backend",
            )

        headers = {
            "x-rapidapi-host": self.api_host,
            "x-rapidapi-key": self.api_key,
        }

        try:
            response = httpx.get(
                f"{RAPIDAPI_BASE_URL}/city",
                params={"lang": "EN", "city": city},
                headers=headers,
                timeout=15,
            )
        except httpx.RequestError as exc:
            raise HTTPException(
                status_code=502,
                detail=f"Unable to reach weather provider: {exc}",
            ) from exc

        if response.status_code == 404:
            raise HTTPException(status_code=404, detail="City not found")

        if response.status_code >= 400:
            raise HTTPException(
                status_code=502,
                detail=f"Weather provider returned status {response.status_code}",
            )

        return response.json()


app = FastAPI(title="Weather Forecast API", version="1.0.0")
weather_client = RapidWeatherClient()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/api/weather")
def weather_by_city(
    city: str = Query(..., min_length=2, max_length=120, description="City name"),
) -> dict[str, Any]:
    return weather_client.get_city_weather(city.strip())
