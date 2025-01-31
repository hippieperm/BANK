import 'dart:ui';

import 'package:bank/data/banks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BankChoiceDialog extends StatefulWidget {
  const BankChoiceDialog({super.key});

  @override
  State<BankChoiceDialog> createState() => _BankChoiceDialogState();
}

class _BankChoiceDialogState extends State<BankChoiceDialog>
    with SingleTickerProviderStateMixin {
  String? selectedBankName;
  String? selectedBankImage;
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
    // Banks.banks가 null이거나 비어있는지 확인
    if (Banks.banks.isEmpty) {
      return const AlertDialog(
        content: Text('은행 데이터를 불러올 수 없습니다.'),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 1, vertical: 100),
      child: Stack(
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
              child: AlertDialog(
                backgroundColor: const Color.fromARGB(255, 100, 82, 97),
                // title: const Text('은행 선택'),
                content: SizedBox(
                  width: double.maxFinite, // 최대 너비 설정
                  height: 440, // 다이얼로그 높이 조정
                  child: GridView.count(
                    crossAxisCount: 3, // 3개의 열
                    children: List.generate(Banks.banks.length, (index) {
                      final bank = Banks.banks[index];
                      // null 체크 추가
                      if (bank['name'] == null || bank['image'] == null) {
                        return const SizedBox(); // 빈 위젯 반환
                      }

                      return GestureDetector(
                        onTap: () {
                          try {
                            Navigator.pop(context, {
                              'name': bank['name'],
                              'image': bank['image'],
                            });
                          } catch (e) {
                            print('은행 선택 오류: $e');
                            Navigator.pop(context); // 오류 발생시 다이얼로그만 닫기
                          }
                        },
                        child: Card(
                          color: const Color.fromARGB(255, 160, 120, 152),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                bank['image']!.endsWith('.svg')
                                    ? SvgPicture.asset(
                                        bank['image']!,
                                        width: 40,
                                        height: 40,
                                        placeholderBuilder: (context) =>
                                            const Icon(Icons.error),
                                      )
                                    : Image.asset(
                                        bank['image']!,
                                        width: 40,
                                        height: 40,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(Icons.error);
                                        },
                                      ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  bank['name']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
