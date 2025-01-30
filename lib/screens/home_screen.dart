import 'dart:ui';

import 'package:bank/screens/widget/account_detail_dialog.dart';
import 'package:bank/screens/widget/add_edit_account_dialog.dart';
import 'package:bank/main.dart';
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
                        // 배경 블러 처리,
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
                                  fontSize: 20, fontWeight: FontWeight.bold
                                  )),
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
