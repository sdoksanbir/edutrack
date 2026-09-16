import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/features/settings/profile_screen.dart';
import 'package:ozel_ders_takip/shared/constants/curriculum_folders.dart';
import 'package:ozel_ders_takip/shared/constants/student_grade_levels.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';

enum _TopicProgressState { none, partial, complete }

/// Öğrencinin tamamladığı konuları seçilebilir müfredat ağacında gösterir.
class StudentCompletedTopicsScreen extends ConsumerStatefulWidget {
  const StudentCompletedTopicsScreen({
    super.key,
    required this.student,
  });

  final Student student;

  @override
  ConsumerState<StudentCompletedTopicsScreen> createState() =>
      _StudentCompletedTopicsScreenState();
}

class _StudentCompletedTopicsScreenState
    extends ConsumerState<StudentCompletedTopicsScreen> {
  List<CurriculumSubject> _subjects = [];
  final Map<String, List<CurriculumUnit>> _unitsBySubject = {};
  final Map<String, List<CurriculumTopic>> _topicsByUnit = {};
  final Map<String, List<CurriculumOutcome>> _outcomesByTopic = {};
  bool _loadingTree = true;
  bool _imported = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final progressRepo = ref.read(studentTopicProgressRepoProvider);
    await progressRepo.importFromDoneLessons(widget.student.id);
    await _loadTree();
    if (mounted) setState(() => _imported = true);
  }

  Future<void> _loadTree() async {
    final repo = ref.read(curriculumRepoProvider);
    await repo.ensureDefaultCurriculum();
    final subjects = await repo.getSubjects();
    final grade = widget.student.gradeLevel;
    final filtered = subjects
        .where((s) => StudentGradeLevels.subjectMatchesGrade(s.name, grade))
        .toList();

    final unitsBySubject = <String, List<CurriculumUnit>>{};
    final topicsByUnit = <String, List<CurriculumTopic>>{};
    final outcomesByTopic = <String, List<CurriculumOutcome>>{};

    for (final s in filtered) {
      final units = await repo.getUnits(s.id);
      unitsBySubject[s.id] = units;
      for (final u in units) {
        final topics = await repo.getTopics(u.id);
        topicsByUnit[u.id] = topics;
        for (final t in topics) {
          outcomesByTopic[t.id] = await repo.getOutcomes(t.id);
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _subjects = filtered;
      _unitsBySubject
        ..clear()
        ..addAll(unitsBySubject);
      _topicsByUnit
        ..clear()
        ..addAll(topicsByUnit);
      _outcomesByTopic
        ..clear()
        ..addAll(outcomesByTopic);
      _loadingTree = false;
    });
  }

  List<String> _outcomeLabels(CurriculumTopic topic) {
    final outs = _outcomesByTopic[topic.id] ?? const [];
    return outs.map((o) => '${topic.name} — ${o.name}').toList();
  }

  _TopicProgressState _topicState(CurriculumTopic topic, Set<String> done) {
    if (done.contains(topic.name)) return _TopicProgressState.complete;
    final labels = _outcomeLabels(topic);
    if (labels.isEmpty) return _TopicProgressState.none;
    final hit = labels.where(done.contains).length;
    if (hit == 0) return _TopicProgressState.none;
    if (hit >= labels.length) return _TopicProgressState.complete;
    return _TopicProgressState.partial;
  }

  bool _outcomeDone(
    CurriculumTopic topic,
    CurriculumOutcome o,
    Set<String> done,
  ) {
    if (done.contains(topic.name)) return true;
    return done.contains('${topic.name} — ${o.name}');
  }

  Color _stateColor(_TopicProgressState state) {
    switch (state) {
      case _TopicProgressState.complete:
        return AppColors.success;
      case _TopicProgressState.partial:
        return AppColors.warning;
      case _TopicProgressState.none:
        return AppColors.muted;
    }
  }

  IconData _stateIcon(_TopicProgressState state) {
    switch (state) {
      case _TopicProgressState.complete:
        return Icons.check_circle;
      case _TopicProgressState.partial:
        return Icons.timelapse;
      case _TopicProgressState.none:
        return Icons.radio_button_unchecked;
    }
  }

  int _countCompletedTopics(Set<String> done) {
    var n = 0;
    for (final topics in _topicsByUnit.values) {
      for (final t in topics) {
        if (_topicState(t, done) == _TopicProgressState.complete) n++;
      }
    }
    return n;
  }

  int _countPartialTopics(Set<String> done) {
    var n = 0;
    for (final topics in _topicsByUnit.values) {
      for (final t in topics) {
        if (_topicState(t, done) == _TopicProgressState.partial) n++;
      }
    }
    return n;
  }

  Future<void> _onToggleTopic(CurriculumTopic topic, Set<String> done) async {
    final state = _topicState(topic, done);
    final labels = _outcomeLabels(topic);
    await ref.read(studentTopicProgressRepoProvider).toggleWholeTopic(
          studentId: widget.student.id,
          topicName: topic.name,
          outcomeLabels: labels,
          currentlyComplete: state == _TopicProgressState.complete,
        );
  }

  Future<void> _onToggleOutcome(
    CurriculumTopic topic,
    CurriculumOutcome outcome,
    Set<String> done,
  ) async {
    await ref.read(studentTopicProgressRepoProvider).toggleOutcome(
          studentId: widget.student.id,
          topicName: topic.name,
          outcomeLabel: '${topic.name} — ${outcome.name}',
          allOutcomeLabels: _outcomeLabels(topic),
          current: done,
        );
  }

  @override
  Widget build(BuildContext context) {
    final progressStream = ref
        .watch(studentTopicProgressRepoProvider)
        .watchLabels(widget.student.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text(StringsTr.completedTopicsTitle),
      ),
      body: StreamBuilder<Set<String>>(
        stream: progressStream,
        builder: (context, snapshot) {
          final done = snapshot.data ?? {};
          if (_loadingTree || !_imported) {
            return const Center(child: CircularProgressIndicator());
          }

          final completedCount = _countCompletedTopics(done);
          final partialCount = _countPartialTopics(done);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              Card(
                elevation: 0,
                color: AppColors.primarySoft,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.task_alt, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.student.fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  StudentGradeLevels.labelFor(
                                        widget.student.gradeLevel,
                                      ) ??
                                      StringsTr.completedTopicsNoGrade,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _LegendChip(
                            color: AppColors.success,
                            label: 'Tamam ($completedCount)',
                          ),
                          const SizedBox(width: 8),
                          _LegendChip(
                            color: AppColors.warning,
                            label: 'Yarım ($partialCount)',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        StringsTr.completedTopicsTapHint,
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ..._buildCurriculumTree(done),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildCurriculumTree(Set<String> done) {
    final visible =
        ref.watch(teacherProfileProvider).asData?.value.visibleFolders ??
            const <String>[];
    final byFolder = <String, List<CurriculumSubject>>{};
    for (final s in _subjects) {
      final folder =
          (s.folder.trim().isEmpty) ? 'MATEMATİK' : s.folder.trim();
      if (visible.isNotEmpty && !visible.contains(folder)) continue;
      byFolder.putIfAbsent(folder, () => []).add(s);
    }
    final folders = byFolder.keys.toList()..sort(CurriculumFolders.compare);
    if (folders.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              StringsTr.noSubjectsYet,
              style: TextStyle(color: AppColors.muted),
            ),
          ),
        ),
      ];
    }

    return [
      for (final folder in folders)
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: folders.length == 1,
            leading: const Icon(Icons.folder, color: AppColors.primary),
            title: Text(
              folder,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            children: [
              for (final subject in byFolder[folder]!)
                _buildSubjectTile(subject, done),
            ],
          ),
        ),
    ];
  }

  Widget _buildSubjectTile(CurriculumSubject subject, Set<String> done) {
    final units = _unitsBySubject[subject.id] ?? const [];
    final topicCount = units.fold<int>(
      0,
      (n, u) => n + (_topicsByUnit[u.id]?.length ?? 0),
    );
    final doneCount = units.fold<int>(0, (n, u) {
      final topics = _topicsByUnit[u.id] ?? const [];
      return n +
          topics
              .where(
                (t) => _topicState(t, done) == _TopicProgressState.complete,
              )
              .length;
    });

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.only(left: 28, right: 12),
        title: Text(subject.name, style: const TextStyle(fontSize: 14)),
        subtitle: Text(
          '$doneCount / $topicCount konu',
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
        children: [
          for (final unit in units) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 8, 12, 4),
              child: Text(
                unit.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppColors.muted,
                ),
              ),
            ),
            for (final topic in _topicsByUnit[unit.id] ?? const [])
              _buildTopicBlock(topic, done),
          ],
        ],
      ),
    );
  }

  Widget _buildTopicBlock(CurriculumTopic topic, Set<String> done) {
    final outs = _outcomesByTopic[topic.id] ?? const [];
    final state = _topicState(topic, done);
    final color = _stateColor(state);
    final icon = _stateIcon(state);

    if (outs.isEmpty) {
      return ListTile(
        dense: true,
        contentPadding: const EdgeInsets.only(left: 40, right: 8),
        leading: Icon(icon, color: color, size: 22),
        title: Text(
          topic.name,
          style: TextStyle(
            fontSize: 13,
            fontWeight: state == _TopicProgressState.none
                ? FontWeight.w500
                : FontWeight.w600,
            color: state == _TopicProgressState.none
                ? AppColors.muted
                : AppColors.textPrimary,
          ),
        ),
        onTap: () => _onToggleTopic(topic, done),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.only(left: 32, right: 8),
        leading: InkWell(
          onTap: () => _onToggleTopic(topic, done),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(icon, color: color, size: 22),
          ),
        ),
        title: InkWell(
          onTap: () => _onToggleTopic(topic, done),
          child: Text(
            topic.name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: state == _TopicProgressState.none
                  ? FontWeight.w500
                  : FontWeight.w700,
            ),
          ),
        ),
        subtitle: state == _TopicProgressState.partial
            ? Text(
                StringsTr.completedTopicsPartialHint,
                style: TextStyle(fontSize: 11, color: color),
              )
            : null,
        children: outs.map((o) {
          final ok = _outcomeDone(topic, o, done);
          return ListTile(
            dense: true,
            contentPadding: const EdgeInsets.only(left: 64, right: 12),
            leading: Icon(
              ok ? Icons.check_box : Icons.check_box_outline_blank,
              size: 20,
              color: ok ? AppColors.success : AppColors.muted,
            ),
            title: Text(
              o.name,
              style: TextStyle(
                fontSize: 12,
                color: ok ? AppColors.textPrimary : AppColors.muted,
              ),
            ),
            onTap: () => _onToggleOutcome(topic, o, done),
          );
        }).toList(),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
