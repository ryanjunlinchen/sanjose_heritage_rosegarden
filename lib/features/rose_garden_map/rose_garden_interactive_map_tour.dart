import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

// 1. Define a Rose data model that is completely consistent with JSON
class RoseModel {
  final String name;
  final String bedNumber;
  final String roseClass;
  final String color;
  final String hybridist;
  final String hybDate;
  final String adoptionExpire;
  final String photoUrl;
  final double dx;
  final double dy;

  RoseModel({
    required this.name,
    required this.bedNumber,
    required this.roseClass,
    required this.color,
    required this.hybridist,
    required this.hybDate,
    required this.adoptionExpire,
    required this.photoUrl,
    required this.dx,
    required this.dy,
  });

  factory RoseModel.fromJson(Map<String, dynamic> json) {
    return RoseModel(
      name: json['Variety name'] ?? json['name'] ?? 'Unknown Name',
      bedNumber: json['Bed #'] ?? json['bedNumber'] ?? '',
      roseClass: json['Class'] ?? json['class'] ?? 'Unknown',
      color: json['Color'] ?? json['color'] ?? 'Unknown',
      hybridist: json['Hybridist'] ?? json['hybridist'] ?? 'Unknown',
      hybDate: (json['Hyb. Date'] ?? json['year'] ?? '').toString(),
      adoptionExpire:
          (json['Adoption Expiration'] ?? json['mon/day/year'] ?? '')
              .toString(),
      photoUrl: json['Photo Link'] ?? json['photoUrl'] ?? '',
      dx: (json['dx'] as num).toDouble(),
      dy: (json['dy'] as num).toDouble(),
    );
  }
}

class RoseGardenInteractiveMapTour extends StatefulWidget {
  const RoseGardenInteractiveMapTour({super.key});

  @override
  State<RoseGardenInteractiveMapTour> createState() =>
      _RoseGardenInteractiveMapTourState();
}

