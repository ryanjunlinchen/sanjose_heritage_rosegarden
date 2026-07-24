import 'package:flutter/material.dart';
import 'rose_garden_app.dart';
import 'features/weather/weather_scheduler.dart';
import 'features/weather/weather_api_service.dart';


//import 'package:geolocator/geolocator.dart';
//import 'package:shared_preferences/shared_preferences.dart'; // Handles local device memory storage persistence
//import 'rose_doctor_page.dart'; // 🚀 ADDED: Imports your camera scanner screen module

void main() {
  runApp(const RoseGardenAppRoot());
}

class RoseGardenAppRoot extends StatelessWidget {
  const RoseGardenAppRoot({super.key});

  @override
  Widget build(BuildContext context) {
      return const RoseGardenApp();    
  }
}
class FlowerScheduleScreen extends StatefulWidget {
  const FlowerScheduleScreen({super.key});

  @override
  State<FlowerScheduleScreen> createState() => _FlowerScheduleScreenState();
}

class _FlowerScheduleScreenState extends State<FlowerScheduleScreen> {
  // Free demo API key to test the connection
  final WeatherApiService _weatherService = WeatherApiService();
  late Future<List<MaintenanceTask>> _scheduleFuture;

  @override
  void initState() {
    super.initState();
    // Loads weather tasks for London when this screen opens
     _scheduleFuture = _weatherService.fetchGardeningSchedule("San Jose");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flower Maintenance Tasks'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<MaintenanceTask>>(
        future: _scheduleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          } 
          
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks scheduled for today.'));
          }

          final tasks = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              
              Color priorityColor = Colors.yellow;
              if (task.priority == 'High') priorityColor = Colors.red;
              if (task.priority == 'Medium') priorityColor = Colors.orange;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: priorityColor,
                    child: Text(
                      task.priority[0], // Shows 'H', 'M', or 'L'
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(task.description),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
