import 'package:flutter/material.dart';
import '../features/volunteer_check_in/volunteer_check_in.dart';
import '../features/rose_diagnosis/rose_doctor_page.dart'; 
// 1. ADDED: Points to your main.dart file so this page can see the Weather Schedule Screen
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), 
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                // Embedded the isolated functional Check-In feature panel here
                const VolunteerCheckInPage(),
                
                const SizedBox(height: 30),
                
                // Diagnosis feature navigation route hook trigger button
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

                // 2. FIXED: Added a gap and placed the Weather Schedule button safely inside the layout layout
                const SizedBox(height: 20),

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
              ],
            ),
          ),
        ),
      ),
    ); // The return statement safely ends here now
  }
}
