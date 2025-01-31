import 'dart:ui';

import 'package:flutter/material.dart';

import 'bank_choice_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // 배경을 투명하게 설정
      insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 100),
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
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const BankChoiceDialog();
                          },
                        ).catchError((error) {
                          // 오류 처리
                          print("다이얼로그 열기 오류: $error");
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.7),
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 3),
                          child: selectedBankName != null &&
                                  selectedBankImage != null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(selectedBankImage!,
                                        fit: BoxFit.cover),
                                    Text(
                                      selectedBankName!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.grey,
                              width: 3,
                            ), // 보더라인 추가
                          ),
                          onPressed: () async {
                            // 날짜 선택 기능
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2010),
                              lastDate: DateTime(2101),
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
                              width: 3,
                            ), // 보더라인 추가
                          ),
                          onPressed: () async {
                            // 날짜 선택 기능
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
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
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: interestRateController,
                        decoration: const InputDecoration(
                          labelText: '이자율 (%)',
                          suffixText: '%',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: 180,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.black,
                          )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text('비과세여부'),
                          Switch(
                            value: isTaxExempt,
                            onChanged: (value) {
                              setState(() {
                                isTaxExempt = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Slider(
                      value: taxRate,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: '세율',
                      onChanged: (value) {
                        setState(() {
                          taxRate = value;
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      // 저장 기능

                      Navigator.pop(
                        context,
                      ); // 다이얼로그 닫기 및 저장된 텍스트 반환
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
