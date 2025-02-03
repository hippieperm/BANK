class NotificationService {
  static List<String> getNotifications() {
    return [
      '알림 1: 계좌 잔액이 부족합니다.',
      '알림 2: 이자 지급일이 다가옵니다.',
      '알림 3: 계좌 정보가 업데이트되었습니다.',
    ];
  }

  static void clearNotifications() {
    // 알림 초기화 로직
  }

  static void addNotification(String message) {
    // 새로운 알림 추가 로직
  }
} 