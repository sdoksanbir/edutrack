import 'package:flutter/services.dart';

/// Türkiye cep: `0 (532) 271 88 56`
String? formatTurkishPhone(String? raw) {
  if (raw == null) return null;
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;

  var digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return null;

  if (digits.startsWith('00')) {
    digits = digits.substring(2);
  }
  if (digits.startsWith('90') && digits.length >= 12) {
    digits = digits.substring(2);
  }
  if (digits.length == 10 && !digits.startsWith('0')) {
    digits = '0$digits';
  }
  if (digits.length > 11 && digits.startsWith('0')) {
    digits = digits.substring(0, 11);
  }

  return _formatDigits(digits);
}

/// Görüntüleme; boşsa orijinal metin.
String formatTurkishPhoneDisplay(String raw) {
  return formatTurkishPhone(raw) ?? raw.trim();
}

String _formatDigits(String digits) {
  if (digits.isEmpty) return '';

  // 0 ile başlat
  if (!digits.startsWith('0') && digits.length <= 10) {
    digits = '0$digits';
  }
  if (digits.length > 11) {
    digits = digits.substring(0, 11);
  }

  final buf = StringBuffer('0');
  final rest = digits.startsWith('0') ? digits.substring(1) : digits;

  if (rest.isEmpty) return buf.toString();

  buf.write(' (');
  final a = rest.length >= 3 ? rest.substring(0, 3) : rest;
  buf.write(a);
  if (rest.length < 3) return buf.toString();
  buf.write(')');

  if (rest.length == 3) return buf.toString();
  buf.write(' ');
  final b = rest.length >= 6 ? rest.substring(3, 6) : rest.substring(3);
  buf.write(b);
  if (rest.length <= 6) return buf.toString();

  buf.write(' ');
  final c = rest.length >= 8 ? rest.substring(6, 8) : rest.substring(6);
  buf.write(c);
  if (rest.length <= 8) return buf.toString();

  buf.write(' ');
  buf.write(rest.substring(8, rest.length > 10 ? 10 : rest.length));
  return buf.toString();
}

int phoneDigitCount(String? raw) {
  if (raw == null) return 0;
  return raw.replaceAll(RegExp(r'[^0-9]'), '').length;
}

/// Yazarken `0 (***) *** ** **` formatı.
class TurkishPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('90') && digits.length > 11) {
      digits = digits.substring(2);
    }
    if (digits.length > 11) {
      digits = digits.substring(0, 11);
    }
    if (digits.length == 10 && !digits.startsWith('0')) {
      digits = '0$digits';
    }

    final formatted = _formatDigits(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
