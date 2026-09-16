import 'package:flutter/services.dart';

/// Türkçe ad-soyad biçimlendirme.
/// Ad(lar): İlk harf büyük, kalanı küçük (örn. Ahmet, Mehmet).
/// Soyad: Tüm harfler büyük (örn. YILMAZ).
String formatPersonFullName(String input) {
  final parts = input
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '';

  if (parts.length == 1) {
    // Tek kelime: ad gibi Title Case
    return _titleCaseTr(parts.first);
  }

  final givenNames = parts
      .sublist(0, parts.length - 1)
      .map(_titleCaseTr)
      .join(' ');
  final surname = _toUpperTr(parts.last);
  return '$givenNames $surname';
}

/// Yazarken anlık ad-soyad biçimi (sondaki boşluk korunur — imleç bozulmasın).
/// Son kelime soyad (BÜYÜK); önceki kelimeler Ad.
String formatPersonFullNameLive(String input) {
  if (input.isEmpty) return input;

  final hasTrailingSpace = RegExp(r'\s$').hasMatch(input);
  final core = input.replaceFirst(RegExp(r'\s+$'), '');
  final parts = core
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();

  if (parts.isEmpty) {
    return hasTrailingSpace ? ' ' : '';
  }

  final String formatted;
  if (parts.length == 1) {
    formatted = _titleCaseTr(parts.first);
  } else {
    final givenNames =
        parts.sublist(0, parts.length - 1).map(_titleCaseTr).join(' ');
    final surname = _toUpperTr(parts.last);
    formatted = '$givenNames $surname';
  }

  return hasTrailingSpace ? '$formatted ' : formatted;
}

/// [TextField] / [TextFormField] için canlı ad-soyad biçimleyici.
class PersonFullNameInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = formatPersonFullNameLive(newValue.text);
    if (formatted == newValue.text) return newValue;

    // Uzunluk aynı kaldığında (sadece büyük/küçük) imleci koru;
    // değişirse sonda tut.
    final selectionIndex = formatted.length == newValue.text.length
        ? newValue.selection.baseOffset.clamp(0, formatted.length)
        : formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
      composing: TextRange.empty,
    );
  }
}

String _toLowerTr(String s) {
  return s
      .replaceAll('I', 'ı')
      .replaceAll('İ', 'i')
      .toLowerCase();
}

String _toUpperTr(String s) {
  return s
      .replaceAll('i', 'İ')
      .replaceAll('ı', 'I')
      .toUpperCase();
}

/// Kaynak adları vb. için tüm harfler büyük (Türkçe İ/ı kurallı).
/// Boşlukları temizler (kayıt anı için).
String formatTurkishUpperCase(String input) {
  final collapsed = input.replaceAll(RegExp(r'[ \t]+'), ' ').trim();
  if (collapsed.isEmpty) return '';
  return toTurkishUpperCaseLive(collapsed);
}

/// Yazarken anlık büyük harf (trim yok — imleç bozulmasın).
String toTurkishUpperCaseLive(String input) {
  return input
      .replaceAll('i', 'İ')
      .replaceAll('ı', 'I')
      .toUpperCase();
}

String _titleCaseTr(String word) {
  if (word.isEmpty) return word;
  final lower = _toLowerTr(word);
  final runes = lower.runes.toList();
  if (runes.isEmpty) return word;
  final first = _toUpperTr(String.fromCharCode(runes.first));
  final rest = String.fromCharCodes(runes.skip(1));
  return '$first$rest';
}

/// Türkçe alfabe sırası: …ç, …ğ, ı, i, …ö, …ş, …ü…
const _turkishAlphabet = [
  'a', 'b', 'c', 'ç', 'd', 'e', 'f', 'g', 'ğ', 'h', 'ı', 'i', 'j', 'k', 'l',
  'm', 'n', 'o', 'ö', 'p', 'r', 's', 'ş', 't', 'u', 'ü', 'v', 'y', 'z',
];

final Map<String, int> _turkishLetterOrder = {
  for (var i = 0; i < _turkishAlphabet.length; i++) _turkishAlphabet[i]: i,
};

