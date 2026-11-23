import 'package:intl/intl.dart';

class Fmt {

  static String compactUsd(double? v) {
    if (v == null) return '—';
    final abs = v.abs();
    if (abs >= 1e12) return '\$${(v / 1e12).toStringAsFixed(3)}T';
    if (abs >= 1e9) return '\$${(v / 1e9).toStringAsFixed(2)}B';
    if (abs >= 1e6) return '\$${(v / 1e6).toStringAsFixed(2)}M';
    if (abs >= 1e3) return '\$${(v / 1e3).toStringAsFixed(2)}K';
    return '\$${v.toStringAsFixed(2)}';
  }

  static String price(double? v) {
    if (v == null) return '—';
    final abs = v.abs();
    int dec;
    if (abs >= 1) {
      dec = 2;
    } else if (abs >= 0.01) {
      dec = 4;
    } else if (abs >= 0.0001) {
      dec = 6;
    } else {
      dec = 8;
    }
    return '\$${NumberFormat.decimalPatternDigits(decimalDigits: dec).format(v)}';
  }

  static String percent(double? v, {int digits = 1}) {
    if (v == null) return '—';
    final sign = v > 0 ? '+' : '';
    return '$sign${v.toStringAsFixed(digits)}%';
  }

  static String supply(double? v, String symbol) {
    if (v == null) return '∞';
    final abs = v.abs();
    String s;
    if (abs >= 1e12) {
      s = '${(v / 1e12).toStringAsFixed(2)}T';
    } else if (abs >= 1e9) {
      s = '${(v / 1e9).toStringAsFixed(2)}B';
    } else if (abs >= 1e6) {
      s = '${(v / 1e6).toStringAsFixed(2)}M';
    } else {
      s = NumberFormat.decimalPattern().format(v.round());
    }
    return '$s ${symbol.toUpperCase()}';
  }

  static String dateTime(DateTime d, {bool withTime = true}) =>
      withTime ? DateFormat('d MMM yyyy, HH:mm').format(d) : DateFormat('d MMM yyyy').format(d);
}
