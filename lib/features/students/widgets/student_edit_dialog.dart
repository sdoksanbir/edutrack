import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/shared/utils/name_format.dart';

/// Öğrenci düzenleme dialog'u. Ad Soyad, Telefon, Saatlik Ücret, Notlar ve veli alanları.
/// Kitap/kaynak öğrenci detay sayfasından eklenir.
void showStudentEditDialog(BuildContext context, WidgetRef ref, Student student) {
  final nameController = TextEditingController(text: student.fullName);
  final phoneController = TextEditingController(text: student.phone ?? '');
  final hourlyRateController = TextEditingController(text: student.hourlyRate.toString());
  final notesController = TextEditingController(text: student.notes ?? '');
  final guardianNameController = TextEditingController(text: student.guardianFullName ?? '');
  final guardianPhoneController = TextEditingController(text: student.guardianPhone ?? '');

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Öğrenci Düzenle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad *',
                border: OutlineInputBorder(),
                hintText: 'Örn. Ahmet Mehmet YILMAZ',
              ),
              autofocus: true,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              onEditingComplete: () {
                nameController.text =
                    formatPersonFullName(nameController.text);
                nameController.selection = TextSelection.collapsed(
                  offset: nameController.text.length,
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefon',
                border: OutlineInputBorder(),
                hintText: '5XX XXX XX XX',
              ),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: hourlyRateController,
              decoration: const InputDecoration(
                labelText: 'Saatlik Ücret (TL) *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notlar',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: guardianNameController,
              decoration: const InputDecoration(
                labelText: 'Veli Ad Soyad',
                border: OutlineInputBorder(),
                hintText: 'Örn. Ayşe YILMAZ',
              ),
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              onEditingComplete: () {
                guardianNameController.text =
                    formatPersonFullName(guardianNameController.text);
                guardianNameController.selection = TextSelection.collapsed(
                  offset: guardianNameController.text.length,
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: guardianPhoneController,
              decoration: const InputDecoration(
                labelText: 'Veli Telefon',
                border: OutlineInputBorder(),
                hintText: '5XX XXX XX XX',
              ),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('İptal'),
        ),
        FilledButton(
          onPressed: () async {
            final fullName = formatPersonFullName(nameController.text);
            final phone = phoneController.text.trim();
            final hourlyRateStr = hourlyRateController.text.trim();
            final notes = notesController.text.trim();
            final guardianFullName =
                formatPersonFullName(guardianNameController.text);
            final guardianPhone = guardianPhoneController.text.trim();

            nameController.text = fullName;
            guardianNameController.text = guardianFullName;

            if (fullName.isEmpty) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(content: Text('Ad Soyad boş olamaz')),
              );
              return;
            }

            if (phone.isNotEmpty && phone.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(content: Text('Telefon en az 10 haneli olmalıdır')),
              );
              return;
            }
            if (guardianPhone.isNotEmpty && guardianPhone.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(content: Text('Veli telefonu en az 10 haneli olmalıdır')),
              );
              return;
            }

            final hourlyRate = int.tryParse(hourlyRateStr);
            if (hourlyRate == null || hourlyRate <= 0) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(content: Text('Saatlik ücret 0\'dan büyük olmalıdır')),
              );
              return;
            }

            try {
              final studentsRepo = ref.read(studentsRepoProvider);
              await studentsRepo.updateStudent(
                id: student.id,
                fullName: fullName,
                phone: phone.isEmpty ? null : phone,
                hourlyRate: hourlyRate,
                notes: notes.isEmpty ? null : notes,
                guardianFullName: guardianFullName.isEmpty ? null : guardianFullName,
                guardianPhone: guardianPhone.isEmpty ? null : guardianPhone,
              );

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Öğrenci güncellendi')),
                );
              }
            } catch (e) {
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text('Hata: $e')),
                );
              }
            }
          },
          child: const Text('Kaydet'),
        ),
      ],
    ),
  );
}
