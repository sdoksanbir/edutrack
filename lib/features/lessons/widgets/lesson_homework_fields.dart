import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/features/students/widgets/student_book_resource_dialog.dart';
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
    return '$numbered\n   ${item.note}';
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
    return '$numbered\n   $note';
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
    this.onFormatTopic,
    this.onFormatHomework,
    this.onFormatResource,
  });

  final String studentId;
  final TextEditingController topicController;
  final TextEditingController homeworkController;
  final TextEditingController resourceController;
  final bool compact;
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
  /// deneme kaynak → deneme no (null = boş)
  final Map<String, int?> _denemeNumbers = {};
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
    for (final a in assignments) {
      if (a.isPractice) {
        _denemeNumbers[a.resource] = a.denemeNo;
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

    final remappedDenemes = <String, int?>{};
    for (final entry in _denemeNumbers.entries) {
      final key = _matchResourceName(entry.key, _practiceResources) ?? entry.key;
      remappedDenemes[key] = entry.value;
    }
    _denemeNumbers
      ..clear()
      ..addAll(remappedDenemes);

    for (final name in _practiceResources) {
      _denemeNumbers.putIfAbsent(name, () => null);
    }

    final assignedNames = [
      ..._resourceTopics.keys,
      ..._denemeNumbers.entries.where((e) => e.value != null).map((e) => e.key),
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
      if (!mounted) return;
      final topicList = parseStudentBookResources(student?.bookResource);
      final practiceList =
          parseStudentBookResources(student?.bookResourcePractice);
      setState(() {
        _topicResources = topicList;
        _practiceResources = practiceList;
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
      denemeNumbers: _denemeNumbers,
    );
    widget.resourceController.text = joinHomeworkResourceAssignments(items);
  }

  void _syncHomeworkSummary() {
    if (_customHomework) return;
    final items = collectHomeworkResourceAssignments(
      resourceTopics: _resourceTopics,
      denemeNumbers: _denemeNumbers,
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
        denemeNumbers: _denemeNumbers,
      );

  bool get _hasHomeworkAssignments => _homeworkAssignments.isNotEmpty;

  Future<void> _addTaughtTopicFromSystem() async {
    final picked = await showCurriculumMultiTopicPicker(
      context,
      ref,
      initiallySelected: _taughtTopics,
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
      _denemeNumbers.removeWhere((k, _) => !_practiceResources.contains(k));
      for (final name in _practiceResources) {
        _denemeNumbers[name] = null;
      }
    });
    _syncResourceController();
    _syncHomeworkSummary();
  }

  Future<void> _assignTopicsToResource(String resource) async {
    final current =
        List<HomeworkTopicEntry>.from(_resourceTopics[resource] ?? const []);
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
    final current = _denemeNumbers[resource];
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _DenemeNumberSheet(initial: current),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (picked < 0) {
        _denemeNumbers[resource] = null;
      } else {
        _denemeNumbers[resource] = picked;
      }
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            parts.first,
            style: TextStyle(
              fontSize: fontSize,
              height: 1.35,
              color: AppColors.textPrimary,
            ),
          ),
          if (parts.length > 1)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 2),
              child: Text(
                parts.sublist(1).join('\n'),
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
    );
  }

  Widget _topicResourceCard(String name) {
    final entries = _resourceTopics[name] ?? const <HomeworkTopicEntry>[];
    final selected = entries.isNotEmpty;
    final numberedLines = buildResourceHomeworkLines(
      name,
      entries,
      taughtTopics: _taughtTopics,
    );
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.primarySoft : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.45)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          if (numberedLines.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...numberedLines.map((line) => _numberedHomeworkText(line)),
          ] else
            const Padding(
              padding: EdgeInsets.only(left: 2),
              child: Text(
                StringsTr.noTopicsAssigned,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.muted,
                  fontStyle: FontStyle.italic,
                ),
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

  Widget _denemeResourceCard(String name) {
    final no = _denemeNumbers[name];
    final selected = no != null;
    final numberedLine = selected ? '1. $name: Deneme $no' : null;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  constraints: const BoxConstraints(minWidth: 72),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    no == null ? StringsTr.denemeNumberEmpty : '$no',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: no == null ? AppColors.muted : AppColors.warning,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (numberedLine != null) ...[
            const SizedBox(height: 6),
            _numberedHomeworkText(numberedLine),
          ],
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _taughtTopics
                      .map(
                        (t) => InputChip(
                          label: Text(t, style: const TextStyle(fontSize: 12)),
                          onDeleted: () => _removeTaughtTopic(t),
                          deleteIconColor: AppColors.muted,
                          backgroundColor: AppColors.primarySoft,
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.35),
                          ),
                        ),
                      )
                      .toList(),
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

class _DenemeNumberSheet extends StatelessWidget {
  const _DenemeNumberSheet({this.initial});

  final int? initial;

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
              onPressed: () => Navigator.pop(context, -1),
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
                  final selected = initial == n;
                  return Material(
                    color: selected
                        ? AppColors.warningSoft
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => Navigator.pop(context, n),
                      child: Center(
                        child: Text(
                          '$n',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? AppColors.warning
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
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
  });

  final String resourceName;
  final List<String> taughtTopics;
  final List<HomeworkTopicEntry> initiallySelected;

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
                selectedTopics: _selected,
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
    ),
  );
}

