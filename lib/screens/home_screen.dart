import 'dart:math';
import 'dart:io';
import 'dart:typed_data';

import 'package:bank/screens/dialog/account_detail_dialog.dart';
import 'package:bank/screens/dialog/add_edit_account_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bank/services/account_service.dart';

import 'package:bank/services/storage_service.dart';
import 'package:bank/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool isDarkMode = true;
  List<Map<String, dynamic>> accounts = []; // 계좌 목록을 저장할 리스트 추가
  String currentSortType = ''; // 현재 정렬 기준
  bool isAscending = true; // 오름차순/내림차순 상태
  final List<String> notifications = [
    // 알림 목록 추가,
    '알림 1: 계좌 잔액이 부족합니다.',
    '알림 2: 이자 지급일이 다가옵니다.',
    '알림 3: 계좌 정보가 업데이트되었습니다.',
  ];
  bool hideExpiredAccounts = false; // 만기된 계좌 숨기기 상태 추가

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadHideExpiredAccountsSetting(); // 만기된 계좌 숨기기 설정 불러오기
    notifications.clear();
    notifications.addAll(NotificationService.getNotifications());
  }

  Future<void> _loadData() async {
    final loadedAccounts = await StorageService.loadAccounts();
    setState(() {
      accounts = loadedAccounts;
    });
    _loadSortSettings(); // 정렬 설정 불러오기
  }

  Future<void> _loadSortSettings() async {
    final settings = await StorageService.loadSortSettings();
    setState(() {
      currentSortType =
          settings['currentSortType'] ?? '총 수입'; // 기본 정렬 기준을 총 수입으로 설정
      isAscending = settings['isAscending'] ?? true; // 기본 정렬 방향 설정
    });
    AccountService.sortAccounts(
        accounts, currentSortType, isAscending); // 불러온 정렬 기준으로 정렬
  }

  Future<void> _loadHideExpiredAccountsSetting() async {
    final settings = await StorageService.loadSettings();
    setState(() {
      hideExpiredAccounts =
          settings['hideExpiredAccounts'] ?? false; // 기본값은 false
    });
  }

  // 계좌 추가 시 저장
  void _addAccount(Map<String, dynamic> account) {
    setState(() {
      accounts.add(account);
      // 총수입 필드 추가
      account['totalIncome'] = calculateTotalIncome(account); // 총수입 계산
      // 정렬 설정에 따라 계좌를 추가 후 정렬
      AccountService.sortAccounts(accounts, currentSortType, isAscending);
      StorageService.saveAccounts(accounts);
    });
  }

  // 계좌 삭제 시 저장
  void _deleteAccount(int index) {
    if (index >= 0 && index < accounts.length) {
      // 인덱스 유효성 검사
      setState(() {
        accounts.removeAt(index);
        StorageService.saveAccounts(accounts);
      });
    } else {
      // 인덱스가 유효하지 않을 경우 처리
      print('Invalid index: $index');
    }
  }

  // 계좌 수정 시 저장
  void _updateAccount(int index, Map<String, dynamic> updatedAccount) {
    setState(() {
      accounts[index] = updatedAccount; // 업데이트된 계좌 정보로 변경
      StorageService.saveAccounts(accounts); // 변경된 계좌 목록 저장
    });
  }

  void sortAccounts(String sortType) {
    setState(() {
      if (currentSortType == sortType) {
        isAscending = !isAscending; // 현재 정렬 기준이 같으면 오름차순/내림차순 전환
      } else {
        currentSortType = sortType; // 새로운 정렬 기준 설정
        isAscending = true; // 새로운 기준으로는 항상 오름차순으로 시작
      }
      if (currentSortType == '금리') {
        AccountService.sortAccountsByInterestRate(accounts, isAscending);
      } else if (currentSortType == '총 수입') {
        AccountService.sortAccountsByTotalIncome(accounts, isAscending);
      } else {
        AccountService.sortAccounts(accounts, currentSortType, isAscending);
      }
      StorageService.saveSortSettings(currentSortType, isAscending); // 정렬 설정 저장
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1b1b1b),
      appBar: AppBar(
        backgroundColor: const Color(0xff2d2d2d),
        elevation: 0.1,
        title: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            '정기예금 관리',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white, size: 28),
            color: const Color(0xff2d2d2d),
            onSelected: sortAccounts,
            itemBuilder: (BuildContext context) => [
              '은행별',
              '만기일자',
              '원금',
              '월이자수입',
              '금리',
              '시작일자',
              '총 수입',
              //총수입,
              //만기인지 아닌지 차트,
              //상세보기에 은행 전화번호,총수입 원금
            ].map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Row(
                  children: [
                    Text(
                      choice,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (currentSortType == choice)
                      Icon(
                        isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                        color: Colors.white,
                        size: 18,
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(
                hideExpiredAccounts ? Icons.visibility_off : Icons.visibility,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  hideExpiredAccounts = !hideExpiredAccounts; // 상태 전환
                  StorageService.saveSettings(
                      {'hideExpiredAccounts': hideExpiredAccounts}); // 설정 저장
                });
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
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: const Color(0xff3d3d3d),
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
                            SizedBox(
                              width: 150, // 원하는 최대 너비 설정
                              child: FittedBox(
                                fit: BoxFit.scaleDown, // 텍스트가 너무 클 경우에만 축소
                                child: Text(
                                  '₩ ${formatNumber(calculateTotalMonthlyInterest())}',
                                  style: const TextStyle(
                                    fontSize: 24, // 기본 폰트 크기
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
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
                              // '누적 수령 이자',
                              '총 수입',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 150, // 원하는 최대 너비 설정
                              child: FittedBox(
                                fit: BoxFit.scaleDown, // 텍스트가 너무 클 경우에만 축소
                                child: Text(
                                  '₩ ${formatNumber(calculateTotalReceivedInterest())}',
                                  style: const TextStyle(
                                    fontSize: 24, // 기본 폰트 크기 설정
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
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
            Expanded(
              child: ListView.builder(
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  final endDate = DateTime.parse(account['endDate']);
                  final remainingDays =
                      max(0, endDate.difference(DateTime.now()).inDays);

                  // 만기된 계좌 숨기기 로직 추가
                  if (hideExpiredAccounts && remainingDays <= 0) {
                    return const SizedBox.shrink(); // 만기된 계좌는 숨김
                  }

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
                    margin: const EdgeInsets.only(top: 10),
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
                                  Row(
                                    children: [
                                      if (account['isCustomName'] == true) ...[
                                        const Icon(Icons.account_balance,
                                            size: 24, color: Colors.white),
                                        const SizedBox(width: 8),
                                        Text(
                                          account['bankName'] ?? '',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ] else if (account['isApp'] == true) ...[
                                        Image.memory(
                                          Uint8List.fromList(List<int>.from(
                                              account['bankImage'])),
                                          width: 24,
                                          height: 24,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              const Icon(Icons.account_balance,
                                                  size: 24),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          account['appName'] ?? '',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ] else ...[
                                        account['bankImage']
                                                .toString()
                                                .endsWith('.svg')
                                            ? SvgPicture.asset(
                                                account['bankImage'],
                                                width: 24,
                                                height: 24,
                                                fit: BoxFit.contain,
                                              )
                                            : Image.asset(
                                                account['bankImage'],
                                                width: 24,
                                                height: 24,
                                                fit: BoxFit.contain,
                                              ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        '${account['startDate']}  ~  ',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        '${account['endDate']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: remainingDays <= 30
                                              ? Colors.red
                                              : Colors.white70,
                                          fontWeight: remainingDays <= 30
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Text(
                                        '원금: ₩ ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        formatNumber(principal),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 1),
                                  Row(
                                    children: [
                                      const Text(
                                        '월 이자 수입: ₩ ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        formatNumber(monthlyInterest),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 80,
                                height: 80,
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
                                      builder: (context) => AccountDetailDialog(
                                        lateDay: remainingDays,
                                        account: account,
                                        bankName: account['isApp'] == true ||
                                                account['isGallery'] == true
                                            ? '커스텀 이미지' // 앱이나 갤러리에서 가져온 이미지인 경우
                                            : account[
                                                'bankImage'], // 기본 은행 이미지인 경우
                                        onEdit: (updatedAccount) {
                                          _updateAccount(index, updatedAccount);
                                        },
                                        onDelete: () {
                                          _deleteAccount(index);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    );
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'D-Day',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: remainingDays <= 30
                                              ? Colors.red
                                              : Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '$remainingDays',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: remainingDays
                                                      .toString()
                                                      .length >=
                                                  5
                                              ? 18
                                              : remainingDays
                                                          .toString()
                                                          .length >=
                                                      4
                                                  ? 20
                                                  : remainingDays
                                                              .toString()
                                                              .length >=
                                                          3
                                                      ? 26
                                                      : 28, // 글자 수에 따라 폰트 사이즈 조정
                                          color: remainingDays <= 30
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
              builder: (context) => const AddEditAccountDialog(
                bankName: '',
                startDate: '',
                endDate: '',
                isTaxExempt: false,
                bankImage: '',
                account: {},
              ),
            ).then((result) {
              if (result != null) {
                _addAccount(result);
              }
            });
          } else if (index == 2) {
            // 설정 화면으로 이동
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => const SettingsScreen()),
            // );
          }
        },
      ),
    );
  }

  double calculateTotalMonthlyInterest() {
    return AccountService.calculateTotalMonthlyInterest(accounts);
  }

  double calculateTotalReceivedInterest() {
    return AccountService.calculateTotalReceivedInterest(accounts);
  }

  String formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  // 총수입 계산 함수 추가
  double calculateTotalIncome(Map<String, dynamic> account) {
    // 총수입 계산 로직 구현
    double principal = account['principal'] ?? 0.0;
    double interestRate = account['interestRate'] ?? 0.0;
    int durationMonths = account['durationMonths'] ?? 0; // 계좌 기간 (개월)
    return principal * (interestRate / 100) * durationMonths / 12; // 총수입 계산
  }
}
