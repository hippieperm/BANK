class AccountService {
  // 월별 총 이자 계산
  static double calculateTotalMonthlyInterest(List<Map<String, dynamic>> accounts) {
    double total = 0;
    for (var account in accounts) {
      double principal = account['principal'];
      double interestRate = account['interestRate'];
      total += principal * (interestRate / 100) / 12;
    }
    return total;
  }

  // 누적 수령 이자 계산
  static double calculateTotalReceivedInterest(List<Map<String, dynamic>> accounts) {
    double total = 0;
    for (var account in accounts) {
      double principal = account['principal'];
      double interestRate = account['interestRate'];
      DateTime startDate = DateTime.parse(account['startDate']);
      int monthsPassed = DateTime.now().difference(startDate).inDays ~/ 30;
      total += (principal * (interestRate / 100) / 12) * monthsPassed;
    }
    return total;
  }

  // 계좌 정렬
  static void sortAccounts(List<Map<String, dynamic>> accounts, String sortType, bool isAscending) {
    accounts.sort((a, b) {
      int comparison = 0;
      switch (sortType) {
        case '은행별':
          comparison = a['bankName'].compareTo(b['bankName']);
          break;
        case '남은기간별':
          final aEndDate = DateTime.parse(a['endDate']);
          final bEndDate = DateTime.parse(b['endDate']);
          comparison = aEndDate.compareTo(bEndDate);
          break;
        case '원금순':
          comparison = a['principal'].compareTo(b['principal']);
          break;
        case '월이자수입순':
          final aInterest = a['principal'] * (a['interestRate'] / 100) / 12;
          final bInterest = b['principal'] * (b['interestRate'] / 100) / 12;
          comparison = aInterest.compareTo(bInterest);
          break;
      }
      return isAscending ? comparison : -comparison;
    });
  }
} 