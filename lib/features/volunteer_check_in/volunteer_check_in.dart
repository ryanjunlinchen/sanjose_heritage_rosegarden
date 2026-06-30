import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Handles local device memory storage persistence

class VolunteerCheckInPage extends StatefulWidget {
  const VolunteerCheckInPage({super.key});

  @override
  State<VolunteerCheckInPage> createState() => VolunteerCheckInPageState();
}

class VolunteerCheckInPageState extends State<VolunteerCheckInPage> {

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

    return Column(
      children: [
        // Hours Display Metrics Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Today\'s Hours', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('$_volunteerHours hrs',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary)),
                  ],
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                Column(
                  children: [
                    const Text('Lifetime Hours', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('$_allTimeHours hrs',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Text input field for specifying work hours
        TextField(
          controller: _todayHoursController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Hours worked today (defaults to 1)',
            prefixIcon: const Icon(Icons.access_time),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 10),

        Text(
          _statusMessage,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          textAlign: TextAlign.center),
        const SizedBox(height: 20),

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
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
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
    );
  }
}