class Account {
  final String bankName;
  final String bankImage;
  final DateTime startDate;
  final DateTime endDate;
  final double principal;
  final double interestRate;
  final bool isTaxExempt;
  final double taxRate;

  Account({
    required this.bankName,
    required this.bankImage,
    required this.startDate,
    required this.endDate,
    required this.principal,
    required this.interestRate,
    required this.isTaxExempt,
    required this.taxRate,
  });

  double get monthlyInterest => principal * (interestRate / 100) / 12;
  int get remainingDays => endDate.difference(DateTime.now()).inDays;
  double get totalIncome => principal * (interestRate / 100) * remainingDays / 365;
} 