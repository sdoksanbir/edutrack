import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/features/settings/profile_screen.dart';
import 'package:ozel_ders_takip/features/students/widgets/student_book_resource_dialog.dart';
import 'package:ozel_ders_takip/shared/constants/curriculum_folders.dart';
import 'package:ozel_ders_takip/shared/constants/student_grade_levels.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';
import 'package:ozel_ders_takip/shared/models/homework_assignment.dart';
import 'package:ozel_ders_takip/shared/utils/name_format.dart';

export 'package:ozel_ders_takip/shared/models/homework_assignment.dart';

/// Ödev satırları: anlatılan konular önce, her satır numaralı.
List<String> buildHomeworkSummaryLines(
  List<HomeworkResourceAssignment> items, {
  List<String> taughtTopics = const [],
}) {
  final taughtSet = taughtTopics.toSet();
  final topicEntries = <({String topic, String line, String note})>[];
  final denemeLines = <String>[];

  for (final e in items) {
    if (e.isPractice && e.denemeNo != null) {
      denemeLines.add('${e.resource}: Deneme ${e.denemeNo}');
      continue;
    }
    for (final entry in e.topicEntries) {
      topicEntries.add((
        topic: entry.topic,
        line: '${e.resource}: ${entry.topic}',
        note: entry.note.trim(),
      ));
    }
  }

  final ordered = <({String line, String note})>[];
  for (final topic in taughtTopics) {
    for (final entry in topicEntries) {
      if (entry.topic == topic) {
        ordered.add((line: entry.line, note: entry.note));
      }
    }
  }
  for (final entry in topicEntries) {
    if (!taughtSet.contains(entry.topic)) {
      ordered.add((line: entry.line, note: entry.note));
    }
  }
  for (final line in denemeLines) {
    ordered.add((line: line, note: ''));
  }

  return ordered.asMap().entries.map((e) {
    final item = e.value;
    final numbered = '${e.key + 1}. ${item.line}';
    if (item.note.isEmpty) return numbered;
    return '$numbered\n${item.note}';
  }).toList();
}

/// Ödev alanında okunabilir özet (numaralı, alt alta).
String formatHomeworkSummary(
  List<HomeworkResourceAssignment> items, {
  List<String> taughtTopics = const [],
}) {
  return buildHomeworkSummaryLines(
    items,
    taughtTopics: taughtTopics,
  ).join('\n');
}

List<HomeworkTopicEntry> _orderTopicEntries(
  List<HomeworkTopicEntry> entries,
  List<String> taughtTopics,
) {
  final taughtSet = taughtTopics.toSet();
  final byTopic = {for (final e in entries) e.topic: e};
  final ordered = <HomeworkTopicEntry>[
    for (final topic in taughtTopics)
      if (byTopic.containsKey(topic)) byTopic[topic]!,
    ...entries.where((e) => !taughtSet.contains(e.topic)),
  ];
  return ordered;
}

/// Tek kaynak için numaralı ödev satırları (Kaynak: Konu + açıklama).
List<String> buildResourceHomeworkLines(
  String resource,
  List<HomeworkTopicEntry> entries, {
  List<String> taughtTopics = const [],
}) {
  if (entries.isEmpty) return [];
  return _orderTopicEntries(entries, taughtTopics).asMap().entries.map((e) {
    final entry = e.value;
    final numbered = '${e.key + 1}. $resource: ${entry.topic}';
    final note = entry.note.trim();
    if (note.isEmpty) return numbered;
    return '$numbered\n$note';
  }).toList();
}

/// Konu (çoklu sistem / kendim) + Ödev + Kaynak listesi (kaynak başına konu).
class LessonHomeworkFields extends ConsumerStatefulWidget {
  const LessonHomeworkFields({
    super.key,
    required this.studentId,
    required this.topicController,
    required this.homeworkController,
    required this.resourceController,
    this.compact = false,
    this.showTaughtTopics = true,
    this.onFormatTopic,
    this.onFormatHomework,
    this.onFormatResource,
  });

  final String studentId;
  final TextEditingController topicController;
  final TextEditingController homeworkController;
  final TextEditingController resourceController;
  final bool compact;
  /// false ise yalnızca ödev / kaynak seçimi gösterilir.
  final bool showTaughtTopics;
  final VoidCallback? onFormatTopic;
  final VoidCallback? onFormatHomework;
  final VoidCallback? onFormatResource;

  @override
  ConsumerState<LessonHomeworkFields> createState() =>
      _LessonHomeworkFieldsState();
}

class _LessonHomeworkFieldsState extends ConsumerState<LessonHomeworkFields> {
  bool _customTopic = false;
  bool _customResource = false;
  bool _customHomework = false;
  List<String> _taughtTopics = [];
  List<String> _topicResources = [];
  List<String> _practiceResources = [];
  /// konu anlatımlı kaynak → seçili konular + açıklama
  final Map<String, List<HomeworkTopicEntry>> _resourceTopics = {};
  /// deneme kaynak → seçili deneme noları
  final Map<String, Set<int>> _denemeSelections = {};
  /// Daha önce ödev olarak verilmiş deneme noları (yeşil gösterim)
  final Map<String, Set<int>> _previouslyAssignedDenemes = {};
  bool _loadingResources = true;

