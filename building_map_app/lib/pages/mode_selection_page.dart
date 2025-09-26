import 'package:flutter/material.dart';
import '../models/user.dart';

/// 사용자 모드 선택 페이지
class ModeSelectionPage extends StatelessWidget {
  final Function(UserMode) onModeSelected;

  const ModeSelectionPage({
    super.key,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('모드 선택'),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 안내 텍스트
            const Text(
              'EZStay를 어떻게\n이용하시겠어요?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '원하는 모드를 선택하고 시작해보세요',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),

            // 게스트 모드 카드
            _buildModeCard(
              context: context,
              title: '게스트 모드',
              subtitle: '숙소를 찾고 예약하고 싶어요',
              icon: Icons.search_rounded,
              description: '다양한 숙소를 검색하고 예약할 수 있어요',
              color: const Color(0xFF4A90E2),
              onTap: () => onModeSelected(UserMode.guest),
            ),

            const SizedBox(height: 20),

            // 호스트 모드 카드
            _buildModeCard(
              context: context,
              title: '호스트 모드',
              subtitle: '내 숙소를 등록하고 관리하고 싶어요',
              icon: Icons.home_work_rounded,
              description: '숙소를 등록하고 예약을 관리할 수 있어요',
              color: const Color(0xFF27AE60),
              onTap: () => onModeSelected(UserMode.host),
            ),

            const SizedBox(height: 40),

            // 나중에 선택하기
            TextButton(
              onPressed: () {
                // 기본값으로 게스트 모드 선택
                onModeSelected(UserMode.guest);
              },
              child: Text(
                '나중에 선택할게요',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // 아이콘
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(height: 20),

              // 제목
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),

              // 부제목
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // 설명
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // 선택 버튼
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '선택하기',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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