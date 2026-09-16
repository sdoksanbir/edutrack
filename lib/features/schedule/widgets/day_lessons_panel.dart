import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/providers/calendar_providers.dart';
import 'package:ozel_ders_takip/data/providers/payment_providers.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/features/schedule/widgets/done_lesson_sheet.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:ozel_ders_takip/shared/models/lesson_status.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';

final _dateFormat = DateFormat('dd.MM.yyyy', 'tr_TR');
final _timeFormat = DateFormat('HH:mm', 'tr_TR');

/// Sebep ve not girişi için bottom sheet widget'ı
/// Controller'lar widget lifecycle'ı ile uyumlu şekilde dispose edilir
class _ReasonSheetWidget extends StatefulWidget {
  final String title;

  const _ReasonSheetWidget({required this.title});

  @override
  State<_ReasonSheetWidget> createState() => _ReasonSheetWidgetState();
}

class _ReasonSheetWidgetState extends State<_ReasonSheetWidget> {
  late final TextEditingController _reasonController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: '${StringsTr.reasonLabel} *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: StringsTr.noteLabel,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(StringsTr.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final reason = _reasonController.text.trim();
                    if (reason.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(StringsTr.reasonRequired)),
                      );
                      return;
                    }
                    final note = _noteController.text.trim();
                    Navigator.pop(context, (reason: reason, note: note.isEmpty ? null : note));
                  },
                  child: Text(StringsTr.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Seçili günün derslerini gösteren expandable panel
class DayLessonsPanel extends ConsumerWidget {
  final DateTime selectedDate;
  final List<Lesson> lessons;
  final VoidCallback? onDismiss;
  final ScrollController? scrollController;

  const DayLessonsPanel({
    super.key,
    required this.selectedDate,
    required this.lessons,
    this.onDismiss,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final selectedDateOnly = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    // Öğrenci ID'lerini topla
    final studentIds = lessons.map((l) => l.studentId).toSet().toList();
    
    // Öğrenci adlarını önceden yükle
    final studentsFuture = Future.wait(
      studentIds.map((id) => _getStudentName(ref, id)),
    ).then((names) {
      return Map<String, String>.fromIterables(studentIds, names);
    });

    return FutureBuilder<Map<String, String>>(
      future: studentsFuture,
      builder: (context, studentsSnapshot) {
        final studentsMap = studentsSnapshot.data ?? {};

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((255 * 0.1).toInt()),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header with back button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Row(
                    children: [
                      // Geri butonu
                      if (onDismiss != null)
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                          onPressed: onDismiss,
                          tooltip: 'Geri',
                        ),
                      Expanded(
                        child: Text(
                          'Seçili Gün: ${_dateFormat.format(selectedDate)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                      ),
                      if (onDismiss != null)
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.muted),
                          onPressed: onDismiss,
                          tooltip: 'Kapat',
                        ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Lessons list
                Expanded(
                  child: lessons.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              'Bu gün için ders yok',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      : studentsSnapshot.connectionState == ConnectionState.waiting
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.all(8.0),
                              itemCount: lessons.length,
                              itemBuilder: (context, index) {
                                final lesson = lessons[index];
                                return _buildLessonItem(
                                  context,
                                  ref,
                                  lesson,
                                  selectedDateOnly,
                                  todayOnly,
                                  studentsMap[lesson.studentId] ?? 'Yükleniyor...',
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLessonItem(
    BuildContext context,
    WidgetRef ref,
    Lesson lesson,
    DateTime selectedDateOnly,
    DateTime todayOnly,
    String studentName,
  ) {
    final isPast = selectedDateOnly.isBefore(todayOnly);
    
    // Virtual lesson (SessionOccurrence'dan oluşturulan) kontrolü
    final isVirtualLesson = lesson.id.startsWith('occurrence_');
    
    // Virtual lesson için SessionOccurrence status'ünü kullan
    // lessons_repo.dart'ta virtual lesson oluştururken occurrence.status lesson.status'e kopyalanıyor
    String? effectiveStatus = lesson.status;
    
    // SessionOccurrence status'leri: 'planned', 'done', 'not_done'
    // Lesson status'leri: 'done', 'not_done', 'postponed', null
    // Renk teması için SessionOccurrence status'ünü Lesson status formatına dönüştür
    if (isVirtualLesson && effectiveStatus != null) {
      // SessionOccurrence status'ü zaten lesson.status'te, direkt kullan
      // 'planned' -> null (planlandı, renk teması için)
      if (effectiveStatus == 'planned') {
        effectiveStatus = null;
      }
    }
    
    final statusColor = getLessonStatusColor(
      lessonDate: lesson.startDateTime,
      status: effectiveStatus,
      today: DateTime.now(),
    );
    final cardBg = getLessonStatusCardBackground(
      lessonDate: lesson.startDateTime,
      status: effectiveStatus,
      today: DateTime.now(),
    );
    // Soft koyu kartlarda metin beyaz; durum rengi kenarlık + badge'de

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withValues(alpha: 0.55), width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.25),
          child: Text(
            studentName.isNotEmpty
                ? studentName[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          studentName,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: AppColors.muted),
                const SizedBox(width: 4),
                Text(
                  '${_timeFormat.format(lesson.startDateTime)} - ${_formatDuration(lesson.durationMin)}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
            if (lesson.topic != null && lesson.topic!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                lesson.topic!,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Builder(
                builder: (context) {
                  final statusLabel = _getStatusText(lesson.status, isPast);
                  final Color badgeBg;
                  if (effectiveStatus == 'done') {
                    badgeBg = AppColors.success;
                  } else if (effectiveStatus == 'missed' ||
                      effectiveStatus == 'not_done') {
                    badgeBg = AppColors.danger;
                  } else if (effectiveStatus == 'postponed') {
                    badgeBg = AppColors.warning;
                  } else if (isPast) {
                    badgeBg = AppColors.muted;
                  } else {
                    badgeBg = AppColors.primary;
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: badgeBg == AppColors.warning
                            ? const Color(0xFF0B0F14)
                            : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Ödeme durumu (sadece done status için)
            if (lesson.status == 'done') ...[
              const SizedBox(height: 6),
              FutureBuilder<String?>(
                future: _getPaymentStatus(ref, lesson.occurrenceId),
                builder: (context, snapshot) {
                  final paymentStatus = snapshot.data;
                  if (paymentStatus == null) {
                    return const SizedBox.shrink();
                  }
                  final paid = paymentStatus == 'Ödendi';
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: paid
                            ? AppColors.success
                            : AppColors.danger,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: paid ? AppColors.success : AppColors.danger,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            paid ? Icons.check_circle : Icons.pending,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Ödeme: $paymentStatus',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.muted),
          onSelected: (value) {
            if (isVirtualLesson && lesson.occurrenceId != null) {
              // Virtual lesson için SessionOccurrence status güncellemesi
              _handleOccurrenceStatusChange(
                context,
                ref,
                lesson.occurrenceId!,
                value,
                lesson.startDateTime,
              );
            } else {
              // Normal lesson için Lesson status güncellemesi
              _handleStatusChange(
                context,
                ref,
                lesson.id,
                value,
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'done',
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text('Yapıldı'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'not_done',
              child: Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Yapılmadı'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'postponed',
              child: Row(
                children: [
                  Icon(Icons.schedule, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Text('Ertele'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Sil'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.clear, color: Colors.grey, size: 20),
                  SizedBox(width: 8),
                  Text('Temizle'),
                ],
              ),
            ),
          ],
        ),
        onLongPress: () async {
          if (!context.mounted) return;
          final action = await _showStatusDialog(context, ref, lesson, isPast);
          if (action == null || !context.mounted) return;
          final isVirtual = isVirtualLesson && lesson.occurrenceId != null;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            if (isVirtual) {
              _handleOccurrenceStatusChange(context, ref, lesson.occurrenceId!, action, lesson.startDateTime);
            } else {
              _handleStatusChange(context, ref, lesson.id, action);
            }
          });
        },
      ),
    );
  }

  String _getStatusText(String? status, bool isPast) {
    if (status == null || status == 'planned') {
      return isPast ? 'İşaretlenmemiş (Geçmiş)' : 'Planlandı';
    }
    switch (status) {
      case 'done':
        return 'Yapıldı';
      case 'missed':
      case 'not_done': // Eski kod uyumluluğu
        return 'Yapılmadı';
      case 'postponed':
        return 'Ertelendi';
      default:
        return 'Bilinmeyen';
    }
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return mins > 0 ? '${hours}s ${mins}dk' : '${hours}s';
    }
    return '${mins}dk';
  }

  Future<String?> _getPaymentStatus(WidgetRef ref, String? occurrenceId) async {
    if (occurrenceId == null) return null;
    
    try {
      final scheduleRepo = ref.read(scheduleRepoProvider);
      final occurrence = await scheduleRepo.getOccurrenceById(occurrenceId);
      if (occurrence == null) return null;
      
      // Sadece done status için ödeme durumu göster
      if (occurrence.status != 'done') return null;
      
      return occurrence.paymentId != null ? 'Ödendi' : 'Ödenmedi';
    } catch (e) {
      return null;
    }
  }

  Future<String> _getStudentName(WidgetRef ref, String studentId) async {
    final studentsRepo = ref.read(studentsRepoProvider);
    final student = await studentsRepo.getStudentById(studentId);
    return student?.fullName ?? 'Bilinmeyen';
  }

  /// Yapıldı: konu/ödev/kaynak/ders notu formunu gösterir. ref/DB kullanmaz; modal sadece form verisi döndürür.
  /// DB ve invalidate çağrısı modal kapandıktan sonra caller tarafında yapılır (_dependents.isEmpty önlemi).
  static Future<DoneLessonSheetResult?> _showDoneLessonSheet(
    BuildContext context, {
    required String studentId,
  }) async {
    if (!context.mounted) return null;
    final result = await showModalBottomSheet<DoneLessonSheetResult?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DoneLessonSheet(studentId: studentId),
    );
    return result;
  }

  /// Kaynak seçimi: 'TEACHER' veya 'STUDENT' döner.
  Future<String?> _showSourceChoiceDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(StringsTr.sourceLabel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(StringsTr.teacherSource),
              onTap: () => Navigator.pop(ctx, 'TEACHER'),
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: Text(StringsTr.studentSource),
              onTap: () => Navigator.pop(ctx, 'STUDENT'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(StringsTr.cancel),
          ),
        ],
      ),
    );
  }

  /// Sebep + ek not sheet. (reason, note) döner; iptal = null.
  Future<({String reason, String? note})?> _showReasonSheet(BuildContext context, String title) async {
    final result = await showModalBottomSheet<({String reason, String? note})?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ReasonSheetWidget(title: title),
    );
    return result;
  }

  Future<void> _handleStatusChange(
    BuildContext context,
    WidgetRef ref,
    String lessonId,
    String action,
  ) async {
    final lessonsRepo = ref.read(lessonsRepoProvider);
    String? newStatus;

    if (action == 'clear') {
      newStatus = null;
    } else {
      newStatus = action;
    }

    try {
      await lessonsRepo.updateLessonStatus(
        lessonId: lessonId,
        status: newStatus,
      );
      
      // Provider'ları güvenli bir şekilde yenile
      if (context.mounted) {
        try {
          final now = DateTime.now();
          final firstDay = DateTime(now.year, now.month, 1);
          final lastDay = DateTime(now.year, now.month + 1, 0);
          final dateRange = DateTimeRange(start: firstDay, end: lastDay);
          ref.invalidate(calendarLessonsProvider(dateRange));
        } catch (e) {
          debugPrint('Provider refresh hatası: $e');
        }
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == null
                  ? 'Durum temizlendi'
                  : 'Durum güncellendi: ${_getStatusDisplayName(newStatus)}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleOccurrenceStatusChange(
    BuildContext context,
    WidgetRef ref,
    String occurrenceId,
    String action,
    DateTime lessonDate,
  ) async {
    final scheduleRepo = ref.read(scheduleRepoProvider);
    
    // Occurrence'ı al (UI refresh için gerekli)
    final occurrence = await scheduleRepo.getOccurrenceById(occurrenceId);
    if (occurrence == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ders bulunamadı'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    
    try {
      if (action == 'postponed') {
        // Ertele: Tarih ve saat seçici aç
        final now = DateTime.now();
        final firstDate = DateTime(now.year, now.month, now.day);
        // initialDate, firstDate'den önce olamaz
        final initialDate = lessonDate.add(const Duration(days: 1));
        final safeInitialDate = initialDate.isBefore(firstDate) ? firstDate : initialDate;
        
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: safeInitialDate,
          firstDate: firstDate,
          lastDate: DateTime.now().add(const Duration(days: 365)),
          locale: const Locale('tr', 'TR'),
        );
        
        if (selectedDate == null) {
          return; // Kullanıcı iptal etti
        }
        
        // Saat seçici aç
        TimeOfDay? selectedTime;
        if (context.mounted) {
          selectedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(lessonDate),
          );
        }
        
        if (selectedTime == null) {
          return; // Kullanıcı iptal etti
        }
        
        if (!context.mounted) return;
        
        // Erteleme sebebi (isteğe bağlı)
        final reasonData = await _showReasonSheet(context, 'Erteleme sebebi (isteğe bağlı)');
        if (!context.mounted) return;
        final trimmed = reasonData?.reason?.trim();
        final reasonToSave = (trimmed != null && trimmed.isNotEmpty) ? trimmed : null;
        
        // Çakışma kontrolü yap (postponeByMove kullan - DELETE+INSERT)
        final success = await scheduleRepo.postponeByMove(
          oldOccurrenceId: occurrenceId,
          newDate: selectedDate,
          newStartTime: selectedTime,
          postponementReason: reasonToSave,
        );
        
        if (!context.mounted) return;
        
        if (!success) {
          // Çakışma var, uyarı göster
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Çakışma Uyarısı'),
              content: const Text(
                'Seçilen tarih ve saatte başka bir ders bulunmaktadır. '
                'Lütfen farklı bir tarih veya saat seçiniz.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Tamam'),
                ),
              ],
            ),
          );
        } else {
          // Başarılı - picker kapandıktan sonra invalidate/SnackBar ertelenir (_dependents.isEmpty önlemi)
          final refPost = ref;
          final contextPost = context;
          final occ = occurrence;
          final selDate = selectedDate;
          final selTime = selectedTime;
          final lessonDt = lessonDate;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!contextPost.mounted) return;
            final oldFirstDay = DateTime(lessonDt.year, lessonDt.month, 1);
            final oldLastDay = DateTime(lessonDt.year, lessonDt.month + 1, 0);
            refPost.invalidate(calendarLessonsProvider(DateTimeRange(start: oldFirstDay, end: oldLastDay)));
            final newFirstDay = DateTime(selDate.year, selDate.month, 1);
            final newLastDay = DateTime(selDate.year, selDate.month + 1, 0);
            refPost.invalidate(calendarLessonsProvider(DateTimeRange(start: newFirstDay, end: newLastDay)));
            if (occ.status == 'done') {
              refPost.invalidate(globalPaymentSummaryProvider);
              refPost.invalidate(studentPaymentSummariesProvider);
              if (occ.studentId.isNotEmpty) {
                refPost.invalidate(studentPaymentSummaryProvider(occ.studentId));
                refPost.invalidate(studentUnpaidLessonsProvider(
                  StudentUnpaidLessonsParams(studentId: occ.studentId, includePaid: false),
                ));
              }
            }
            if (!contextPost.mounted) return;
            ScaffoldMessenger.of(contextPost).showSnackBar(
              SnackBar(
                content: Text(
                  'Ders ${selDate.day}.${selDate.month}.${selDate.year} '
                  '${selTime.hour.toString().padLeft(2, '0')}:${selTime.minute.toString().padLeft(2, '0')} '
                  'tarihine taşındı',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          });
        }
      } else if (action == 'delete') {
        if (!context.mounted) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Dersi Sil'),
            content: const Text('Bu dersi silmek istediğinize emin misiniz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sil'),
              ),
            ],
          ),
        );
        if (confirmed != true || !context.mounted) return;
        await scheduleRepo.deleteOccurrence(occurrenceId);
        if (!context.mounted) return;
        final refDel = ref;
        final contextDel = context;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!contextDel.mounted) return;
          final now = DateTime.now();
          refDel.invalidate(calendarLessonsProvider(DateTimeRange(start: DateTime(now.year, now.month, 1), end: DateTime(now.year, now.month + 1, 0))));
          refDel.invalidate(calendarLessonsProvider(DateTimeRange(start: DateTime(now.year, now.month - 1, 1), end: DateTime(now.year, now.month, 0))));
          refDel.invalidate(calendarLessonsProvider(DateTimeRange(start: DateTime(now.year, now.month + 1, 1), end: DateTime(now.year, now.month + 2, 0))));
          if (!contextDel.mounted) return;
          ScaffoldMessenger.of(contextDel).showSnackBar(
            const SnackBar(
              content: Text('Ders silindi'),
              duration: Duration(seconds: 2),
            ),
          );
        });
        return;
      } else if (action == 'done') {
        // Yapıldı: Öğrenci bilgisi ref ile alınır (modal açılmadan önce). Modal sadece form döndürür; DB modal kapandıktan sonra.
        if (!context.mounted) return;
        final studentsRepo = ref.read(studentsRepoProvider);
        final student = await studentsRepo.getStudentById(occurrence.studentId);
        if (student == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Öğrenci bulunamadı'), backgroundColor: AppColors.danger),
            );
          }
          return;
        }
        if (!context.mounted) return;
        // Popup menü tam kapansın diye bir frame bekle; sonra sadece form sheet'ini aç (ref/DB yok).
        final contextForSheet = context;
        final completer = Completer<DoneLessonSheetResult?>();
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!contextForSheet.mounted) {
            if (!completer.isCompleted) completer.complete(null);
            return;
          }
          final formResult = await DayLessonsPanel._showDoneLessonSheet(
            contextForSheet,
            studentId: occurrence.studentId,
          );
          if (!completer.isCompleted) completer.complete(formResult);
        });
        final formResult = await completer.future;
        if (formResult == null || !context.mounted) return;
        // Modal kapandı. DB ve invalidate sadece modal kapandıktan sonra, gecikmeyle (lifecycle güvenli).
        final startDateTime = DateTime(
          int.parse(occurrence.date.split('-')[0]),
          int.parse(occurrence.date.split('-')[1]),
          int.parse(occurrence.date.split('-')[2]),
          int.parse(occurrence.startTime.split(':')[0]),
          int.parse(occurrence.startTime.split(':')[1]),
        );
        final refForInvalidate = ref;
        final contextAfterClose = context;
        final studentIdForInvalidate = occurrence.studentId;
        final scheduleRepoForSave = ref.read(scheduleRepoProvider);
        Future.delayed(const Duration(milliseconds: 250), () async {
          if (!contextAfterClose.mounted) return;
          try {
            await scheduleRepoForSave.createLessonForOccurrence(
              occurrenceId: occurrenceId,
              studentId: occurrence.studentId,
              startDateTime: startDateTime,
              durationMin: occurrence.durationMin,
              hourlyRate: student.hourlyRate,
              topic: formResult.topic,
              homework: formResult.homework,
              homeworkResource: formResult.homeworkResource,
              lessonNotes: formResult.note,
            );
          } catch (e) {
            if (contextAfterClose.mounted) {
              ScaffoldMessenger.of(contextAfterClose).showSnackBar(
                SnackBar(content: Text('${StringsTr.errorPrefix}$e'), backgroundColor: AppColors.danger),
              );
            }
            return;
          }
          if (!contextAfterClose.mounted) return;
          final now = DateTime.now();
          refForInvalidate.invalidate(calendarLessonsProvider(DateTimeRange(start: DateTime(now.year, now.month, 1), end: DateTime(now.year, now.month + 1, 0))));
          refForInvalidate.invalidate(calendarLessonsProvider(DateTimeRange(start: DateTime(now.year, now.month - 1, 1), end: DateTime(now.year, now.month, 0))));
          refForInvalidate.invalidate(calendarLessonsProvider(DateTimeRange(start: DateTime(now.year, now.month + 1, 1), end: DateTime(now.year, now.month + 2, 0))));
          refForInvalidate.invalidate(globalPaymentSummaryProvider);
          refForInvalidate.invalidate(studentPaymentSummariesProvider);
          refForInvalidate.invalidate(studentPaymentSummaryProvider(studentIdForInvalidate));
          refForInvalidate.invalidate(studentUnpaidLessonsProvider(StudentUnpaidLessonsParams(studentId: studentIdForInvalidate, includePaid: false)));
          if (!contextAfterClose.mounted) return;
          ScaffoldMessenger.of(contextAfterClose).showSnackBar(
            const SnackBar(
              content: Text('Ders yapıldı olarak kaydedildi'),
              duration: Duration(seconds: 2),
            ),
          );
        });
        return;
      } else if (action == 'not_done') {
        // Yapılmadı: Önce kaynak seçimi, sonra sebep modalı. Modal kapandıktan sonra invalidate ertelenir (_dependents.isEmpty önlemi).
        if (!context.mounted) return;
        final source = await _showSourceChoiceDialog(context);
        if (source == null || !context.mounted) return;
        final reasonData = await _showReasonSheet(context, StringsTr.missed);
        if (reasonData == null || !context.mounted) return;
        await scheduleRepo.markMissedWithReason(
          occurrenceId: occurrenceId,
          source: source,
          reason: reasonData.reason,
          note: reasonData.note,
        );
        if (!context.mounted) return;
        final refNotDone = ref;
        final contextNotDone = context;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!contextNotDone.mounted) return;
          final now = DateTime.now();
          final firstDay = DateTime(now.year, now.month, 1);
          final lastDay = DateTime(now.year, now.month + 1, 0);
          refNotDone.invalidate(calendarLessonsProvider(DateTimeRange(start: firstDay, end: lastDay)));
          if (!contextNotDone.mounted) return;
          ScaffoldMessenger.of(contextNotDone).showSnackBar(
            const SnackBar(
              content: Text('Ders yapılmadı olarak işaretlendi'),
              duration: Duration(seconds: 2),
            ),
          );
        });
        return;
      } else if (action == 'clear') {
        // Temizle = occurrence'ı sıfırla. Modal/route kapandıktan sonra SnackBar ertelenir.
        await scheduleRepo.resetOccurrence(occurrenceId);
        if (!context.mounted) return;
        final contextClear = context;
        final refClear = ref;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!contextClear.mounted) return;
          final now = DateTime.now();
          refClear.invalidate(calendarLessonsProvider(DateTimeRange(start: DateTime(now.year, now.month, 1), end: DateTime(now.year, now.month + 1, 0))));
          refClear.invalidate(calendarLessonsProvider(DateTimeRange(start: DateTime(now.year, now.month - 1, 1), end: DateTime(now.year, now.month, 0))));
          refClear.invalidate(calendarLessonsProvider(DateTimeRange(start: DateTime(now.year, now.month + 1, 1), end: DateTime(now.year, now.month + 2, 0))));
          if (!contextClear.mounted) return;
          ScaffoldMessenger.of(contextClear).showSnackBar(
            const SnackBar(
              content: Text('Durum temizlendi'),
              duration: Duration(seconds: 2),
            ),
          );
        });
        return;
      }
      
      // Provider'ları invalidate et - UI anında güncellensin (sadece delete/postponed vb. için; done/not_done/clear yukarıda return etti)
      if (context.mounted) {
        try {
          final now = DateTime.now();
          final currentFirstDay = DateTime(now.year, now.month, 1);
          final currentLastDay = DateTime(now.year, now.month + 1, 0);
          ref.invalidate(calendarLessonsProvider(DateTimeRange(start: currentFirstDay, end: currentLastDay)));
          final prevMonth = DateTime(now.year, now.month - 1, 1);
          final prevFirstDay = DateTime(prevMonth.year, prevMonth.month, 1);
          final prevLastDay = DateTime(prevMonth.year, prevMonth.month + 1, 0);
          ref.invalidate(calendarLessonsProvider(DateTimeRange(start: prevFirstDay, end: prevLastDay)));
          final nextMonth = DateTime(now.year, now.month + 1, 1);
          final nextFirstDay = DateTime(nextMonth.year, nextMonth.month, 1);
          final nextLastDay = DateTime(nextMonth.year, nextMonth.month + 1, 0);
          ref.invalidate(calendarLessonsProvider(DateTimeRange(start: nextFirstDay, end: nextLastDay)));
        } catch (e) {
          debugPrint('Provider invalidate hatası: $e');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Occurrence status değiştirme hatası: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Dialog sonucu: 'done' | 'not_done' | 'postponed' | 'clear' veya null (iptal).
  Future<String?> _showStatusDialog(
    BuildContext context,
    WidgetRef ref,
    Lesson lesson,
    bool isPast,
  ) async {
    if (!context.mounted) return null;
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Durum Değiştir'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Yapıldı'),
              onTap: () => Navigator.pop(dialogContext, 'done'),
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Yapılmadı'),
              onTap: () => Navigator.pop(dialogContext, 'not_done'),
            ),
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.orange),
              title: const Text('Ertelendi'),
              onTap: () => Navigator.pop(dialogContext, 'postponed'),
            ),
            ListTile(
              leading: const Icon(Icons.clear, color: Colors.grey),
              title: const Text('Temizle'),
              onTap: () => Navigator.pop(dialogContext, 'clear'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'done':
        return 'Yapıldı';
      case 'not_done':
        return 'Yapılmadı';
      case 'postponed':
        return 'Ertelendi';
      default:
        return status;
    }
  }
}
