import argparse
import sys
from typing import Dict, Any, Optional
import requests

GEO_API_URL = "https://geocoding-api.open-meteo.com/v1/search"
WEATHER_API_URL = "https://api.open-meteo.com/v1/forecast"

# WMO Weather interpretation codes (WW)
WEATHER_CODES = {
    0: "Clear sky",
    1: "Mainly clear", 2: "Partly cloudy", 3: "Overcast",
    45: "Fog", 48: "Depositing rime fog",
    51: "Light drizzle", 53: "Moderate drizzle", 55: "Dense drizzle",
    56: "Light freezing drizzle", 57: "Dense freezing drizzle",
    61: "Slight rain", 63: "Moderate rain", 65: "Heavy rain",
    66: "Light freezing rain", 67: "Heavy freezing rain",
    71: "Slight snow fall", 73: "Moderate snow fall", 75: "Heavy snow fall",
    77: "Snow grains",
    80: "Slight rain showers", 81: "Moderate rain showers", 82: "Violent rain showers",
    85: "Slight snow showers", 86: "Heavy snow showers",
    95: "Thunderstorm", 96: "Thunderstorm with slight hail", 99: "Thunderstorm with heavy hail"
}

def get_coordinates(city_name: str) -> Optional[Dict[str, Any]]:
    """
    Fetches the latitude, longitude, and full name of a city using the Open-Meteo Geocoding API.
    """
    params = {
        "name": city_name,
        "count": 1,
        "language": "en",
        "format": "json"
    }
    try:
        response = requests.get(GEO_API_URL, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        results = data.get("results")
        if not results:
            return None
        
        target = results[0]
        return {
            "name": target.get("name"),
            "country": target.get("country"),
            "admin1": target.get("admin1"),  # State/Province
            "latitude": target.get("latitude"),
            "longitude": target.get("longitude")
        }
    except requests.exceptions.RequestException as e:
        print(f"Error fetching coordinates: {e}", file=sys.stderr)
        return None

def get_weather(latitude: float, longitude: float, temperature_unit: str = "celsius") -> Optional[Dict[str, Any]]:
    """
    Fetches real-time weather data for given coordinates using the Open-Meteo Forecast API.
    """
    params = {
        "latitude": latitude,
        "longitude": longitude,
        "current": [
            "temperature_2m",
            "relative_humidity_2m",
            "apparent_temperature",
            "is_day",
            "precipitation",
            "weather_code",
            "wind_speed_10m"
        ],
        "temperature_unit": temperature_unit,
        "wind_speed_unit": "kmh",
        "timezone": "auto"
    }
    try:
        response = requests.get(WEATHER_API_URL, params=params, timeout=10)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error fetching weather data: {e}", file=sys.stderr)
        return None

def display_weather(city_info: Dict[str, Any], weather_data: Dict[str, Any]) -> None:
    """
    Formats and prints the retrieved weather data.
    """
    current = weather_data.get("current")
    units = weather_data.get("current_units", {})
    
    if not current:
        print("No current weather data found.", file=sys.stderr)
        return

    location_str = f"{city_info['name']}"
    if city_info.get("admin1"):
        location_str += f", {city_info['admin1']}"
    if city_info.get("country"):
        location_str += f", {city_info['country']}"

    temp = current.get("temperature_2m")
    temp_unit = units.get("temperature_2m", "°C")
    feels_like = current.get("apparent_temperature")
    humidity = current.get("relative_humidity_2m")
    humidity_unit = units.get("relative_humidity_2m", "%")
    wind_speed = current.get("wind_speed_10m")
    wind_unit = units.get("wind_speed_10m", "km/h")
    precipitation = current.get("precipitation")
    precip_unit = units.get("precipitation", "mm")
    weather_code = current.get("weather_code", -1)
    condition = WEATHER_CODES.get(weather_code, "Unknown")
    is_day = current.get("is_day")
    time_str = current.get("time")

    day_night = "Day" if is_day == 1 else "Night"

    print("=" * 50)
    print(f" WEATHER REPORT FOR: {location_str.upper()}")
    print("=" * 50)
    print(f"Local Time:        {time_str}")
    print(f"Condition:         {condition} ({day_night})")
    print(f"Temperature:       {temp}{temp_unit}")
    print(f"Feels Like:        {feels_like}{temp_unit}")
    print(f"Humidity:          {humidity}{humidity_unit}")
    print(f"Wind Speed:        {wind_speed} {wind_unit}")
    print(f"Precipitation:     {precipitation} {precip_unit}")
    print(f"Coordinates:       Lat {city_info['latitude']:.4f}, Lon {city_info['longitude']:.4f}")
    print("=" * 50)

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Fetch real-time weather data for a city using the Open-Meteo API."
    )
    parser.add_argument(
        "city",
        type=str,
        help="The name of the city to lookup weather for."
    )
    parser.add_argument(
        "-u", "--unit",
        type=str,
        choices=["celsius", "fahrenheit"],
        default="celsius",
        help="Temperature unit to display (default: celsius)."
    )
    args = parser.parse_args()

    print(f"Searching for city: '{args.city}'...")
    city_info = get_coordinates(args.city)
    
    if not city_info:
        print(f"Error: Could not find coordinates for city '{args.city}'. Please check the spelling.", file=sys.stderr)
        sys.exit(1)

    print(f"Found location: {city_info['name']} (Lat: {city_info['latitude']}, Lon: {city_info['longitude']})")
    print("Fetching current weather forecast...")
    weather_data = get_weather(city_info["latitude"], city_info["longitude"], args.unit)

    if not weather_data:
        print("Error: Failed to retrieve weather data.", file=sys.stderr)
        sys.exit(1)

    display_weather(city_info, weather_data)

if __name__ == "__main__":
    main()