  @override
  void initState() {
    super.initState();
    _taughtTopics = parseTaughtTopics(widget.topicController.text);
    _customHomework = false;
    _applySavedAssignments();
    _loadResources();
  }

  void _applySavedAssignments() {
    final assignments =
        parseHomeworkResourceAssignments(widget.resourceController.text);
    _resourceTopics.clear();
    _denemeSelections.clear();
    for (final a in assignments) {
      if (a.isPractice) {
        if (a.denemeNo != null) {
          _denemeSelections
              .putIfAbsent(a.resource, () => <int>{})
              .add(a.denemeNo!);
        }
      } else if (a.topicEntries.isNotEmpty) {
        _resourceTopics[a.resource] = a.topicEntries
            .map(
              (e) => HomeworkTopicEntry(
                topic: e.topic,
                note: formatTurkishNoteText(e.note),
              ),
            )
            .toList();
      }
    }
  }

  String? _matchResourceName(String name, List<String> knownResources) {
    for (final resource in knownResources) {
      if (resource.toLowerCase() == name.toLowerCase()) return resource;
    }
    return null;
  }

  void _reconcileResourceKeys() {
    final known = [..._topicResources, ..._practiceResources];
    final remappedTopics = <String, List<HomeworkTopicEntry>>{};
    for (final entry in _resourceTopics.entries) {
      final key = _matchResourceName(entry.key, _topicResources) ?? entry.key;
      remappedTopics[key] = entry.value;
    }
    _resourceTopics
      ..clear()
      ..addAll(remappedTopics);

    final remappedDenemes = <String, Set<int>>{};
    for (final entry in _denemeSelections.entries) {
      final key = _matchResourceName(entry.key, _practiceResources) ?? entry.key;
      remappedDenemes.putIfAbsent(key, () => <int>{}).addAll(entry.value);
    }
    _denemeSelections
      ..clear()
      ..addAll(remappedDenemes);

    for (final name in _practiceResources) {
      _denemeSelections.putIfAbsent(name, () => <int>{});
    }

    // Artık listede olmayan kaynak anahtarlarını temizle
    _denemeSelections.removeWhere(
      (k, _) =>
          _matchResourceName(k, _practiceResources) == null &&
          !_practiceResources.contains(k),
    );

    final assignedNames = [
      ..._resourceTopics.keys,
      ..._denemeSelections.entries
          .where((e) => e.value.isNotEmpty)
          .map((e) => e.key),
    ];
    if (assignedNames.isNotEmpty &&
        assignedNames.every((n) => !known.contains(n))) {
      _customResource = true;
    }
  }

  Future<void> _loadResources() async {
    try {
      final student =
          await ref.read(studentsRepoProvider).getStudentById(widget.studentId);
      final previous = await ref
          .read(homeworkRepoProvider)
          .getAssignedDenemeNumbers(widget.studentId);
      if (!mounted) return;
      final topicList = parseStudentBookResources(student?.bookResource);
      final practiceList =
          parseStudentBookResources(student?.bookResourcePractice);
      setState(() {
        _topicResources = topicList;
        _practiceResources = practiceList;
        _previouslyAssignedDenemes.clear();
        for (final entry in previous.entries) {
          final key =
              _matchResourceName(entry.key, practiceList) ?? entry.key;
          _previouslyAssignedDenemes
              .putIfAbsent(key, () => <int>{})
              .addAll(entry.value);
        }
        _loadingResources = false;
        _reconcileResourceKeys();
        _syncResourceController();
        _syncHomeworkSummary();
      });
    } catch (_) {
      if (mounted) setState(() => _loadingResources = false);
    }
  }

  void _syncTopicsController() {
    widget.topicController.text = joinTaughtTopics(_taughtTopics);
    widget.onFormatTopic?.call();
  }

  void _syncResourceController() {
    final items = collectHomeworkResourceAssignments(
      resourceTopics: _resourceTopics,
      denemeSelections: _denemeSelections,
    );
    widget.resourceController.text = joinHomeworkResourceAssignments(items);
  }

  void _syncHomeworkSummary() {
    if (_customHomework) return;
    final items = collectHomeworkResourceAssignments(
      resourceTopics: _resourceTopics,
      denemeSelections: _denemeSelections,
    );
    widget.homeworkController.text = formatHomeworkSummary(
      items,
      taughtTopics: _taughtTopics,
    );
  }

  List<String> get _homeworkSummaryLines => buildHomeworkSummaryLines(
        _homeworkAssignments,
        taughtTopics: _taughtTopics,
      );

  List<HomeworkResourceAssignment> get _homeworkAssignments =>
      collectHomeworkResourceAssignments(
        resourceTopics: _resourceTopics,
        denemeSelections: _denemeSelections,
      );

  bool get _hasHomeworkAssignments => _homeworkAssignments.isNotEmpty;

