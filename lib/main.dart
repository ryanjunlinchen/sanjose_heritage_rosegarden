import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Handles local device memory storage persistence
import 'rose_doctor_page.dart'; // 🚀 ADDED: Imports your camera scanner screen module

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
          surface: const Color(0xFFF5F7F5),    // morning mist white
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
  int _allTimeHours = 0;   // Track permanent master running history history
  bool _isLoading = false;
  String _statusMessage = "Ready";

  // Single controller tool to extract custom inputs typed into the single input field
  final TextEditingController _todayHoursController = TextEditingController();

  // San Jose Heritage Rose Garden real center coordinates
  final double _targetLatitude = 37.34392;
  final double _targetLongitude = -121.90729;
  final double _allowedRadiusInMeters = 500.0; // allowed check-in radius (meters)

  @override
  void initState() {
    super.initState();
    _loadSavedHours(); // Automatically pull saved hours from the disk when the screen initializes
  }

  @override
  void dispose() {
    _todayHoursController.dispose(); // Avoid memory footprint leaks by explicitly disposing controller object
    super.dispose();
  }

  // Helper function to format a unique daily validation string
  String _getTodayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  // Reads the device's storage drive to restore the volunteer's historic hours
  Future<void> _loadSavedHours() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    // Fetch historical data metrics from separate storage tracks
    int savedDailyHours = prefs.getInt('saved_volunteer_hours_key') ?? 0;
    int savedAllTimeHours = prefs.getInt('saved_all_time_hours_key') ?? 0;
    String? lastDateStr = prefs.getString('saved_last_check_in_date_key');

    final now = DateTime.now();
    final todayStr = _getTodayDateString(); 

    // Automated Midnight Checking Protocol: If the calendar date changes, reset the daily counter
    if (lastDateStr != null && lastDateStr != todayStr) {
      savedDailyHours = 0; // Wipe yesterday's daily record cleanly back to zero
    }

    setState(() {
      _volunteerHours = savedDailyHours; 
      _allTimeHours = savedAllTimeHours; // Restores master lifetime history tracking
    });
  }

  // Commits both counters independently directly onto local device hard drive storage
  Future<void> _saveHoursToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _getTodayDateString(); 

    await prefs.setInt('saved_volunteer_hours_key', _volunteerHours);
    await prefs.setInt('saved_all_time_hours_key', _allTimeHours); // Store grand history separately
    await prefs.setString('saved_last_check_in_date_key', todayStr); // Locks down calendar day date tag
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

      // 5. Determine whether inside garden
      setState(() {
        _isLoading = false;
        if (distanceInMeters <= _allowedRadiusInMeters) {
          
          // Read the single input value safely. Fallback cleanly to 1 hour if it is empty.
          int enteredHours = int.tryParse(_todayHoursController.text) ?? 1;

          // Simultaneously add the EXACT same user input to both variables
          _volunteerHours += enteredHours;
          _allTimeHours += enteredHours; 
          _statusMessage = "Check in successful! You are currently in the Rose Garden.";
          
          _saveHoursToDisk(); // Triggers local file system update block
          _todayHoursController.clear(); // Automatically empty text element for clear next-run
          
          // Refined success dialog reflecting singular input values mapped to dual categories
          _showResultDialog(
            true, 
            "Check in successful! ", 
            "The distance between the garden is ${distanceInMeters.toStringAsFixed(1)} meters. Successfully logged $enteredHours hours to both your daily shift and lifetime records."
          );
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Automatically dismisses the keypad when tapping blank canvas space
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0x1A2E7D32), // Standard 10% opacity primary green color token
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
                    side: const BorderSide(color: Color(0x332E7D32)), // Standard 20% opacity green boundary
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
                      ), // 👍 FIXED: Closed missing structural parenthesis here to stop argument errors
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status Card: Double row display tracking both variables independently
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0x332E7D32)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.today, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          "Today's Time: $_volunteerHours Hours",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(height: 1, color: Color(0x1A000000)),
                    ),
                    Row(
                      children: [
                        Icon(Icons.stars, color: theme.colorScheme.secondary),
                        const SizedBox(width: 12),
                        Text(
                          'Total Lifetime Time: $_allTimeHours Hours',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Singular Input Box Card Layout: Custom Hours Entry to apply toward both counts simultaneously
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0x332E7D32)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: TextField(
                  controller: _todayHoursController,
                  keyboardType: TextInputType.number, // Strips alphabetic options from mobile layout boards
                  decoration: const InputDecoration(
                    icon: Icon(Icons.edit_calendar_outlined),
                    border: InputBorder.none,
                    labelText: "Hours to log for today's shift",
                    hintText: 'Defaults to 1 if empty',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🚀 ADDED: Open Rose Doctor AI Navigation Link Button Layout Element
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RoseDoctorPage()),
                );
              },
              icon: Icon(Icons.medication_liquid_outlined, color: theme.colorScheme.primary),
              label: const Text('Open Rose Doctor AI', style: TextStyle(fontSize: 16, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                side: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 30),

            // Check in Action Trigger Button
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _handleCheckIn,
                      icon: const Icon(Icons.gps_fixed, color: Colors.white),
                      label: const Text(
                        'Verify GPS and Check In',
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
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
);
  }
}
