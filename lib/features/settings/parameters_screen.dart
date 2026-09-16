import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/features/settings/profile_screen.dart';
import 'package:ozel_ders_takip/shared/constants/curriculum_folders.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';
import 'package:ozel_ders_takip/shared/utils/name_format.dart';

/// Ayarlar → Parametreler: Ders → Ünite → Konu → Kazanım yönetimi.
class ParametersScreen extends ConsumerStatefulWidget {
  const ParametersScreen({super.key});

  @override
  ConsumerState<ParametersScreen> createState() => _ParametersScreenState();
}

class _ParametersScreenState extends ConsumerState<ParametersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(curriculumRepoProvider).ensureDefaultCurriculum();
    });
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync =
        ref.watch(curriculumRepoProvider).watchSubjects();
    final profile = ref.watch(teacherProfileProvider).asData?.value;
    final visibleFolders = profile?.visibleFolders ?? const <String>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text(StringsTr.parameters),
        actions: [
          IconButton(
            tooltip: 'Varsayılan müfredatı tamamla',
            icon: const Icon(Icons.cloud_download_outlined),
            onPressed: () async {
              await ref.read(curriculumRepoProvider).ensureDefaultCurriculum();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Tüm branş müfredatları (TYT/AYT + 9–11) kontrol edildi',
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: StringsTr.addSubject,
            icon: const Icon(Icons.add),
            onPressed: () => _promptAdd(
              context,
              ref,
              title: StringsTr.addSubject,
              onSave: (name) =>
                  ref.read(curriculumRepoProvider).addSubject(name),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<CurriculumSubject>>(
        stream: subjectsAsync,
        builder: (context, snapshot) {
          final subjects = snapshot.data ?? [];
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (subjects.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      StringsTr.noSubjectsYet,
                      style: TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () async {
                        await ref
                            .read(curriculumRepoProvider)
                            .ensureDefaultCurriculum();
                      },
                      icon: const Icon(Icons.cloud_download_outlined),
                      label: const Text('Varsayılan müfredatı yükle'),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () => _promptAdd(
                        context,
                        ref,
                        title: StringsTr.addSubject,
                        onSave: (name) =>
                            ref.read(curriculumRepoProvider).addSubject(name),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text(StringsTr.addSubject),
                    ),
                  ],
                ),
              ),
            );
          }
          // Klasöre göre grupla (varsayılan: MATEMATİK)
          final byFolder = <String, List<CurriculumSubject>>{};
          for (final s in subjects) {
            final folder =
                (s.folder.trim().isEmpty) ? 'MATEMATİK' : s.folder.trim();
            byFolder.putIfAbsent(folder, () => []).add(s);
          }
          var folders = byFolder.keys.toList()
            ..sort(CurriculumFolders.compare);

          // Profilde seçili görünecek dersler varsa filtrele
          if (visibleFolders.isNotEmpty) {
            final allow = visibleFolders.toSet();
            folders = folders.where((f) => allow.contains(f)).toList();
          }

          if (folders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  visibleFolders.isNotEmpty
                      ? 'Seçili ders klasörlerinde içerik yok. Profil veya müfredat ayarlarını kontrol edin.'
                      : StringsTr.noSubjectsYet,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            itemCount: folders.length,
            itemBuilder: (context, i) {
              final folder = folders[i];
              final list = byFolder[folder]!;
              return _FolderTile(
                folder: folder,
                subjects: list,
                initiallyExpanded: false,
              );
            },
          );
        },
      ),
    );
  }
}