/// Türkçe karakterlere göre karşılaştırma (büyük/küçük duyarsız).
int compareTurkish(String a, String b) {
  final la = _toLowerTr(a.trim());
  final lb = _toLowerTr(b.trim());
  final ra = la.runes.toList();
  final rb = lb.runes.toList();
  final n = ra.length < rb.length ? ra.length : rb.length;

  for (var i = 0; i < n; i++) {
    final ca = String.fromCharCode(ra[i]);
    final cb = String.fromCharCode(rb[i]);
    final oa = _turkishLetterOrder[ca];
    final ob = _turkishLetterOrder[cb];

    if (oa != null && ob != null) {
      final c = oa.compareTo(ob);
      if (c != 0) return c;
      continue;
    }
    if (oa != null) return -1;
    if (ob != null) return 1;
    final c = ca.compareTo(cb);
    if (c != 0) return c;
  }
  return ra.length.compareTo(rb.length);
}

/// Ders konu / ödev / not metinleri için Türkçe yazım.
/// Cümle başı büyük, devamı küçük (İ/ı kurallarına uygun).
/// Nokta, soru, ünlem ve satır başından sonra yeni cümle büyük harfle başlar.
String formatTurkishText(String input) {
  if (input.trim().isEmpty) return '';

  final lines = input.split('\n');
  final formattedLines = <String>[];
  for (final line in lines) {
    final collapsed = line.replaceAll(RegExp(r'[ \t]+'), ' ').trim();
    if (collapsed.isEmpty) {
      formattedLines.add('');
      continue;
    }
    formattedLines.add(_formatTurkishSentenceLine(collapsed));
  }

  // Baş/sondaki boş satırları temizle, ara boş satırları koru
  return formattedLines.join('\n').trim();
}

String _formatTurkishSentenceLine(String s) {
  final buffer = StringBuffer();
  var capitalizeNext = true;

  for (final rune in s.runes) {
    final char = String.fromCharCode(rune);
    if (_isTurkishLetter(char)) {
      if (capitalizeNext) {
        buffer.write(_toUpperTr(char));
        capitalizeNext = false;
      } else {
        buffer.write(_toLowerTr(char));
      }
    } else {
      buffer.write(char);
      if (char == '.' || char == '!' || char == '?' || char == ':') {
        capitalizeNext = true;
      }
    }
  }
  return buffer.toString();
}

bool _isTurkishLetter(String char) {
  if (char.isEmpty) return false;
  final lower = char
      .replaceAll('I', 'ı')
      .replaceAll('İ', 'i')
      .toLowerCase();
  return RegExp(r'[a-zçğıöşü]').hasMatch(lower);
}

/// Ödev açıklaması vb.: kelime/kısım başları büyük (Türkçe İ/ı kurallı).
String _formatTurkishNoteLine(String s) {
  final buffer = StringBuffer();
  var capitalizeNext = true;

  for (final rune in s.runes) {
    final char = String.fromCharCode(rune);
    if (_isTurkishLetter(char)) {
      if (capitalizeNext) {
        buffer.write(_toUpperTr(char));
        capitalizeNext = false;
      } else {
        buffer.write(_toLowerTr(char));
      }
    } else {
      buffer.write(char);
      if (char == ' ' ||
          char == ',' ||
          char == '.' ||
          char == '!' ||
          char == '?' ||
          char == ':' ||
          char == ';') {
        capitalizeNext = true;
      }
    }
  }
  return buffer.toString();
}

/// Kayıt anında ödev açıklaması biçimlendirme.
String formatTurkishNoteText(String input) {
  if (input.trim().isEmpty) return '';

  final lines = input.split('\n');
  final formattedLines = <String>[];
  for (final line in lines) {
    final collapsed = line.replaceAll(RegExp(r'[ \t]+'), ' ').trim();
    if (collapsed.isEmpty) {
      formattedLines.add('');
      continue;
    }
    formattedLines.add(_formatTurkishNoteLine(collapsed));
  }

  return formattedLines.join('\n').trim();
}

/// Yazarken anlık ödev açıklaması biçimlendirme (trim yok — imleç bozulmasın).
String toTurkishNoteTextLive(String input) {
  if (input.isEmpty) return input;
  final lines = input.split('\n');
  return lines
      .map((line) => line.isEmpty ? line : _formatTurkishNoteLine(line))
      .join('\n');
}
