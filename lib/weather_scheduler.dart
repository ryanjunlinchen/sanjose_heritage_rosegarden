/// Represents a single maintenance task generated from weather analysis.
class MaintenanceTask {
  final String title;
  final String description;
  final String priority; // 'High', 'Medium', 'Low'

  MaintenanceTask({
    required this.title,
    required this.description,
    required this.priority,
  });

  @override
  String toString() => '[$priority] $title: $description';
}

/// Analyzes weather conditions to generate flower maintenance schedules.
class WeatherScheduler {
  
  /// Generates a list of tasks based on weather parameters.
  List<MaintenanceTask> generateSchedule({
    required double forecastRainInches,
    required double maxTempF,
    required double minTempF,
    required double avgHumidity,
    required double maxWindMph,
  }) {
    List<MaintenanceTask> tasks = [];

    // 1. Watering Schedule Logic
    if (forecastRainInches < 1.0) {
      if (maxTempF > 85.0) {
        tasks.add(MaintenanceTask(
          title: 'Increase Watering Frequency',
          description: 'High heat (>85°F) and low rain (<1") detected. Water deeply 3 times this week.',
          priority: 'High',
        ));
      } else {
        tasks.add(MaintenanceTask(
          title: 'Standard Supplemental Watering',
          description: 'Forecast shows less than 1 inch of rain. Provide manual watering to reach the 1" weekly threshold.',
          priority: 'Medium',
        ));
      }
    } else if (forecastRainInches >= 2.0) {
      tasks.add(MaintenanceTask(
        title: 'Pause Manual Irrigation',
        description: 'Heavy rainfall expected ($forecastRainInches"). Turn off automated sprinkler systems to avoid root rot.',
        priority: 'Medium',
      ));
    }

    // 2. Frost Protection Logic
    if (minTempF <= 32.0) {
      tasks.add(MaintenanceTask(
        title: 'Apply Frost Protection',
        description: 'Freezing temperatures alert ($minTempF°F). Cover tender blooms tonight.',
        priority: 'High',
      ));
    }

    // 3. Wind Protection Logic
    if (maxWindMph >= 20.0) {
      tasks.add(MaintenanceTask(
        title: 'Secure Tall Flowers',
        description: 'High wind gusts ($maxWindMph mph) forecasted. Stake tall stems and move potted flowers to a sheltered area.',
        priority: 'High',
      ));
    }

    // 4. Disease and Pest Prevention Logic
    if (avgHumidity > 75.0 && maxTempF >= 70.0) {
      tasks.add(MaintenanceTask(
        title: 'Fungal Disease Prevention',
        description: 'Warm, humid weather breeds fungi. Inspect leaves for powdery mildew and prune dense areas.',
        priority: 'Medium',
      ));
    } else if (maxTempF > 90.0 && forecastRainInches == 0.0) {
      tasks.add(MaintenanceTask(
        title: 'Pest Outbreak Monitoring',
        description: 'Prolonged dry heat triggers spider mites. Mist plant foliage during early morning hours to deter them.',
        priority: 'Low',
      ));
    }

    // 5. Fertilization Timing Logic
    if (forecastRainInches > 0.1 && forecastRainInches < 0.5) {
      tasks.add(MaintenanceTask(
        title: 'Apply Fertilizer',
        description: 'Perfect timing! Light rain ($forecastRainInches") will safely wash nutrients into the root zone.',
        priority: 'Low',
      ));
    }

    return tasks;
  }
}
