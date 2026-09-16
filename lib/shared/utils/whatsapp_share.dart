import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/features/lessons/widgets/lesson_homework_fields.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Türkiye telefonunu WhatsApp için uluslararası formata çevirir.
String? normalizeWhatsAppPhone(String? raw) {
  if (raw == null) return null;
  var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return null;

  if (digits.startsWith('00')) {
    digits = digits.substring(2);
  }
  if (digits.startsWith('0')) {
    digits = '90${digits.substring(1)}';
  } else if (digits.length == 10 && digits.startsWith('5')) {
    digits = '90$digits';
  }

  if (digits.length < 11 || digits.length > 15) return null;
  return digits;
}

String buildLessonWhatsAppMessage({
  required String studentName,
  required DateTime lessonDateTime,
  String? topic,
  String? homework,
  String? homeworkResource,
  String? lessonNotes,
}) {
  final dateStr =
      DateFormat('dd MMMM yyyy, EEEE HH:mm', 'tr_TR').format(lessonDateTime);
  final buf = StringBuffer();

  buf.writeln('Merhaba $studentName,');
  buf.writeln();
  buf.writeln('📅 Ders özeti');
  buf.writeln('Tarih: $dateStr');
  buf.writeln();

  final topics = parseTaughtTopics(topic);
  if (topics.isNotEmpty) {
    buf.writeln('📚 Anlatılan konular:');
    for (var i = 0; i < topics.length; i++) {
      buf.writeln('${i + 1}. ${topics[i]}');
    }
    buf.writeln();
  }

  final homeworkLines = buildHomeworkSummaryLines(
    parseHomeworkResourceAssignments(homeworkResource),
    taughtTopics: topics,
  );
  if (homeworkLines.isNotEmpty) {
    buf.writeln('📝 Ödevler:');
    for (final line in homeworkLines) {
      buf.writeln(line);
    }
    buf.writeln();
  } else if (homework != null && homework.trim().isNotEmpty) {
    buf.writeln('📝 Ödevler:');
    buf.writeln(homework.trim());
    buf.writeln();
  }

  if (lessonNotes != null && lessonNotes.trim().isNotEmpty) {
    buf.writeln('📌 Ders notu:');
    buf.writeln(lessonNotes.trim());
    buf.writeln();
  }

  buf.writeln('İyi çalışmalar!');
  return buf.toString().trim();
}

String buildHomeworkItemsWhatsAppMessage({
  required String studentName,
  required DateTime lessonDate,
  required List<HomeworkItem> items,
}) {
  final dateStr = DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(lessonDate);
  final buf = StringBuffer();
  buf.writeln('Merhaba $studentName,');
  buf.writeln();
  buf.writeln('📅 Ders: $dateStr');
  buf.writeln();
  buf.writeln('📝 Ödevler:');
  for (var i = 0; i < items.length; i++) {
    final item = items[i];
    final resource =
        item.resource != null && item.resource!.trim().isNotEmpty
            ? '${item.resource}: '
            : '';
    buf.writeln('${i + 1}. $resource${item.topic}');
    if (item.detail != null && item.detail!.trim().isNotEmpty) {
      buf.writeln('   ${item.detail}');
    }
    if (item.dueAt != null) {
      buf.writeln(
        '   Bitiş: ${DateFormat('dd.MM.yyyy', 'tr_TR').format(item.dueAt!)}',
      );
    }
  }
  buf.writeln();
  buf.writeln('İyi çalışmalar!');
  return buf.toString().trim();
}

Future<void> sendWhatsAppMessage({
  required BuildContext context,
  required String message,
  String? phone,
}) async {
  final normalized = normalizeWhatsAppPhone(phone);
  if (normalized == null) {
    // Telefon yoksa paylaşım menüsü (WhatsApp seçilebilir)
    await Share.share(message);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(StringsTr.whatsappNoPhoneShare)),
      );
    }
    return;
  }

  final uri = Uri.parse(
    'https://wa.me/$normalized?text=${Uri.encodeComponent(message)}',
  );

  try {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      await Share.share(message);
    }
  } catch (_) {
    await Share.share(message);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(StringsTr.whatsappOpenFailed)),
      );
    }
  }
}
