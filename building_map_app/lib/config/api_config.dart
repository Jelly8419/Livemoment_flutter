/// API 키와 설정을 관리하는 클래스
class ApiConfig {
  /// Google Maps API 키
  /// 실제 배포 시에는 환경변수나 보안 저장소에서 가져와야 함
  static const String googleMapsApiKey = 'AIzaSyDQK8SOOSJsDH8H7HuPbwHNv72MHE_ZpsA';

  /// 개발/프로덕션 환경 구분
  static const bool isProduction = false;

  /// API 키 유효성 검사
  static bool isApiKeyValid() {
    return googleMapsApiKey.isNotEmpty && googleMapsApiKey != 'YOUR_API_KEY_HERE';
  }
}