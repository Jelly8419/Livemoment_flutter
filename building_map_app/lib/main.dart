import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'models/building.dart';
import 'data/dummy_buildings.dart';
import 'config/api_config.dart';
import 'pages/room_registration_page.dart';

/// 앱의 진입점
void main() {
  // WebView 플랫폼 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // API 키 유효성 검사
  if (!ApiConfig.isApiKeyValid()) {
    debugPrint('경고: Google Maps API 키가 설정되지 않았거나 유효하지 않습니다.');
    debugPrint('API 키: ${ApiConfig.googleMapsApiKey}');
  }

  runApp(const MyApp());
}

/// 메인 앱 클래스
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Now Stay',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

/// 홈 화면 위젯
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('부동산 매물 앱'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 앱 로고나 제목
              Icon(
                Icons.location_city,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              const Text(
                '부동산 매물 검색',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '지도에서 다양한 건물과 매물 정보를 확인하세요',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // 매물 검색 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // 지도 화면으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MapScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search),
                      SizedBox(width: 8),
                      Text(
                        '매물 검색',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 호스트 전용 방 등록 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    // 방 등록 화면으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RoomRegistrationPage(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_home, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        '방 등록하기 (호스트 전용)',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 지도 화면을 보여주는 위젯
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

/// 지도 화면의 상태를 관리하는 클래스
class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController; // 구글 맵 컨트롤러
  Set<Marker> markers = {}; // 지도에 표시할 마커들

  /// 초기 카메라 위치 (서울시청 좌표)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.5666805, 126.9784147), // 서울시청 좌표
    zoom: 11.0,
  );

  @override
  void initState() {
    super.initState();
    _createMarkers(); // 마커 생성
  }

  /// 건물 데이터를 기반으로 마커를 생성하는 메소드
  void _createMarkers() {
    markers = DummyBuildings.buildings.map((building) {
      return Marker(
        markerId: MarkerId(building.id.toString()),
        position: LatLng(building.latitude, building.longitude),
        infoWindow: InfoWindow(
          title: building.name,
          snippet: building.type,
        ),
        onTap: () => _showBuildingDetails(building), // 마커 탭 시 상세 정보 표시
      );
    }).toSet();
  }

  /// 건물 상세 정보를 모달로 표시하는 메소드
  void _showBuildingDetails(Building building) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 건물명
              Text(
                building.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // 건물 타입
              Text(
                building.type,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              // 주소 정보
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      building.address,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 건물 설명
              Text(
                building.description,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              // 닫기 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 지도가 생성되었을 때 호출되는 콜백
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('건물 지도'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated, // 지도 생성 콜백
        initialCameraPosition: _initialPosition, // 초기 카메라 위치
        markers: markers, // 마커 표시
        myLocationEnabled: true, // 내 위치 표시
        myLocationButtonEnabled: true, // 내 위치 버튼 활성화
        zoomControlsEnabled: true, // 줌 컨트롤 활성화
        mapToolbarEnabled: true, // 지도 툴바 활성화
      ),
    );
  }
}