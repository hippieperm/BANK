import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String ACCOUNTS_KEY = 'accounts';
  static const String SETTINGS_KEY = 'settings';
  static const String NOTIFICATIONS_KEY = 'notifications';

  static late SharedPreferences _prefs;

  // SharedPreferences 초기화
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 계좌 데이터 저장
  static Future<void> saveAccounts(List<Map<String, dynamic>> accounts) async {
    final String encodedData = json.encode(accounts);
    await _prefs.setString(ACCOUNTS_KEY, encodedData);
  }

  // 계좌 데이터 불러오기
  static Future<List<Map<String, dynamic>>> loadAccounts() async {
    final String? encodedData = _prefs.getString(ACCOUNTS_KEY);
    if (encodedData == null) return [];

    final List<dynamic> decodedData = json.decode(encodedData);
    return decodedData.cast<Map<String, dynamic>>();
  }

  // 설정 데이터 저장
  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    final String encodedData = json.encode(settings);
    await _prefs.setString(SETTINGS_KEY, encodedData);
  }

  // 설정 데이터 불러오기
  static Future<Map<String, dynamic>> loadSettings() async {
    final String? encodedData = _prefs.getString(SETTINGS_KEY);
    if (encodedData == null) {
      return {
        'notificationPeriod': '14일',
        'taxRate': 15.4,
        'isDarkMode': false,
      };
    }
    return json.decode(encodedData);
  }

  // 알림 데이터 저장
  static Future<void> saveNotifications(List<String> notifications) async {
    await _prefs.setStringList(NOTIFICATIONS_KEY, notifications);
  }

  // 알림 데이터 불러오기
  static Future<List<String>> loadNotifications() async {
    return _prefs.getStringList(NOTIFICATIONS_KEY) ?? [];
  }

  // 모든 데이터 초기화
  static Future<void> clearAllData() async {
    await _prefs.clear();
  }
}