class _FolderTile extends StatelessWidget {
  const _FolderTile({
    required this.folder,
    required this.subjects,
    this.initiallyExpanded = false,
  });
  final String folder;
  final List<CurriculumSubject> subjects;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: ValueKey('folder-$folder-$initiallyExpanded'),
          initiallyExpanded: initiallyExpanded,
          leading: const Icon(Icons.folder, color: AppColors.primary),
          title: Text(
            folder,
            style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.3),
          ),
          subtitle: Text(
            '${subjects.length} ders',
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
              child: Column(
                children: subjects
                    .map((s) => _SubjectTile(subject: s))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectTile extends ConsumerWidget {
  const _SubjectTile({required this.subject});
  final CurriculumSubject subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(curriculumRepoProvider);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          leading: const Icon(Icons.school_outlined, color: AppColors.primary),
          title: Text(
            subject.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: const Text(StringsTr.curriculumSubject),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                tooltip: StringsTr.addUnit,
                onPressed: () => _promptAdd(
                  context,
                  ref,
                  title: StringsTr.addUnit,
                  onSave: (name) => repo.addUnit(
                    subjectId: subject.id,
                    name: name,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: () => _promptEdit(
                  context,
                  ref,
                  title: StringsTr.curriculumSubject,
                  initial: subject.name,
                  onSave: (name) => repo.renameSubject(subject.id, name),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                onPressed: () => _confirmDelete(
                  context,
                  message: '"${subject.name}" dersi ve altındaki tüm kayıtlar silinecek.',
                  onConfirm: () => repo.deleteSubject(subject.id),
                ),
              ),
            ],
          ),
          children: [
            StreamBuilder<List<CurriculumUnit>>(
              stream: repo.watchUnits(subject.id),
              builder: (context, snap) {
                final units = snap.data ?? [];
                if (units.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      'Ünite yok — + ile ekleyin',
                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                  );
                }
                return Column(
                  children: units
                      .map((u) => _UnitTile(unit: u))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitTile extends ConsumerWidget {
  const _UnitTile({required this.unit});
  final CurriculumUnit unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(curriculumRepoProvider);
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 4, bottom: 4),
      child: Card(
        color: AppColors.surfaceElevated,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: false,
            leading: const Icon(Icons.folder_outlined, color: AppColors.accent, size: 22),
            title: Text(unit.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text(StringsTr.curriculumUnit, style: TextStyle(fontSize: 12)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  tooltip: StringsTr.addTopic,
                  onPressed: () => _promptAdd(
                    context,
                    ref,
                    title: StringsTr.addTopic,
                    onSave: (name) =>
                        repo.addTopic(unitId: unit.id, name: name),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  onPressed: () => _promptEdit(
                    context,
                    ref,
                    title: StringsTr.curriculumUnit,
                    initial: unit.name,
                    onSave: (name) => repo.renameUnit(unit.id, name),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                  onPressed: () => _confirmDelete(
                    context,
                    message: '"${unit.name}" ünitesi ve altındaki konular silinecek.',
                    onConfirm: () => repo.deleteUnit(unit.id),
                  ),
                ),
              ],
            ),
            children: [
              StreamBuilder<List<CurriculumTopic>>(
                stream: repo.watchTopics(unit.id),
                builder: (context, snap) {
                  final topics = snap.data ?? [];
                  if (topics.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        'Konu yok — + ile ekleyin',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    );
                  }
                  return Column(
                    children: topics.map((t) => _TopicTile(topic: t)).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicTile extends ConsumerWidget {
  const _TopicTile({required this.topic});
  final CurriculumTopic topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(curriculumRepoProvider);
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 4, bottom: 4),
      child: Card(
        color: AppColors.primarySoft,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: false,
            leading: const Icon(Icons.menu_book_outlined, color: AppColors.warning, size: 20),
            title: Text(topic.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: const Text(StringsTr.curriculumTopic, style: TextStyle(fontSize: 11)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  tooltip: StringsTr.addOutcome,
                  onPressed: () => _promptAdd(
                    context,
                    ref,
                    title: StringsTr.addOutcome,
                    onSave: (name) =>
                        repo.addOutcome(topicId: topic.id, name: name),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  onPressed: () => _promptEdit(
                    context,
                    ref,
                    title: StringsTr.curriculumTopic,
                    initial: topic.name,
                    onSave: (name) => repo.renameTopic(topic.id, name),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                  onPressed: () => _confirmDelete(
                    context,
                    message: '"${topic.name}" konusu ve kazanımları silinecek.',
                    onConfirm: () => repo.deleteTopic(topic.id),
                  ),
                ),
              ],
            ),
            children: [
              StreamBuilder<List<CurriculumOutcome>>(
                stream: repo.watchOutcomes(topic.id),
                builder: (context, snap) {
                  final outcomes = snap.data ?? [];
                  if (outcomes.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        'Kazanım yok — + ile ekleyin',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    );
                  }
                  return Column(
                    children: outcomes
                        .map(
                          (o) => ListTile(
                            dense: true,
                            leading: const Icon(
                              Icons.check_circle_outline,
                              size: 18,
                              color: AppColors.success,
                            ),
                            title: Text(o.name, style: const TextStyle(fontSize: 13)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 16),
                                  onPressed: () => _promptEdit(
                                    context,
                                    ref,
                                    title: StringsTr.curriculumOutcome,
                                    initial: o.name,
                                    onSave: (name) =>
                                        repo.renameOutcome(o.id, name),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 16,
                                    color: AppColors.danger,
                                  ),
                                  onPressed: () => _confirmDelete(
                                    context,
                                    message: '"${o.name}" kazanımı silinecek.',
                                    onConfirm: () => repo.deleteOutcome(o.id),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _promptAdd(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required Future<void> Function(String name) onSave,
}) async {
  final controller = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'Ad...'),
        onSubmitted: (_) => Navigator.pop(ctx, true),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(StringsTr.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text(StringsTr.save),
        ),
      ],
    ),
  );
  final name = formatTurkishText(controller.text);
  controller.dispose();
  if (ok == true && name.isNotEmpty) {
    await onSave(name);
  }
}

Future<void> _promptEdit(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required String initial,
  required Future<void> Function(String name) onSave,
}) async {
  final controller = TextEditingController(text: initial);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('$title düzenle'),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (_) => Navigator.pop(ctx, true),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(StringsTr.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text(StringsTr.save),
        ),
      ],
    ),
  );
  final name = formatTurkishText(controller.text);
  controller.dispose();
  if (ok == true && name.isNotEmpty) {
    await onSave(name);
  }
}

Future<void> _confirmDelete(
  BuildContext context, {
  required String message,
  required Future<void> Function() onConfirm,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Silinsin mi?'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(StringsTr.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text(StringsTr.delete),
        ),
      ],
    ),
  );
  if (ok == true) await onConfirm();
}
