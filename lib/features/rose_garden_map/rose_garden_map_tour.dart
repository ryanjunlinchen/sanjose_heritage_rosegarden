import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 

class RoseGardenMapTour extends StatefulWidget {
  const RoseGardenMapTour({super.key});

  @override
  State<RoseGardenMapTour> createState() => _RoseGardenMapTourState();
  
}

class _RoseGardenMapTourState extends State<RoseGardenMapTour> {
  final TransformationController _transformationController = TransformationController();

  @override
  void dispose() {
    _transformationController.dispose(); // Always dispose controllers to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('San Jose Rose Garden Tour')),
      body: Center(
        child: Builder(
          builder: (innerContext) {
            return InteractiveViewer(
              transformationController: _transformationController,
              maxScale: 5.0,
              minScale: 1.0,
              // FIX 1: Set interactive to false if you only want taps, 
              // or keep it true but ensure the child fills space.
              child: SizedBox(
                // FIX 2: Give the asset explicit layout bounds so hit-testing succeeds
                width: MediaQuery.of(innerContext).size.width,
                height: MediaQuery.of(innerContext).size.height,
                child: GestureDetector(
                  // FIX 3: DeferToChild forces Flutter to check the SVG boundaries
                  behavior: HitTestBehavior.deferToChild, 
                  onTapUp: (details) => _handleMapTap(innerContext, details),
                  child: SvgPicture.asset(
                    'assets/images/rose_garden_map.svg', 
                    fit: BoxFit.contain,
                    // FIX 4: Add placeholders to guarantee layout sizes even if asset fails to load
                    placeholderBuilder: (BuildContext context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  void _handleMapTap(BuildContext context, TapUpDetails details) {
    // For now, this placeholder always passes "A1" when clicked
    print("Map tapped at: ${details.localPosition}");
    String detectedBedId = "A1"; 
    String roseName = "Baronne Prévost";
    String roseType = "Hybrid Perpetual • Deep Pink (1842)";

    // ➕ ADD THIS LOGIC BLOCK RIGHT AFTER YOUR VARIABLE DECLARATIONS:

// Fetch screen sizing measurements
final double screenWidth = MediaQuery.of(context).size.width;
final double screenHeight = MediaQuery.of(context).size.height;

if (details.localPosition.dx < (screenWidth / 2)) {
  // --- LEFT SIDE ---
  if (details.localPosition.dy < (screenHeight / 2)) {
    detectedBedId = "Bed A1";
    roseName = "Baronne Prévost";
    roseType = "Hybrid Perpetual • Deep Pink (1842)";
  } else {
    detectedBedId = "Bed A2";
    roseName = "Souvenir de la Malmaison";
    roseType = "Bourbon • Pale Pink (1843)";
  }
} else {
  // --- RIGHT SIDE ---
  if (details.localPosition.dy < (screenHeight / 2)) {
    detectedBedId = "Bed B1";
    roseName = "Cecile Brunner";
    roseType = "Polyantha • Light Pink (1881)";
  } else {
    detectedBedId = "Bed B2";
    roseName = "Mermaid";
    roseType = "Hybrid Bracteata • Pale Yellow (1917)";
  }
}


    try {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          // 🛠️ UPDATE YOUR RETURN STATEMENT TO LOOK LIKE THIS:
          return RoseDetailsSheet(
            bedId: detectedBedId,
            roseName: roseName,
            roseType: roseType,
          );

          // Debug Step 2: Check if the bottom sheet widget is building
        },
      );
    } catch (e) {
      // Debug Step 3: Check if Flutter is throwing a silent context error
      print("Error opening bottom sheet: $e");
    }
  }
}

class RoseDetailsSheet extends StatelessWidget {
  final String bedId;
  final String roseName; // ➕ Add this parameter line
  final String roseType ; // ➕ Add this parameter line
  const RoseDetailsSheet({
  super.key, 
  required this.bedId,
  required this.roseName,
  required this.roseType,
});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      maxChildSize: 0.8,
      expand: false,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(16),
        children: [
          Text('Rose Bed $bedId', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 10),
          ListTile(
            title: Text(roseName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), // 🚀 Use variable
            subtitle: Text(roseType), // 🚀 Use variable
            leading: const Icon(Icons.yard, color: Colors.pink, size: 30),
          ),
        ],
      ),
    );
  }
}
