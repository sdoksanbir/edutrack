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
