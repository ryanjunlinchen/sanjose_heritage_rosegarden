import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

// 1. 定义与 JSON 完全一致的玫瑰数据模型
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
        required this.name, required this.bedNumber, required this.roseClass,
        required this.color, required this.hybridist, required this.hybDate,
        required this.adoptionExpire, required this.photoUrl,
        required this.dx, required this.dy,
    });

    factory RoseModel.fromJson(Map<String, dynamic> json) {
        return RoseModel(
            name: json['Variety name'] ?? json['name'] ?? 'Unknown Name',
            bedNumber: json['Bed #'] ?? json['bedNumber'] ?? '',
            roseClass: json['Class'] ?? json['class'] ?? 'Unknown',
            color: json['Color'] ?? json['color'] ?? 'Unknown',
            hybridist: json['Hybridist'] ?? json['hybridist'] ?? 'Unknown',
            hybDate: (json['Hyb. Date'] ?? json['year'] ?? '').toString(),
            adoptionExpire: (json['Adoption Expiration'] ?? json['mon/day/year'] ?? '').toString(),
            photoUrl: json['Photo Link'] ?? json['photoUrl'] ?? '',
            dx: (json['dx'] as num).toDouble(),
            dy: (json['dy'] as num).toDouble(),
        );
    }
}

class RoseGardenInteractiveMapTour extends StatefulWidget {
  const RoseGardenInteractiveMapTour({super.key});

  @override
  State<RoseGardenInteractiveMapTour> createState() => _RoseGardenInteractiveMapTourState();
  
}

class _RoseGardenInteractiveMapTourState extends State<RoseGardenInteractiveMapTour> {
  final TransformationController _transformationController = TransformationController();

  @override
  void dispose() {
      _transformationController.dispose(); // Always dispose controllers to prevent memory leaks
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

      // 监听地图缩放比例,用于性能优化(放大后才渲染密集打点)
      _transformationController.addListener(() {
          setState(() {
              debugPrint("getMax scale ...");
              _currentScale = _transformationController.value.getMaxScaleOnAxis();
          });
      });
  }

  // 2. 异步读取解析你的 JSON 玫瑰表格资产
  Future<List<RoseModel>> _loadAndParseRoses() async {
      print("debug: initialize rose garden database...");
      final String jsonString = await rootBundle.loadString(
          'assets/data/sanjose_heritage_rose_garden_database_filter_used_rose_map.json'
      );
      print("debug: json file text layout loaded into memory...");
      final List<dynamic> jsonList = json.decode(jsonString);
      print("debug: raw list array extracted. Found ${jsonList.length} entry element...");
      _allRoses = jsonList.map((e) => RoseModel.fromJson(e)).toList();
      if (_allRoses.isNotEmpty) {
        debugPrint("get all the Roses ...");
      }
      _displayedRoses = List.from(_allRoses);
      debugPrint("ready to display rose ...");
      return _allRoses;
  }

