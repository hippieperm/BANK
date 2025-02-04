class AccountService {
  // 월별 총 이자 계산
  static double calculateTotalMonthlyInterest(
      List<Map<String, dynamic>> accounts) {
    double total = 0;
    for (var account in accounts) {
      double principal = account['principal'];
      double interestRate = account['interestRate'];
      total += principal * (interestRate / 100) / 12;
    }
    return total;
  }

  // 누적 수령 이자 계산
  static double calculateTotalReceivedInterest(
      List<Map<String, dynamic>> accounts) {
    double total = 0;
    for (var account in accounts) {
      double principal = account['principal'];
      double interestRate = account['interestRate'];
      DateTime startDate = DateTime.parse(account['startDate']);
      int daysPassed = DateTime.now().difference(startDate).inDays;
      total += (principal * (interestRate / 100) * daysPassed / 365);
    }
    return total;
  }

  // 계좌 정렬
  static void sortAccounts(
      List<Map<String, dynamic>> accounts, String sortType, bool isAscending) {
    accounts.sort((a, b) {
      int comparison;

      switch (sortType) {
        case '은행별':
          comparison = a['bankName'].compareTo(b['bankName']);
          break;
        case '만기일자':
          DateTime endDateA = DateTime.parse(a['endDate']);
          DateTime endDateB = DateTime.parse(b['endDate']);
          comparison = endDateA.compareTo(endDateB);
          break;
        case '원금':
          comparison = a['principal'].compareTo(b['principal']);
          break;
        case '월이자수입':
          double monthlyInterestA =
              a['principal'] * (a['interestRate'] / 100) / 12;
          double monthlyInterestB =
              b['principal'] * (b['interestRate'] / 100) / 12;
          comparison = monthlyInterestA.compareTo(monthlyInterestB);
          break;
        case '금리':
          comparison = (a['interestRate']).compareTo(b['interestRate']);
          break;
        case '시작일자':
          DateTime startDateA = DateTime.parse(a['startDate']);
          DateTime startDateB = DateTime.parse(b['startDate']);
          comparison = startDateA.compareTo(startDateB);
          break;
        default:
          comparison = 0; // 기본값
      }

      return isAscending ? comparison : -comparison; // 오름차순/내림차순 적용
    });
  }

  // 총 수입 순으로 계좌 정렬
  static void sortAccountsByTotalIncome(
      List<Map<String, dynamic>> accounts, bool isAscending) {
    accounts.sort((a, b) {
      double totalIncomeA = a['principal'] *
          (a['interestRate'] / 100) *
          (DateTime.now().difference(DateTime.parse(a['startDate'])).inDays) /
          365;
      double totalIncomeB = b['principal'] *
          (b['interestRate'] / 100) *
          (DateTime.now().difference(DateTime.parse(b['startDate'])).inDays) /
          365;
      return isAscending
          ? totalIncomeA.compareTo(totalIncomeB)
          : totalIncomeB.compareTo(totalIncomeA);
    });
  }

  // 금리순으로 계좌 정렬
  static void sortAccountsByInterestRate(
      List<Map<String, dynamic>> accounts, bool isAscending) {
    accounts.sort((a, b) {
      double interestRateA = a['interestRate'] ?? 0.0;
      double interestRateB = b['interestRate'] ?? 0.0;
      return isAscending
          ? interestRateA.compareTo(interestRateB)
          : interestRateB.compareTo(interestRateA);
    });
  }
}
