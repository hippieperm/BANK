import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String ACCOUNTS_KEY = 'accounts';
  static const String SETTINGS_KEY = 'settings';
  static const String NOTIFICATIONS_KEY = 'notifications';

  static SharedPreferences? _prefs;

  // SharedPreferences 초기화
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 계좌 데이터 저장
  static Future<void> saveAccounts(List<Map<String, dynamic>> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('accounts', jsonEncode(accounts));
  }

  // 계좌 데이터 불러오기
  static Future<List<Map<String, dynamic>>> loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? accountsString = prefs.getString('accounts');
    if (accountsString != null) {
      List<dynamic> jsonList = jsonDecode(accountsString);
      return jsonList.map((json) => json as Map<String, dynamic>).toList();
    }
    return [];
  }

  // 설정 데이터 저장
  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    final String encodedData = json.encode(settings);
    await _prefs!.setString(SETTINGS_KEY, encodedData);
  }

  // 설정 데이터 불러오기
  static Future<Map<String, dynamic>> loadSettings() async {
    final String? encodedData = _prefs!.getString(SETTINGS_KEY);
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
    await _prefs!.setStringList(NOTIFICATIONS_KEY, notifications);
  }

  // 알림 데이터 불러오기
  static Future<List<String>> loadNotifications() async {
    return _prefs!.getStringList(NOTIFICATIONS_KEY) ?? [];
  }

  // 모든 데이터 초기화
  static Future<void> clearAllData() async {
    await _prefs!.clear();
  }

  // 정렬 설정 저장
  static Future<void> saveSortSettings(
      String sortType, bool isAscending) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentSortType', sortType);
    await prefs.setBool('isAscending', isAscending);
  }

  // 정렬 설정 불러오기
  static Future<Map<String, dynamic>> loadSortSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'currentSortType': prefs.getString('currentSortType'),
      'isAscending': prefs.getBool('isAscending') ?? true,
    };
  }
}
