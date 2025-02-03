import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

import 'bank_choice_dialog.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class AddEditAccountDialog extends StatefulWidget {
  const AddEditAccountDialog({super.key});

  @override
  _AddEditAccountDialogState createState() => _AddEditAccountDialogState();
}

class _AddEditAccountDialogState extends State<AddEditAccountDialog>
    with SingleTickerProviderStateMixin {
  String? selectedBankName;
  String? selectedBankImage;
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController interestRateController = TextEditingController();
  final TextEditingController principalController = TextEditingController();
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // 배경을 투명하게 설정
      insetPadding: const EdgeInsets.symmetric(horizontal: 1, vertical: 100),
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
                backgroundColor: Colors.white.withOpacity(0.7),
                title: const Text('계좌 추가/수정'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final result = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const BankChoiceDialog();
                          },
                        );

                        if (result != null && mounted) {
                          setState(() {
                            selectedBankName = result['name'];
                            selectedBankImage = result['image'];
                          });
                        }
                      },
                      child: Material(
                        // InkWell을 사용하기 위해 Material 위젯 추가
                        color: Colors.transparent, // 배경색 투명 설정
                        child: InkWell(
                          // 터치 효과를 위해 InkWell 추가
                          borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                          splashColor:
                              Colors.white.withOpacity(0.3), // 터치 효과 색상
                          highlightColor:
                              Colors.white.withOpacity(0.1), // 눌렀을 때 효과 색상
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.7),
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 3,
                              ),
                              child: selectedBankName != null &&
                                      selectedBankImage != null
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        selectedBankImage!.endsWith('.svg')
                                            ? SvgPicture.asset(
                                                selectedBankImage!,
                                                width: 24,
                                                height: 24,
                                                placeholderBuilder: (context) =>
                                                    const Icon(Icons.error),
                                              )
                                            : Image.asset(
                                                selectedBankImage!,
                                                width: 24,
                                                height: 24,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return const Icon(
                                                      Icons.error);
                                                },
                                              ),
                                        const SizedBox(width: 8),
                                      ],
                                    )
                                  : const Text(
                                      '은행선택',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2010),
                              lastDate: DateTime(2101),
                              builder: (BuildContext context, Widget? child) {
                                return BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 5.0, sigmaY: 5.0),
                                  child: AnimatedScale(
                                    scale: 0.95,
                                    duration:
                                        const Duration(milliseconds: 1800),
                                    child: child!,
                                  ),
                                );
                              },
                            );
                            if (pickedDate != null) {
                              setState(() {
                                startDateController.text =
                                    "${pickedDate.toLocal()}".split(' ')[0];
                              });
                            }
                          },
                          child: Text(
                            startDateController.text.isEmpty
                                ? '시작일 선택'
                                : startDateController.text,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                        const Text(
                          '  ~  ',
                          style: TextStyle(
                            fontSize: 24,
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
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                              builder: (BuildContext context, Widget? child) {
                                return BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 5.0, sigmaY: 5.0),
                                  child: AnimatedScale(
                                    scale: 0.95,
                                    duration:
                                        const Duration(milliseconds: 1800),
                                    child: child!,
                                  ),
                                );
                              },
                            );
                            if (pickedDate != null) {
                              setState(() {
                                endDateController.text =
                                    "${pickedDate.toLocal()}".split(' ')[0];
                              });
                            }
                          },
                          child: Text(
                            endDateController.text.isEmpty
                                ? '종료일 선택'
                                : endDateController.text,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 180,
                      child: TextField(
                        controller: principalController,
                        decoration: InputDecoration(
                          labelText: '원금',
                          suffixText: '원',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(
                              color: Colors.black.withOpacity(0.4),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: const BorderSide(color: Colors.purple),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          // 쉼표 제거 후 숫자만 추출
                          String numericOnly = removeCommas(value);
                          if (numericOnly.isNotEmpty) {
                            // 천 단위 쉼표 추가
                            String formatted = formatNumber(numericOnly);
                            // 커서 위치 저장
                            int cursorPosition =
                                principalController.selection.start;
                            // 이전 쉼표 개수와 새로운 쉼표 개수의 차이
                            int commasDiff = formatted.length - value.length;

                            principalController.text = formatted;
                            // 커서 위치 조정
                            principalController.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: cursorPosition + commasDiff),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: interestRateController,
                        decoration: InputDecoration(
                          labelText: '이자율(%)',
                          suffixText: '%',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(
                              color: Colors.black.withOpacity(0.4),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: const BorderSide(color: Colors.purple),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 195,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          )),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Switch(
                              value: isTaxExempt,
                              onChanged: (value) {
                                setState(() {
                                  isTaxExempt = value;
                                });
                              },
                            ),
                            const Text('비과세여부 '),
                            Text(
                              isTaxExempt
                                  ? '${taxRate.toStringAsFixed(1)}%'
                                  : '세율',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: isTaxExempt ? taxRate : 0,
                      min: 0,
                      max: 30,
                      divisions: 300,
                      label:
                          isTaxExempt ? '${taxRate.toStringAsFixed(1)}%' : '세율',
                      onChanged: isTaxExempt
                          ? (value) {
                              setState(() {
                                taxRate = value;
                              });
                            }
                          : null,
                      activeColor: isTaxExempt
                          ? Colors.purple.withOpacity(0.9)
                          : Colors.grey,
                      inactiveColor: Colors.grey,
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

                      Navigator.pop(context, {
                        'bankName': selectedBankName,
                        'bankImage': selectedBankImage,
                        'startDate': startDateController.text,
                        'endDate': endDateController.text,
                        'interestRate':
                            double.parse(interestRateController.text),
                        'isTaxExempt': isTaxExempt,
                        'taxRate': taxRate,
                        'principal': double.parse(removeCommas(
                            principalController.text)), // 쉼표 제거 후 변환
                      });
                    },
                    child: Center(
                      child: Container(
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
