import 'dart:ui';

import 'package:bank/data/banks.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:installed_apps/app_info.dart';
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
                    crossAxisCount: 3, // 3개의 열
                    children: [
                      // 직접 추가 버튼
                      GestureDetector(
                        onTap: () async {
                          // 이미지 소스 선택 다이얼로그 표시
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: const Color(0xff2d2d2d),
                                title: const Text(
                                  '이미지 소스 선택',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.photo_library,
                                          color: Colors.white),
                                      title: const Text('갤러리에서 선택',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      onTap: () async {
                                        print('갤러리 선택 시작'); // 디버그 로그
                                        Navigator.pop(context);

                                        try {
                                          final ImagePicker picker =
                                              ImagePicker();
                                          print('ImagePicker 초기화'); // 디버그 로그

                                          final XFile? image =
                                              await picker.pickImage(
                                            source: ImageSource.gallery,
                                            maxWidth: 1000,
                                            maxHeight: 1000,
                                            imageQuality: 85,
                                          );

                                          print(
                                              '선택된 이미지: ${image?.path}'); // 디버그 로그

                                          if (image != null &&
                                              context.mounted) {
                                            String bankName = '';

                                            final result = await showDialog<
                                                Map<String, String>>(
                                              context: context,
                                              barrierDismissible:
                                                  false, // 바깥 터치로 닫기 방지
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  backgroundColor:
                                                      const Color(0xff2d2d2d),
                                                  title: const Text('은행 이름 입력',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                  content: TextField(
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: '은행 이름을 입력하세요',
                                                      hintStyle: TextStyle(
                                                          color: Colors.grey),
                                                    ),
                                                    onChanged: (value) {
                                                      bankName = value;
                                                    },
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context), // 취소
                                                      child: const Text('취소',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        if (bankName
                                                            .isNotEmpty) {
                                                          print(
                                                              '반환할 데이터: name=$bankName, image=${image.path}'); // 디버그 로그
                                                          Navigator.pop(
                                                              context, {
                                                            'name': bankName,
                                                            'image': image.path,
                                                          });
                                                        }
                                                      },
                                                      child: const Text('확인',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                            if (result != null &&
                                                context.mounted) {
                                              print(
                                                  '최종 반환 데이터: $result'); // 디버그 로그
                                              Navigator.pop(context, result);
                                            }
                                          }
                                        } catch (e) {
                                          print('이미지 선택 오류: $e'); // 디버그 로그
                                          if (!context.mounted) return;

                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                backgroundColor:
                                                    const Color(0xff2d2d2d),
                                                title: const Text('오류',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                content: Text(
                                                    '이미지 선택 중 오류가 발생했습니다: $e',
                                                    style: const TextStyle(
                                                        color: Colors.white)),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text('확인',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.apps,
                                          color: Colors.white),
                                      title: const Text('설치된 앱에서 선택',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      onTap: () async {
                                        Navigator.pop(context);

                                        try {
                                          print('앱 목록 가져오기 시작');
                                          List<AppInfo> apps =
                                              await InstalledApps
                                                  .getInstalledApps(true, true);

                                          if (!context.mounted) return;

                                          final selectedApp =
                                              await showDialog<AppInfo>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                backgroundColor:
                                                    const Color(0xff2d2d2d),
                                                title: const Text('앱 선택',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                content: SizedBox(
                                                  width: double.maxFinite,
                                                  height: 400,
                                                  child: ListView.builder(
                                                    itemCount: apps.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final app = apps[index];
                                                      return ListTile(
                                                        leading: Image.memory(
                                                          app.icon!,
                                                          width: 40,
                                                          height: 40,
                                                        ),
                                                        title: Text(app.name,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                        onTap: () =>
                                                            Navigator.pop(
                                                                context, app),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text('취소',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (selectedApp != null &&
                                              context.mounted) {
                                            Navigator.pop(context, {
                                              'name': selectedApp.name,
                                              'image': selectedApp.icon,
                                            });
                                          }
                                        } catch (e) {
                                          print('오류 발생: $e');
                                          if (!context.mounted) return;

                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                backgroundColor:
                                                    const Color(0xff2d2d2d),
                                                title: const Text('오류',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                content: Text(
                                                  '앱 목록을 가져오는 중 오류가 발생했습니다: $e',
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text('확인',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ],
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
                              Icon(
                                Icons.add_circle_outline,
                                size: 40,
                                color: Colors.white,
                              ),
                              SizedBox(height: 10),
                              Text(
                                '직접 추가',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 기존 은행 목록
                      ...List.generate(Banks.banks.length, (index) {
                        final bank = Banks.banks[index];
                        // null 체크 추가
                        if (bank['name'] == null || bank['image'] == null) {
                          return const SizedBox(); // 빈 위젯 반환
                        }

                        return GestureDetector(
                          onTap: () {
                            try {
                              Navigator.pop(context, {
                                'name': bank['image'],
                                'image': bank['name'],
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
