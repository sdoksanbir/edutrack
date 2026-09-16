import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ozel_ders_takip/app/router.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/data/repositories/homework_repo.dart';
import 'package:ozel_ders_takip/features/homework/widgets/extra_homework_sheet.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';

class HomeworkScreen extends ConsumerStatefulWidget {
  const HomeworkScreen({super.key});

  @override
  ConsumerState<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends ConsumerState<HomeworkScreen> {
  @override
  void initState() {
    super.initState();
    // Ağır backfill sadece bir kez, arka planda (her açılışta değil).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeworkRepoProvider).ensureMigratedOnce();
    });
  }

  @override
  Widget build(BuildContext context) {
    final studentsRepo = ref.watch(studentsRepoProvider);
    final studentsStream = studentsRepo.watchAllStudents(includeInactive: false);
    final summariesAsync = ref.watch(homeworkStudentSummariesProvider);
    final alertCount = ref.watch(homeworkAlertCountProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: StringsTr.back,
          onPressed: () => context.go(AppRouter.home),
        ),
        title: const Text(StringsTr.homeworksMenuTitle),
        actions: [
          IconButton(
            tooltip: StringsTr.todosTitle,
            icon: const Icon(Icons.checklist_rtl_outlined),
            onPressed: () => context.push(AppRouter.todos),
          ),
        ],
      ),
      body: Column(
        children: [
          if (alertCount > 0)
            MaterialBanner(
              backgroundColor: AppColors.warning.withValues(alpha: 0.15),
              content: Text(
                '$alertCount ${StringsTr.homeworkAlertCount}: ${StringsTr.homeworkAlertBanner}',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              leading:
                  Icon(Icons.warning_amber_rounded, color: AppColors.warning),
              actions: const [SizedBox(width: 8)],
            ),
          Expanded(
            child: StreamBuilder<List<Student>>(
              stream: studentsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('${StringsTr.errorPrefix}${snapshot.error}'),
                  );
                }
                final students = snapshot.data ?? [];
                if (students.isEmpty) {
                  return Center(
                    child: Text(
                      StringsTr.noStudentsYet,
                      style: TextStyle(color: AppColors.muted),
                    ),
                  );
                }

                final summaries = summariesAsync.value ?? {};

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final summary = summaries[student.id];
                    return _StudentHomeworkCard(
                      student: student,
                      summary: summary,
                      onTap: () => context.push(
                        '${AppRouter.homeworks}/student/${student.id}',
                        extra: student.fullName,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showExtraHomeworkSheet(context, ref),
        icon: const Icon(Icons.note_add_outlined),
        label: const Text(StringsTr.extraHomeworkTitle),
      ),
    );
  }
}

class _StudentHomeworkCard extends StatelessWidget {
  final Student student;
  final StudentHomeworkSummary? summary;
  final VoidCallback onTap;

  const _StudentHomeworkCard({
    required this.student,
    required this.summary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final total = summary?.totalCount ?? 0;
    final alerts = summary?.alertCount ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: alerts > 0
              ? AppColors.warning.withValues(alpha: 0.6)
              : AppColors.border,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.primarySoft,
          child: Text(
            student.fullName.isNotEmpty
                ? student.fullName[0].toUpperCase()
                : '?',
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
        subtitle: Text(
          total == 0 ? StringsTr.noHomeworksYet : '$total ödev',
          style: TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        trailing: alerts > 0
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$alerts ${StringsTr.homeworkAlertCount}',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              )
            : const Icon(Icons.chevron_right, color: AppColors.muted),
      ),
    );
  }
}
