import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'add_edit_account_dialog.dart';

class AccountDetailDialog extends StatefulWidget {
  final Map<String, dynamic> account;
  final String bankName;
  final List<String>? notifications;
  final Function(Map<String, dynamic>)? onEdit;
  final Function()? onDelete;
  final int? lateDay;

  const AccountDetailDialog({
    super.key,
    required this.account,
    required this.bankName,
    this.notifications,
    this.onEdit,
    this.onDelete,
    this.lateDay,
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
    return Center(
      child: SizedBox(
        width: 500,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal:
                MediaQuery.of(context).size.width * 0.05, // 화면 너비의 5%로 설정
            vertical:
                MediaQuery.of(context).size.height * 0.15, // 화면 높이의 10%로 설정
          ),
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
                      backgroundColor: const Color.fromARGB(255, 56, 55, 55)
                          .withOpacity(0.8),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildBankImage(),
                        ],
                      ),
                      content: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                                    style: TextStyle(
                                      color: DateTime.parse(
                                                      widget.account['endDate'])
                                                  .difference(DateTime.now())
                                                  .inDays <=
                                              30
                                          ? Colors.red
                                          : Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  widget.lateDay! > 0
                                      ? Text(
                                          '남은 기간: ${DateTime.parse(widget.account['endDate']).difference(DateTime.now()).inDays}일 남음',
                                          style: TextStyle(
                                            color: DateTime.parse(widget
                                                            .account['endDate'])
                                                        .difference(
                                                            DateTime.now())
                                                        .inDays <=
                                                    30
                                                ? Colors.red
                                                : Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : Container(),
                                  // : const Text(
                                  //     '만기',
                                  //     style: TextStyle(
                                  //       color: Colors.red,
                                  //       fontWeight: FontWeight.bold,
                                  //       fontSize: 18,
                                  //     ),
                                  //   ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Center(
                                      child: Container(
                                        width: 190,
                                        height: 2,
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '원금: ₩ ${formatNumber(widget.account['principal'])}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '이자율: ${widget.account['interestRate']}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '비과세 여부: ${widget.account['isTaxExempt'] ? '비과세' : '과세'} 적용',
                                    style: TextStyle(
                                      color: widget.account['isTaxExempt']
                                          ? Colors.purple[200]
                                          : Colors.red[200],
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Center(
                                      child: Container(
                                        width: 190,
                                        height: 2,
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '월 수익: ₩ ${formatNumber(widget.account['principal'] * (widget.account['interestRate'] / 100) / 12)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // const SizedBox(height: 4),
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
                                        horizontal: 30,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: TextButton(
                                      onPressed: () {
                                        AwesomeDialog(
                                          width: 380,
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
                                                account: widget.account,
                                                bankName: widget.bankName,
                                                bankImage:
                                                    widget.account['bankImage'],
                                                startDate:
                                                    widget.account['startDate'],
                                                endDate:
                                                    widget.account['endDate'],
                                                interestRate: widget
                                                    .account['interestRate'],
                                                principal:
                                                    widget.account['principal'],
                                                isTaxExempt: widget
                                                    .account['isTaxExempt'],
                                                    
                                                isEditing: true,
                                              ),
                                            ).then((result) {
                                              if (result != null &&
                                                  widget.onEdit != null) {
                                                widget.onEdit!(result);
                                                Navigator.pop(context);
                                              }
                                            });
                                          },
                                        ).show();
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(1),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 14,
                                            horizontal: 20,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '수정하기',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: TextButton(
                                      onPressed: () {
                                        // 삭제 확인 다이얼로그 표시
                                        AwesomeDialog(
                                          width: 380,
                                          context: context,
                                          dialogType: DialogType.error,
                                          animType: AnimType.scale,
                                          title: '삭제 확인',
                                          desc: '정말로 삭제하시겠습니까?',
                                          btnCancelOnPress: () {},
                                          btnOkOnPress: () {
                                            if (widget.onDelete != null) {
                                              widget.onDelete!(); // 삭제 콜백 호출
                                            }
                                          },
                                        ).show();
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(1),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 14,
                                            horizontal: 20,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '삭제하기',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
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
        ),
      ),
    );
  }

  Widget buildBankImage() {
    try {
      if (widget.account['isApp'] == true) {
        final List<dynamic> imageData = widget.account['bankImage'];
        final List<int> intList = imageData.map((e) => e as int).toList();
        return Image.memory(
          Uint8List.fromList(intList),
          height: 28,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.account_balance, size: 28),
        );
      } else if (widget.account['isGallery'] == true) {
        return Image.file(
          File(widget.account['bankImage']),
          height: 28,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.account_balance, size: 28),
        );
      } else {
        final String imagePath = widget.account['bankImage'];
        return imagePath.endsWith('.svg')
            ? SvgPicture.asset(
                imagePath,
                height: 28,
                placeholderBuilder: (context) =>
                    const Icon(Icons.account_balance, size: 28),
              )
            : Image.asset(
                imagePath,
                height: 28,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.account_balance, size: 28),
              );
      }
    } catch (e) {
      print('Error loading bank image: $e');
      return const Icon(Icons.account_balance, size: 28);
    }
  }
}
