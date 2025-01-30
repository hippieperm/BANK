import 'package:bank/add_edit_account_dialog.dart';
import 'package:bank/home_screen.dart';
import 'package:flutter/material.dart';
import 'dart:ui'; // 추가: BackdropFilter를 사용하기 위해 필요

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '정기예금 관리',
      theme: ThemeData.light(), // 화이트모드 테마
      darkTheme: ThemeData.dark(), // 다크모드 테마
      themeMode: ThemeMode.light, // 시스템 설정에 따라 테마 선택
      home: const HomeScreen(),
    );
  }
}
