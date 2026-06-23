import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added dependency to handle local physical storage persistence

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
          surface: const Color(0xFFF5F7F5),    // morning mist white (Mapped to surface for Material 3 uniformity)
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
  int _volunteerHours = 0; // Handled as your Daily Volunteer Hours counter
  int _allTimeHours = 0;   // Added state field to protect and store your permanent master running history
  bool _isLoading = false;
  String _statusMessage = "Ready";

  // San Jose Heritage Rose Garden coordinates
  final double _targetLatitude = 37.3323;
  final double _targetLongitude = -121.9234;
  final double _allowedRadiusInMeters = 200.0; // allowed check-in radius (meters)

  @override
  void initState() {
    super.initState();
    _loadSavedHours(); // Automatically pull saved hours from the disk when the screen initializes
  }

  // Reads the device's storage drive to restore the volunteer's historic hours
  Future<void> _loadSavedHours() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    // Fetch historical data metrics from storage fields
    int savedDailyHours = prefs.getInt('saved_volunteer_hours_key') ?? 0;
    int savedAllTimeHours = prefs.getInt('saved_all_time_hours_key') ?? 0;
    String? lastDateStr = prefs.getString('saved_last_check_in_date_key');

    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}"; // Unique string key representation of today's date

    // Automated Midnight Checking Protocol: If the calendar date changes, reset the daily counter
    if (lastDateStr != null && lastDateStr != todayStr) {
      savedDailyHours = 0; // Wipe yesterday's daily record cleanly back to zero
    }

    setState(() {
      _volunteerHours = savedDailyHours; // Fallback to 0 if it's the first time opening the app
      _allTimeHours = savedAllTimeHours; // Restores master background counter metrics
    });
  }

  // Commits the newly accumulated hour count directly onto physical device storage
  Future<void> _saveHoursToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";

    await prefs.setInt('saved_volunteer_hours_key', _volunteerHours);
    await prefs.setInt('saved_all_time_hours_key', _allTimeHours); // Added persistent preservation for the grand history value
    await prefs.setString('saved_last_check_in_date_key', todayStr); // Locks down the last active day calendar timestamp
  }

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

      if (!mounted) return;

      // 5. Determine whether inside garden
      setState(() {
        _isLoading = false;
        if (distanceInMeters <= _allowedRadiusInMeters) {
          _volunteerHours += 1;
          _allTimeHours += 1; // Safely increments permanent grand history total metrics simultaneously
          _statusMessage = "Check in successful! You are currently in the Rose Garden.";
          
          _saveHoursToDisk(); // Triggers storage operation right after confirming valid check-in
          
          _showResultDialog(true, "Check in successful! ", "The distance between the garden is ${distanceInMeters.toStringAsFixed(1)} meters, your working time has been recorded. ");
        } else {
          _statusMessage = "Unable to check in：Outside garden boundaries.";
          _showResultDialog(false, "Unable to check in.", "The distance between the garden is ${ (distanceInMeters / 1000).toStringAsFixed(2) } kilometers。\n\nplease try again after arriving at the park. ");
        }
      });

    } catch (e) {
      if (!mounted) return;
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
              Expanded(child: Text(title)),
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
                decoration: const BoxDecoration(
                  color: Color(0x1A2E7D32), // Hardcoded 10% opacity primary green for broad Flutter SDK support
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_florist,
                  size: 90,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 30),
             
              // Status Card: System Notification (Only one clean card kept)
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0x332E7D32)), // Hardcoded 20% opacity primary green border
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

              // Status Card: Daily Volunteer Hours
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0x332E7D32)), // Hardcoded 20% opacity primary green border
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        'Today\'s Volunteer Hours',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_volunteerHours',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Status Card: Cumulative Master All-Time Hours
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0x332E7D32)), // Hardcoded 20% opacity primary green border
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        'Grand Total Volunteer Hours',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_allTimeHours',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary, // Stylized with rose red for card distinction
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleCheckIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.location_on),
                  label: Text(
                    _isLoading ? 'Checking In...' : 'Check In at Garden',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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