  // 3. 全局模糊搜索过滤过滤逻辑(支持名字和床号搜索)
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
              title: const Text('San Jose 玫瑰园云导览', style: TextStyle(fontWeight: FontWeight.bold,
              color: Colors.white)),
              backgroundColor: Colors.pink.shade400,
              elevation: 2,
          ),
          body: FutureBuilder<List<RoseModel>>(
              future: _roseDataFuture,
              builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.pink));
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                      return const Center(child: Text('玫瑰园数据库资产加载失败,请检查路径。'));
                  }

                  return Column(
                      children: [
                          // 🔍 顶层浮动搜索过滤栏
                          Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TextField(
                                  onChanged: _filterRoses,
                                  decoration: InputDecoration(
                                      hintText: '搜索玫瑰品种或输入网格床号 (如 Arethusa, K-8-12)...',
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

                          // ️ 主地图交互画布区域
                          Expanded(
                              child: LayoutBuilder(
                                  builder: (context, constraints) {
                                      if(constraints.maxWidth == 0 || constraints.maxHeight == 0) {
                                        debugPrint("Wrong width and height ...");
                                      }
                                    
                                      return Stack (
                                        children: [
                                            InteractiveViewer(                                    
                                                transformationController: _transformationController,
                                                maxScale: 6.0, // 支持放大6倍看清密集的单株
                                                minScale: 1.0,
                                                boundaryMargin: const EdgeInsets.all(20),
                                                child: Stack(
                                                    children: [
                                                        // 【底层】:你的 PNG 高清插画地图资产
                                                        Image.asset(
                                                            'assets/images/sanjose_heritage_rose_garden.png',
                                                            width: constraints.maxWidth,
                                                            fit: BoxFit.contain,
                                                        ),

                                                         // 【上层】:利用百分比坐标,将每朵花以🌳或🌹的组件钉在地图上
                                                         // 【性能优化】:当全景地图未放大(Scale < 2.5)且数据密集时,隐藏单株打点,防止低配手机卡顿

                                                        if (_currentScale >= 2.5 || _allRoses.length < 100)
                                                            ..._displayedRoses.map((rose) {
                                                            return Positioned(
                                                                // 核心公式:相对坐标比例 × 当前容器实际像素宽高 = 精准像素位置
                                                                left: rose.dx * constraints.maxWidth - 12,
                                                                top: rose.dy * constraints.maxHeight - 12,
                                                                child: GestureDetector(
                                                                    // do not allow gesture break by interactiveViewer
                                                                    behavior: HitTestBehavior.opaque,
                                                                    onTap: () {
                                                                        debugPrint("Visitor click the map grid ...");
                                                                        _showRoseBottomSheet(context, rose);
                                                                    },
                                                                    child: MouseRegion(
                                                                        cursor: SystemMouseCursors.click,
                                                                        child: AnimatedContainer(
                                                                            duration: const Duration(milliseconds: 200),
                                                                            child: Icon(
                                                                                rose.bedNumber.contains('Shed') ? Icons.home_work : Icons.yard,
                                                                                color: rose.bedNumber.contains('Shed') ? Colors.teal : Colors.pinkAccent.shade200,
                                                                                size: 22 / (_currentScale * 0.4).clamp(1.0, 2.0), // 随放大倍数动态微调图标大小,防止叠死
                                                                            ),
                                                                        ),
                                                                    ),
                                                                ),
                                                            );
                                                        }),
                                                    ],
                                                ),
                                            ), 

                                            // 2. Floating Zoom Control Panel
                                            Positioned(
                                                bottom: 20,
                                                right: 20,
                                                child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                            // Zoom In Button
                                                            FloatingActionButton.small(
                                                                heroTag: 'zoom_in',
                                                                onPressed: () => _handleZoom(1.5), // Scale up by 1.5x
                                                                child: const Icon(Icons.add),
                                                            ),
                                                            const SizedBox(height: 8),
                                                            // Zoom Out Button
                                                            FloatingActionButton.small(
                                                                heroTag: 'zoom_out',
                                                                onPressed: () => _handleZoom(0.66), // Scale down
                                                                child: const Icon(Icons.remove),
                                                            ),
                                                        ],
                                                ),
                                            ),
                                        ], //children
                                      );
                                  }, //builder
                              ),
                          ), 
                      ],
                  );
              },
          ),
      );
  }


  // 4. 点击花朵时弹出的精美拟物化信息底层抽屉 (BottomSheet)
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
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                          color: Colors.pink.shade50,
                                          borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                          rose.bedNumber,
                                          style: TextStyle(color: Colors.pink.shade700, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                      ),
                                  ),
                                  IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => Navigator.pop(context),
                                  )
                              ],
                          ),
                          const SizedBox(height: 12),
                          Text(rose.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color:Colors.black87)),
                          const SizedBox(height: 8),
                          Text('分类(Class): ${rose.roseClass}', style: const TextStyle(fontSize: 16, color:Colors.black54)),
                          const SizedBox(height: 4),
                          Text('育种作者(Hybridist): ${rose.hybridist} (${rose.hybDate}年)', style: const TextStyle(fontSize: 16, color: Colors.black54)),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 12),

                          // 如果这朵玫瑰有实地 Flickr 网址链接,显示看图互动按钮
                          if (rose.photoUrl.isNotEmpty)
                              ElevatedButton.icon(
                                  icon: const Icon(Icons.photo_library, color: Colors.white),
                                  label: const Text('在线观赏真花花期大图 (Flickr)', style: TextStyle(color: Colors.white,fontSize: 16)),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.pink.shade400,
                                      minimumSize: const Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  onPressed: () async {
                                      final Uri url = Uri.parse(rose.photoUrl);
                                      if (await canLaunchUrl(url)) {
                                          await launchUrl(url, mode: LaunchMode.externalApplication);
                                      }
                                  },
                              )
                          else
                              Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                                  child: const Text('🏕️ 暂无该品种实地花期照片记录', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
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