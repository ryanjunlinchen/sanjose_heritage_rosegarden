import 'package:flutter/material.dart';
import '../features/volunteer_check_in/volunteer_check_in.dart';
import '../features/rose_diagnosis/rose_doctor_page.dart'; 
//import '../features/rose_garden_map/rose_garden_virtual_tour.dart';
//import '../features/rose_garden_map/rose_garden_map_tour.dart';
import '../features/rose_garden_map/rose_garden_interactive_map_tour.dart';
import 'package:geolocator/geolocator.dart';//for gps check in system
import 'package:shared_preferences/shared_preferences.dart'; //ai diagnosis
import '../main.dart'; 


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Welcome to San Jose Heritage Rose Garden',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Volunteer Check-In
              const VolunteerCheckInPage(),

              const SizedBox(height: 24),

              // BUTTON: Open Rose Health Identifier
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const RoseDoctorPage(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  label: Text(
                    'Open Rose Health Identifier',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // BUTTON: View Weather Schedule
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.wb_sunny,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    'View Weather Schedule',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const FlowerScheduleScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // BUTTON: Open Interactive Map Tour
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.map,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    'Open Interactive Map Tour',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const RoseGardenInteractiveMapTour(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
