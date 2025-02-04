class NumberFormatter {
  static String formatCurrency(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  static String formatPercent(double value) {
    return '${value.toStringAsFixed(1)}%';
  }
}