class _CurriculumMultiTopicPickerSheet extends ConsumerStatefulWidget {
  const _CurriculumMultiTopicPickerSheet({
    this.initiallySelected = const [],
  });

  final List<String> initiallySelected;

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
            const SizedBox(height: 12),
            Expanded(
              child: _CurriculumTopicBrowser(
                multiSelect: true,
                onPick: _toggleTopic,
                selectedTopics: _selected,
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

/// Parametrelerden Ders → Ünite → Konu → Kazanım gezintisi.
class _CurriculumTopicBrowser extends ConsumerStatefulWidget {
  const _CurriculumTopicBrowser({
    required this.onPick,
    this.selectedTopics = const {},
    this.multiSelect = false,
  });

  final void Function(String topicLabel) onPick;
  final Set<String> selectedTopics;
  final bool multiSelect;

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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    await ref.read(curriculumRepoProvider).ensureDefaultCurriculum();
    final list = await ref.read(curriculumRepoProvider).getSubjects();
    if (!mounted) return;
    setState(() {
      _subjects = list;
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
    });
  }

  Future<void> _selectUnit(CurriculumUnit u) async {
    final topics = await ref.read(curriculumRepoProvider).getTopics(u.id);
    if (!mounted) return;
    setState(() {
      _unit = u;
      _topic = null;
      _topics = topics;
      _outcomes = [];
    });
  }

  Future<void> _selectTopic(CurriculumTopic t) async {
    final outcomes = await ref.read(curriculumRepoProvider).getOutcomes(t.id);
    if (!mounted) return;
    if (outcomes.isEmpty) {
      widget.onPick(t.name);
      return;
    }
    setState(() {
      _topic = t;
      _outcomes = outcomes;
    });
  }

  void _selectOutcome(CurriculumOutcome o) {
    final label = '${_topic!.name} — ${o.name}';
    widget.onPick(label);
  }

  void _pickTopicOnly() {
    if (_topic != null) widget.onPick(_topic!.name);
  }

  bool _isTopicSelected(CurriculumTopic t) {
    if (widget.selectedTopics.contains(t.name)) return true;
    final prefix = '${t.name} — ';
    return widget.selectedTopics.any((s) => s.startsWith(prefix));
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

  Widget _selectedBadge(String label) {
    if (!widget.selectedTopics.contains(label)) return const SizedBox.shrink();
    return const Icon(Icons.check_circle, color: AppColors.success, size: 18);
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
    if (_subject == null) {
      if (_subjects.isEmpty) {
        return const Center(
          child: Text(
            StringsTr.noSubjectsYet,
            style: TextStyle(color: AppColors.muted),
          ),
        );
      }
      return ListView(
        children: _subjects
            .map(
              (s) => ListTile(
                leading:
                    const Icon(Icons.school_outlined, color: AppColors.primary),
                title: Text(s.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _selectSubject(s),
              ),
            )
            .toList(),
      );
    }
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
                leading:
                    const Icon(Icons.folder_outlined, color: AppColors.accent),
                title: Text(u.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _selectUnit(u),
              ),
            )
            .toList(),
      );
    }
    if (_topic == null) {
      if (_topics.isEmpty) {
        return const Center(
          child: Text(
            'Bu ünitede konu yok',
            style: TextStyle(color: AppColors.muted),
          ),
        );
      }
      return ListView(
        children: _topics
            .map(
              (t) {
                if (widget.multiSelect) {
                  final selected = _isTopicSelected(t);
                  return ListTile(
                    leading: const Icon(
                      Icons.menu_book_outlined,
                      color: AppColors.warning,
                    ),
                    title: Text(t.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selected) _selectedBadge(t.name),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () => _selectTopic(t),
                  );
                }
                return ListTile(
                  leading: const Icon(
                    Icons.menu_book_outlined,
                    color: AppColors.warning,
                  ),
                  title: Text(t.name),
                  trailing: widget.selectedTopics.contains(t.name)
                      ? _selectedBadge(t.name)
                      : const Icon(Icons.chevron_right),
                  onTap: () => _selectTopic(t),
                );
              },
            )
            .toList(),
      );
    }
    if (widget.multiSelect) {
      return Column(
        children: [
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: widget.selectedTopics.contains(_topic!.name),
            title: Text('Sadece konu: ${_topic!.name}'),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (_) => _pickTopicOnly(),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: _outcomes
                  .map(
                    (o) {
                      final label = '${_topic!.name} — ${o.name}';
                      return CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        value: widget.selectedTopics.contains(label),
                        title: Text(o.name, style: const TextStyle(fontSize: 14)),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (_) => _selectOutcome(o),
                      );
                    },
                  )
                  .toList(),
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.check, color: AppColors.primary),
          title: Text('Sadece konu: ${_topic!.name}'),
          trailing: _selectedBadge(_topic!.name),
          onTap: _pickTopicOnly,
        ),
        const Divider(),
        Expanded(
          child: ListView(
            children: _outcomes
                .map(
                  (o) {
                    final label = '${_topic!.name} — ${o.name}';
                    return ListTile(
                      leading: const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.success,
                      ),
                      title: Text(o.name),
                      trailing: _selectedBadge(label),
                      onTap: () => _selectOutcome(o),
                    );
                  },
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
