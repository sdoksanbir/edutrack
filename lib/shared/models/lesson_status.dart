import 'package:flutter/material.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';

/// Ders durumu enum
enum LessonStatus {
  done,      // Yapıldı
  notDone,   // Yapılmadı
  postponed, // Ertelendi
}

/// LessonStatus extension - String dönüşümü için
extension LessonStatusExtension on LessonStatus {
  String get value {
    switch (this) {
      case LessonStatus.done:
        return 'done';
      case LessonStatus.notDone:
        return 'not_done';
      case LessonStatus.postponed:
        return 'postponed';
    }
  }

  String get displayName {
    switch (this) {
      case LessonStatus.done:
        return 'Yapıldı';
      case LessonStatus.notDone:
        return 'Yapılmadı';
      case LessonStatus.postponed:
        return 'Ertelendi';
    }
  }
}

/// String'den LessonStatus'a dönüştürme
LessonStatus? lessonStatusFromString(String? status) {
  if (status == null) return null;
  switch (status) {
    case 'done':
      return LessonStatus.done;
    case 'not_done':
      return LessonStatus.notDone;
    case 'postponed':
      return LessonStatus.postponed;
    default:
      return null;
  }
}

/// Ders durumuna göre renk döndürür
/// SessionOccurrences.status kullanır: 'planned' | 'done' | 'missed' | 'postponed'
///
/// Kurallar:
/// - Geçmiş tarih + status 'planned' -> Siyah
/// - done -> success
/// - missed -> danger
/// - postponed -> warning
/// - Gelecek tarih + status 'planned' -> nötr border
Color getLessonStatusColor({
  required DateTime lessonDate,
  required String? status,
  required DateTime today,
}) {
  final lessonDateOnly = DateTime(lessonDate.year, lessonDate.month, lessonDate.day);
  final todayOnly = DateTime(today.year, today.month, today.day);
  final isPast = lessonDateOnly.isBefore(todayOnly);

  if (status == null || status == 'planned') {
    if (isPast) {
      return AppColors.textPrimary;
    } else {
      return AppColors.border;
    }
  }

  switch (status) {
    case 'done':
      return AppColors.success;
    case 'missed':
    case 'not_done':
      return AppColors.danger;
    case 'postponed':
      return AppColors.warning;
    default:
      return AppColors.border;
  }
}

/// Kart arka planı — koyu temada soft dolgu (parlak zemin yok).
Color getLessonStatusCardBackground({
  required DateTime lessonDate,
  required String? status,
  required DateTime today,
}) {
  final lessonDateOnly = DateTime(lessonDate.year, lessonDate.month, lessonDate.day);
  final todayOnly = DateTime(today.year, today.month, today.day);
  final isPast = lessonDateOnly.isBefore(todayOnly);

  if (status == null || status == 'planned') {
    if (isPast) {
      return AppColors.surfaceElevated;
    }
    return AppColors.surface;
  }

  switch (status) {
    case 'done':
      return AppColors.successSoft;
    case 'missed':
    case 'not_done':
      return AppColors.dangerSoft;
    case 'postponed':
      return AppColors.warningSoft;
    default:
      return AppColors.surface;
  }
}

/// Kart metin / ikon rengi — soft zemin üzerinde canlı vurgu.
Color getLessonStatusForeground({
  required DateTime lessonDate,
  required String? status,
  required DateTime today,
}) {
  return getLessonStatusColor(
    lessonDate: lessonDate,
    status: status,
    today: today,
  );
}

/// Ders durumuna göre metin rengi (kontrast için)
Color getLessonStatusTextColor(Color backgroundColor) {
  final luminance = backgroundColor.computeLuminance();
  // Açık zeminlerde koyu metin; AppColors.textPrimary koyu temada beyazdır.
  return luminance > 0.45 ? const Color(0xFF0B0F14) : Colors.white;
}
