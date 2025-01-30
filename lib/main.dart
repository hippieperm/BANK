import 'package:flutter/material.dart';
import 'dart:ui'; // 추가: BackdropFilter를 사용하기 위해 필요

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '정기예금 관리',
      theme: ThemeData.light(), // 화이트모드 테마
      darkTheme: ThemeData.dark(), // 다크모드 테마
      themeMode: ThemeMode.light, // 시스템 설정에 따라 테마 선택
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('정기예금 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // 알림 설정 기능
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  },
                  child: Dialog(
                    backgroundColor: Colors.transparent, // 배경을 투명하게 설정
                    child: Stack(
                      children: [
                        // 배경 블러 처리
                        BackdropFilter(
                          filter: ImageFilter.blur(
                              sigmaX: 10.0, sigmaY: 10.0), // 블러 강도 조절
                          child: Container(
                            color: Colors.black.withOpacity(0), // 투명한 배경
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // 다이얼로그 내부 터치 시 아무 동작도 하지 않음
                          },
                          child: const SettingsScreen(), // 다이얼로그 내용
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 10, // 예시 데이터 수
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('은행명',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('시작일 ~ 종료일', style: TextStyle(fontSize: 12)),
                          Text('남은 만기일: 20일 남음',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('월 이자 수입: ₩ XXX,XXX',
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      SizedBox(
                        width: 100, // 버튼의 너비
                        height: 100, // 버튼의 높이
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.purple.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15), // 라운딩
                            ),
                          ),
                          onPressed: () {
                            // 상세 보기 기능
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (context) => GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop(); // 다이얼로그 닫기
                                },
                                child: Dialog(
                                  backgroundColor:
                                      Colors.transparent, // 배경을 투명하게 설정
                                  child: Stack(
                                    children: [
                                      // 배경 블러 처리
                                      BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 10.0,
                                            sigmaY: 10.0), // 블러 강도 조절
                                        child: Container(
                                          color: Colors.black
                                              .withOpacity(0), // 투명한 배경
                                        ),
                                      ),
                                      // 애니메이션 효과 추가
                                      AnimatedOpacity(
                                        opacity: 1.0,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        child: ScaleTransition(
                                          scale: Tween<double>(
                                                  begin: 0.8, end: 1.0)
                                              .animate(
                                            CurvedAnimation(
                                              parent: AnimationController(
                                                vsync: this,
                                                duration: const Duration(
                                                    milliseconds: 300),
                                              )..forward(),
                                              curve: Curves.easeInOut,
                                            ),
                                          ),
                                          child: const AccountDetailDialog(
                                              bankName: '은행명'), // 다이얼로그 내용
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          child: const Text('상세 보기'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: '계좌 추가'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
        onTap: (index) {
          if (index == 1) {
            // 계좌 추가 기능
            showDialog(
              context: context,
              builder: (context) => const AddEditAccountDialog(),
            );
          } else if (index == 2) {
            // 설정 화면으로 이동
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 새 계좌 추가 기능
          showDialog(
            context: context,
            builder: (context) => const AddEditAccountDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AccountDetailDialog extends StatelessWidget {
  final String bankName;

  const AccountDetailDialog({super.key, required this.bankName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(bankName),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('시작일: YYYY-MM-DD'),
          Text('종료일: YYYY-MM-DD'),
          Text('이자율: X.X%'),
          Text('비과세 여부: 비과세 적용'),
          Text('월 수익: ₩ XXX,XXX'),
          Text('남은 기간: 30일 남음'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // 수정하기 기능
            Navigator.pop(context); // 다이얼로그 닫기
            // 수정 로직 추가 필요
          },
          child: const Text('수정하기'),
        ),
        TextButton(
          onPressed: () {
            // 삭제하기 기능
            Navigator.pop(context); // 다이얼로그 닫기
            // 삭제 로직 추가 필요
          },
          child: const Text('삭제하기'),
        ),
      ],
    );
  }
}

class AddEditAccountDialog extends StatefulWidget {
  const AddEditAccountDialog({super.key});

  @override
  _AddEditAccountDialogState createState() => _AddEditAccountDialogState();
}

class _AddEditAccountDialogState extends State<AddEditAccountDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController interestRateController = TextEditingController();
  bool isTaxExempt = false;
  double taxRate = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // 배경을 투명하게 설정
      child: Stack(
        children: [
          // 배경 블러 처리
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // 블러 강도 조절
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: Container(
                color: Colors.black.withOpacity(0), // 투명한 배경
              ),
            ),
          ),
          // 애니메이션 효과 추가
          AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeInOut,
                ),
              ),
              child: AlertDialog(
                title: const Text('계좌 추가/수정'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: bankNameController,
                      decoration: const InputDecoration(labelText: '은행명'),
                    ),
                    TextField(
                      controller: startDateController,
                      decoration: const InputDecoration(labelText: '시작일'),
                      onTap: () async {
                        // 날짜 선택 기능
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          startDateController.text =
                              "${pickedDate.toLocal()}".split(' ')[0];
                        }
                      },
                    ),
                    TextField(
                      controller: endDateController,
                      decoration: const InputDecoration(labelText: '종료일'),
                      onTap: () async {
                        // 날짜 선택 기능
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          endDateController.text =
                              "${pickedDate.toLocal()}".split(' ')[0];
                        }
                      },
                    ),
                    TextField(
                      controller: interestRateController,
                      decoration: const InputDecoration(labelText: '이자율'),
                      keyboardType: TextInputType.number,
                    ),
                    SwitchListTile(
                      title: const Text('비과세 여부'),
                      value: isTaxExempt,
                      onChanged: (value) {
                        isTaxExempt = value;
                      },
                    ),
                    Slider(
                      value: taxRate,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: '세율',
                      onChanged: (value) {
                        taxRate = value;
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      // 저장 기능
                      Navigator.pop(context); // 다이얼로그 닫기
                      // 저장 로직 추가 필요
                    },
                    child: const Text('저장'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: Column(
        children: [
          DropdownButton<String>(
            items: <String>['7일', '14일', '30일'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              // 알림 주기 설정 처리
            },
            hint: const Text('알림 주기 설정'),
          ),
          const TextField(decoration: InputDecoration(labelText: '기본 세율 설정')),
          ElevatedButton(
            onPressed: () {
              // 데이터 초기화 기능
            },
            child: const Text('데이터 초기화'),
          ),
        ],
      ),
    );
  }
}
