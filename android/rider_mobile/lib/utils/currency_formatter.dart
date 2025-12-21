import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );
  
  static String format(double amount) {
    return _formatter.format(amount);
  }
  
  static String formatWhole(double amount) {
    return '\$${amount.toStringAsFixed(0)}';
  }
}
