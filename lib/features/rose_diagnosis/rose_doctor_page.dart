import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RoseDoctorPage extends StatefulWidget {
  const RoseDoctorPage({super.key});

  @override
  State<RoseDoctorPage> createState() => _RoseDoctorPageState();
}

class _RoseDoctorPageState extends State<RoseDoctorPage> {
  File? _imageFile;
  bool _isAnalyzing = false;
  
  // Diagnostic state variables
  String _detectedIssue = "";
  String _organicTreatment = "";

  final ImagePicker _picker = ImagePicker();

  // Core Function: Handle camera capture
  Future<void> _captureImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080, // Optimizes file size for performance
        maxHeight: 1080,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isAnalyzing = true;
          _detectedIssue = "";
          _organicTreatment = "";
        });

        // Simulate AI analysis delay
        await Future.delayed(const Duration(seconds: 2));

        _runOrganicDiagnosis();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera error: $e')),
      );
    }
  }

  // Organic Treatment Knowledge Base (Eco-Friendly / Chemical-Free)
  void _runOrganicDiagnosis() {
    if (!mounted) return;
    setState(() {
      _isAnalyzing = false;
      
      // For demonstration, we simulate finding Black Spot. 
      // In production, this data will come from your machine learning endpoint.
      _detectedIssue = "Black Spot Fungus (黑斑病)";
      _organicTreatment = 
          "⚠️ NO CHEMICAL PESTICIDES ALLOWED IN THIS GARDEN!\n\n"
          "1. Pruning: Carefully snip off infected leaves and drop them into a trash can. Do NOT compost them.\n\n"
          "2. Baking Soda Spray: Mix 1 tablespoon of baking soda, 1/2 teaspoon of liquid non-detergent soap, and 1 gallon of water. Spray thoroughly on dry leaves.\n\n"
          "3. Prevention: Always water the base of the rose plant, never wet the leaves directly.";
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rose Doctor AI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image Preview Window
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x332E7D32)), 
              ),
              child: _imageFile == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_camera, size: 60, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No rose scanned yet', style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(_imageFile!, fit: BoxFit.cover), 
                    ),
            ),
            const SizedBox(height: 24),

            // Scan Action Trigger Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _captureImage,
                icon: const Icon(Icons.center_focus_strong, color: Colors.white),
                label: const Text('Scan Rose Leaf', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Analysis UI Feedback State
            if (_isAnalyzing) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              const Text('AI running eco-analysis...', style: TextStyle(fontStyle: FontStyle.italic)),
            ],

            // Diagnostic & Organic Remedy Card Presentation Layout
            if (_detectedIssue.isNotEmpty) ...[
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0x4DE91E63)), 
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: theme.colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text('Diagnosis: $_detectedIssue', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 24),
                      Text(
                        _organicTreatment,
                        style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87), // 👍 FIXED: Changed black85 to valid Colors.black87 token
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
