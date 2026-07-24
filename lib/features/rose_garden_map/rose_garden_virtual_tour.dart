import 'package:flutter/material.dart';

class RoseGardenVirtualTour extends StatefulWidget {
  const RoseGardenVirtualTour({super.key});

  @override
  State<RoseGardenVirtualTour> createState() => _RoseGardenVirtualTourState();
}

class _RoseGardenVirtualTourState extends State<RoseGardenVirtualTour> {
  // 1. Data sequential list representing each section of your garden
  final List<Map<String, String>> _tourSteps = [
    {
      'title': 'Heritage Garden Entrance',
      'description': 'Welcome to the garden! Walk straight ahead down the stone path to begin your tour.',
      'image': 'assets/images/tour_entrance.jpg', 
    },
    {
      'title': 'Central Rose Quadrant',
      'description': 'This section features our beautiful roses. Tap the flashing health monitor icon to view active plant diagnostic analytics.',
      'image': 'assets/images/tour_roses.jpg',
    },
    {
      'title': 'Tropical Greenhouse',
      'description': 'An enclosed climate-controlled pavilion dedicated to sensitive indoor flora and exotic jungle ferns.',
      'image': 'assets/images/tour_greenhouse.jpg',
    },
  ];

  int _currentIndex = 0;

  // 2. Displays your precise Plant.id treatment analytics inside a clean bottom panel
  void _showHealthDetails() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rose Black Spot Detected', 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 4),
            const Text(
              'Fungal Infection (Diplocarpon)', 
              style: TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
            const Divider(height: 24),
            const Text('Recommended Treatment:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('• Chemical: Apply fungicides containing chlorothalonil or copper spray.'),
            const Text('• Biological: Prune internal branches for ventilation and clear fallen leaves.'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _tourSteps[_currentIndex];

    return Scaffold(
      body: Stack(
        children: [
          // Background Image Layer
          Positioned.fill(
            child: Image.asset(
              currentStep['image']!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback colored background container if local assets are missing during build testing
                return Container(
                  color: Colors.green.shade900,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 50, color: Colors.white),
                  ),
                );
              },
            ),
          ),
          
          // Floating Top Back Navigation Button
          Positioned(
            top: 50,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          
          // Contextual Hotspot Pin (Only appears when viewing the Central Rose Quadrant step)
          if (_currentIndex == 1) 
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              left: MediaQuery.of(context).size.width * 0.45,
              child: GestureDetector(
                onTap: _showHealthDetails,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red, 
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.24), 
                        blurRadius: 10, 
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.healing, color: Colors.white, size: 28),
                ),
              ),
            ),
            
          // Bottom Control Center Panel
          Positioned(
            bottom: 40,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.96),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12), 
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentStep['title']!, 
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currentStep['description']!, 
                    style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.arrow_back_ios, size: 14),
                        label: const Text('Back'),
                        onPressed: _currentIndex > 0 
                            ? () => setState(() => _currentIndex--) 
                            : null,
                      ),
                      Text(
                        '${_currentIndex + 1} / ${_tourSteps.length}', 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _currentIndex < _tourSteps.length - 1 
                            ? () => setState(() => _currentIndex++) 
                            : null,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Next'),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios, size: 14),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
