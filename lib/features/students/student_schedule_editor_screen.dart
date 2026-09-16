import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/data/repositories/schedule_repo.dart';
import 'package:ozel_ders_takip/data/providers/calendar_providers.dart';

class StudentScheduleEditorScreen extends ConsumerWidget {
  final String studentId;

  const StudentScheduleEditorScreen({
    super.key,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch yerine ref.read kullan - stream zaten reactive
    final scheduleRepo = ref.read(scheduleRepoProvider);
    final studentsRepo = ref.read(studentsRepoProvider);
    final templatesStream = scheduleRepo.watchTemplatesByStudent(studentId);

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Student?>(
          future: studentsRepo.getStudentById(studentId),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Text('${snapshot.data!.fullName} - Haftalık Program');
            }
            return const Text('Haftalık Program');
          },
        ),
      ),
      body: StreamBuilder<List<ScheduleTemplate>>(
        stream: templatesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Hata: ${snapshot.error}'),
            );
          }

          final templates = snapshot.data ?? [];
          final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

          if (templates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Henüz ders planı eklenmemiş',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Sırala: önce aktif, sonra pasif; aynı grupta startDate'e göre
          final sorted = List<ScheduleTemplate>.from(templates)
            ..sort((a, b) {
              final aActive = _isActive(a, today);
              final bActive = _isActive(b, today);
              if (aActive && !bActive) return -1;
              if (!aActive && bActive) return 1;
              return a.startDate.compareTo(b.startDate);
            });

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final template = sorted[index];
              return _buildTemplateCard(context, ref, template, today);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Haftalık / Tekil ders ekleme seçenekleri
          final action = await showDialog<String>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Ders Ekle'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.repeat),
                    title: const Text('Haftalık Ders Ekle'),
                    onTap: () => Navigator.pop(dialogContext, 'weekly'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.event),
                    title: const Text('Tek Ders Ekle'),
                    onTap: () => Navigator.pop(dialogContext, 'single'),
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

          if (action == 'weekly') {
            _showAddDialog(context, ref);
          } else if (action == 'single') {
            _showOneOffDialog(context, ref);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Tekil (one-off / extra) ders ekleme diyaloğu
  void _showOneOffDialog(BuildContext context, WidgetRef ref) {
    DateTime? selectedDate = DateTime.now();
    TimeOfDay? selectedTime = TimeOfDay.now();
    final durationController = TextEditingController(text: '60');

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tek Ders Ekle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tarih
                ListTile(
                  title: const Text('Tarih *'),
                  subtitle: Text(
                    selectedDate != null
                        ? '${selectedDate!.day.toString().padLeft(2, '0')}.'
                            '${selectedDate!.month.toString().padLeft(2, '0')}.'
                            '${selectedDate!.year}'
                        : 'Tarih seçiniz',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final now = DateTime.now();
                    final initial = selectedDate ??
                        DateTime(now.year, now.month, now.day);
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initial,
                      firstDate: DateTime(now.year - 1),
                      lastDate: DateTime(now.year + 5),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                        );
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                // Saat
                ListTile(
                  title: const Text('Saat *'),
                  subtitle: Text(
                    selectedTime != null
                        ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                        : 'Saat seçiniz',
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final initial = selectedTime ?? TimeOfDay.now();
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: initial,
                    );
                    if (picked != null) {
                      setState(() {
                        selectedTime = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                // Süre
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'Süre (dakika) *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tarih seçiniz')),
                  );
                  return;
                }
                if (selectedTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saat seçiniz')),
                  );
                  return;
                }

                final duration = int.tryParse(durationController.text);
                if (duration == null || duration <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Geçerli bir süre giriniz')),
                  );
                  return;
                }

                final startDateTime = DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                  selectedTime!.hour,
                  selectedTime!.minute,
                );
                final endDateTime =
                    startDateTime.add(Duration(minutes: duration));

                try {
                  final scheduleRepo = ref.read(scheduleRepoProvider);

                  // Çakışma kontrolü
                  final hasConflict = await scheduleRepo.checkConflict(
                    studentId: studentId,
                    newStart: startDateTime,
                    newEnd: endDateTime,
                  );

                  if (hasConflict) {
                    if (dialogContext.mounted) {
                      await showDialog<void>(
                        context: dialogContext,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Çakışma Uyarısı'),
                          content: const Text(
                            'Seçilen tarih ve saatte bu öğrenci için başka bir ders bulunmaktadır.\n'
                            'Lütfen farklı bir tarih veya saat seçiniz.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Tamam'),
                            ),
                          ],
                        ),
                      );
                    }
                    return;
                  }

                  await scheduleRepo.createOneOffOccurrence(
                    studentId: studentId,
                    date: selectedDate!,
                    startTime: selectedTime!,
                    durationMin: duration,
                  );

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tek ders eklendi')),
                    );
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Hata: $e')),
                    );
                  }
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekdayName(int weekday) {
    const days = [
      'Pazar',
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
    ];
    return days[weekday % 7];
  }

  String _getWeekdayShort(int weekday) {
    const days = ['Pz', 'Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct'];
    return days[weekday % 7];
  }

  /// 'YYYY-MM-DD' string'ini DateTime (sadece gün) olarak parse eder.
  DateTime _parseTemplateDate(String dateStr) {
    final p = dateStr.split('-');
    return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  /// Template'in bitiş tarihi (null ise null).
  DateTime? _templateEndDate(ScheduleTemplate t) {
    if (t.endDate == null) return null;
    return _parseTemplateDate(t.endDate!);
  }

  /// PASİF: endDate < today
  bool _isPassive(ScheduleTemplate t, DateTime today) {
    final end = _templateEndDate(t);
    return end != null && end.isBefore(today);
  }

  /// AKTİF: startDate <= today && (endDate == null || endDate >= today)
  bool _isActive(ScheduleTemplate t, DateTime today) {
    final start = _parseTemplateDate(t.startDate);
    final end = _templateEndDate(t);
    if (start.isAfter(today)) return false;
    if (end != null && end.isBefore(today)) return false;
    return true;
  }

  /// GELECEK: startDate > today
  bool _isFuture(ScheduleTemplate t, DateTime today) {
    return _parseTemplateDate(t.startDate).isAfter(today);
  }

  Widget _buildTemplateCard(
    BuildContext context,
    WidgetRef ref,
    ScheduleTemplate template,
    DateTime today,
  ) {
    final passive = _isPassive(template, today);
    final active = _isActive(template, today);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: Opacity(
        opacity: passive ? 0.6 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: passive
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.7)
                : colorScheme.primaryContainer.withValues(alpha: 0.35),
            border: active
                ? Border.all(
                    color: colorScheme.primary,
                    width: 1.5,
                  )
                : null,
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: passive
                  ? colorScheme.surfaceContainerHigh
                  : colorScheme.primaryContainer,
              child: Text(
                _getWeekdayShort(template.weekday),
                style: TextStyle(
                  color: passive
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_getWeekdayName(template.weekday)} - ${template.startTime}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                _buildStatusBadge(context, active: active, passive: passive),
              ],
            ),
            subtitle: Text('${template.durationMin} dakika'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: passive
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Pasif program düzenlenemez. Yeni bir program ekleyip eski tarihi kapatabilirsiniz.',
                              ),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      : () => _showEditDialog(context, ref, template),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _showDeleteDialog(context, ref, template),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, {required bool active, required bool passive}) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = passive ? 'Pasif' : 'Aktif';
    final bgColor = passive
        ? colorScheme.surfaceContainerHigh
        : colorScheme.primaryContainer;
    final fgColor = passive
        ? colorScheme.onSurfaceVariant
        : colorScheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fgColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w600,
            ) ??
            TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fgColor),
      ),
    );
  }

  void _invalidateNearbyCalendarMonths(WidgetRef ref) {
    final now = DateTime.now();
    for (final offset in [-1, 0, 1]) {
      final month = DateTime(now.year, now.month + offset, 1);
      final range = DateTimeRange(
        start: month,
        end: DateTime(month.year, month.month + 1, 0),
      );
      ref.invalidate(calendarLessonsProvider(range));
    }
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => _AddWeeklyPlanDialog(
        studentId: studentId,
        ref: ref,
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    ScheduleTemplate template,
  ) {
    int? selectedWeekday = template.weekday;
    final timeParts = template.startTime.split(':');
    TimeOfDay? selectedTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
    final durationController =
        TextEditingController(text: template.durationMin.toString());

    // Değişiklik başlangıç tarihi (effectiveFrom): zorunlu
    final templateStartParts = template.startDate.split('-');
    final templateStart = DateTime(
      int.parse(templateStartParts[0]),
      int.parse(templateStartParts[1]),
      int.parse(templateStartParts[2]),
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Mevcut planın başlangıcı — düzenlemede aynı kayıt güncellenir
    DateTime? selectedEffectiveFrom = templateStart;
    DateTime? selectedEndDate;
    if (template.endDate != null) {
      final endParts = template.endDate!.split('-');
      selectedEndDate = DateTime(
        int.parse(endParts[0]),
        int.parse(endParts[1]),
        int.parse(endParts[2]),
      );
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Ders Planı Düzenle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Gün *',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: selectedWeekday,
                  items: List.generate(7, (index) {
                    final weekday = index + 1;
                    return DropdownMenuItem(
                      value: weekday,
                      child: Text(_getWeekdayName(weekday)),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      selectedWeekday = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Saat *'),
                  subtitle: Text(
                    selectedTime != null
                        ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                        : 'Saat seçiniz',
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime!,
                    );
                    if (time != null) {
                      setState(() {
                        selectedTime = time;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'Süre (dakika) *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                // Başlangıç Tarihi
                ListTile(
                  title: const Text('Başlangıç Tarihi *'),
                  subtitle: Text(
                    selectedEffectiveFrom != null
                        ? '${selectedEffectiveFrom!.day.toString().padLeft(2, '0')}.'
                            '${selectedEffectiveFrom!.month.toString().padLeft(2, '0')}.'
                            '${selectedEffectiveFrom!.year}'
                        : 'Tarih seçiniz',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final initial = selectedEffectiveFrom ?? today;
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initial,
                      firstDate: DateTime(now.year - 1),
                      lastDate: DateTime(now.year + 10),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedEffectiveFrom = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                        );
                        if (selectedEndDate != null &&
                            selectedEndDate!.isBefore(selectedEffectiveFrom!)) {
                          selectedEndDate = null;
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mevcut ders planı güncellenir; yeni plan eklenmez.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                // Bitiş Tarihi (opsiyonel)
                ListTile(
                  title: const Text('Bitiş Tarihi (Opsiyonel)'),
                  subtitle: Text(
                    selectedEndDate != null
                        ? '${selectedEndDate!.day.toString().padLeft(2, '0')}.'
                            '${selectedEndDate!.month.toString().padLeft(2, '0')}.'
                            '${selectedEndDate!.year}'
                        : 'Varsayılan bitiş tarihi kullanılacak',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selectedEndDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() {
                              selectedEndDate = null;
                            });
                          },
                        ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                  onTap: () async {
                    final minDate = selectedEffectiveFrom ?? today;
                    // Takvim başlangıç tarihinden açılsın (gelecek yıl değil)
                    final initial = selectedEndDate ?? minDate;
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initial.isBefore(minDate) ? minDate : initial,
                      firstDate: minDate,
                      lastDate: DateTime(now.year + 10),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedEndDate = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                        );
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedWeekday == null || selectedTime == null) {
                  return;
                }
                if (selectedEffectiveFrom == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Başlangıç tarihi seçiniz')),
                  );
                  return;
                }

                final duration = int.tryParse(durationController.text);
                if (duration == null || duration <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Geçerli bir süre giriniz')),
                  );
                  return;
                }

                try {
                  final scheduleRepo = ref.read(scheduleRepoProvider);
                  final startTime =
                      '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';

                  await scheduleRepo.updateWeeklyPlanAndOccurrences(
                    templateId: template.id,
                    weekday: selectedWeekday!,
                    startTime: startTime,
                    durationMin: duration,
                    startDate: selectedEffectiveFrom!,
                    endDate: selectedEndDate, // null → ayarlar
                  );

                  _invalidateNearbyCalendarMonths(ref);

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ders planı güncellendi')),
                    );
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Hata: $e')),
                    );
                  }
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    ScheduleTemplate template,
  ) async {
    // Template bilgilerini al
    final scheduleRepo = ref.read(scheduleRepoProvider);
    final appSettingsRepo = ref.read(appSettingsRepoProvider);
    
    // Template'in startDate'ini parse et
    final templateStartDateParts = template.startDate.split('-');
    final templateStart = DateTime(
      int.parse(templateStartDateParts[0]),
      int.parse(templateStartDateParts[1]),
      int.parse(templateStartDateParts[2]),
    );
    
    // Default end date al
    final defaultEndDate = await appSettingsRepo.getDefaultScheduleEndDate();
    
    // Template'in endDate'i (null ise defaultEndDate kullan)
    final templateEnd = template.endDate != null
        ? (() {
            final templateEndDateParts = template.endDate!.split('-');
            return DateTime(
              int.parse(templateEndDateParts[0]),
              int.parse(templateEndDateParts[1]),
              int.parse(templateEndDateParts[2]),
            );
          })()
        : defaultEndDate;
    
    // Tarihler opsiyonel: seçilmezse bugünden → plan bitişine kadar silinir
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime? selectedFromDate;
    DateTime? selectedToDate;
    
    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Planı Kaldır / Tekrarı Durdur'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Planlanan dersler kaldırılır. Yapıldı/Yapılmadı kayıtları korunur.\n\n'
                  'Tarih seçilmezse: bugünden itibaren plan bitiş tarihine kadar silinir.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                // Başlangıç tarihi (opsiyonel)
                ListTile(
                  title: const Text('Başlangıç Tarihi'),
                  subtitle: Text(
                    selectedFromDate != null
                        ? '${selectedFromDate!.day.toString().padLeft(2, '0')}.'
                            '${selectedFromDate!.month.toString().padLeft(2, '0')}.'
                            '${selectedFromDate!.year}'
                        : 'Seçilmezse bugünden itibaren',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selectedFromDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() {
                              selectedFromDate = null;
                            });
                          },
                        ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                  onTap: () async {
                    final minDate = templateStart;
                    final initial = selectedFromDate ??
                        (today.isAfter(templateStart) ? today : templateStart);
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initial,
                      firstDate: minDate,
                      lastDate: DateTime(now.year + 10),
                      locale: const Locale('tr', 'TR'),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedFromDate = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                        );
                        if (selectedToDate != null &&
                            selectedToDate!.isBefore(selectedFromDate!)) {
                          selectedToDate = null;
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                // Bitiş tarihi (opsiyonel)
                ListTile(
                  title: const Text('Bitiş Tarihi'),
                  subtitle: Text(
                    selectedToDate != null
                        ? '${selectedToDate!.day.toString().padLeft(2, '0')}.'
                            '${selectedToDate!.month.toString().padLeft(2, '0')}.'
                            '${selectedToDate!.year}'
                        : 'Seçilmezse planın bitiş tarihine kadar',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selectedToDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() {
                              selectedToDate = null;
                            });
                          },
                        ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                  onTap: () async {
                    final defaultFrom = today.isAfter(templateStart)
                        ? today
                        : templateStart;
                    final minDate = selectedFromDate ?? defaultFrom;
                    final initial = selectedToDate ?? templateEnd;
                    final picked = await showDatePicker(
                      context: context,
                      initialDate:
                          initial.isBefore(minDate) ? minDate : initial,
                      firstDate: minDate,
                      lastDate: DateTime(now.year + 10),
                      locale: const Locale('tr', 'TR'),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedToDate = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                        );
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Tarih seçilmezse: bugün → plan bitişi
                  final defaultFrom =
                      today.isAfter(templateStart) ? today : templateStart;
                  final finalFromDate = selectedFromDate ?? defaultFrom;
                  final finalToDate = selectedToDate ?? templateEnd;

                  if (finalFromDate.isAfter(finalToDate)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Başlangıç tarihi bitiş tarihinden sonra olamaz',
                        ),
                      ),
                    );
                    return;
                  }

                  final result = await scheduleRepo.safeDisableTemplateInRange(
                    templateId: template.id,
                    fromDate: finalFromDate,
                    toDate: finalToDate,
                  );
                  
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    
                    // Takvim güncelleme - komşu aylar
                    _invalidateNearbyCalendarMonths(ref);
                    
                    // Sonuç raporu göster
                    _showResultDialog(context, ref, result);
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Hata: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Uygula'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showResultDialog(
    BuildContext context,
    WidgetRef ref,
    SafeDisableResult result,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Plan Güncellendi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${result.deletedPlannedCount} planlanan ders kaldırıldı'),
              const SizedBox(height: 8),
              Text('${result.keptOccurrences.length} ders korunarak silinmedi (Yapıldı/Yapılmadı)'),
              if (result.keptOccurrences.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Korunan Dersler:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...result.keptOccurrences.map((occ) {
                  final dateParts = occ.date.split('-');
                  final timeParts = occ.startTime.split(':');
                  
                  final statusText = occ.status == 'done' ? 'Yapıldı' : 'Yapılmadı';
                  final paymentText = occ.paymentId != null ? 'Ödendi' : 'Ödenmedi';
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '${dateParts[2]}.${dateParts[1]}.${dateParts[0]} ${timeParts[0]}:${timeParts[1]} - $statusText - $paymentText',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}

/// Haftalık ders planı ekleme diyaloğu — state burada tutulur (tarih kaybı olmasın).
class _AddWeeklyPlanDialog extends StatefulWidget {
  final String studentId;
  final WidgetRef ref;

  const _AddWeeklyPlanDialog({
    required this.studentId,
    required this.ref,
  });

  @override
  State<_AddWeeklyPlanDialog> createState() => _AddWeeklyPlanDialogState();
}

class _AddWeeklyPlanDialogState extends State<_AddWeeklyPlanDialog> {
  int? _weekday;
  TimeOfDay? _time;
  DateTime? _startDate;
  DateTime? _endDate;
  final _durationController = TextEditingController(text: '60');
  bool _saving = false;

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  String _weekdayName(int weekday) {
    const names = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    return names[weekday - 1];
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.'
      '${d.year}';

  Future<void> _save() async {
    if (_weekday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gün seçiniz')),
      );
      return;
    }
    if (_time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saat seçiniz')),
      );
      return;
    }
    final duration = int.tryParse(_durationController.text);
    if (duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir süre giriniz')),
      );
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Başlangıç seçilmezse bugün; bitiş seçilmezse ayarlar (repo içinde)
    final start = _startDate ?? today;
    // Kullanıcı bitiş girdiyse onu kullan; girmediyse null → ayarlar
    final end = _endDate;

    if (end != null && end.isBefore(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitiş tarihi başlangıçtan önce olamaz')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final scheduleRepo = widget.ref.read(scheduleRepoProvider);
      final startTime =
          '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}';

      await scheduleRepo.createWeeklyPlanAndOccurrences(
        studentId: widget.studentId,
        weekday: _weekday!,
        startTime: startTime,
        durationMin: duration,
        startDate: start,
        endDate: end, // null ise ayarlardaki bitiş
      );

      // Takvimde yeni plan hemen görünsün
      final now = DateTime.now();
      for (final offset in [-1, 0, 1]) {
        final month = DateTime(now.year, now.month + offset, 1);
        widget.ref.invalidate(
          calendarLessonsProvider(
            DateTimeRange(
              start: month,
              end: DateTime(month.year, month.month + 1, 0),
            ),
          ),
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            end != null
                ? 'Ders planı eklendi (${_fmt(start)} – ${_fmt(end)})'
                : 'Ders planı eklendi (${_fmt(start)} – ayar bitiş tarihi)',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return AlertDialog(
      title: const Text('Yeni Ders Planı Ekle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Gün *',
                border: OutlineInputBorder(),
              ),
              initialValue: _weekday,
              items: List.generate(7, (i) {
                final w = i + 1;
                return DropdownMenuItem(value: w, child: Text(_weekdayName(w)));
              }),
              onChanged: _saving
                  ? null
                  : (v) => setState(() => _weekday = v),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Saat *'),
              subtitle: Text(
                _time != null
                    ? '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}'
                    : 'Saat seçiniz',
              ),
              trailing: const Icon(Icons.access_time),
              onTap: _saving
                  ? null
                  : () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (t != null) setState(() => _time = t);
                    },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _durationController,
              enabled: !_saving,
              decoration: const InputDecoration(
                labelText: 'Süre (dakika) *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Başlangıç Tarihi'),
              subtitle: Text(
                _startDate != null
                    ? _fmt(_startDate!)
                    : 'Seçilmezse bugünden itibaren',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_startDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: _saving
                          ? null
                          : () => setState(() => _startDate = null),
                    ),
                  const Icon(Icons.calendar_today),
                ],
              ),
              onTap: _saving
                  ? null
                  : () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate ??
                            DateTime(now.year, now.month, now.day),
                        firstDate: DateTime(now.year - 1),
                        lastDate: DateTime(now.year + 5),
                      );
                      if (picked != null) {
                        setState(() {
                          _startDate = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                          );
                          if (_endDate != null &&
                              _endDate!.isBefore(_startDate!)) {
                            _endDate = null;
                          }
                        });
                      }
                    },
            ),
            ListTile(
              title: const Text('Bitiş Tarihi'),
              subtitle: Text(
                _endDate != null
                    ? _fmt(_endDate!)
                    : 'Seçilmezse ayarlardaki son bitiş tarihi',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_endDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: _saving
                          ? null
                          : () => setState(() => _endDate = null),
                    ),
                  const Icon(Icons.calendar_today),
                ],
              ),
              onTap: _saving
                  ? null
                  : () async {
                      final minDate = _startDate ??
                          DateTime(now.year, now.month, now.day);
                      // Takvim başlangıç tarihinden açılsın (gelecek yıl değil)
                      final initial = _endDate ?? minDate;
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            initial.isBefore(minDate) ? minDate : initial,
                        firstDate: minDate,
                        lastDate: DateTime(now.year + 10),
                      );
                      if (picked != null) {
                        setState(() {
                          _endDate = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                          );
                        });
                      }
                    },
            ),
            const SizedBox(height: 8),
            Text(
              _endDate != null
                  ? 'Seçilen günlerde ${_fmt(_startDate ?? DateTime(now.year, now.month, now.day))} – ${_fmt(_endDate!)} arası dersler oluşturulur.'
                  : 'Bitiş seçilmezse ayarlardaki bitiş tarihine kadar dersler oluşturulur.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Kaydet'),
        ),
      ],
    );
  }
}

