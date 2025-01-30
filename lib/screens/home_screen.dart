import 'dart:ui';

import 'package:bank/screens/widget/account_detail_dialog.dart';
import 'package:bank/screens/widget/add_edit_account_dialog.dart';

import 'package:bank/screens/settings_screen.dart';
import 'package:flutter/material.dart';

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
      backgroundColor: Colors.white.withOpacity(0.8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0), // AppBar의 높이 설정
        child: AppBar(
          backgroundColor: Colors.white.withOpacity(0.1),
          elevation: 1,
          title: Text(
            '정기예금 관리',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.black.withOpacity(0.9),
            ),
          ),
          actions: [
            Padding(
              // 우측 아이콘 버튼에 패딩 추가
              padding: const EdgeInsets.only(right: 16.0), // 우측 패딩
              child: IconButton(
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
                              child: const AccountDetailDialog(
                                  bankName: '알림 설정',
                                  notifications: [
                                    '알림 1: 계좌 잔액이 부족합니다.',
                                    '알림 2: 이자 지급일이 다가옵니다.',
                                    '알림 3: 계좌 정보가 업데이트되었습니다.',
                                  ]), // 다이얼로그 내용 변경
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // IconButton(
            //   icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
            //   onPressed: () {
            //     setState(() {
            //       isDarkMode = !isDarkMode;
            //     });
            //   },
            // ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: ListView.builder(
          itemCount: 10, // 예시 데이터 수
          itemBuilder: (context, index) {
            return Card(
              color: const Color.fromARGB(255, 223, 220, 213),
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
                            Text(
                              '은행명',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '시작일 ~ 종료일',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '남은 만기일: 20일 남음',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '월 이자 수입: ₩ XXX,XXX',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                                    backgroundColor: Colors.transparent,
                                    child: Stack(
                                      children: [
                                        BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 10.0, sigmaY: 10.0),
                                          child: Container(
                                            color: Colors.black.withOpacity(0),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {}, // 내부 클릭 시 이벤트 중단
                                          child: const AccountDetailDialog(
                                              bankName: '은행명'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(
                                  Icons.account_balance, // 은행 관련 아이콘으로 변경
                                ),
                                Text(
                                  '상세 보기',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white.withOpacity(0.4),
        elevation: 1,
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // 새 계좌 추가 기능
      //     showDialog(
      //       context: context,
      //       builder: (context) => const AddEditAccountDialog(),
      //     );
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
