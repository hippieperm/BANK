import '../models/account.dart';

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
      List<Account> accounts, String sortType, bool ascending) {
    if (sortType == '은행별') {
      accounts.sort((a, b) => ascending
          ? a.bankName.compareTo(b.bankName)
          : b.bankName.compareTo(a.bankName));
    } else if (sortType == '만기일자') {
      accounts.sort((a, b) => ascending
          ? a.endDate.compareTo(b.endDate)
          : b.endDate.compareTo(a.endDate));
    } else if (sortType == '원금순') {
      accounts.sort((a, b) => ascending
          ? a.principal.compareTo(b.principal)
          : b.principal.compareTo(a.principal));
    } else if (sortType == '월이자수입순') {
      accounts.sort((a, b) => ascending
          ? (a.principal * (a.interestRate / 100) / 12)
              .compareTo(b.principal * (b.interestRate / 100) / 12)
          : (b.principal * (b.interestRate / 100) / 12)
              .compareTo(a.principal * (a.interestRate / 100) / 12));
    } else if (sortType == '월 금리순') {
      accounts.sort((a, b) => ascending
          ? a.interestRate.compareTo(b.interestRate)
          : b.interestRate.compareTo(a.interestRate));
    } else if (sortType == '시작일자') {
      accounts.sort((a, b) => ascending
          ? a.startDate.compareTo(b.startDate)
          : b.startDate.compareTo(a.startDate));
    } else if (sortType == '카드') {
      // 카드 정렬 로직 추가
    }
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
