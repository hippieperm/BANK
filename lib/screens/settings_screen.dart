import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            DropdownButton<String>(
              items: <String>['7일', '14일', '30일'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                // 알림 주기 설정 처리
              },
              hint: const Text('알림 주기 설정'),
            ),
            const TextField(decoration: InputDecoration(labelText: '기본 세율 설정')),
            ElevatedButton(
              onPressed: () {
                // 데이터 초기화 기능
              },
              child: const Text('데이터 초기화'),
            ),
          ],
        ),
      ),
    );
  }
}
