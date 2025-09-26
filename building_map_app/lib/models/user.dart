/// 사용자 모델
class User {
  final String id;
  final String email;
  final String name;
  final String? profileImageUrl;
  final UserMode mode;
  final AuthProvider provider;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.profileImageUrl,
    required this.mode,
    required this.provider,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      profileImageUrl: json['profileImageUrl'],
      mode: UserMode.values.firstWhere((mode) => mode.toString() == json['mode']),
      provider: AuthProvider.values.firstWhere((provider) => provider.toString() == json['provider']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'mode': mode.toString(),
      'provider': provider.toString(),
    };
  }
}

/// 사용자 모드 (게스트/호스트)
enum UserMode {
  guest,
  host,
}

/// 인증 제공자
enum AuthProvider {
  email,
  google,
  kakao,
}