import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather_scheduler.dart'; 

class WeatherApiService {
  // Correct active API server subdomain for raw queries
  final String _baseUrl = "https://api.open-meteo.com/v1/forecast";

  /// Fetches raw weather data and returns the calculated gardening schedule
  Future<List<MaintenanceTask>> fetchGardeningSchedule(String location) async {
    // Default coordinates: San Jose, CA (Lat: 37.3382, Lon: -121.8863)
    double lat = 37.3382;
    double lon = -121.8863;

    if (location.toLowerCase() == "london") {
      lat = 51.5074;
      lon = -0.1278;
    }

    // Clean parameter string tailored explicitly for Open-Meteo engine standards
    final url = Uri.parse(
        '$_baseUrl?latitude=$lat&longitude=$lon&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,wind_gusts_10m_max&hourly=relative_humidity_2m&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch&timezone=auto&forecast_days=1'
    );

    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return _parseAndSchedule(data);
      } else {
        // If the server fails, capture the text to print it onto the screen instead of crashing
        throw Exception('Server error status: ${response.statusCode}. Body: ${response.body}');
      }
    } catch (e) {
      return [
        MaintenanceTask(
          title: 'Connection Error',
          description: 'Could not sync forecast. Details: $e',
          priority: 'High',
        )
      ];
    }
  }

  /// Parses the complex JSON object into numbers the WeatherScheduler can read
  List<MaintenanceTask> _parseAndSchedule(Map<String, dynamic> json) {
    final scheduler = WeatherScheduler();
    
    final daily = json['daily'] ?? {};
    final hourly = json['hourly'] ?? {};

    // Calculate hourly average humidity from the dataset array layout
    List<dynamic> humidities = hourly['relative_humidity_2m'] ?? [];
    double avgHumidity = 60.0;
    if (humidities.isNotEmpty) {
      double sum = humidities.map((e) => (e as num).toDouble()).reduce((a, b) => a + b);
      avgHumidity = sum / humidities.length;
    }

    // FIXED: Unpack parameters safely by pointing to the array index [0] (Today)
    final List<dynamic> rainList = daily['precipitation_sum'] ?? [0.0];
    final List<dynamic> maxTempList = daily['temperature_2m_max'] ?? [72.0];
    final List<dynamic> minTempList = daily['temperature_2m_min'] ?? [55.0];
    final List<dynamic> windList = daily['wind_gusts_10m_max'] ?? [5.0];

    return scheduler.generateSchedule(
      forecastRainInches: (rainList.isNotEmpty ? rainList[0] : 0.0).toDouble(),
      maxTempF: (maxTempList.isNotEmpty ? maxTempList[0] : 72.0).toDouble(),
      minTempF: (minTempList.isNotEmpty ? minTempList[0] : 55.0).toDouble(),
      avgHumidity: avgHumidity,
      maxWindMph: (windList.isNotEmpty ? windList[0] : 5.0).toDouble(),
    );
  }
}
