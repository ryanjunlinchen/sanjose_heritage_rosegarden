import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const RoseGardenApp());
}

class RoseGardenApp extends StatelessWidget {
  const RoseGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SJ Rose Garden',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),    // plant green
          secondary: const Color(0xFFE91E63),  // rose red
          background: const Color(0xFFF5F7F5), // morning mist white
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7F5),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _volunteerHours = 0;
  bool _isLoading = false;
  String _statusMessage = "Ready";

  // San Jose Heritage Rose Garden coordinates
  final double _targetLatitude = 37.3323;
  final double _targetLongitude = -121.9234;
  final double _allowedRadiusInMeters = 200.0; // allowed check-in radius (meters)

  // Core functionality: Retrieve location and verify geofence
  Future<void> _handleCheckIn() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Currently retrieving your GPS location...";
    });

    try {
      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled, please enable GPS in system settings.';
      }

      // 2. Check for and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions denied, unable to verify your location.';
        }
      }
     
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions denied, please grant it in your phone settings.';
      }

      // 3. Get current location in high precision
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      // 4. Calculate the distance from current location to San Jose Heritage Rose Garden in meters
      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        _targetLatitude,
        _targetLongitude,
      );

      // 5. Determine whether inside garden
      setState(() {
        _isLoading = false;
        if (distanceInMeters <= _allowedRadiusInMeters) {
          _volunteerHours += 1;
          _statusMessage = "Check in successful! You are currently in the Rose Garden.";
          _showResultDialog(true, "Check in successful! ", "The distance between the garden is ${distanceInMeters.toStringAsFixed(1)} meters, your working time has been recorded. ");
        } else {
          _statusMessage = "Unable to check in：Outside garden boundaries.";
          _showResultDialog(false, "Unable to check in.", "The distance between the garden is ${ (distanceInMeters / 1000).toStringAsFixed(2) } kilometers。\n\nplease try again after arriving at the park. ");
        }
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = "Error";
      });
      _showResultDialog(false, "Location Failed", e.toString());
    }
  }

  // 弹窗提示函数
  void _showResultDialog(bool success, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary
              ),
              const SizedBox(width: 10),
              Text(title),
            ],
          ),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('San Jose Heritage Rose Garden', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_florist,
                  size: 90,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 30),
             
              // Status Card: System Notification
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Current Status: $_statusMessage',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Status Card: Volunteer Hours
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.stars, color: theme.colorScheme.secondary),
                      const SizedBox(width: 12),
                      Text(
                        'My Volunteer Time: $_volunteerHours Hours',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // check in button 
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _handleCheckIn,
                      icon: const Icon(Icons.gps_fixed, color: Colors.white),
                      label: const Text('Verify GPS and Check In', style: TextStyle(fontSize: 16, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 3,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
