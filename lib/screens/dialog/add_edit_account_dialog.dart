import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

import 'bank_choice_dialog.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class AddEditAccountDialog extends StatefulWidget {
  final Map<String, dynamic> account;
  final String bankName;
  final dynamic bankImage;
  final String startDate;
  final String endDate;
  final double? interestRate;
  final double? principal;
  final bool isTaxExempt;
  final bool isEditing;

  const AddEditAccountDialog({
    super.key,
    required this.account,
    required this.bankName,
    required this.bankImage,
    required this.startDate,
    required this.endDate,
    this.interestRate,
    this.principal,
    required this.isTaxExempt,
    this.isEditing = false,
  });

  @override
  _AddEditAccountDialogState createState() => _AddEditAccountDialogState();
}

class _AddEditAccountDialogState extends State<AddEditAccountDialog>
    with SingleTickerProviderStateMixin {
  String? selectedBankName;
  dynamic selectedBankImage;
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController interestRateController = TextEditingController();
  final TextEditingController principalController = TextEditingController();
  bool isTaxExempt = false;
  double taxRate = 0;
  late AnimationController _controller;
  Map<String, dynamic> result = {};

  @override
  void initState() {
    super.initState();
    selectedBankName = widget.bankName;

    // result 초기화 수정
    result = {
      'isCustomName': widget.account['isCustomName'] ?? false,
      'bankName': widget.bankName,
    };

    // bankImage 초기화 시 타입 체크 및 변환
    if (widget.account['isApp'] == true) {
      selectedBankImage = widget.bankImage;
      result['isApp'] = true;
      result['appName'] = widget.account['appName'];
    } else {
      selectedBankImage = widget.bankImage;
    }

    startDateController.text = widget.startDate;
    endDateController.text = widget.endDate;
    principalController.text = formatCurrency(widget.principal ?? 0);
    interestRateController.text = widget.interestRate?.toString() ?? '';
    isTaxExempt = widget.isTaxExempt;
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
  String formatNumber(String text) {
    if (text.isEmpty) return '';
    return text.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  // 쉼표를 제거하는 함수
  String removeCommas(String text) {
    return text.replaceAll(',', '');
  }

  String formatCurrency(double amount) {
    // 소수점 이하를 제거하고 천 단위로 쉼표 추가
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  // 숫자 문자열을 double로 안전하게 변환하는 함수 추가
  double? parseDouble(String text) {
    if (text.isEmpty) return null;
    final cleanText = text.replaceAll(',', '').trim();
    try {
      return double.parse(cleanText);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: Center(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        color: Colors.black.withOpacity(0),
                      ),
                    ),
                  ),
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
                      child: SingleChildScrollView(
                        child: AlertDialog(
                          backgroundColor: Colors.white.withOpacity(0.7),
                          title: Center(
                            child: Text(
                              widget.isEditing ? '계좌 수정' : '계좌 추가',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 18),
                                child: Center(
                                  child: Container(
                                    width: 190,
                                    height: 2,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: widget.isEditing
                                    ? null // 수정 모드일 때는 터치 비활성화
                                    : () async {
                                        final dialogResult = await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return const BankChoiceDialog();
                                          },
                                        );

                                        if (dialogResult != null && mounted) {
                                          setState(() {
                                            result = dialogResult;
                                            selectedBankName =
                                                dialogResult['name'];
                                            selectedBankImage =
                                                dialogResult['image'];
                                          });
                                        }
                                      },
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    splashColor: widget.isEditing
                                        ? Colors
                                            .transparent // 수정 모드일 때는 터치 효과 제거
                                        : Colors.white.withOpacity(0.3),
                                    highlightColor: widget.isEditing
                                        ? Colors
                                            .transparent // 수정 모드일 때는 터치 효과 제거
                                        : Colors.white.withOpacity(0.1),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0),
                                      decoration: BoxDecoration(
                                        color: widget.isEditing
                                            ? Colors.grey.withOpacity(
                                                0.9) // 수정 모드일 때는 회색으로 변경
                                            : Colors.purple.withOpacity(0.7),
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 30,
                                          vertical: 3,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (widget.account[
                                                        'isCustomName'] ==
                                                    true ||
                                                result['isCustomName'] ==
                                                    true) ...[
                                              const Icon(Icons.account_balance,
                                                  size: 24,
                                                  color: Colors.white),
                                              const SizedBox(width: 8),
                                              Text(
                                                widget.account['bankName'] ??
                                                    selectedBankName ??
                                                    '',
                                                style: TextStyle(
                                                  color: widget.isEditing
                                                      ? Colors.black
                                                      : Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ] else if (result['isApp'] ==
                                                true) ...[
                                              Image.memory(
                                                Uint8List.fromList(
                                                    List<int>.from(
                                                        selectedBankImage)),
                                                width: 24,
                                                height: 24,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Container(),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                result['appName'] ??
                                                    widget.account['appName'] ??
                                                    '',
                                                style: TextStyle(
                                                  color: widget.isEditing
                                                      ? Colors.black
                                                      : Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ] else if (selectedBankImage !=
                                                    null &&
                                                selectedBankImage != '') ...[
                                              selectedBankImage
                                                      .toString()
                                                      .endsWith('.svg')
                                                  ? SvgPicture.asset(
                                                      selectedBankImage
                                                          .toString(),
                                                      width: 24,
                                                      height: 24,
                                                      placeholderBuilder:
                                                          (context) =>
                                                              Container(),
                                                    )
                                                  : Image.asset(
                                                      selectedBankImage
                                                          .toString(),
                                                      width: 24,
                                                      height: 24,
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          Container(),
                                                    ),
                                            ] else ...[
                                              const Text(
                                                '은행선택',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      side: const BorderSide(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                    ),
                                    onPressed: () async {
                                      // 날짜 선택 기능
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2010),
                                        lastDate: DateTime(2101),
                                        builder: (BuildContext context,
                                            Widget? child) {
                                          return BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 5.0, sigmaY: 5.0),
                                            child: AnimatedScale(
                                              scale: 0.95,
                                              duration: const Duration(
                                                  milliseconds: 1800),
                                              child: child!,
                                            ),
                                          );
                                        },
                                      );
                                      if (pickedDate != null) {
                                        setState(() {
                                          startDateController.text =
                                              "${pickedDate.toLocal()}"
                                                  .split(' ')[0];
                                        });
                                      }
                                    },
                                    child: Text(
                                      startDateController.text.isEmpty
                                          ? '시작일 선택'
                                          : startDateController.text,
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  const Text(
                                    '  ~  ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      side: const BorderSide(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                    ),
                                    onPressed: () async {
                                      // 날짜 선택 기능
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2101),
                                        builder: (BuildContext context,
                                            Widget? child) {
                                          return BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 5.0, sigmaY: 5.0),
                                            child: AnimatedScale(
                                              scale: 0.95,
                                              duration: const Duration(
                                                  milliseconds: 1800),
                                              child: child!,
                                            ),
                                          );
                                        },
                                      );
                                      if (pickedDate != null) {
                                        setState(() {
                                          endDateController.text =
                                              "${pickedDate.toLocal()}"
                                                  .split(' ')[0];
                                        });
                                      }
                                    },
                                    child: Text(
                                      endDateController.text.isEmpty
                                          ? '종료일 선택'
                                          : endDateController.text,
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: TextField(
                                    controller: principalController,
                                    decoration: InputDecoration(
                                      labelText: '원금',
                                      suffixText: '원',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        borderSide: BorderSide(
                                          color: Colors.black.withOpacity(0.4),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        borderSide: const BorderSide(
                                            color: Colors.purple),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      // 쉼표 제거 후 숫자만 추출
                                      String numericOnly = removeCommas(value);
                                      if (numericOnly.isNotEmpty) {
                                        // 안전하게 double로 변환
                                        double? number =
                                            parseDouble(numericOnly);
                                        if (number != null) {
                                          // 천 단위 쉼표 추가
                                          String formatted =
                                              formatCurrency(number);
                                          principalController.text = formatted;
                                          // 커서 위치 조정
                                          principalController.selection =
                                              TextSelection.fromPosition(
                                            TextPosition(
                                                offset: formatted.length),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 115,
                                    height: 50, // 높이를 동일하게 설정
                                    child: TextField(
                                      controller: interestRateController,
                                      decoration: InputDecoration(
                                        labelText: '이자율(%)',
                                        suffixText: '%',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          borderSide: BorderSide(
                                            color:
                                                Colors.black.withOpacity(0.4),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          borderSide: const BorderSide(
                                              color: Colors.purple),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        // 쉼표 제거 후 숫자만 추출
                                        String numericOnly =
                                            removeCommas(value);
                                        if (numericOnly.isNotEmpty) {
                                          // 천 단위 쉼표 추가
                                          String formatted =
                                              formatNumber(numericOnly);
                                          // 커서 위치 저장
                                          int cursorPosition =
                                              interestRateController
                                                  .selection.start;
                                          // 이전 쉼표 개수와 새로운 쉼표 개수의 차이
                                          int commasDiff =
                                              formatted.length - value.length;

                                          interestRateController.text =
                                              formatted;
                                          // 커서 위치 조정
                                          interestRateController.selection =
                                              TextSelection.fromPosition(
                                            TextPosition(
                                                offset: cursorPosition +
                                                    commasDiff),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isTaxExempt =
                                            !isTaxExempt; // 클릭 시 비과세 여부 토글
                                        taxRate = isTaxExempt
                                            ? 0
                                            : taxRate; // 비과세 선택 시 세율을 0으로 설정
                                      });
                                    },
                                    child: Container(
                                      width: 115,
                                      height: 50, // 높이를 동일하게 설정
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isTaxExempt
                                              ? Colors.black
                                              : Colors.black.withOpacity(0.4),
                                          width: 1,
                                        ),
                                        color: isTaxExempt
                                            ? Colors.purple.withOpacity(0.3)
                                            : Colors.transparent, // 색상 변경
                                      ),
                                      child: Center(
                                        // 텍스트 중앙 정렬
                                        child: Text(
                                          '비과세',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: isTaxExempt
                                                ? 16
                                                : 14, // 비과세 선택 시 폰트 크기 조정
                                            fontWeight: isTaxExempt
                                                ? FontWeight.bold
                                                : FontWeight
                                                    .normal, // 비과세 선택 시 볼드체
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                if (selectedBankName == null ||
                                    startDateController.text.isEmpty ||
                                    endDateController.text.isEmpty ||
                                    interestRateController.text.isEmpty ||
                                    principalController.text.isEmpty) {
                                  AwesomeDialog(
                                    width: 380,
                                    context: context,
                                    dialogType: DialogType.warning,
                                    animType: AnimType.scale,
                                    title: '입력 오류',
                                    desc: '모든 필드를 입력해주세요',
                                    btnOkOnPress: () {},
                                    btnOkColor: Colors.purple,
                                  ).show();
                                  return;
                                }

                                // 계좌 추가 성공 다이얼로그
                                AwesomeDialog(
                                  width: 380,
                                  context: context,
                                  dialogType: DialogType.success,
                                  animType: AnimType.scale,
                                  title: widget.isEditing
                                      ? '계좌 수정 성공'
                                      : '계좌 추가 성공',
                                  desc: widget.isEditing
                                      ? '계좌가 성공적으로 수정되었습니다.'
                                      : '계좌가 성공적으로 추가되었습니다.',
                                  btnOkOnPress: () {
                                    Navigator.pop(context, {
                                      ...widget.account, // 기존 계좌 정보를 먼저 복사
                                      'bankName': result['isCustomName'] == true
                                          ? result['bankName']
                                          : result['isApp'] == true
                                              ? result['appName']
                                              : selectedBankName,
                                      'bankImage': selectedBankImage ?? '',
                                      'startDate': startDateController.text,
                                      'endDate': endDateController.text,
                                      'interestRate': double.parse(removeCommas(
                                          interestRateController.text)),
                                      'isTaxExempt': isTaxExempt,
                                      'taxRate': taxRate,
                                      'principal': double.parse(removeCommas(
                                          principalController.text)),
                                      'isApp': result['isApp'] ??
                                          widget.account['isApp'] ??
                                          false,
                                      'isCustomName': result['isCustomName'] ??
                                          widget.account['isCustomName'] ??
                                          false,
                                      'appName': result['appName'] ??
                                          widget.account['appName'],
                                    });
                                  },
                                  btnOkColor: Colors.green,
                                ).show();
                              },
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 93, 72, 153),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 90,
                                  ),
                                  child: Text(
                                    '저장',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
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
        ),
      ),
    );
  }
}
