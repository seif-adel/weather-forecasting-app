const weatherForm = document.getElementById("weatherForm");
const cityInput = document.getElementById("cityInput");
const searchButton = document.getElementById("searchButton");
const statusEl = document.getElementById("status");
const weatherCard = document.getElementById("weatherCard");
const cityNameEl = document.getElementById("cityName");
const weatherDescriptionEl = document.getElementById("weatherDescription");
const weatherEmojiEl = document.getElementById("weatherEmoji");
const weatherIconEl = document.getElementById("weatherIcon");
const tempValueEl = document.getElementById("tempValue");
const feelsLikeValueEl = document.getElementById("feelsLikeValue");
const humidityValueEl = document.getElementById("humidityValue");
const windValueEl = document.getElementById("windValue");
const rawJsonEl = document.getElementById("rawJson");

function apiBaseUrl() {
  if (window.APP_CONFIG && window.APP_CONFIG.apiBaseUrl) {
    return window.APP_CONFIG.apiBaseUrl;
  }
  return "http://localhost:8000";
}

function toCelsius(kelvinValue) {
  if (typeof kelvinValue !== "number") return "N/A";
  return `${(kelvinValue - 273.15).toFixed(1)} C`;
}

function weatherEmoji(main = "") {
  const key = main.toLowerCase();
  if (key.includes("clear")) return "☀️";
  if (key.includes("cloud")) return "☁️";
  if (key.includes("rain")) return "🌧️";
  if (key.includes("drizzle")) return "🌦️";
  if (key.includes("thunder")) return "⛈️";
  if (key.includes("snow")) return "❄️";
  if (key.includes("mist") || key.includes("fog") || key.includes("haze")) return "🌫️";
  return "🌤️";
}

function setStatus(message, type) {
  statusEl.textContent = message;
  statusEl.className = "status";
  if (type) {
    statusEl.classList.add(type);
  }
}

function renderWeather(payload) {
  const weather = payload.weather && payload.weather.length ? payload.weather[0] : {};
  const mainInfo = payload.main || {};
  const windInfo = payload.wind || {};

  cityNameEl.textContent = payload.name || "Unknown city";
  weatherDescriptionEl.textContent = weather.description || "No description";
  weatherEmojiEl.textContent = weatherEmoji(weather.main || "");

  if (weather.icon) {
    weatherIconEl.src = `https://openweathermap.org/img/wn/${weather.icon}@2x.png`;
    weatherIconEl.style.display = "block";
  } else {
    weatherIconEl.removeAttribute("src");
    weatherIconEl.style.display = "none";
  }

  tempValueEl.textContent = toCelsius(mainInfo.temp);
  feelsLikeValueEl.textContent = toCelsius(mainInfo.feels_like);
  humidityValueEl.textContent =
    typeof mainInfo.humidity === "number" ? `${mainInfo.humidity}%` : "N/A";
  windValueEl.textContent =
    typeof windInfo.speed === "number" ? `${windInfo.speed} m/s` : "N/A";

  rawJsonEl.textContent = JSON.stringify(payload, null, 2);
  weatherCard.classList.remove("hidden");
}

weatherForm.addEventListener("submit", async (event) => {
  event.preventDefault();

  const city = cityInput.value.trim();
  if (!city) {
    setStatus("Please enter a city name.", "error");
    return;
  }

  searchButton.disabled = true;
  setStatus(`Searching weather for ${city}...`);

  try {
    const response = await fetch(
      `${apiBaseUrl()}/api/weather?city=${encodeURIComponent(city)}`,
      {
        method: "GET",
      }
    );

    const payload = await response.json();

    if (!response.ok) {
      throw new Error(payload.detail || "Could not retrieve weather data");
    }

    renderWeather(payload);
    setStatus("Weather loaded successfully.", "ok");
  } catch (error) {
    weatherCard.classList.add("hidden");
    setStatus(`Request failed: ${error.message}`, "error");
  } finally {
    searchButton.disabled = false;
  }
});
