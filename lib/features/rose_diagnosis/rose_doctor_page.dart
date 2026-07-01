import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart'; // Handles hidden storage keys
import 'package:http/http.dart' as http; // Handles third-party endpoint mapping
import 'dart:convert';
import 'dart:io';

class RoseDoctorPage extends StatefulWidget {
  const RoseDoctorPage({super.key});

  @override
  State<RoseDoctorPage> createState() => _RoseDoctorPageState();
}

class _RoseDoctorPageState extends State<RoseDoctorPage> {
  File? _imageFile;
  bool _isAnalyzing = false;
  
  String _detectedIssue = "";
  String _organicTreatment = "";

  final ImagePicker _picker = ImagePicker();
  
  // Pull the secure third-party botanical identification key token
  final String _plantIdKey = "fXT8hXdngkSabmAnr5TGpSH8lfcTM1hlZKDXy6qhWc8G9EeHIH";

  Future<void> _captureImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 600, // Downscale image size to minimize mobile data usage on upload
        maxHeight: 600,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isAnalyzing = true;
          _detectedIssue = "";
          _organicTreatment = "";
        });

        // 🚀 ROUTE PAYLOAD TO THE THIRD-PARTY BOTANICAL ENGINE
        await _scanWithThirdPartyAPI();
      }
    } catch (e) {
      setState(() => _isAnalyzing = false);
      _showSnackbar('Hardware Engine Error: $e');
    }
  }
   
   Future<void> _uploadFromGallery() async {
    _pickImageFromSource(ImageSource.gallery);
  }

    // 🛠️ REFACTOR HELPER ENGINE: Unified multi-source selection router
  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 600, // Downscale image size to minimize mobile data usage on upload
        maxHeight: 600,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isAnalyzing = true;
          _detectedIssue = "";
          _organicTreatment = "";
        });

        // 🚀 ROUTE PAYLOAD TO THE THIRD-PARTY BOTANICAL ENGINE
        await _scanWithThirdPartyAPI();
      }
    } catch (e) {
      setState(() => _isAnalyzing = false);
      _showSnackbar('Hardware Engine Error: $e');
    }
  }

  // 🚀 THIRD-PARTY ENDPOINT PARSING ENGINE
  Future<void> _scanWithThirdPartyAPI() async {
    if (_imageFile == null) return;

    if (_plantIdKey.isEmpty) {
      setState(() {
        _isAnalyzing = false;
        _detectedIssue = "API Access Missing";
        _organicTreatment = "Configure your PLANT_ID_API_KEY inside the root project .env configuration token grid.";
      });
      return;
    }

    try {
      // 1. Convert physical camera asset into base64 binary text blocks required by Web API schemas
      final List<int> imageBytes = await _imageFile!.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      // 2. Map standard target URL rules according to Health assessment schemas
      final Uri targetUrl = Uri.parse('https://plant.id');

      // 3. Assemble JSON multi-level layout payloads
      final Map<String, dynamic> payloadJson = {
        "images": ["data:image/jpeg;base64,$base64Image"],
        "latitude": 37.3439,   // Feeds San Jose coordinates to assist region optimization
        "longitude": -121.9072, 
        "language": "en",
      };

      // 4. Dispatch live asynchronous POST call out across web data pipelines
      final http.Response networkResponse = await http.post(
        targetUrl,
        headers: {
          'Content-Type': 'application/json',
          'Api-Key': _plantIdKey,
        },
        body: jsonEncode(payloadJson),
      );

      // 5. Deconstruct incoming structural system JSON trees safely
      if (networkResponse.statusCode == 200 || networkResponse.statusCode == 201) {
        final Map<String, dynamic> dataTree = jsonDecode(networkResponse.body);
        
        final Map<String, dynamic>? resultObj = dataTree['result'];
        
        if (resultObj != null && resultObj['is_healthy'] == false) {
          // Pull target diagnostic properties safely from structural dictionary matrices
          final List diseases = resultObj['disease']['suggestions'];
          final Map leadingDisease = diseases.first;
          
          final String commonName = leadingDisease['name'] ?? "Unknown Affliction";
          final double probability = (leadingDisease['probability'] ?? 0.0) * 100;
          
          // Pull treatment details from third-party biological maps if accessible
          final Map? details = leadingDisease['details'];
          String careTips = "⚠️ NO CHEMICAL PESTICIDES ALLOWED IN SAN JOSE PUBLIC PARKS!\n\n";
          
          if (details != null && details['treatment'] != null) {
            final Map treatments = details['treatment'];
            // Dynamic biological processing checks map treatment strategies strings directly
            if (treatments.containsKey('biological')) {
              careTips += "🌿 Organic Remedies:\n${treatments['biological'].join('\n')}\n\n";
            }
            if (treatments.containsKey('cultural')) {
              careTips += "✂️ Pruning & Cultural Work:\n${treatments['cultural'].join('\n')}";
            }
          } else {
            careTips += "1. Quarantine: Isolate or remove matching target foliage immediately.\n2. Apply organic neem spray treatments at twilight hours.";
          }

          setState(() {
            _detectedIssue = "$commonName (${probability.toStringAsFixed(0)}% Confidence)";
            _organicTreatment = careTips;
            _isAnalyzing = false;
          });
        } else {
          setState(() {
            _detectedIssue = "Healthy Specimen Verified!";
            _organicTreatment = "Third-party assessment reports zero pathogen active traits or insect damage vectors.";
            _isAnalyzing = false;
          });
        }
      } else {
        throw "Server response returned fault code: ${networkResponse.statusCode}";
      }

    } catch (networkFault, stackTrace) {
      // 1. 在控制台打印完整的错误类型和堆栈信息 
      print("================= API ERROR ================="); 
      print("错误类型: ${networkFault.runtimeType}"); print("错误详情: $networkFault"); 
      print("堆栈轨迹:\n$stackTrace"); 
      print("============================================="); 
      _showSnackBarInfo('网络请求异常: ${networkFault.toString().split('\n').first}'); 
      //_setFailState();
      setState(() {
        _isAnalyzing = false;
        _detectedIssue = "Assessment Aborted";
        _organicTreatment = "Database parsing error. Verify third-party portal setup metrics.\nLog: $networkFault";
      });
    }
  }

  void _showSnackBarInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3), // Optional: controls how long it stays
      ),
    );
  }

  void _showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Flower Doctor AI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                        Text('Point camera at any flower', style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(_imageFile!, fit: BoxFit.cover), 
                    ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                // Source Selector Path A: Live Hardware Lens Trigger
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : _captureImage,
                      icon: const Icon(Icons.photo_camera, color: Colors.white),
                      label: const Text('Take Photo', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Source Selector Path B: Local Gallery Upload Engine
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : _uploadFromGallery,
                      icon: const Icon(Icons.image_search, color: Colors.white),
                      label: const Text('Upload Image', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),


            if (_isAnalyzing) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              const Text('Analyzing plant visuals via secure server...', 
              style: TextStyle(fontStyle: FontStyle.italic)),
            ],

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
                          Icon(Icons.local_florist, color: theme.colorScheme.secondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _detectedIssue, 
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Text(
                        _organicTreatment,
                        style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ]
        ),
      ),
    );  
  }
}