  Future<void> _addTaughtTopicFromSystem() async {
    final student =
        await ref.read(studentsRepoProvider).getStudentById(widget.studentId);
    if (!mounted) return;
    final picked = await showCurriculumMultiTopicPicker(
      context,
      ref,
      initiallySelected: _taughtTopics,
      gradeLevel: student?.gradeLevel,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _customTopic = false;
      _taughtTopics = picked;
    });
    _syncTopicsController();
    _syncHomeworkSummary();
  }

  void _removeTaughtTopic(String topic) {
    setState(() {
      _taughtTopics = _taughtTopics.where((t) => t != topic).toList();
      for (final key in _resourceTopics.keys.toList()) {
        _resourceTopics[key] =
            _resourceTopics[key]!.where((e) => e.topic != topic).toList();
        if (_resourceTopics[key]!.isEmpty) _resourceTopics.remove(key);
      }
    });
    _syncTopicsController();
    _syncResourceController();
    _syncHomeworkSummary();
  }

  void _enableCustomTopic() {
    setState(() => _customTopic = true);
  }

  void _backFromCustomTopic() {
    setState(() {
      _customTopic = false;
      _taughtTopics = parseTaughtTopics(widget.topicController.text);
    });
  }

  void _enableCustomHomework() {
    setState(() => _customHomework = true);
  }

  void _backFromCustomHomework() {
    setState(() {
      _customHomework = false;
      _syncHomeworkSummary();
    });
  }

  void _enableCustomResource() {
    setState(() => _customResource = true);
  }

  void _backFromCustomResource() {
    setState(() {
      _customResource = false;
      widget.resourceController.clear();
      _resourceTopics.clear();
      _denemeSelections
          .removeWhere((k, _) => !_practiceResources.contains(k));
      for (final name in _practiceResources) {
        _denemeSelections.putIfAbsent(name, () => <int>{}).clear();
      }
    });
    _syncResourceController();
    _syncHomeworkSummary();
  }

  Future<void> _assignTopicsToResource(String resource) async {
    final current =
        List<HomeworkTopicEntry>.from(_resourceTopics[resource] ?? const []);
    final student =
        await ref.read(studentsRepoProvider).getStudentById(widget.studentId);
    if (!mounted) return;
    final selected = await showModalBottomSheet<List<HomeworkTopicEntry>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ResourceTopicPickSheet(
        resourceName: resource,
        taughtTopics: _taughtTopics,
        initiallySelected: current,
        gradeLevel: student?.gradeLevel,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (selected.isEmpty) {
        _resourceTopics.remove(resource);
      } else {
        _resourceTopics[resource] = selected;
      }
    });
    _syncResourceController();
    _syncHomeworkSummary();
  }

  Future<void> _pickDenemeNumber(String resource) async {
    final current = Set<int>.from(_denemeSelections[resource] ?? const {});
    final previously =
        _previouslyAssignedDenemes[resource] ?? const <int>{};
    final picked = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _DenemeNumberSheet(
        initial: current,
        previouslyAssigned: previously,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _denemeSelections[resource] = picked;
    });
    _syncResourceController();
    _syncHomeworkSummary();
  }

  InputDecoration _decoration({required String label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: AppColors.surface,
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.muted,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  /// Ortada, bar şeklinde belirgin bölüm başlığı.
  Widget _centerBarTitle(
    String title, {
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (trailing != null) trailing else const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _numberedHomeworkText(String line, {double fontSize = 13}) {
    final parts = line.split('\n');
    final first = parts.first.trimLeft();
    final match = RegExp(r'^(\d+\.\s*)(.*)$').firstMatch(first);
    final bullet = match?.group(1) ?? '';
    final body = (match?.group(2) ?? first).trimLeft();
    final notes = parts
        .skip(1)
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final bodyStyle = TextStyle(
      fontSize: fontSize,
      height: 1.35,
      color: AppColors.textPrimary,
    );
    final bulletStyle = bodyStyle.copyWith(fontWeight: FontWeight.w600);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bullet.isNotEmpty) Text(bullet, style: bulletStyle),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(body, style: bodyStyle),
                for (final note in notes)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      note,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: AppColors.muted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topicResourceCard(String name) {
    final entries = _resourceTopics[name] ?? const <HomeworkTopicEntry>[];
    final selected = entries.isNotEmpty;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 4, 6, 4),
      decoration: BoxDecoration(
        color: selected ? AppColors.primarySoft : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.45)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            tooltip: StringsTr.pickTopicsForResource,
            onPressed: () => _assignTopicsToResource(name),
            icon: Icon(
              Icons.add_circle,
              color: selected ? AppColors.primary : AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _homeworkSummaryLine(String line) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: _numberedHomeworkText(line),
    );
  }

  Widget _taughtTopicLine(int index, String topic) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${index + 1}. $topic',
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          InkWell(
            onTap: () => _removeTaughtTopic(topic),
            borderRadius: BorderRadius.circular(16),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 16, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _denemeResourceCard(String name) {
    final nos = (_denemeSelections[name] ?? const <int>{}).toList()..sort();
    final selected = nos.isNotEmpty;
    final previous = _previouslyAssignedDenemes[name] ?? const <int>{};
    final label = selected ? nos.join(', ') : StringsTr.denemeNumberEmpty;
    final allPreviouslyAssigned =
        selected && nos.every(previous.contains);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.warningSoft : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? AppColors.warning.withValues(alpha: 0.45)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          InkWell(
            onTap: () => _pickDenemeNumber(name),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              constraints: const BoxConstraints(minWidth: 72, maxWidth: 140),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: !selected
                      ? AppColors.muted
                      : allPreviouslyAssigned
                          ? AppColors.success
                          : AppColors.warning,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gap = widget.compact ? 12.0 : 16.0;
    final hasAnyResource =
        _topicResources.isNotEmpty || _practiceResources.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTaughtTopics) ...[
          _sectionCard(
            children: [
              _centerBarTitle(
                StringsTr.taughtTopicsLabel,
                trailing: _customTopic
                    ? IconButton(
                        tooltip: StringsTr.back,
                        onPressed: _backFromCustomTopic,
                        icon: const Icon(Icons.arrow_back, size: 18),
                        color: AppColors.muted,
                        visualDensity: VisualDensity.compact,
                      )
                    : TextButton(
                        onPressed: _enableCustomTopic,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text(
                          StringsTr.defineMyself,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 10),
              if (_customTopic)
                TextField(
                  controller: widget.topicController,
                  decoration: _decoration(
                    label: StringsTr.curriculumTopic,
                    hint: StringsTr.customTopicHint,
                  ),
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) {
                    _taughtTopics =
                        parseTaughtTopics(widget.topicController.text);
                  },
                  onEditingComplete: () {
                    _taughtTopics =
                        parseTaughtTopics(widget.topicController.text);
                    widget.onFormatTopic?.call();
                  },
                  onTapOutside: (_) {
                    _taughtTopics =
                        parseTaughtTopics(widget.topicController.text);
                    widget.onFormatTopic?.call();
                  },
                )
              else ...[
                if (_taughtTopics.isNotEmpty)
                  ..._taughtTopics.asMap().entries.map(
                        (e) => _taughtTopicLine(e.key, e.value),
                      ),
                if (_taughtTopics.isNotEmpty) const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _addTaughtTopicFromSystem,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                    _taughtTopics.isEmpty
                        ? StringsTr.pickTopicFromSystem
                        : StringsTr.addTopicAction,
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: gap),
        ],
        _sectionCard(
          children: [
            _centerBarTitle(
              StringsTr.homeworkLabel,
              trailing: _customHomework
                  ? IconButton(
                      tooltip: StringsTr.back,
                      onPressed: _backFromCustomHomework,
                      icon: const Icon(Icons.arrow_back, size: 18),
                      color: AppColors.muted,
                      visualDensity: VisualDensity.compact,
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    StringsTr.bookResourceLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                  ),
                ),
                if (_customResource)
                  TextButton.icon(
                    onPressed: _backFromCustomResource,
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text(StringsTr.back),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.muted,
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                else
                  TextButton(
                    onPressed: _enableCustomResource,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text(
                      StringsTr.defineMyself,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_customResource)
              TextField(
                controller: widget.resourceController,
                decoration: _decoration(
                  label: StringsTr.homeworkResourceLabel,
                  hint: StringsTr.customResourceHint,
                ),
                textCapitalization: TextCapitalization.sentences,
                onEditingComplete: widget.onFormatResource,
                onTapOutside: (_) => widget.onFormatResource?.call(),
              )
            else if (_loadingResources)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              )
            else if (!hasAnyResource)
              const Text(
                StringsTr.noStudentResources,
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              )
            else ...[
              if (_topicResources.isNotEmpty) ...[
                _sectionLabel(StringsTr.bookResourceTopicLabel),
                ..._topicResources.map(_topicResourceCard),
              ],
              if (_practiceResources.isNotEmpty) ...[
                _sectionLabel(StringsTr.bookResourcePracticeLabel),
                ..._practiceResources.map(_denemeResourceCard),
              ],
            ],
            const SizedBox(height: 12),
            if (_customHomework) ...[
              TextField(
                controller: widget.homeworkController,
                decoration: _decoration(
                  label: StringsTr.homeworkLabel,
                  hint: 'Verilen ödev...',
                ),
                minLines: 2,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onEditingComplete: widget.onFormatHomework,
                onTapOutside: (_) => widget.onFormatHomework?.call(),
              ),
            ] else ...[
              _sectionLabel(StringsTr.selectedHomeworkLabel),
              if (_hasHomeworkAssignments)
                ..._homeworkSummaryLines.map(_homeworkSummaryLine)
              else
                const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(
                    StringsTr.noHomeworkSelected,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _enableCustomHomework,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text(
                    StringsTr.defineMyself,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Ödev açıklaması yazarken kelime başlarını Türkçe kurallarla büyütür.
class _TurkishNoteInputFormatter extends TextInputFormatter {
  const _TurkishNoteInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = toTurkishNoteTextLive(newValue.text);
    if (formatted == newValue.text) return newValue;
    final base = newValue.selection.baseOffset.clamp(0, formatted.length);
    final extent = newValue.selection.extentOffset.clamp(0, formatted.length);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection(baseOffset: base, extentOffset: extent),
      composing: TextRange.empty,
    );
  }
}

class _DenemeNumberSheet extends StatefulWidget {
  const _DenemeNumberSheet({
    this.initial = const {},
    this.previouslyAssigned = const {},
  });

  final Set<int> initial;
  final Set<int> previouslyAssigned;

  @override
  State<_DenemeNumberSheet> createState() => _DenemeNumberSheetState();
}

class _DenemeNumberSheetState extends State<_DenemeNumberSheet> {
  late final Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<int>.from(widget.initial);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              StringsTr.pickDenemeNumber,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => setState(() => _selected.clear()),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
              ),
              child: const Text(StringsTr.denemeNumberEmpty),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 280,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.2,
                ),
                itemCount: 40,
                itemBuilder: (context, i) {
                  final n = i + 1;
                  final selected = _selected.contains(n);
                  final prior = widget.previouslyAssigned.contains(n);
                  final Color bg;
                  final Color fg;
                  if (selected && prior) {
                    bg = AppColors.successSoft;
                    fg = AppColors.success;
                  } else if (selected) {
                    bg = AppColors.warningSoft;
                    fg = AppColors.warning;
                  } else if (prior) {
                    bg = AppColors.successSoft;
                    fg = AppColors.success;
                  } else {
                    bg = AppColors.surfaceElevated;
                    fg = AppColors.textPrimary;
                  }
                  return Material(
                    color: bg,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        setState(() {
                          if (selected) {
                            _selected.remove(n);
                          } else {
                            _selected.add(n);
                          }
                        });
                      },
                      child: Center(
                        child: Text(
                          '$n',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: fg,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pop(context, Set<int>.from(_selected)),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text(StringsTr.ok),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceTopicPickSheet extends ConsumerStatefulWidget {
  const _ResourceTopicPickSheet({
    required this.resourceName,
    required this.taughtTopics,
    required this.initiallySelected,
    this.gradeLevel,
  });

  final String resourceName;
  final List<String> taughtTopics;
  final List<HomeworkTopicEntry> initiallySelected;
  final String? gradeLevel;

  @override
  ConsumerState<_ResourceTopicPickSheet> createState() =>
      _ResourceTopicPickSheetState();
}

class _ResourceTopicPickSheetState extends ConsumerState<_ResourceTopicPickSheet> {
  late final Set<String> _selected;
  final Map<String, TextEditingController> _noteControllers = {};

  @override
  void initState() {
    super.initState();
    _selected = widget.initiallySelected.map((e) => e.topic).toSet();
    for (final entry in widget.initiallySelected) {
      _noteControllers[entry.topic] = TextEditingController(
        text: formatTurkishNoteText(entry.note),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _noteControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String topic) {
    return _noteControllers.putIfAbsent(
      topic,
      () => TextEditingController(),
    );
  }

  void _removeNoteController(String topic) {
    _noteControllers.remove(topic)?.dispose();
  }

  List<String> _selectedTopicsOrdered() {
    final taught = widget.taughtTopics.where(_selected.contains).toList();
    final rest = _selected.where((t) => !widget.taughtTopics.contains(t)).toList()
      ..sort();
    return [...taught, ...rest];
  }

  List<HomeworkTopicEntry> _buildResult() {
    return _selectedTopicsOrdered()
        .map(
          (topic) => HomeworkTopicEntry(
            topic: topic,
            note: formatTurkishNoteText(
              _noteControllers[topic]?.text ?? '',
            ),
          ),
        )
        .toList();
  }

  void _toggleTopic(String topic, bool? checked) {
    setState(() {
      if (checked == true) {
        _selected.add(topic);
        _controllerFor(topic);
      } else {
        _selected.remove(topic);
        _removeNoteController(topic);
      }
    });
  }

  void _toggleTopicFromCurriculum(String topic) {
    if (topic.trim().isEmpty) return;
    setState(() {
      if (_selected.contains(topic)) {
        _selected.remove(topic);
        _removeNoteController(topic);
      } else {
        _selected.add(topic);
        _controllerFor(topic);
      }
    });
  }

  void _applyCurriculumDelta({
    Iterable<String> add = const [],
    Iterable<String> remove = const [],
  }) {
    setState(() {
      for (final t in remove) {
        _selected.remove(t);
        _removeNoteController(t);
      }
      for (final t in add) {
        if (t.trim().isEmpty) continue;
        _selected.add(t);
        _controllerFor(t);
      }
    });
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.muted,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              StringsTr.pickTopicsForResource,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.resourceName,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              StringsTr.multiSelectTopicsHint,
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 8),
            if (widget.taughtTopics.isNotEmpty) ...[
              _sectionHeader(StringsTr.taughtTopicsLabel),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: widget.taughtTopics.length > 4 ? 160 : 200,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: widget.taughtTopics.map((t) {
                    final checked = _selected.contains(t);
                    return CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: checked,
                      title: Text(t, style: const TextStyle(fontSize: 14)),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (v) => _toggleTopic(t, v),
                    );
                  }).toList(),
                ),
              ),
              const Divider(height: 24),
            ],
            _sectionHeader(StringsTr.topicsFromParameters),
            const SizedBox(height: 4),
            Expanded(
              flex: _selected.isEmpty ? 1 : 2,
              child: _CurriculumTopicBrowser(
                multiSelect: true,
                onPick: _toggleTopicFromCurriculum,
                onBulkChange: _applyCurriculumDelta,
                selectedTopics: _selected,
                gradeLevel: widget.gradeLevel,
              ),
            ),
            if (_selected.isNotEmpty) ...[
              const SizedBox(height: 8),
              _sectionHeader(StringsTr.selectedHomeworkLabel),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView(
                  shrinkWrap: true,
                  children: _selectedTopicsOrdered().map((topic) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  topic,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.close, size: 18),
                                color: AppColors.muted,
                                onPressed: () => _toggleTopic(topic, false),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _controllerFor(topic),
                            decoration: InputDecoration(
                              labelText: StringsTr.homeworkTopicNoteLabel,
                              hintText: StringsTr.homeworkTopicNoteHint,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: AppColors.surfaceElevated,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            minLines: 1,
                            maxLines: 3,
                            inputFormatters: const [_TurkishNoteInputFormatter()],
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(StringsTr.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(context, _buildResult()),
                  child: const Text(StringsTr.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Anlatılan konular için çoklu konu seçici.
Future<List<String>?> showCurriculumMultiTopicPicker(
  BuildContext context,
  WidgetRef ref, {
  List<String> initiallySelected = const [],
  String? gradeLevel,
}) async {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _CurriculumMultiTopicPickerSheet(
      initiallySelected: initiallySelected,
      gradeLevel: gradeLevel,
    ),
  );
}

class _CurriculumMultiTopicPickerSheet extends ConsumerStatefulWidget {
  const _CurriculumMultiTopicPickerSheet({
    this.initiallySelected = const [],
    this.gradeLevel,
  });

  final List<String> initiallySelected;
  final String? gradeLevel;

  @override
  ConsumerState<_CurriculumMultiTopicPickerSheet> createState() =>
      _CurriculumMultiTopicPickerSheetState();
}

class _CurriculumMultiTopicPickerSheetState
    extends ConsumerState<_CurriculumMultiTopicPickerSheet> {
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.initiallySelected);
  }

  void _toggleTopic(String topic) {
    if (topic.trim().isEmpty) return;
    setState(() {
      if (_selected.contains(topic)) {
        _selected.remove(topic);
      } else {
        _selected.add(topic);
      }
    });
  }

  void _applyDelta({
    Iterable<String> add = const [],
    Iterable<String> remove = const [],
  }) {
    setState(() {
      _selected.removeAll(remove);
      _selected.addAll(add.where((e) => e.trim().isNotEmpty));
    });
  }

  List<String> _orderedSelection() {
    final initial = widget.initiallySelected.where(_selected.contains).toList();
    final added = _selected
        .where((t) => !widget.initiallySelected.contains(t))
        .toList()
      ..sort();
    return [...initial, ...added];
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              StringsTr.pickTopicFromSystem,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            const Text(
              StringsTr.multiSelectTopicsHint,
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            if (widget.gradeLevel != null) ...[
              const SizedBox(height: 4),
              Text(
                StudentGradeLevels.labelFor(widget.gradeLevel) ?? '',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: _CurriculumTopicBrowser(
                multiSelect: true,
                onPick: _toggleTopic,
                onBulkChange: _applyDelta,
                selectedTopics: _selected,
                gradeLevel: widget.gradeLevel,
              ),
            ),
            if (_selected.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                StringsTr.selectedHomeworkLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _orderedSelection()
                    .map(
                      (t) => Chip(
                        label: Text(t, style: const TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: AppColors.primarySoft,
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => _toggleTopic(t),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(StringsTr.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(context, _orderedSelection()),
                  child: const Text(StringsTr.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Branş → (TYT/AYT/sınıf collapse) → ünite → konu(+checkbox) → kazanım(+checkbox).
class _CurriculumTopicBrowser extends ConsumerStatefulWidget {
  const _CurriculumTopicBrowser({
    required this.onPick,
    this.onBulkChange,
    this.selectedTopics = const {},
    this.multiSelect = false,
    this.gradeLevel,
  });

  final void Function(String topicLabel) onPick;
  final void Function({
    Iterable<String> add,
    Iterable<String> remove,
  })? onBulkChange;
  final Set<String> selectedTopics;
  final bool multiSelect;
  final String? gradeLevel;

  @override
  ConsumerState<_CurriculumTopicBrowser> createState() =>
      _CurriculumTopicBrowserState();
}

class _CurriculumTopicBrowserState
    extends ConsumerState<_CurriculumTopicBrowser> {
  CurriculumSubject? _subject;
  CurriculumUnit? _unit;
  CurriculumTopic? _topic;
  List<CurriculumSubject> _subjects = [];
  List<CurriculumUnit> _units = [];
  List<CurriculumTopic> _topics = [];
  List<CurriculumOutcome> _outcomes = [];
  final Map<String, List<CurriculumOutcome>> _outcomesByTopic = {};
  late Set<String> _expandedGroups;
  late Set<String> _expandedFolders;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _expandedGroups =
        StudentGradeLevels.defaultExpandedGroups(widget.gradeLevel);
    final profile = ref.read(teacherProfileProvider).asData?.value;
    final branches = profile?.branches ?? const <String>[];
    _expandedFolders = branches.isNotEmpty
        ? branches.toSet()
        : (profile?.visibleFolders.toSet() ?? <String>{});
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    await ref.read(curriculumRepoProvider).ensureDefaultCurriculum();
    final list = await ref.read(curriculumRepoProvider).getSubjects();
    if (!mounted) return;
    setState(() {
      _subjects = list
          .where(
            (s) => StudentGradeLevels.subjectMatchesGrade(
              s.name,
              widget.gradeLevel,
            ),
          )
          .toList();
      _loading = false;
    });
  }

  Future<void> _selectSubject(CurriculumSubject s) async {
    final units = await ref.read(curriculumRepoProvider).getUnits(s.id);
    if (!mounted) return;
    setState(() {
      _subject = s;
      _unit = null;
      _topic = null;
      _units = units;
      _topics = [];
      _outcomes = [];
      _outcomesByTopic.clear();
    });
  }

  Future<void> _selectUnit(CurriculumUnit u) async {
    final topics = await ref.read(curriculumRepoProvider).getTopics(u.id);
    final map = <String, List<CurriculumOutcome>>{};
    for (final t in topics) {
      map[t.id] = await ref.read(curriculumRepoProvider).getOutcomes(t.id);
    }
    if (!mounted) return;
    setState(() {
      _unit = u;
      _topic = null;
      _topics = topics;
      _outcomes = [];
      _outcomesByTopic
        ..clear()
        ..addAll(map);
    });
  }

  Future<void> _openTopic(CurriculumTopic t) async {
    final outcomes = _outcomesByTopic[t.id] ??
        await ref.read(curriculumRepoProvider).getOutcomes(t.id);
    if (!mounted) return;
    if (outcomes.isEmpty) {
      _toggleWholeTopic(t, outcomes);
      return;
    }
    setState(() {
      _topic = t;
      _outcomes = outcomes;
      _outcomesByTopic[t.id] = outcomes;
    });
  }

  List<String> _outcomeLabels(
    CurriculumTopic t,
    List<CurriculumOutcome> outs,
  ) =>
      outs.map((o) => '${t.name} — ${o.name}').toList();

  bool _isWholeTopicSelected(
    CurriculumTopic t,
    List<CurriculumOutcome> outs,
  ) {
    if (widget.selectedTopics.contains(t.name)) return true;
    if (outs.isEmpty) return false;
    final labels = _outcomeLabels(t, outs);
    return labels.every(widget.selectedTopics.contains);
  }

  bool _isOutcomeChecked(CurriculumTopic t, CurriculumOutcome o) {
    if (widget.selectedTopics.contains(t.name)) return true;
    return widget.selectedTopics.contains('${t.name} — ${o.name}');
  }

  void _toggleWholeTopic(CurriculumTopic t, List<CurriculumOutcome> outs) {
    final labels = _outcomeLabels(t, outs);
    final selected = _isWholeTopicSelected(t, outs);
    if (widget.onBulkChange != null) {
      if (selected) {
        widget.onBulkChange!(
          add: const [],
          remove: [t.name, ...labels],
        );
      } else {
        widget.onBulkChange!(
          add: [t.name],
          remove: labels,
        );
      }
      return;
    }
    widget.onPick(t.name);
  }

  void _toggleOutcome(CurriculumTopic t, CurriculumOutcome o) {
    final label = '${t.name} — ${o.name}';
    final outs = _outcomesByTopic[t.id] ?? _outcomes;
    final labels = _outcomeLabels(t, outs);
    final topicSelected = widget.selectedTopics.contains(t.name);
    final checked = _isOutcomeChecked(t, o);

    if (widget.onBulkChange != null) {
      if (checked) {
        if (topicSelected) {
          final keep = labels.where((l) => l != label).toList();
          widget.onBulkChange!(
            add: keep,
            remove: [t.name, label],
          );
        } else {
          widget.onBulkChange!(add: const [], remove: [label]);
        }
      } else {
        final next = {
          ...widget.selectedTopics.where((s) => s != t.name),
          label,
        };
        final allOn = labels.every(next.contains);
        if (allOn) {
          widget.onBulkChange!(
            add: [t.name],
            remove: labels,
          );
        } else {
          widget.onBulkChange!(add: [label], remove: const []);
        }
      }
      return;
    }
    widget.onPick(label);
  }

  Widget _backChip() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () {
          setState(() {
            if (_topic != null) {
              _topic = null;
              _outcomes = [];
            } else if (_unit != null) {
              _unit = null;
              _topics = [];
              _outcomesByTopic.clear();
            } else if (_subject != null) {
              _subject = null;
              _units = [];
            }
          });
        },
        icon: const Icon(Icons.arrow_back, size: 16),
        label: const Text(StringsTr.back),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          StringsTr.curriculumPickerHint,
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          [
            if (_subject != null) _subject!.name,
            if (_unit != null) _unit!.name,
            if (_topic != null) _topic!.name,
          ].join(' › '),
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 8),
        if (_subject != null) _backChip(),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _buildList(),
        ),
      ],
    );
  }

  Widget _buildList() {
    if (_subject == null) return _buildFolderSubjectTree();
    if (_unit == null) {
      if (_units.isEmpty) {
        return const Center(
          child: Text(
            'Bu derste ünite yok',
            style: TextStyle(color: AppColors.muted),
          ),
        );
      }
      return ListView(
        children: _units
            .map(
              (u) => ListTile(
                leading: const Icon(
                  Icons.folder_outlined,
                  color: AppColors.accent,
                ),
                title: Text(u.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _selectUnit(u),
              ),
            )
            .toList(),
      );
    }
    if (_topic == null) return _buildTopicsList();
    return _buildOutcomesList();
  }

  Widget _buildFolderSubjectTree() {
    if (_subjects.isEmpty) {
      return const Center(
        child: Text(
          StringsTr.noSubjectsYet,
          style: TextStyle(color: AppColors.muted),
        ),
      );
    }
    final byFolder = <String, List<CurriculumSubject>>{};
    for (final s in _subjects) {
      final folder =
          (s.folder.trim().isEmpty) ? 'MATEMATİK' : s.folder.trim();
      byFolder.putIfAbsent(folder, () => []).add(s);
    }
    var folders = byFolder.keys.toList()..sort(CurriculumFolders.compare);
    final visible =
        ref.watch(teacherProfileProvider).asData?.value.visibleFolders ??
            const <String>[];
    if (visible.isNotEmpty) {
      final allow = visible.toSet();
      folders = folders.where((f) => allow.contains(f)).toList();
    }

    return ListView(
      children: [
        for (final folder in folders)
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: _expandedFolders.isEmpty ||
                  _expandedFolders.contains(folder),
              leading: const Icon(Icons.folder, color: AppColors.primary),
              title: Text(
                folder,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              children: _buildGroupedSubjects(byFolder[folder]!),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildGroupedSubjects(List<CurriculumSubject> subjects) {
    final byGroup = <String, List<CurriculumSubject>>{};
    for (final s in subjects) {
      final g = StudentGradeLevels.groupForSubjectName(s.name);
      byGroup.putIfAbsent(g, () => []).add(s);
    }
    final widgets = <Widget>[];
    for (final group in StudentGradeLevels.subjectGroups) {
      final list = byGroup[group];
      if (list == null || list.isEmpty) continue;
      widgets.add(
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: _expandedGroups.contains(group),
            tilePadding: const EdgeInsets.only(left: 28, right: 12),
            title: Text(
              group,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.muted,
              ),
            ),
            children: list
                .map(
                  (s) => ListTile(
                    contentPadding:
                        const EdgeInsets.only(left: 48, right: 16),
                    leading: const Icon(
                      Icons.school_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    title: Text(s.name, style: const TextStyle(fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _selectSubject(s),
                  ),
                )
                .toList(),
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _buildTopicsList() {
    if (_topics.isEmpty) {
      return const Center(
        child: Text(
          'Bu ünitede konu yok',
          style: TextStyle(color: AppColors.muted),
        ),
      );
    }
    return ListView(
      children: _topics.map((t) {
        final outs = _outcomesByTopic[t.id] ?? const <CurriculumOutcome>[];
        final selected = _isWholeTopicSelected(t, outs);
        if (!widget.multiSelect) {
          return ListTile(
            leading: const Icon(
              Icons.menu_book_outlined,
              color: AppColors.warning,
            ),
            title: Text(t.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openTopic(t),
          );
        }
        return ListTile(
          contentPadding: const EdgeInsets.only(left: 4, right: 8),
          leading: Checkbox(
            value: selected,
            onChanged: (_) => _toggleWholeTopic(t, outs),
          ),
          title: Text(t.name),
          subtitle: selected
              ? const Text(
                  StringsTr.topicSelectAllOutcomesHint,
                  style: TextStyle(fontSize: 11, color: AppColors.success),
                )
              : (outs.isEmpty
                  ? null
                  : Text(
                      '${outs.length} kazanım',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    )),
          trailing: IconButton(
            tooltip: 'Kazanımları aç',
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _openTopic(t),
          ),
          onTap: () => _openTopic(t),
        );
      }).toList(),
    );
  }

  Widget _buildOutcomesList() {
    final topic = _topic!;
    final outs = _outcomes;
    if (!widget.multiSelect) {
      return ListView(
        children: outs
            .map(
              (o) => ListTile(
                leading: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                ),
                title: Text(o.name),
                onTap: () => _toggleOutcome(topic, o),
              ),
            )
            .toList(),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          value: _isWholeTopicSelected(topic, outs),
          title: Text(
            topic.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: const Text(
            StringsTr.topicSelectAllOutcomesHint,
            style: TextStyle(fontSize: 11),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (_) => _toggleWholeTopic(topic, outs),
        ),
        const Divider(height: 12),
        Expanded(
          child: ListView(
            children: outs.map((o) {
              return CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: _isOutcomeChecked(topic, o),
                title: Text(o.name, style: const TextStyle(fontSize: 14)),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (_) => _toggleOutcome(topic, o),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
