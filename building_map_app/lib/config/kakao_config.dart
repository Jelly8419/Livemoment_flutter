/// 카카오 API 설정
class KakaoConfig {
  /// 카카오 REST API 키
  static const String restApiKey = '88df9fa560e1447eb0930e5bae9ff017';

  /// 리다이렉트 URL
  static const String redirectUrl = 'http://localhost:8080/api/auth/kakao';

  /// 웹용 리다이렉트 URL (Flutter Web)
  static const String webRedirectUrl = 'http://localhost:8080/api/auth/kakao';

  /// 카카오 앱 스킴 (네이티브 앱용)
  static const String nativeAppKey = 'kakao$restApiKey';

  /// 카카오 OAuth 인증 URL
  static String get authUrl =>
      'https://kauth.kakao.com/oauth/authorize'
      '?response_type=code'
      '&client_id=$restApiKey'
      '&redirect_uri=$redirectUrl';

  /// 카카오 토큰 발급 URL
  static const String tokenUrl = 'https://kauth.kakao.com/oauth/token';

  /// 카카오 사용자 정보 API URL
  static const String userInfoUrl = 'https://kapi.kakao.com/v2/user/me';

  /// API 키 유효성 검사
  static bool isApiKeyValid() {
    return restApiKey.isNotEmpty && restApiKey != 'YOUR_KAKAO_REST_API_KEY';
  }
}