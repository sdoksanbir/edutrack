import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/shared/constants/student_grade_levels.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';
import 'package:ozel_ders_takip/shared/utils/name_format.dart';
import 'package:ozel_ders_takip/shared/utils/phone_format.dart';

Future<void> showStudentFormSheet(
  BuildContext context,
  WidgetRef ref, {
  Student? student,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _StudentFormSheet(student: student);
    },
  );
}

class _StudentFormSheet extends ConsumerStatefulWidget {
  const _StudentFormSheet({this.student});

  final Student? student;

  @override
  ConsumerState<_StudentFormSheet> createState() => _StudentFormSheetState();
}

class _StudentFormSheetState extends ConsumerState<_StudentFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _rateCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _guardianNameCtrl;
  late final TextEditingController _guardianPhoneCtrl;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  String? _gradeLevel;

  bool get _isEdit => widget.student != null;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _nameCtrl = TextEditingController(
      text: s == null ? '' : formatPersonFullName(s.fullName),
    );
    _phoneCtrl = TextEditingController(
      text: (s?.phone == null || s!.phone!.isEmpty)
          ? ''
          : formatTurkishPhoneDisplay(s.phone!),
    );
    _rateCtrl = TextEditingController(
      text: s == null ? '' : s.hourlyRate.toString(),
    );
    _notesCtrl = TextEditingController(text: s?.notes ?? '');
    _guardianNameCtrl = TextEditingController(
      text: (s?.guardianFullName == null || s!.guardianFullName!.isEmpty)
          ? ''
          : formatPersonFullName(s.guardianFullName!),
    );
    _guardianPhoneCtrl = TextEditingController(
      text: (s?.guardianPhone == null || s!.guardianPhone!.isEmpty)
          ? ''
          : formatTurkishPhoneDisplay(s.guardianPhone!),
    );
    _gradeLevel = s?.gradeLevel;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _rateCtrl.dispose();
    _notesCtrl.dispose();
    _guardianNameCtrl.dispose();
    _guardianPhoneCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon, size: 20),
      filled: true,
      fillColor: AppColors.surfaceElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = formatPersonFullName(_nameCtrl.text);
    final phone = formatTurkishPhone(_phoneCtrl.text);
    final rate = int.tryParse(_rateCtrl.text.trim());
    final notes = _notesCtrl.text.trim();
    final guardianName = formatPersonFullName(_guardianNameCtrl.text);
    final guardianPhone = formatTurkishPhone(_guardianPhoneCtrl.text);

    _nameCtrl.text = name;
    _guardianNameCtrl.text = guardianName;

    if (name.isEmpty) {
      _snack('Ad soyad gereklidir');
      return;
    }
    if (rate == null || rate <= 0) {
      _snack('Geçerli bir saatlik ücret giriniz');
      return;
    }
    if (phone != null && phoneDigitCount(phone) < 10) {
      _snack('Telefon en az 10 haneli olmalıdır');
      return;
    }
    if (guardianPhone != null && phoneDigitCount(guardianPhone) < 10) {
      _snack('Veli telefonu en az 10 haneli olmalıdır');
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(studentsRepoProvider);
      if (_isEdit) {
        await repo.updateStudent(
          id: widget.student!.id,
          fullName: name,
          phone: phone ?? '',
          hourlyRate: rate,
          notes: notes.isEmpty ? null : notes,
          guardianFullName: guardianName.isEmpty ? null : guardianName,
          guardianPhone: guardianPhone ?? '',
          gradeLevel: _gradeLevel,
          clearGradeLevel: _gradeLevel == null,
        );
      } else {
        await repo.insertStudent(
          fullName: name,
          phone: phone,
          hourlyRate: rate,
          notes: notes.isEmpty ? null : notes,
          guardianFullName: guardianName.isEmpty ? null : guardianName,
          guardianPhone: guardianPhone,
          gradeLevel: _gradeLevel,
        );
      }
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Öğrenci güncellendi' : 'Öğrenci eklendi'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _snack('Hata: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _isEdit ? Icons.edit_outlined : Icons.person_add_alt_1,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEdit ? 'Öğrenci Düzenle' : 'Yeni Öğrenci',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isEdit
                              ? 'Bilgileri güncelleyin'
                              : 'Öğrenci ve veli bilgilerini girin',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  children: [
                    const _SectionLabel('Öğrenci'),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _nameCtrl,
                      autofocus: !_isEdit,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [PersonFullNameInputFormatter()],
                      decoration: _dec(
                        label: 'Ad Soyad *',
                        hint: 'Örn. Ahmet Mehmet YILMAZ',
                        icon: Icons.badge_outlined,
                      ),
                      onEditingComplete: () {
                        _nameCtrl.text = formatPersonFullName(_nameCtrl.text);
                        _nameCtrl.selection = TextSelection.collapsed(
                          offset: _nameCtrl.text.length,
                        );
                      },
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Zorunlu' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [TurkishPhoneInputFormatter()],
                      decoration: _dec(
                        label: 'Telefon',
                        hint: '0 (5xx) xxx xx xx',
                        icon: Icons.phone_outlined,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _rateCtrl,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: _dec(
                        label: 'Saatlik Ücret (TL) *',
                        hint: 'Örn. 3000',
                        icon: Icons.payments_outlined,
                      ),
                      validator: (v) {
                        final n = int.tryParse(v?.trim() ?? '');
                        if (n == null || n <= 0) return 'Geçerli ücret girin';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      value: _gradeLevel,
                      decoration: _dec(
                        label: 'Sınıf / Seviye',
                        hint: 'Örn. 10. Sınıf',
                        icon: Icons.school_outlined,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Seçilmedi'),
                        ),
                        ...StudentGradeLevels.options.map(
                          (o) => DropdownMenuItem<String?>(
                            value: o.value,
                            child: Text(o.label),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _gradeLevel = v),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      textInputAction: TextInputAction.next,
                      decoration: _dec(
                        label: 'Notlar',
                        hint: 'İsteğe bağlı notlar',
                        icon: Icons.notes_outlined,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _SectionLabel('Veli'),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _guardianNameCtrl,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [PersonFullNameInputFormatter()],
                      decoration: _dec(
                        label: 'Veli Ad Soyad',
                        hint: 'Örn. Ayşe YILMAZ',
                        icon: Icons.family_restroom_outlined,
                      ),
                      onEditingComplete: () {
                        _guardianNameCtrl.text =
                            formatPersonFullName(_guardianNameCtrl.text);
                        _guardianNameCtrl.selection = TextSelection.collapsed(
                          offset: _guardianNameCtrl.text.length,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _guardianPhoneCtrl,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [TurkishPhoneInputFormatter()],
                      decoration: _dec(
                        label: 'Veli Telefon',
                        hint: '0 (5xx) xxx xx xx',
                        icon: Icons.phone_outlined,
                      ),
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _saving ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          side: const BorderSide(color: AppColors.border),
                          foregroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('İptal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _saving ? null : _submit,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_isEdit ? 'Kaydet' : 'Öğrenci Ekle'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.muted,
      ),
    );
  }
}
