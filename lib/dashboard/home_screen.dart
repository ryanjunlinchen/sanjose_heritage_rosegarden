import 'package:flutter/material.dart';
import '../features/volunteer_check_in/volunteer_check_in.dart';
import '../features/rose_diagnosis/rose_doctor_page.dart'; 
import '../features/rose_garden_map/rose_garden_virtual_tour.dart';
import '../features/rose_garden_map/rose_garden_map_tour.dart';
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
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: theme.colorScheme.primary,
        centerTitle: true,
      ),
      // 🛠️ FIX 1: Removed FocusScope.unfocus() GestureDetector wrapper from the body background.
      // This background interceptor was clashing with column scroll physics, freezing your buttons.
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // ⚠️ CRITICAL LAYOUT WARNING: 
              // If your buttons still do not click after this update, open up your 
              // 'volunteer_check_in.dart' file and make sure it does NOT use a 'Scaffold' 
              // or its own fullscreen background tap listener inside its build method!
              const VolunteerCheckInPage(),
              
              const SizedBox(height: 30),
              
              // BUTTON: Open Rose Health Identifier
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RoseDoctorPage()),
                    );
                  },
                  icon: Icon(Icons.camera_alt, color: theme.colorScheme.primary),
                  label: Text(
                    'Open Rose Health Identifier',
                    style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.primary, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // BUTTON: View Weather Schedule
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.wb_sunny, color: Colors.white),
                  label: const Text(
                    'View Weather Schedule',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FlowerScheduleScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),

              // BUTTON: Start Virtual Garden Tour
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.explore, color: Colors.white),
                  label: const Text(
                    'Start Virtual Garden Tour',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RoseGardenVirtualTour()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20), 

              // BUTTON: Open Interactive Map Tour
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.map, color: Colors.white),
                  label: const Text(
                    'Open Interactive Map Tour',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RoseGardenInteractiveMapTour()), 
                      //MaterialPageRoute(builder: (context) => const RoseGardenMapTour()), 
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ); 
  }
}
