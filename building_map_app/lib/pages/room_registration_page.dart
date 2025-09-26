import 'package:flutter/material.dart';
import '../widgets/daum_postcode_widget.dart';

/// 호스트 전용 방 등록 페이지
class RoomRegistrationPage extends StatefulWidget {
  const RoomRegistrationPage({super.key});

  @override
  State<RoomRegistrationPage> createState() => _RoomRegistrationPageState();
}

class _RoomRegistrationPageState extends State<RoomRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // 폼 컨트롤러들
  final _roomNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _detailAddressController = TextEditingController();
  final _areaController = TextEditingController();
  final _roomCountController = TextEditingController();
  final _bathroomCountController = TextEditingController();
  final _livingRoomCountController = TextEditingController();
  final _kitchenCountController = TextEditingController();

  // 셀렉트 박스 값들
  String _buildingType = '오피스텔';
  String _parkingAvailable = '유';
  String _elevatorAvailable = '유';

  // 체크박스 값
  bool _isDuplex = false;

  @override
  void dispose() {
    _roomNameController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    _areaController.dispose();
    _roomCountController.dispose();
    _bathroomCountController.dispose();
    _livingRoomCountController.dispose();
    _kitchenCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('숙소 등록하기'),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[50],
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 기본 정보 섹션
              _buildSectionTitle('기본 정보'),
              _buildBasicInfoSection(),

              const SizedBox(height: 24),

              // 건물 정보 섹션
              _buildSectionTitle('건물 정보'),
              _buildBuildingInfoSection(),

              const SizedBox(height: 24),

              // 구조 정보 섹션
              _buildSectionTitle('구조 정보'),
              _buildStructureInfoSection(),

              const SizedBox(height: 32),

              // 등록 버튼
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A90E2).withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '숙소 등록하기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 숙소 이름
            TextFormField(
              controller: _roomNameController,
              decoration: InputDecoration(
                labelText: '숙소 이름',
                hintText: '예: 강남역 근처 깨끗한 원룸',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
                ),
                prefixIcon: const Icon(Icons.home_outlined, color: Color(0xFF4A90E2)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '숙소 이름을 입력해주세요';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // 주소 (다음 우편번호 검색)
            TextFormField(
              controller: _addressController,
              readOnly: true,
              onTap: _openAddressSearch,
              decoration: InputDecoration(
                labelText: '주소',
                hintText: '주소 검색 버튼을 눌러주세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
                ),
                prefixIcon: const Icon(Icons.location_on, color: Color(0xFF4A90E2)),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: _openAddressSearch,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '주소를 입력해주세요';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // 상세 주소
            TextFormField(
              controller: _detailAddressController,
              decoration: InputDecoration(
                labelText: '상세 주소',
                hintText: '예: 101동 501호, 3층 등',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
                ),
                prefixIcon: const Icon(Icons.location_city, color: Color(0xFF4A90E2)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                // 상세 주소는 선택사항이므로 유효성 검사 없음
                return null;
              },
            ),

            const SizedBox(height: 16),

            // 전용면적
            TextFormField(
              controller: _areaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '전용면적 (평)',
                hintText: '예: 10',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
                ),
                prefixIcon: const Icon(Icons.square_foot, color: Color(0xFF4A90E2)),
                suffixText: '평',
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '전용면적을 입력해주세요';
                }
                final area = double.tryParse(value);
                if (area == null || area <= 0) {
                  return '올바른 면적을 입력해주세요';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildingInfoSection() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 건물유형
            DropdownButtonFormField<String>(
              value: _buildingType,
              decoration: InputDecoration(
                labelText: '건물유형',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
                ),
                prefixIcon: const Icon(Icons.apartment, color: Color(0xFF4A90E2)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: ['오피스텔', '아파트', '단독주택', '기타']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _buildingType = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                // 주차여부
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _parkingAvailable,
                    decoration: InputDecoration(
                      labelText: '주차여부',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
                      ),
                      prefixIcon: const Icon(Icons.local_parking, color: Color(0xFF4A90E2)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: ['유', '무']
                        .map((option) => DropdownMenuItem(
                              value: option,
                              child: Text(option),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _parkingAvailable = value!;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 16),

                // 엘리베이터
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _elevatorAvailable,
                    decoration: InputDecoration(
                      labelText: '엘리베이터',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
                      ),
                      prefixIcon: const Icon(Icons.elevator, color: Color(0xFF4A90E2)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: ['유', '무']
                        .map((option) => DropdownMenuItem(
                              value: option,
                              child: Text(option),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _elevatorAvailable = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStructureInfoSection() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                // 방 수
                Expanded(
                  child: TextFormField(
                    controller: _roomCountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '방 수',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
                      ),
                      prefixIcon: const Icon(Icons.bed, color: Color(0xFF4A90E2)),
                      suffixText: '개',
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '방 수를 입력해주세요';
                      }
                      final count = int.tryParse(value);
                      if (count == null || count <= 0) {
                        return '올바른 수를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(width: 16),

                // 화장실 수
                Expanded(
                  child: TextFormField(
                    controller: _bathroomCountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '화장실 수',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
                      ),
                      prefixIcon: const Icon(Icons.wc, color: Color(0xFF4A90E2)),
                      suffixText: '개',
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '화장실 수를 입력해주세요';
                      }
                      final count = int.tryParse(value);
                      if (count == null || count <= 0) {
                        return '올바른 수를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                // 거실 수
                Expanded(
                  child: TextFormField(
                    controller: _livingRoomCountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '거실 수',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
                      ),
                      prefixIcon: const Icon(Icons.weekend, color: Color(0xFF4A90E2)),
                      suffixText: '개',
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '거실 수를 입력해주세요';
                      }
                      final count = int.tryParse(value);
                      if (count == null || count <= 0) {
                        return '올바른 수를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(width: 16),

                // 주방 수
                Expanded(
                  child: TextFormField(
                    controller: _kitchenCountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '주방 수',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
                      ),
                      prefixIcon: const Icon(Icons.kitchen, color: Color(0xFF4A90E2)),
                      suffixText: '개',
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '주방 수를 입력해주세요';
                      }
                      final count = int.tryParse(value);
                      if (count == null || count <= 0) {
                        return '올바른 수를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 복층 여부
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  '복층 여부',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                subtitle: const Text(
                  '복층 구조인 경우 체크해주세요',
                  style: TextStyle(color: Color(0xFF6C7B7F)),
                ),
                value: _isDuplex,
                onChanged: (value) {
                  setState(() {
                    _isDuplex = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: const Color(0xFF4A90E2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddressSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DaumPostcodeWidget(
          onAddressSelected: (addressData) {
            if (addressData.containsKey('action') && addressData['action'] == 'close') {
              // 사용자가 주소 선택 없이 창을 닫은 경우
              return;
            }

            // 선택된 주소 정보를 텍스트 필드에 설정
            String fullAddress = '';
            if (addressData.containsKey('roadAddress') && addressData['roadAddress']!.isNotEmpty) {
              // 도로명 주소가 있는 경우 우선 사용
              fullAddress = addressData['roadAddress']!;
            } else if (addressData.containsKey('jibunAddress') && addressData['jibunAddress']!.isNotEmpty) {
              // 지번 주소 사용
              fullAddress = addressData['jibunAddress']!;
            } else if (addressData.containsKey('address') && addressData['address']!.isNotEmpty) {
              // 기본 주소 사용
              fullAddress = addressData['address']!;
            }

            // 건물명이 있는 경우 추가
            if (addressData.containsKey('buildingName') && addressData['buildingName']!.isNotEmpty) {
              fullAddress += ' (${addressData['buildingName']!})';
            }

            setState(() {
              _addressController.text = fullAddress;
            });



            // 디버그용 - 선택된 주소 데이터 출력
            debugPrint('선택된 주소 데이터: $addressData');
          },
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // 폼 데이터 수집
      final roomData = {
        'roomName': _roomNameController.text,
        'address': _addressController.text, 
        'detailAddress': _detailAddressController.text,
        'area': double.parse(_areaController.text),
        'buildingType': _buildingType,
        'parkingAvailable': _parkingAvailable == '유',
        'elevatorAvailable': _elevatorAvailable == '유',
        'roomCount': int.parse(_roomCountController.text),
        'bathroomCount': int.parse(_bathroomCountController.text),
        'livingRoomCount': int.parse(_livingRoomCountController.text),
        'kitchenCount': int.parse(_kitchenCountController.text),
        'isDuplex': _isDuplex, //복층 여부
      };

      // TODO: 서버로 데이터 전송
      print('방 등록 데이터: $roomData');

      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '숙소가 성공적으로 등록되었습니다! 🎉',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF4A90E2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // 이전 페이지로 돌아가기
      Navigator.pop(context);
    }
  }
}