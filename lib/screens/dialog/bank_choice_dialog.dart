import 'dart:ui';

import 'package:bank/data/banks.dart';
import 'package:flutter/material.dart';

class BankChoiceDialog extends StatefulWidget {
  const BankChoiceDialog({super.key});

  @override
  State<BankChoiceDialog> createState() => _BankChoiceDialogState();
}

class _BankChoiceDialogState extends State<BankChoiceDialog> {
  String? selectedBankName;
  String? selectedBankImage;

  // 은행 데이터를 저장하는 리스트

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
          children: List.generate(Banks.banks.length, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedBankName = Banks.banks[index]['name'];
                  selectedBankImage = Banks.banks[index]['image'];
                });
                Navigator.pop(context);
              },
              child: Card(
                color: Colors.white.withOpacity(0.7),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      Banks.banks[index]['image']!,
                      width: 40,
                      height: 40,
                    ),
                    Text(Banks.banks[index]['name']!),
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
