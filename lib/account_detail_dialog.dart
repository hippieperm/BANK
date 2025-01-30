import 'package:flutter/material.dart';

class AccountDetailDialog extends StatelessWidget {
  final String bankName;

  const AccountDetailDialog({super.key, required this.bankName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(bankName),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('시작일: YYYY-MM-DD'),
          Text('종료일: YYYY-MM-DD'),
          Text('이자율: X.X%'),
          Text('비과세 여부: 비과세 적용'),
          Text('월 수익: ₩ XXX,XXX'),
          Text('남은 기간: 30일 남음'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // 수정하기 기능
            Navigator.pop(context); // 다이얼로그 닫기
            // 수정 로직 추가 필요
          },
          child: const Text('수정하기'),
        ),
        TextButton(
          onPressed: () {
            // 삭제하기 기능
            Navigator.pop(context); // 다이얼로그 닫기
            // 삭제 로직 추가 필요
          },
          child: const Text('삭제하기'),
        ),
      ],
    );
  }
}
