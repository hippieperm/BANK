import 'dart:ui';
import 'dart:io';

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
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _getImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      Navigator.pop(
          context, {'name': image.path, 'image': image.path, 'isFile': true});
    }
  }

  Future<void> _getAppIcon() async {
    try {
      List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true);
      if (!mounted) return;

      final selectedApp = await showDialog<AppInfo>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xff2d2d2d),
            title: const Text('앱 선택', style: TextStyle(color: Colors.white)),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: ListView.builder(
                itemCount: apps.length,
                itemBuilder: (context, index) {
                  final app = apps[index];
                  return ListTile(
                    leading: Image.memory(
                      app.icon!,
                      width: 40,
                      height: 40,
                    ),
                    title: Text(app.name,
                        style: const TextStyle(color: Colors.white)),
                    onTap: () => Navigator.pop(context, app),
                  );
                },
              ),
            ),
          );
        },
      );

      if (selectedApp != null && mounted) {
        Navigator.pop(context, {
          'name': selectedApp.name,
          'image': selectedApp.icon,
          'isApp': true
        });
      }
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xff2d2d2d),
            title: const Text('오류', style: TextStyle(color: Colors.white)),
            content: Text(
              '앱 목록을 가져오는 중 오류가 발생했습니다: $e',
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    }
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
                title: const Text(
                  '이미지 선택',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading:
                          const Icon(Icons.photo_library, color: Colors.white),
                      title: const Text('갤러리에서 선택',
                          style: TextStyle(color: Colors.white)),
                      onTap: _getImageFromGallery,
                    ),
                    ListTile(
                      leading: const Icon(Icons.apps, color: Colors.white),
                      title: const Text('설치된 앱에서 선택',
                          style: TextStyle(color: Colors.white)),
                      onTap: _getAppIcon,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