class _RoseGardenInteractiveMapTourState
    extends State<RoseGardenInteractiveMapTour> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController
        .dispose(); // Always dispose controllers to prevent memory leaks
    super.dispose();
  }

  late Future<List<RoseModel>> _roseDataFuture;
  List<RoseModel> _allRoses = [];
  List<RoseModel> _displayedRoses = [];
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    debugPrint("init state ...");
    _roseDataFuture = _loadAndParseRoses();

    // Listen to the map zoom level for performance optimization (only render dense markers after zooming in)
    _transformationController.addListener(() {
      setState(() {
        debugPrint("getMax scale ...");
        _currentScale = _transformationController.value.getMaxScaleOnAxis();
      });
    });
  }

  // 2. Asynchronously read and parse your JSON rose table assets
  Future<List<RoseModel>> _loadAndParseRoses() async {
    print("debug: initialize rose garden database...");
    final String jsonString = await rootBundle.loadString(
      'assets/data/sanjose_heritage_rose_garden_database.json',
    );
    print("debug: json file text layout loaded into memory...");
    final List<dynamic> jsonList = json.decode(jsonString);
    print(
      "debug: raw list array extracted. Found ${jsonList.length} entry element...",
    );
    _allRoses = jsonList.map((e) => RoseModel.fromJson(e)).toList();
    if (_allRoses.isNotEmpty) {
      debugPrint("get all the Roses ...");
    }
    _displayedRoses = List.from(_allRoses);
    debugPrint("ready to display rose ...");
    return _allRoses;
  }

  // 3. Global fuzzy search filtering logic (supporting search by name and bed number)
  void _filterRoses(String query) {
    debugPrint("Filter rose ...");
    setState(() {
      if (query.isEmpty) {
        _displayedRoses = List.from(_allRoses);
      } else {
        _displayedRoses = _allRoses.where((rose) {
          return rose.name.toLowerCase().contains(query.toLowerCase()) ||
              rose.bedNumber.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
      debugPrint("finished filter ...");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'San Jose Rose Garden Virtual Tour',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.pink.shade400,
        elevation: 2,
      ),
      body: FutureBuilder<List<RoseModel>>(
        future: _roseDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.pink),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('Database loading failed, please check the path.'),
            );
          }

          return Column(
            children: [
              // 🔍 Top Floating Search Filter Bar
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  onChanged: _filterRoses,
                  decoration: InputDecoration(
                    hintText:
                        'Search for rose varieties or enter a grid bed number (e.g., Arethusa, K-8-12)...',
                    prefixIcon: const Icon(Icons.search, color: Colors.pink),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // ️ Main Map Interactive Canvas Area
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Match the original map image dimensions.
                    const double mapAspectRatio = 1182 / 1330;

                    late final double mapWidth;
                    late final double mapHeight;

                    if (constraints.maxWidth / constraints.maxHeight >
                        mapAspectRatio) {
                      mapHeight = constraints.maxHeight;
                      mapWidth = mapHeight * mapAspectRatio;
                    } else {
                      mapWidth = constraints.maxWidth;
                      mapHeight = mapWidth / mapAspectRatio;
                    }

                    return Center(
                      child: SizedBox(
                        width: mapWidth,
                        height: mapHeight,
                        child: Stack(
                          children: [
                            // MAP + ROSE MARKERS
                            Positioned.fill(
                              child: InteractiveViewer(
                                transformationController:
                                    _transformationController,
                                minScale: 1.0,
                                maxScale: 6.0,
                                boundaryMargin: const EdgeInsets.all(20),
                                child: SizedBox(
                                  width: mapWidth,
                                  height: mapHeight,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Map image
                                      Positioned.fill(
                                        child: Image.asset(
                                          'assets/images/'
                                          'sanjose_heritage_rose_garden_map.png',
                                          fit: BoxFit.fill,
                                        ),
                                      ),

                                      // Rose markers
                                      if (_currentScale >= 2.5 ||
                                          _allRoses.length < 100)
                                        ..._displayedRoses.map((rose) {
                                          const double iconSize = 8.0;

                                          return Positioned(
                                            left:
                                                rose.dx * mapWidth -
                                                iconSize / 2,
                                            top:
                                                rose.dy * mapHeight -
                                                iconSize / 2,
                                            child: GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onTap: () {
                                                debugPrint(
                                                  'Selected rose: '
                                                  '${rose.bedNumber}',
                                                );
                                                _showRoseBottomSheet(
                                                  context,
                                                  rose,
                                                );
                                              },
                                              child: MouseRegion(
                                                cursor:
                                                    SystemMouseCursors.click,
                                                child: Icon(
                                                  rose.bedNumber.contains(
                                                        'Shed',
                                                      )
                                                      ? Icons.home_work
                                                      : Icons.yard,
                                                  color:
                                                      rose.bedNumber.contains(
                                                        'Shed',
                                                      )
                                                      ? Colors.teal
                                                      : Colors.pinkAccent,
                                                  size: iconSize,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // ZOOM CONTROLS
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Zoom in
                                  FloatingActionButton.small(
                                    heroTag: 'zoom_in',
                                    onPressed: () {
                                      setState(() {
                                        _currentScale = (_currentScale * 1.3)
                                            .clamp(1.0, 6.0)
                                            .toDouble();
                                      });

                                      _transformationController.value =
                                          Matrix4.diagonal3Values(
                                            _currentScale,
                                            _currentScale,
                                            1.0,
                                          );
                                    },
                                    child: const Icon(Icons.add),
                                  ),

                                  const SizedBox(height: 8),

                                  // Zoom out
                                  FloatingActionButton.small(
                                    heroTag: 'zoom_out',
                                    onPressed: () {
                                      setState(() {
                                        _currentScale = (_currentScale / 1.3)
                                            .clamp(1.0, 6.0)
                                            .toDouble();
                                      });

                                      _transformationController.value =
                                          Matrix4.diagonal3Values(
                                            _currentScale,
                                            _currentScale,
                                            1.0,
                                          );
                                    },
                                    child: const Icon(Icons.remove),
                                  ),

                                  const SizedBox(height: 8),

                                  // Reset zoom
                                  FloatingActionButton.small(
                                    heroTag: 'zoom_reset',
                                    onPressed: () {
                                      setState(() {
                                        _currentScale = 1.0;
                                      });

                                      _transformationController.value =
                                          Matrix4.identity();
                                    },
                                    child: const Icon(Icons.refresh),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 4. An elegant releastic information bottom drawer that pops up when a flower is clicked. (BottomSheet)
  void _showRoseBottomSheet(BuildContext context, RoseModel rose) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      rose.bedNumber,
                      style: TextStyle(
                        color: Colors.pink.shade700,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                rose.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Class: ${rose.roseClass}',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Text(
                'Hybridist: ${rose.hybridist} (${rose.hybDate}year)',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // If this rose has a real-world Flickr URL link, display the photo-interaction button.
              if (rose.photoUrl.isNotEmpty)
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library, color: Colors.white),
                  label: const Text(
                    'View large photos of real flowers in bloom online (Flickr)',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade400,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    final Uri url = Uri.parse(rose.photoUrl);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '🏕️ There is currently no field photo record of this varietys blooming period',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _handleZoom(double factor) {
    final Matrix4 currentMatrix = _transformationController.value;

    // Calculate the new scale matrix
    final Matrix4 newMatrix = currentMatrix.clone()..scale(factor);

    // Extract the actual scale factor from the matrix element
    final double newScale = newMatrix.row0.xyz.length;

    // Constrain the zoom within your predefined limits (1.0 to 6.0)
    if (newScale >= 1.0 && newScale <= 6.0) {
      setState(() {
        _transformationController.value = newMatrix;
        _currentScale = newScale; // Keeps your UI scale check synchronized
      });
    }
  }
}
