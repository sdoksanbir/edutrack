import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/features/homework/homework_helpers.dart';
import 'package:ozel_ders_takip/features/homework/widgets/homework_item_tile.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';
import 'package:ozel_ders_takip/shared/utils/whatsapp_share.dart';

class LessonHomeworkScreen extends ConsumerWidget {
  final String studentId;
  final String studentName;
  final String lessonId;
  final DateTime assignedAt;
  final bool attentionOnly;

  const LessonHomeworkScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.lessonId,
    required this.assignedAt,
    this.attentionOnly = false,
  });

  Future<void> _sendWhatsApp(
    BuildContext context,
    WidgetRef ref,
    List<HomeworkItem> items,
  ) async {
    final student =
        await ref.read(studentsRepoProvider).getStudentById(studentId);
    if (!context.mounted) return;

    final message = buildHomeworkItemsWhatsAppMessage(
      studentName: studentName,
      lessonDate: assignedAt,
      items: items,
    );

    await sendWhatsAppMessage(
      context: context,
      message: message,
      phone: student?.phone,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsStream = ref.watch(homeworkRepoProvider).watchByLesson(lessonId);

    return Scaffold(
      appBar: AppBar(
        title: Text(formatHomeworkDateLong(assignedAt)),
        actions: [
          StreamBuilder<List<HomeworkItem>>(
            stream: itemsStream,
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              if (items.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
                tooltip: StringsTr.sendWhatsApp,
                onPressed: () => _sendWhatsApp(context, ref, items),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: itemsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('${StringsTr.errorPrefix}${snapshot.error}'),
            );
          }

          var items = snapshot.data ?? [];
          if (attentionOnly) {
            items = items.where(homeworkItemNeedsAttention).toList();
          }

          if (items.isEmpty) {
            return Center(
              child: Text(
                attentionOnly
                    ? 'Takip gereken ödev yok'
                    : StringsTr.noHomeworksYet,
                style: TextStyle(color: AppColors.muted),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return HomeworkItemTile(
                key: ValueKey(items[index].id),
                item: items[index],
                studentName: studentName,
              );
            },
          );
        },
      ),
    );
  }
}
