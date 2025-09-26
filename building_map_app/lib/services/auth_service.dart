import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:html' as html;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../config/kakao_config.dart';

/// 인증 서비스 클래스
class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  static const _storage = FlutterSecureStorage();

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  /// 로그인 상태 변경
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 이메일 로그인
  Future<bool> loginWithEmail(String email, String password, UserMode mode) async {
    _setLoading(true);

    try {
      // TODO: 실제 API 호출
      await Future.delayed(const Duration(seconds: 2)); // 시뮬레이션

      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: email.split('@')[0],
        mode: mode,
        provider: AuthProvider.email,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  /// 구글 로그인
  Future<bool> loginWithGoogle(UserMode mode) async {
    _setLoading(true);

    try {
      // TODO: Google Sign-In 구현
      await Future.delayed(const Duration(seconds: 2)); // 시뮬레이션

      _currentUser = User(
        id: 'google_${DateTime.now().millisecondsSinceEpoch}',
        email: 'user@gmail.com',
        name: 'Google User',
        profileImageUrl: 'https://example.com/profile.jpg',
        mode: mode,
        provider: AuthProvider.google,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  /// 카카오 로그인
  Future<bool> loginWithKakao(UserMode mode) async {
    debugPrint('🚀 [KAKAO] 로그인 시작');
    debugPrint('🔧 [KAKAO] API 키: ${KakaoConfig.restApiKey}');
    debugPrint('🔧 [KAKAO] Redirect URL: ${KakaoConfig.redirectUrl}');
    debugPrint('🔧 [KAKAO] Auth URL: ${KakaoConfig.authUrl}');
    _setLoading(true);

    try {
      if (kIsWeb) {
        // 웹에서는 브라우저에서 직접 OAuth URL 열기
        debugPrint('웹 환경: 브라우저에서 카카오 로그인 페이지 열기');
        html.window.location.href = KakaoConfig.authUrl;
        // 웹에서는 리다이렉트로 처리되므로 여기서는 false 반환
        _setLoading(false);
        return false;
      } else {
        // 모바일에서는 기존 Flutter SDK 사용
        return await _loginWithKakaoMobile(mode);
      }
    } catch (error) {
      debugPrint('카카오 로그인 에러: $error');
      _setLoading(false);
      return false;
    }
  }

  /// 모바일 환경 카카오 로그인
  Future<bool> _loginWithKakaoMobile(UserMode mode) async {
    try {
      // 1. 카카오 로그인 시도
      kakao.OAuthToken? token;

      // 카카오톡 앱이 설치되어 있는지 확인
      if (await kakao.isKakaoTalkInstalled()) {
        try {
          // 카카오톡으로 로그인
          token = await kakao.UserApi.instance.loginWithKakaoTalk();
          debugPrint('카카오톡으로 로그인 성공');
        } catch (error) {
          debugPrint('카카오톡으로 로그인 실패 $error');

          // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
          // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
          if (error is PlatformException && error.code == 'CANCELED') {
            _setLoading(false);
            return false;
          }
          // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
          try {
            token = await kakao.UserApi.instance.loginWithKakaoAccount();
            debugPrint('카카오계정으로 로그인 성공');
          } catch (error) {
            debugPrint('카카오계정으로 로그인 실패 $error');
            _setLoading(false);
            return false;
          }
        }
      } else {
        try {
          // 카카오계정으로 로그인
          token = await kakao.UserApi.instance.loginWithKakaoAccount();
          debugPrint('카카오계정으로 로그인 성공');
        } catch (error) {
          debugPrint('카카오계정으로 로그인 실패 $error');
          _setLoading(false);
          return false;
        }
      }

      // 2. 사용자 정보 가져오기
      final kakaoUser = await kakao.UserApi.instance.me();

      debugPrint('카카오 사용자 정보: ${kakaoUser.toString()}');

      // 3. 백엔드에 토큰 전송 및 인증 처리
      final success = await _authenticateWithBackend(token, kakaoUser, mode);

      if (success) {
        // 4. 로컬 사용자 정보 설정
        _currentUser = User(
          id: kakaoUser.id.toString(),
          email: kakaoUser.kakaoAccount?.email ?? 'user@kakao.com',
          name: kakaoUser.kakaoAccount?.profile?.nickname ?? '카카오 사용자',
          profileImageUrl: kakaoUser.kakaoAccount?.profile?.profileImageUrl,
          mode: mode,
          provider: AuthProvider.kakao,
        );

        _setLoading(false);
        return true;
      } else {
        _setLoading(false);
        return false;
      }
    } catch (error) {
      debugPrint('모바일 카카오 로그인 에러: $error');
      _setLoading(false);
      return false;
    }
  }

  /// 백엔드와 카카오 토큰 인증 처리
  Future<bool> _authenticateWithBackend(kakao.OAuthToken token, kakao.User kakaoUser, UserMode mode) async {
    try {
      // 백엔드 API 엔드포인트 (실제 백엔드 URL로 변경 필요)
      const String backendUrl = 'http://localhost:8080/auth/kakao';

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'access_token': token.accessToken,
          'refresh_token': token.refreshToken,
          'user_mode': mode.name,
          'kakao_user_id': kakaoUser.id,
          'email': kakaoUser.kakaoAccount?.email,
          'nickname': kakaoUser.kakaoAccount?.profile?.nickname,
          'profile_image': kakaoUser.kakaoAccount?.profile?.profileImageUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('백엔드 인증 성공: $data');

        // JWT 토큰 저장 등 추가 처리
        if (data['accessToken'] != null && data['refreshToken'] != null) {
          await _saveTokens(data['accessToken'], data['refreshToken']);
        }

        return true;
      } else {
        debugPrint('백엔드 인증 실패: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('백엔드 인증 에러: $e');
      // 백엔드 연결 실패해도 로그인은 성공으로 처리 (개발 환경)
      return true;
    }
  }

  /// 토큰 저장
  Future<void> _saveTokens(String accessToken, String? refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: 'refresh_token', value: refreshToken);
    }
    debugPrint('토큰 저장 완료');
  }

  /// 저장된 토큰 불러오기
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  /// 저장된 리프레시 토큰 불러오기
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  /// 웹에서 카카오 로그인 콜백 처리 (JWT 토큰 기반)
  Future<bool> handleKakaoWebCallback() async {
    if (!kIsWeb) return false;

    try {
      final uri = Uri.parse(html.window.location.href);
      debugPrint('🔍 [CALLBACK] 현재 URL: ${uri.toString()}');
      debugPrint('🔍 [CALLBACK] 경로: ${uri.path}');
      debugPrint('🔍 [CALLBACK] 쿼리 파라미터: ${uri.queryParameters}');

      // /auth/callback 경로 체크
      if (uri.path == '/auth/callback') {
        // 에러 파라미터 체크
        final errorParam = uri.queryParameters['error'];
        if (errorParam != null) {
          debugPrint('❌ 카카오 로그인 에러: $errorParam');
          html.window.history.replaceState({}, '', '/');
          return false;
        }

        // 백엔드에서 전달받은 토큰들 체크
        final accessToken = uri.queryParameters['token'];
        final refreshToken = uri.queryParameters['refresh'];

        if (accessToken != null) {
          debugPrint('🔐 Access Token 발견: ${accessToken.substring(0, 20)}...');
          if (refreshToken != null) {
            debugPrint('🔄 Refresh Token 발견: ${refreshToken.substring(0, 20)}...');
          }

          // 토큰들 저장
          await _saveTokens(accessToken, refreshToken);

          // 토큰으로 사용자 정보 요청
          final success = await _authenticateWithToken(accessToken);

          if (success) {
            // URL에서 파라미터 제거
            html.window.history.replaceState({}, '', '/');
            debugPrint('✅ 카카오 로그인 성공');
            return true;
          } else {
            debugPrint('❌ 사용자 정보 가져오기 실패');
            await _clearTokens();
            html.window.history.replaceState({}, '', '/');
            return false;
          }
        }
      }

      // 카카오 인증 코드 처리 (기존 방식 - 하위 호환성)
      final code = uri.queryParameters['code'];
      if (code != null) {
        debugPrint('🔑 카카오 인증 코드 발견: $code');
        return await _handleKakaoAuthCode(code);
      }

      return false;
    } catch (error) {
      debugPrint('❌ 웹 카카오 콜백 처리 에러: $error');
      html.window.history.replaceState({}, '', '/');
      return false;
    }
  }

  /// JWT 토큰으로 사용자 정보 인증
  Future<bool> _authenticateWithToken(String token) async {
    try {
      // 토큰 기본 검증 (형식 확인)
      if (!_isValidTokenFormat(token)) {
        debugPrint('❌ 토큰 형식이 유효하지 않음');
        return false;
      }

      // 토큰 유효성 검증 및 사용자 정보 요청
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10)); // 타임아웃 설정

      if (response.statusCode == 200) {
        debugPrint('🔍 서버 응답: ${response.body}');
        final data = json.decode(response.body);
        debugPrint('🔍 파싱된 데이터: $data');

        if (data['success'] == true && data['data'] != null && data['data']['user'] != null) {
          final user = data['data']['user'];

          // 사용자 데이터 유효성 검증
          if (!_isValidUserData(user)) {
            debugPrint('❌ 서버에서 받은 사용자 데이터가 유효하지 않음');
            return false;
          }

          // 서버에서 검증된 사용자 정보로 설정
          _currentUser = User(
            id: user['id'].toString(),
            email: user['email'] ?? 'user@kakao.com',
            name: user['name'] ?? '카카오 사용자',
            profileImageUrl: user['profileImageUrl'],
            mode: UserMode.guest, // 기본값, 나중에 사용자가 선택
            provider: AuthProvider.kakao,
          );

          // 검증된 토큰 저장
          await _storage.write(key: 'access_token', value: token);
          if (data['refreshToken'] != null) {
            await _storage.write(key: 'refresh_token', value: data['refreshToken']);
          }

          notifyListeners();
          debugPrint('✅ 서버 검증 완료 - 사용자: ${user['name']}');
          return true;
        } else {
          debugPrint('❌ 서버 응답 데이터 형식 오류');
        }
      } else if (response.statusCode == 401) {
        debugPrint('❌ 토큰이 유효하지 않음 (401) - refresh 토큰으로 갱신 시도');

        // Refresh 토큰으로 갱신 시도
        final refreshSuccess = await _refreshAccessToken();
        if (refreshSuccess) {
          // 새로운 액세스 토큰으로 재시도
          final newAccessToken = await getAccessToken();
          if (newAccessToken != null) {
            return await _authenticateWithToken(newAccessToken);
          }
        }

        return false;
      } else if (response.statusCode == 403) {
        debugPrint('❌ 접근 권한 없음 (403)');
      } else {
        debugPrint('❌ 서버 오류: ${response.statusCode} - ${response.body}');
      }

      return false;
    } on TimeoutException {
      debugPrint('❌ 서버 요청 타임아웃');
      return false;
    } on FormatException catch (e) {
      debugPrint('❌ JSON 파싱 오류: $e');
      return false;
    } catch (error) {
      debugPrint('❌ 토큰 인증 에러: $error');
      return false;
    }
  }

  /// JWT 토큰 형식 검증 (기본적인 형식만 확인)
  bool _isValidTokenFormat(String token) {
    // JWT는 일반적으로 header.payload.signature 형태
    final parts = token.split('.');
    return parts.length == 3 &&
           parts.every((part) => part.isNotEmpty) &&
           token.length > 10; // 최소 길이 확인
  }

  /// 사용자 데이터 유효성 검증
  bool _isValidUserData(Map<String, dynamic> user) {
    return user['id'] != null &&
           user['id'].toString().isNotEmpty &&
           user['email'] != null &&
           user['name'] != null;
  }

  /// 카카오 인증 코드 처리 (기존 방식 유지)
  Future<bool> _handleKakaoAuthCode(String code) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/auth/kakao?code=$code'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['token'] != null) {
          // JWT 토큰으로 사용자 정보 재요청
          final success = await _authenticateWithToken(data['token']);

          if (success) {
            html.window.history.replaceState({}, '', '/');
            return true;
          }
        }
      }

      return false;
    } catch (error) {
      debugPrint('❌ 카카오 코드 처리 에러: $error');
      return false;
    }
  }

  /// 앱 시작 시 저장된 토큰으로 자동 로그인 시도
  Future<void> tryAutoLogin() async {
    final accessToken = await getAccessToken();
    if (accessToken != null) {
      debugPrint('🔄 저장된 토큰으로 자동 로그인 시도...');

      // 서버에서 토큰 검증 및 사용자 정보 가져오기
      final success = await _authenticateWithToken(accessToken);

      if (success) {
        debugPrint('✅ 자동 로그인 성공');
      } else {
        debugPrint('❌ 자동 로그인 실패 - 토큰 만료 또는 무효');
        // 만료된 토큰 제거
        await _clearTokens();
      }
    } else {
      debugPrint('💡 저장된 토큰 없음');
    }
  }

  /// 저장된 토큰 제거
  Future<void> _clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    debugPrint('🗑️ 토큰 삭제 완료');
  }

  /// Refresh 토큰으로 Access 토큰 갱신
  Future<bool> _refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        debugPrint('❌ Refresh 토큰이 없음');
        return false;
      }

      debugPrint('🔄 Access 토큰 갱신 시도...');

      final response = await http.post(
        Uri.parse('http://localhost:8080/api/auth/refresh'),
        headers: {
          'Authorization': 'Bearer $refreshToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['accessToken'] != null) {
          // 새로운 토큰들 저장
          await _saveTokens(
            data['accessToken'],
            data['refreshToken'] ?? refreshToken, // 새 refresh token이 없으면 기존 것 유지
          );

          debugPrint('✅ Access 토큰 갱신 성공');
          return true;
        }
      } else if (response.statusCode == 401) {
        debugPrint('❌ Refresh 토큰도 만료됨 - 재로그인 필요');
        await _clearTokens();
      } else {
        debugPrint('❌ 토큰 갱신 서버 오류: ${response.statusCode}');
      }

      return false;
    } catch (error) {
      debugPrint('❌ 토큰 갱신 에러: $error');
      return false;
    }
  }

  /// 회원가입 (이메일)
  Future<bool> signUpWithEmail(String email, String password, String name, UserMode mode) async {
    _setLoading(true);

    try {
      // TODO: 실제 API 호출
      await Future.delayed(const Duration(seconds: 2)); // 시뮬레이션

      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        mode: mode,
        provider: AuthProvider.email,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      // 서버에 로그아웃 요청 (토큰 무효화)
      final accessToken = await getAccessToken();
      if (accessToken != null) {
        await http.post(
          Uri.parse('http://localhost:8080/api/auth/logout'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        );
      }
    } catch (e) {
      debugPrint('⚠️ 서버 로그아웃 요청 실패: $e');
    }

    // 로컬 상태 및 토큰 정리
    _currentUser = null;
    await _clearTokens();
    notifyListeners();
    debugPrint('👋 로그아웃 완료');
  }

  /// 사용자 모드 변경
  void switchUserMode(UserMode newMode) {
    if (_currentUser != null) {
      _currentUser = User(
        id: _currentUser!.id,
        email: _currentUser!.email,
        name: _currentUser!.name,
        profileImageUrl: _currentUser!.profileImageUrl,
        mode: newMode,
        provider: _currentUser!.provider,
      );
      notifyListeners();
    }
  }
}