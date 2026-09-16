import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ozel_ders_takip/app/router.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/features/students/widgets/student_edit_dialog.dart';
import 'package:ozel_ders_takip/features/students/widgets/student_form_sheet.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';
import 'package:ozel_ders_takip/shared/utils/phone_format.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  bool _showInactive = false;

  @override
  Widget build(BuildContext context) {
    final studentsRepo = ref.read(studentsRepoProvider);
    final studentsStream =
        studentsRepo.watchAllStudents(includeInactive: _showInactive);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenciler'),
        actions: [
          PopupMenuButton<bool>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _showInactive = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: false,
                child: Text('Sadece Aktif Öğrenciler'),
              ),
              const PopupMenuItem(
                value: true,
                child: Text('Tüm Öğrenciler (Pasif Dahil)'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Student>>(
        stream: studentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final students = snapshot.data ?? [];

          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Henüz öğrenci eklenmemiş',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => showStudentFormSheet(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('İlk Öğrenciyi Ekle'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final isInactive = !student.isActive;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  leading: CircleAvatar(
                    backgroundColor:
                        isInactive ? Colors.grey : AppColors.primarySoft,
                    foregroundColor:
                        isInactive ? Colors.white : AppColors.primary,
                    child: Text(student.fullName[0].toUpperCase()),
                  ),
                  title: Text(
                    student.fullName,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isInactive ? Colors.grey : null,
                      decoration:
                          isInactive ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (student.phone != null)
                        Text(
                          formatTurkishPhoneDisplay(student.phone!),
                          style: TextStyle(
                            color: isInactive ? Colors.grey : AppColors.muted,
                          ),
                        )
                      else
                        Text(
                          'Telefon yok',
                          style: TextStyle(
                            color: isInactive ? Colors.grey : AppColors.muted,
                          ),
                        ),
                      if (isInactive)
                        const Text(
                          'Pasif',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${student.hourlyRate} ₺/saat',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isInactive ? Colors.grey : AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () =>
                            showStudentEditDialog(context, ref, student),
                        tooltip: 'Düzenle',
                      ),
                    ],
                  ),
                  onTap: () {
                    context.push(
                      '${AppRouter.students}/${student.id}',
                      extra: student,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showStudentFormSheet(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
