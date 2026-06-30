
import 'package:flutter/material.dart';
import 'dashboard/home_screen.dart';

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