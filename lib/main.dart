import 'package:flutter/material.dart';
import 'rose_garden_app.dart';
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