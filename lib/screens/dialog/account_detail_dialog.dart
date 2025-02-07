import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'add_edit_account_dialog.dart';

class AccountDetailDialog extends StatefulWidget {
  final Map<String, dynamic> account;
  final String bankName;
  final List<String>? notifications;

  const AccountDetailDialog({
    super.key,
    required this.account,
    required this.bankName,
    this.notifications,
  });

  @override
  State<AccountDetailDialog> createState() => _AccountDetailDialogState();
}

class _AccountDetailDialogState extends State<AccountDetailDialog>
    with SingleTickerProviderStateMixin {
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

  // 천 단위 구분 쉼표를 위한 포맷 함수
  String formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 100),
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                color: Colors.black.withOpacity(0),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.95,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: AnimatedOpacity(
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
                  backgroundColor:
                      const Color.fromARGB(255, 56, 55, 55).withOpacity(0.6),
                  title: Row(
                    children: [
                      SvgPicture.asset(
                        widget.bankName,
                        height: 28,
                      ),
                    ],
                  ),
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.notifications != null
                          ? widget.notifications!
                              .map((notification) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Text(
                                      notification,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ))
                              .toList()
                          : [
                              Text(
                                '시작일: ${widget.account['startDate']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '종료일: ${widget.account['endDate']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '이자율: ${widget.account['interestRate']}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '비과세 여부: ${widget.account['isTaxExempt'] ? '비과세' : '과세'} 적용',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '월 수익: ₩ ${formatNumber(widget.account['principal'] * (widget.account['interestRate'] / 100) / 12)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '남은 기간: ${DateTime.parse(widget.account['endDate']).difference(DateTime.now()).inDays}일 남음',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '총 수입: ₩ ${formatNumber(widget.account['principal'] * (widget.account['interestRate'] / 100) * (DateTime.now().difference(DateTime.parse(widget.account['startDate'])).inDays) / 365)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                    ),
                  ),
                  actions: [
                    widget.notifications != null
                        ? TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: SizedBox(
                              width: double.infinity,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 22,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '알림 지우기',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.warning,
                                    animType: AnimType.scale,
                                    title: '수정 확인',
                                    desc: '정말로 수정하시겠습니까?',
                                    btnCancelOnPress: () {},
                                    btnOkOnPress: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            AddEditAccountDialog(
                                          bankName: widget.bankName,
                                          startDate:
                                              widget.account['startDate'],
                                          endDate: widget.account['endDate'],
                                          interestRate:
                                              widget.account['interestRate'],
                                          principal:
                                              widget.account['principal'],
                                          isTaxExempt:
                                              widget.account['isTaxExempt'],
                                        ),
                                      );
                                    },
                                  ).show();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(1),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 22,
                                    ),
                                    child: Text(
                                      '수정하기',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // 삭제 확인 다이얼로그 표시
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.error,
                                    animType: AnimType.scale,
                                    title: '삭제 확인',
                                    desc: '정말로 삭제하시겠습니까?',
                                    btnCancelOnPress: () {},
                                    btnOkOnPress: () {
                                      // 삭제 로직 추가
                                    },
                                  ).show();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(1),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 22,
                                    ),
                                    child: Text(
                                      '삭제하기',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                      ),
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
        ],
      ),
    );
  }
}
