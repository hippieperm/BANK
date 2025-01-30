import 'dart:ui';

import 'package:bank/main.dart';
import 'package:flutter/material.dart';

class AddEditAccountDialog extends StatefulWidget {
  const AddEditAccountDialog({super.key});

  @override
  _AddEditAccountDialogState createState() => _AddEditAccountDialogState();
}

class _AddEditAccountDialogState extends State<AddEditAccountDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController bankNameController = TextEditingController();
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
                title: const Text('계좌 추가/수정'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: bankNameController,
                      decoration: const InputDecoration(labelText: '은행명'),
                    ),
                    TextField(
                      controller: startDateController,
                      decoration: const InputDecoration(labelText: '시작일'),
                      onTap: () async {
                        // 날짜 선택 기능
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          startDateController.text =
                              "${pickedDate.toLocal()}".split(' ')[0];
                        }
                      },
                    ),
                    TextField(
                      controller: endDateController,
                      decoration: const InputDecoration(labelText: '종료일'),
                      onTap: () async {
                        // 날짜 선택 기능
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          endDateController.text =
                              "${pickedDate.toLocal()}".split(' ')[0];
                        }
                      },
                    ),
                    TextField(
                      controller: interestRateController,
                      decoration: const InputDecoration(labelText: '이자율'),
                      keyboardType: TextInputType.number,
                    ),
                    SwitchListTile(
                      title: const Text('비과세 여부'),
                      value: isTaxExempt,
                      onChanged: (value) {
                        isTaxExempt = value;
                      },
                    ),
                    Slider(
                      value: taxRate,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: '세율',
                      onChanged: (value) {
                        taxRate = value;
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      // 저장 기능
                      Navigator.pop(context); // 다이얼로그 닫기
                      // 저장 로직 추가 필요
                    },
                    child: const Text('저장'),
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
