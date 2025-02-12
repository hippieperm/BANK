import 'dart:typed_data';
import 'dart:ui';

import 'package:bank/data/banks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:installed_apps/installed_apps.dart';

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
                backgroundColor: const Color(0xff2d2d2d),
                // title: const Text('은행 선택'),
                content: SizedBox(
                  width: double.maxFinite, // 최대 너비 설정
                  height: 440, // 다이얼로그 높이 조정
                  child: GridView.count(
                    crossAxisCount: 3,
                    children: [
                      ...List.generate(Banks.banks.length, (index) {
                        final bank = Banks.banks[index];
                        if (bank['name'] == null || bank['image'] == null) {
                          return const SizedBox();
                        }
                        return GestureDetector(
                          onTap: () {
                            try {
                              Navigator.pop(context, {
                                'name': bank['name'],
                                'image': bank['image'],
                                'isAsset': true
                              });
                            } catch (e) {
                              print('은행 선택 오류: $e');
                              Navigator.pop(context); // 오류 발생시 다이얼로그만 닫기
                            }
                          },
                          child: Card(
                            color: const Color(0xff3d3d3d),
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
                      GestureDetector(
                        onTap: () async {
                          // 앱 아이콘 선택 다이얼로그
                          final apps =
                              await InstalledApps.getInstalledApps(true, true);
                          if (!context.mounted) return;

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: const Color(0xff2d2d2d),
                                title: const Text('앱 선택',
                                    style: TextStyle(color: Colors.white)),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  height: MediaQuery.of(context).size.height *
                                      0.45, // 화면 높이의 60%로 설정
                                  child: ListView.builder(
                                    itemCount: apps.length,
                                    itemBuilder: (context, index) {
                                      final app = apps[index];
                                      return ListTile(
                                        leading: Image.memory(app.icon!),
                                        title: Text(app.name,
                                            style: const TextStyle(
                                                color: Colors.white)),
                                        onTap: () {
                                          Navigator.pop(context);
                                          Navigator.pop(context, {
                                            'name': app.name,
                                            'image':
                                                Uint8List.fromList(app.icon!),
                                            'isApp': true,
                                            'appName': app.name
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: const Card(
                          color: Color(0xff3d3d3d),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.apps, size: 40, color: Colors.white),
                              SizedBox(height: 10),
                              Text(
                                '앱 아이콘',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          TextEditingController bankNameController =
                              TextEditingController();
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xff2d2d2d),
                              title: const Text('은행명 입력',
                                  style: TextStyle(color: Colors.white)),
                              content: TextField(
                                controller: bankNameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: '은행명을 입력하세요',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.purple),
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    if (bankNameController.text.isNotEmpty) {
                                      Navigator.pop(context);
                                      Navigator.pop(context, {
                                        'name': bankNameController.text,
                                        'image': '', // 빈 문자열로 설정
                                        'isCustomName': true,
                                        'bankName':
                                            bankNameController.text, // 은행명 추가
                                      });
                                    }
                                  },
                                  child: const Text('확인',
                                      style: TextStyle(color: Colors.purple)),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Card(
                          color: Color(0xff3d3d3d),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit, size: 40, color: Colors.white),
                              SizedBox(height: 10),
                              Text(
                                '은행명 입력',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
