import 'dart:ui';

import 'package:bank/screens/dialog/account_detail_dialog.dart';
import 'package:bank/screens/dialog/add_edit_account_dialog.dart';

import 'package:bank/screens/settings_screen.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';

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
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: '',
                    barrierColor: Colors.black.withOpacity(0.5),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        Container(),
                    transitionBuilder:
                        (context, animation, secondaryAnimation, child) {
                      var curve = Curves.easeInOut;
                      var curvedAnimation = CurvedAnimation(
                        parent: animation,
                        curve: curve,
                      );

                      return GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: GestureDetector(
                            onTap: () {},
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.8, end: 1.0)
                                  .animate(curvedAnimation),
                              child: FadeTransition(
                                opacity: Tween<double>(begin: 0.0, end: 1.0)
                                    .animate(curvedAnimation),
                                child: Dialog(
                                  backgroundColor: const Color(0xff2d2d2d),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          '월별 이자 추이',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        SizedBox(
                                          height: 300,
                                          child: LineChart(
                                            LineChartData(
                                              gridData:
                                                  const FlGridData(show: false),
                                              titlesData: FlTitlesData(
                                                leftTitles: const AxisTitles(
                                                  sideTitles: SideTitles(
                                                      showTitles: false),
                                                ),
                                                rightTitles: const AxisTitles(
                                                  sideTitles: SideTitles(
                                                      showTitles: false),
                                                ),
                                                topTitles: const AxisTitles(
                                                  sideTitles: SideTitles(
                                                      showTitles: false),
                                                ),
                                                bottomTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,
                                                    getTitlesWidget:
                                                        (value, meta) {
                                                      return Text(
                                                        '${value.toInt()}월',
                                                        style: const TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 12,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              borderData:
                                                  FlBorderData(show: false),
                                              lineBarsData: [
                                                LineChartBarData(
                                                  spots:
                                                      List.generate(6, (index) {
                                                    return FlSpot(
                                                        index.toDouble(),
                                                        calculateTotalMonthlyInterest() *
                                                            (1 + index * 0.1));
                                                  }),
                                                  isCurved: true,
                                                  color: Colors.blue,
                                                  barWidth: 3,
                                                  isStrokeCapRound: true,
                                                  dotData: const FlDotData(
                                                      show: false),
                                                  belowBarData: BarAreaData(
                                                    show: true,
                                                    color: Colors.blue
                                                        .withOpacity(0.2),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: const Color(0xff2d2d2d),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text(
                              '이번 달 총 이자',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₩ ${formatNumber(calculateTotalMonthlyInterest())}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white24,
                        ),
                        Column(
                          children: [
                            const Text(
                              '누적 수령 이자',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₩ ${formatNumber(calculateTotalReceivedInterest())}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // const Icon(
                                      //   Icons.date_range_rounded,
                                      //   color: Colors.white,
                                      // ),
                                      Text(
                                        'DAY',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: remainingDays <= 15
                                              ? Colors.red
                                              : Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '$remainingDays',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          color: remainingDays <= 15
                                              ? Colors.red
                                              : Colors.white,
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
    );
  }

  double calculateTotalMonthlyInterest() {
    double total = 0;
    for (var account in accounts) {
      double principal = account['principal'];
      double interestRate = account['interestRate'];
      total += principal * (interestRate / 100) / 12;
    }
    return total;
  }

  double calculateTotalReceivedInterest() {
    double total = 0;
    for (var account in accounts) {
      double principal = account['principal'];
      double interestRate = account['interestRate'];
      DateTime startDate = DateTime.parse(account['startDate']);
      int monthsPassed = DateTime.now().difference(startDate).inDays ~/ 30;
      total += (principal * (interestRate / 100) / 12) * monthsPassed;
    }
    return total;
  }

  String formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }
}
