import 'package:drift/drift.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/services/notification_service.dart';
import 'package:uuid/uuid.dart';

class TodosRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();
  final _notifications = NotificationService();

  TodosRepository(this._db);

  Stream<List<TeacherTodo>> watchOpenTodos() {
    return (_db.select(_db.teacherTodos)
          ..where((t) => t.isDone.equals(false))
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.createdAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  Stream<List<TeacherTodo>> watchAllTodos() {
    return (_db.select(_db.teacherTodos)
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.createdAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  Stream<int> watchOpenCount() {
    return watchOpenTodos().map((items) => items.length);
  }

  Future<void> _syncNotification(TeacherTodo todo) async {
    if (todo.isDone || todo.notifyAt == null) {
      await _notifications.cancelTodoReminder(todo.id);
      return;
    }
    if (!todo.notifyAt!.isAfter(DateTime.now())) {
      await _notifications.cancelTodoReminder(todo.id);
      return;
    }
    await _notifications.scheduleTodoReminder(
      todoId: todo.id,
      title: todo.title,
      notifyAt: todo.notifyAt!,
      studentName: todo.studentName,
    );
  }

  Future<bool> existsForHomeworkItem(String homeworkItemId) async {
    final row = await (_db.select(_db.teacherTodos)
          ..where((t) => t.homeworkItemId.equals(homeworkItemId))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  /// Ödev kaleminden ekler; aynı ödev zaten listedeyse `false` döner (çift ekleme yok).
  Future<bool> addTodoFromHomework({
    required String title,
    required String homeworkItemId,
    String? studentId,
    String? studentName,
    String? homeworkTopic,
    DateTime? notifyAt,
  }) async {
    if (await existsForHomeworkItem(homeworkItemId)) return false;
    await addTodo(
      title: title,
      studentId: studentId,
      studentName: studentName,
      homeworkItemId: homeworkItemId,
      homeworkTopic: homeworkTopic,
      notifyAt: notifyAt,
    );
    return true;
  }

  Future<void> addTodo({
    required String title,
    String? studentId,
    String? studentName,
    String? homeworkItemId,
    String? homeworkTopic,
    DateTime? notifyAt,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.teacherTodos).insert(
          TeacherTodosCompanion.insert(
            id: id,
            title: title.trim(),
            studentId: Value(studentId),
            studentName: Value(studentName),
            homeworkItemId: Value(homeworkItemId),
            homeworkTopic: Value(homeworkTopic),
            notifyAt: Value(notifyAt),
            createdAt: DateTime.now(),
          ),
        );

    final todo = await (_db.select(_db.teacherTodos)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    await _syncNotification(todo);
  }

  Future<void> updateTodo({
    required String id,
    required String title,
    DateTime? notifyAt,
    bool clearNotifyAt = false,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    await (_db.update(_db.teacherTodos)..where((t) => t.id.equals(id))).write(
      TeacherTodosCompanion(
        title: Value(trimmed),
        notifyAt: clearNotifyAt
            ? const Value(null)
            : (notifyAt != null ? Value(notifyAt) : const Value.absent()),
      ),
    );

    final todo = await (_db.select(_db.teacherTodos)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (todo != null) await _syncNotification(todo);
  }

  Future<void> updateTitle(String id, String title) async {
    await updateTodo(id: id, title: title);
  }

  Future<void> toggleDone(String id, bool isDone) async {
    await (_db.update(_db.teacherTodos)..where((t) => t.id.equals(id))).write(
      TeacherTodosCompanion(isDone: Value(isDone)),
    );
    final todo = await (_db.select(_db.teacherTodos)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (todo != null) await _syncNotification(todo);
  }

  Future<void> deleteTodo(String id) async {
    await _notifications.cancelTodoReminder(id);
    await (_db.delete(_db.teacherTodos)..where((t) => t.id.equals(id))).go();
  }
}
