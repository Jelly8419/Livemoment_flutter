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
        title: const Text('방 등록하기'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '방 등록하기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 방 이름
            TextFormField(
              controller: _roomNameController,
              decoration: const InputDecoration(
                labelText: '방 이름',
                hintText: '예: 강남역 근처 깨끗한 원룸',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '방 이름을 입력해주세요';
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
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_on),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _openAddressSearch,
                ),
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
              decoration: const InputDecoration(
                labelText: '상세 주소',
                hintText: '예: 101동 501호, 3층 등',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
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
              decoration: const InputDecoration(
                labelText: '전용면적 (평)',
                hintText: '예: 10',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.square_foot),
                suffixText: '평',
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
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 건물유형
            DropdownButtonFormField<String>(
              value: _buildingType,
              decoration: const InputDecoration(
                labelText: '건물유형',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.apartment),
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
                    decoration: const InputDecoration(
                      labelText: '주차여부',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_parking),
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
                    decoration: const InputDecoration(
                      labelText: '엘리베이터',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.elevator),
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
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // 방 수
                Expanded(
                  child: TextFormField(
                    controller: _roomCountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '방 수',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.bed),
                      suffixText: '개',
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
                    decoration: const InputDecoration(
                      labelText: '화장실 수',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.wc),
                      suffixText: '개',
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
                    decoration: const InputDecoration(
                      labelText: '거실 수',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.weekend),
                      suffixText: '개',
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
                    decoration: const InputDecoration(
                      labelText: '주방 수',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.kitchen),
                      suffixText: '개',
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
            CheckboxListTile(
              title: const Text('복층 여부'),
              subtitle: const Text('복층 구조인 경우 체크해주세요'),
              value: _isDuplex,
              onChanged: (value) {
                setState(() {
                  _isDuplex = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Theme.of(context).primaryColor,
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
        'isDuplex': _isDuplex,
      };

      // TODO: 서버로 데이터 전송
      print('방 등록 데이터: $roomData');

      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('방이 성공적으로 등록되었습니다!'),
          backgroundColor: Colors.green,
        ),
      );

      // 이전 페이지로 돌아가기
      Navigator.pop(context);
    }
  }
}