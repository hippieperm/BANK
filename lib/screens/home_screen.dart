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
  final List<String> notifications = [
    // 알림 목록 추가
    '알림 1: 계좌 잔액이 부족합니다.',
    '알림 2: 이자 지급일이 다가옵니다.',
    '알림 3: 계좌 정보가 업데이트되었습니다.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1b1b1b),
      appBar: AppBar(
        backgroundColor: const Color(0xff2d2d2d),
        elevation: 0.1,
        title: Text(
          '정기예금 관리',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Stack(
                children: [
                  const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 34,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child:
                          notifications.isNotEmpty ? Container() : Container(),
                    ),
                  ),
                ],
              ),
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
                      backgroundColor: Colors.transparent,
                      child: Stack(
                        children: [
                          BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                            child: Container(
                              color: Colors.black.withOpacity(0),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const AccountDetailDialog(
                                bankName: '알림 설정',
                                notifications: [
                                  '알림 1: 계좌 잔액이 부족합니다.',
                                  '알림 2: 이자 지급일이 다가옵니다.',
                                  '알림 3: 계좌 정보가 업데이트되었습니다.',
                                ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xff2d2d2d),
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
                  monthColor: Colors.grey[400],
                  dayColor: Colors.grey[500],
                  activeDayColor: Colors.white,
                  activeBackgroundDayColor: Colors.teal[800],
                  selectableDayPredicate: (date) => date.day != 23,
                  height: 75,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView.builder(
                itemCount: accounts.length, // 실제 계좌 수로 변경
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  // 만기일 계산
                  final endDate = DateTime.parse(account['endDate']);
                  final remainingDays =
                      endDate.difference(DateTime.now()).inDays;

                  // 월 이자 계산 수정
                  final principal = account['principal'];
                  final interestRate = account['interestRate'];
                  final monthlyInterest = principal * (interestRate / 100) / 12;

                  // 천 단위 구분 쉼표를 위한 포맷 함수
                  String formatNumber(double number) {
                    return number.toStringAsFixed(0).replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},');
                  }

                  return Card(
                    color: const Color(0xff2d2d2d),
                    // margin: const EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
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
                                  // Text(
                                  //   '남은 만기일: $remainingDays일 남음',
                                  //   style: const TextStyle(
                                  //     fontSize: 16,
                                  //     fontWeight: FontWeight.bold,
                                  //     color: Colors.white,
                                  //   ),
                                  // ),
                                  Text(
                                    '원금: ₩ ${formatNumber(principal)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '월 이자 수입: ₩ ${formatNumber(monthlyInterest)}',
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
                                    backgroundColor: const Color(0xff3d3d3d),
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
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const Icon(
                                        Icons.date_range_rounded,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        '$remainingDays',
                                        style: const TextStyle(
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
        backgroundColor: Colors.transparent,
        unselectedItemColor: Colors.white,
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
