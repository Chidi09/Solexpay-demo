import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _ngn = NumberFormat.currency(
    locale: 'en_NG',
    symbol: 'NGN ',
    decimalDigits: 0,
  );

  static String format(double amount) {
    return _ngn.format(amount);
  }

  const CurrencyFormatter._();
}
