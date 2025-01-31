import 'dart:ui';

import 'package:flutter/material.dart';

class BankChoiceDialog extends StatefulWidget {
  const BankChoiceDialog({super.key});

  @override
  State<BankChoiceDialog> createState() => _BankChoiceDialogState();
}

class _BankChoiceDialogState extends State<BankChoiceDialog> {
  String? selectedBankName;
  String? selectedBankImage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 86, 89, 92),
      // title: const Text('은행 선택'),
      content: SizedBox(
        width: double.maxFinite, // 최대 너비 설정
        height: 440, // 다이얼로그 높이 조정
        child: GridView.count(
          crossAxisCount: 3, // 3개의 열
          children: List.generate(13, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedBankName = '은행 ${index + 1}';
                  selectedBankImage = '은행 ${index + 1} 이미지 경로';
                });
                Navigator.pop(context);
              },
              child: Card(
                color: Colors.white.withOpacity(0.7),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_balance, size: 40), // 임시 아이콘
                    Text('은행 ${index + 1}'), // 임시 은행명
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
