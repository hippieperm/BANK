import 'dart:ui';

import 'package:bank/screens/dialog/account_detail_dialog.dart';
import 'package:bank/screens/dialog/add_edit_account_dialog.dart';

import 'package:bank/screens/settings_screen.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool isDarkMode = true;
  List<Map<String, dynamic>> accounts = []; // 계좌 목록을 저장할 리스트 추가

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
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: const Color.fromARGB(255, 59, 57, 57),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: CalendarTimeline(
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onDateSelected: (date) => print(date),
                  leftMargin: 20,
                  monthColor: const Color.fromARGB(255, 198, 214, 222),
                  dayColor: const Color.fromARGB(255, 177, 194, 194),
                  activeDayColor: Colors.white,
                  activeBackgroundDayColor: Colors.teal[600],
                  selectableDayPredicate: (date) => date.day != 23,
                  height: 75,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: accounts.length, // 실제 계좌 수로 변경
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  // 만기일 계산
                  final endDate = DateTime.parse(account['endDate']);
                  final remainingDays =
                      endDate.difference(DateTime.now()).inDays;

                  // 월 이자 계산 (간단한 예시)
                  final interestRate = account['interestRate'];
                  final monthlyInterest =
                      10000000 * (interestRate / 100) / 12; // 예시 금액 1000만원

                  return Card(
                    color: const Color(0xff333333),
                    // margin: const EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    account['bankImage']!,
                                    width: 100,
                                    height: 24,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${account['startDate']} ~ ${account['endDate']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    '남은 만기일: $remainingDays일 남음',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '월 이자 수입: ₩ ${monthlyInterest.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 100, // 버튼의 너비
                                height: 100, // 버튼의 높이
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        Colors.purple.withOpacity(0.2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(15), // 라운딩
                                    ),
                                  ),
                                  onPressed: () {
                                    // 상세 보기 기능
                                    showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (context) => GestureDetector(
                                        onTap: () {
                                          Navigator.of(context)
                                              .pop(); // 다이얼로그 닫기
                                        },
                                        child: Dialog(
                                          backgroundColor: Colors.transparent,
                                          child: Stack(
                                            children: [
                                              BackdropFilter(
                                                filter: ImageFilter.blur(
                                                    sigmaX: 10.0, sigmaY: 10.0),
                                                child: Container(
                                                  color: Colors.black
                                                      .withOpacity(0),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {}, // 내부 클릭 시 이벤트 중단
                                                child:
                                                    const AccountDetailDialog(
                                                        bankName: '은행명'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Icons.account_balance,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        '상세 보기',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          color: Colors.white,
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
          ],
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
            showDialog(
              context: context,
              builder: (context) => const AddEditAccountDialog(),
            ).then((result) {
              if (result != null) {
                setState(() {
                  accounts.add(result);
                });
              }
            });
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
