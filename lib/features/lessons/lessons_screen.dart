import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ozel_ders_takip/app/router.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';

/// Dersler sekmesi: Öğrenci listesi. Tıklanınca öğrenci dersleri ekranına gider (/lessons/student/:studentId).
class LessonsScreen extends ConsumerWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsRepo = ref.watch(studentsRepoProvider);
    final studentsStream = studentsRepo.watchAllStudents(includeInactive: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(StringsTr.lessonsMenuTitle),
      ),
      body: StreamBuilder<List<Student>>(
        stream: studentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${StringsTr.errorPrefix}${snapshot.error}'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {},
                    child: const Text('Yenile'),
                  ),
                ],
              ),
            );
          }
          final students = snapshot.data ?? [];
          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: AppColors.muted),
                  const SizedBox(height: 16),
                  Text(
                    StringsTr.noStudentsYet,
                    style: TextStyle(fontSize: 16, color: AppColors.muted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return _StudentLessonCard(
                student: student,
                onTap: () => context.push(
                  '${AppRouter.lessons}/student/${student.id}',
                  extra: student.fullName,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StudentLessonCard extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;

  const _StudentLessonCard({
    required this.student,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: AppColors.primarySoft,
          child: Text(
            student.fullName.isNotEmpty ? student.fullName[0].toUpperCase() : '?',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          student.fullName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: _LastLessonHint(studentId: student.id),
        trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
        onTap: onTap,
      ),
    );
  }
}

/// Opsiyonel: son ders tarihi (küçük özet).
class _LastLessonHint extends ConsumerWidget {
  final String studentId;

  const _LastLessonHint({required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsRepo = ref.watch(lessonsRepoProvider);
    return FutureBuilder<List<Lesson>>(
      future: lessonsRepo.getLessonsByStudent(studentId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final lesson = snapshot.data!.first;
        final date = lesson.startDateTime;
        final formatted = '${date.day}.${date.month}.${date.year}';
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${StringsTr.lastLessonDate}: $formatted',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        );
      },
    );
  }
}
