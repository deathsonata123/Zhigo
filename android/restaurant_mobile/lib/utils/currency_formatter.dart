import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );
  
  // Format as "$123.45"
  static String format(double amount) {
    return _formatter.format(amount);
  }
  
  // Format as "$123" without decimals
  static String formatWhole(double amount) {
    return '\$${amount.toStringAsFixed(0)}';
  }
  
  // Format as "123.45" without currency symbol
  static String formatNumber(double amount) {
    return amount.toStringAsFixed(2);
  }
}
