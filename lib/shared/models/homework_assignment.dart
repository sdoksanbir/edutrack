const homeworkTopicNoteSep = '<<>>';

/// Kaynak başına konu + açıklama.
class HomeworkTopicEntry {
  final String topic;
  final String note;

  const HomeworkTopicEntry({
    required this.topic,
    this.note = '',
  });

  HomeworkTopicEntry copyWith({String? topic, String? note}) {
    return HomeworkTopicEntry(
      topic: topic ?? this.topic,
      note: note ?? this.note,
    );
  }
}

/// Kaynak → konu veya deneme no.
class HomeworkResourceAssignment {
  final String resource;
  final List<HomeworkTopicEntry> topicEntries;
  final int? denemeNo;
  final bool isPractice;

  const HomeworkResourceAssignment({
    required this.resource,
    this.topicEntries = const [],
    this.denemeNo,
    this.isPractice = false,
  });

  List<String> get topics => topicEntries.map((e) => e.topic).toList();
}

String encodeHomeworkTopicSegment(HomeworkTopicEntry entry) {
  final topic = entry.topic.trim();
  final note = entry.note.trim();
  if (note.isEmpty) return topic;
  return '$topic$homeworkTopicNoteSep$note';
}

HomeworkTopicEntry decodeHomeworkTopicSegment(String raw) {
  final segment = raw.trim();
  if (segment.isEmpty) return const HomeworkTopicEntry(topic: '');
  final sepIndex = segment.indexOf(homeworkTopicNoteSep);
  if (sepIndex < 0) return HomeworkTopicEntry(topic: segment);
  return HomeworkTopicEntry(
    topic: segment.substring(0, sepIndex).trim(),
    note: segment.substring(sepIndex + homeworkTopicNoteSep.length).trim(),
  );
}

List<String> parseTaughtTopics(String? raw) {
  if (raw == null || raw.trim().isEmpty) return [];
  return raw
      .split(RegExp(r'[\n·,]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

String joinTaughtTopics(List<String> topics) => topics.join('\n');

List<HomeworkResourceAssignment> parseHomeworkResourceAssignments(String? raw) {
  if (raw == null || raw.trim().isEmpty) return [];
  final result = <HomeworkResourceAssignment>[];
  for (final line in raw.split('\n')) {
    final t = line.trim();
    if (t.isEmpty) continue;
    if (t.contains('::')) {
      final parts = t.split('::');
      final resource = parts.first.trim();
      final rest = parts.sublist(1).join('::').trim();
      if (resource.isEmpty) continue;
      if (rest.startsWith('#')) {
        final body = rest.substring(1);
        final sepIndex = body.indexOf(homeworkTopicNoteSep);
        final numStr = sepIndex >= 0
            ? body.substring(0, sepIndex).trim()
            : body.trim();
        result.add(HomeworkResourceAssignment(
          resource: resource,
          isPractice: true,
          denemeNo: int.tryParse(numStr),
        ));
      } else {
        final topicEntries = rest
            .split('|')
            .map(decodeHomeworkTopicSegment)
            .where((e) => e.topic.isNotEmpty)
            .toList();
        result.add(HomeworkResourceAssignment(
          resource: resource,
          topicEntries: topicEntries,
        ));
      }
    } else {
      result.add(HomeworkResourceAssignment(resource: t));
    }
  }
  return result;
}

String joinHomeworkResourceAssignments(List<HomeworkResourceAssignment> items) {
  return items
      .where((e) => e.resource.trim().isNotEmpty)
      .map((e) {
        if (e.isPractice) {
          if (e.denemeNo == null) return null;
          return '${e.resource}::#${e.denemeNo}';
        }
        if (e.topicEntries.isEmpty) return null;
        return '${e.resource}::${e.topicEntries.map(encodeHomeworkTopicSegment).join('|')}';
      })
      .whereType<String>()
      .join('\n');
}

List<HomeworkResourceAssignment> collectHomeworkResourceAssignments({
  required Map<String, List<HomeworkTopicEntry>> resourceTopics,
  required Map<String, Set<int>> denemeSelections,
}) {
  final denemeItems = <HomeworkResourceAssignment>[];
  for (final entry in denemeSelections.entries) {
    final nos = entry.value.toList()..sort();
    for (final no in nos) {
      denemeItems.add(
        HomeworkResourceAssignment(
          resource: entry.key,
          isPractice: true,
          denemeNo: no,
        ),
      );
    }
  }
  return [
    ...resourceTopics.entries
        .where((e) => e.value.isNotEmpty)
        .map(
          (e) => HomeworkResourceAssignment(
            resource: e.key,
            topicEntries: e.value,
          ),
        ),
    ...denemeItems,
  ];
}

/// Ders kaydından ödev kalemlerine genişletme.
class HomeworkItemDraft {
  final String? resource;
  final String topic;
  final String? detail;

  const HomeworkItemDraft({
    this.resource,
    required this.topic,
    this.detail,
  });
}

String homeworkItemKey(String? resource, String topic) =>
    '${resource ?? ''}|${topic.trim()}';

List<HomeworkItemDraft> expandHomeworkItems({
  String? homeworkResource,
  String? homework,
}) {
  final items = <HomeworkItemDraft>[];
  final assignments = parseHomeworkResourceAssignments(homeworkResource);

  for (final assignment in assignments) {
    if (assignment.isPractice && assignment.denemeNo != null) {
      items.add(HomeworkItemDraft(
        resource: assignment.resource,
        topic: 'Deneme ${assignment.denemeNo}',
      ));
      continue;
    }
    for (final entry in assignment.topicEntries) {
      items.add(HomeworkItemDraft(
        resource: assignment.resource,
        topic: entry.topic,
        detail: entry.note.trim().isEmpty ? null : entry.note.trim(),
      ));
    }
  }

  if (items.isEmpty && homework != null && homework.trim().isNotEmpty) {
    for (final line in homework.split('\n')) {
      var text = line.trim();
      if (text.isEmpty) continue;
      text = text.replaceFirst(RegExp(r'^\d+\.\s*'), '');
      if (text.isEmpty) continue;
      items.add(HomeworkItemDraft(topic: text));
    }
  }

  return items;
}
