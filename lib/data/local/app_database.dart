import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:ozel_ders_takip/data/local/tables.dart';
import 'package:ozel_ders_takip/data/local/curriculum_seed.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Students,
  ScheduleTemplates,
  ScheduleOverrides,
  SessionOccurrences,
  Lessons,
  Attachments,
  AppSettings,
  Payments,
  LessonPayments,
  CurriculumSubjects,
  CurriculumUnits,
  CurriculumTopics,
  CurriculumOutcomes,
  HomeworkItems,
  TeacherTodos,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 18;

  Future<bool> _columnExists(
    GeneratedDatabase db,
    String table,
    String column,
  ) async {
    final rows = await db.customSelect('PRAGMA table_info($table)').get();
    return rows.any((r) => r.read<String>('name') == column);
  }

  Future<void> _addColumnIfMissing(
    GeneratedDatabase db,
    String table,
    String column,
    String sqlType,
  ) async {
    if (await _columnExists(db, table, column)) return;
    await db.customStatement(
      'ALTER TABLE $table ADD COLUMN $column $sqlType',
    );
  }

  Future<bool> _tableExists(GeneratedDatabase db, String table) async {
    final row = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
          variables: [Variable.withString(table)],
        )
        .getSingleOrNull();
    return row != null;
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await seedDefaultCurriculum(this);
      },
      beforeOpen: (details) async {
        // Şema zaten güncel ama müfredat boşsa (eski v14) doldur.
        await seedDefaultCurriculum(this);
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // SessionOccurrences tablosunu ekle
          await m.createTable(sessionOccurrences);
          
          // Lessons tablosuna occurrenceId ekle
          await m.addColumn(lessons, lessons.occurrenceId);
          
          // Unique constraint için index ekle (Drift otomatik yönetir ama manuel de eklenebilir)
        }
        if (from < 3) {
          // Payments ve LessonPayments tablolarını ekle
          await m.createTable(payments);
          await m.createTable(lessonPayments);
          
          // Index'ler (Drift otomatik oluşturur ama manuel de eklenebilir)
          // studentId index için:
          await m.createIndex(Index('idx_payments_student_id', 'CREATE INDEX idx_payments_student_id ON payments(student_id)'));
          // paymentId ve lessonId index'leri için:
          await m.createIndex(Index('idx_lesson_payments_payment_id', 'CREATE INDEX idx_lesson_payments_payment_id ON lesson_payments(payment_id)'));
          await m.createIndex(Index('idx_lesson_payments_lesson_id', 'CREATE INDEX idx_lesson_payments_lesson_id ON lesson_payments(lesson_id)'));
        }
        if (from < 4) {
          // VERİTABANI SIFIRLAMA: Tüm tabloları sil ve yeniden oluştur
          // Bu migration tüm verileri silecek!
          await m.deleteTable('lesson_payments');
          await m.deleteTable('payments');
          await m.deleteTable('attachments');
          await m.deleteTable('lessons');
          await m.deleteTable('session_occurrences');
          await m.deleteTable('schedule_overrides');
          await m.deleteTable('schedule_templates');
          await m.deleteTable('students');
          await m.deleteTable('app_settings');
          
          // Tüm tabloları yeniden oluştur
          await m.createTable(students);
          await m.createTable(scheduleTemplates);
          await m.createTable(scheduleOverrides);
          await m.createTable(sessionOccurrences);
          await m.createTable(lessons);
          await m.createTable(attachments);
          await m.createTable(appSettings);
          await m.createTable(payments);
          await m.createTable(lessonPayments);
          
          // Index'leri yeniden oluştur
          await m.createIndex(Index('idx_payments_student_id', 'CREATE INDEX idx_payments_student_id ON payments(student_id)'));
          await m.createIndex(Index('idx_lesson_payments_payment_id', 'CREATE INDEX idx_lesson_payments_payment_id ON lesson_payments(payment_id)'));
          await m.createIndex(Index('idx_lesson_payments_lesson_id', 'CREATE INDEX idx_lesson_payments_lesson_id ON lesson_payments(lesson_id)'));
        }
        if (from < 5) {
          // Lessons tablosuna status kolonu ekle
          await m.addColumn(lessons, lessons.status as GeneratedColumn<Object>);
        }
        if (from < 6) {
          // SessionOccurrences tablosunu yeniden oluştur:
          // - studentId ekle (NOT NULL)
          // - templateId nullable yap
          // - unique constraint değiştir: (templateId, date) -> (studentId, date, startTime)
          
          final db = m.database;
          
          // 1. Geçici tablo oluştur (yeni şema ile)
          await db.customStatement('''
            CREATE TABLE session_occurrences_new (
              id TEXT NOT NULL PRIMARY KEY,
              student_id TEXT NOT NULL,
              template_id TEXT,
              date TEXT NOT NULL,
              start_time TEXT NOT NULL,
              duration_min INTEGER NOT NULL,
              status TEXT NOT NULL,
              not_done_reason_type TEXT,
              not_done_reason_note TEXT,
              payment_id TEXT,
              completed_at DATETIME,
              created_at DATETIME NOT NULL,
              updated_at DATETIME NOT NULL,
              UNIQUE(student_id, date, start_time)
            )
          ''');
          
          // 2. Mevcut verileri kopyala (studentId'yi template'den al)
          await db.customStatement('''
            INSERT INTO session_occurrences_new 
            (id, student_id, template_id, date, start_time, duration_min, status, 
             not_done_reason_type, not_done_reason_note, payment_id, completed_at, 
             created_at, updated_at)
            SELECT 
              so.id,
              COALESCE(st.student_id, '') as student_id,
              so.template_id,
              so.date,
              so.start_time,
              so.duration_min,
              so.status,
              so.not_done_reason_type,
              so.not_done_reason_note,
              so.payment_id,
              so.completed_at,
              so.created_at,
              so.updated_at
            FROM session_occurrences so
            LEFT JOIN schedule_templates st ON so.template_id = st.id
          ''');
          
          // 3. Eski tabloyu sil
          await m.deleteTable('session_occurrences');
          
          // 4. Yeni tabloyu eski isimle yeniden adlandır
          await db.customStatement('''
            ALTER TABLE session_occurrences_new 
            RENAME TO session_occurrences
          ''');
        }
        if (from < 7) {
          // ScheduleTemplates tablosuna startDate ve endDate ekle
          final db = m.database;
          
          // startDate ve endDate kolonlarını ekle
          await db.customStatement('''
            ALTER TABLE schedule_templates 
            ADD COLUMN start_date TEXT NOT NULL DEFAULT '2000-01-01'
          ''');
          
          await db.customStatement('''
            ALTER TABLE schedule_templates 
            ADD COLUMN end_date TEXT
          ''');
          
          // Mevcut template'ler için bugünü başlangıç tarihi olarak ayarla
          final now = DateTime.now();
          final todayStr = '${now.year.toString().padLeft(4, '0')}-'
              '${now.month.toString().padLeft(2, '0')}-'
              '${now.day.toString().padLeft(2, '0')}';
          
          await db.customStatement('''
            UPDATE schedule_templates 
            SET start_date = '$todayStr'
            WHERE start_date = '2000-01-01'
          ''');
        }
        if (from < 8) {
          // Students tablosuna isActive kolonu ekle
          final db = m.database;
          
          await db.customStatement('''
            ALTER TABLE students 
            ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1
          ''');
        }
        if (from < 9) {
          // Lessons tablosuna: ders notu, sebep, kaynak, sebep tarihi
          final db = m.database;
          await db.customStatement('''
            ALTER TABLE lessons ADD COLUMN lesson_notes TEXT
          ''');
          await db.customStatement('''
            ALTER TABLE lessons ADD COLUMN status_reason TEXT
          ''');
          await db.customStatement('''
            ALTER TABLE lessons ADD COLUMN status_reason_source TEXT
          ''');
          await db.customStatement('''
            ALTER TABLE lessons ADD COLUMN status_changed_at DATETIME
          ''');
        }
        if (from < 10) {
          // Students tablosuna veli bilgileri
          final db = m.database;
          await db.customStatement('''
            ALTER TABLE students ADD COLUMN guardian_full_name TEXT
          ''');
          await db.customStatement('''
            ALTER TABLE students ADD COLUMN guardian_phone TEXT
          ''');
        }
        if (from < 11) {
          // SessionOccurrences: erteleme sebebi ve eski tarih
          final db = m.database;
          await db.customStatement('''
            ALTER TABLE session_occurrences ADD COLUMN postponed_from_date TEXT
          ''');
          await db.customStatement('''
            ALTER TABLE session_occurrences ADD COLUMN postponed_reason TEXT
          ''');
        }
        if (from < 12) {
          // Students: kitap / kaynak (konu anlatımlı) — kolon varsa atla
          await _addColumnIfMissing(
            m.database,
            'students',
            'book_resource',
            'TEXT',
          );
        }
        if (from < 13) {
          // Students: soru bankası / denemeler
          await _addColumnIfMissing(
            m.database,
            'students',
            'book_resource_practice',
            'TEXT',
          );
        }
        if (from < 14) {
          // Müfredat hiyerarşisi + ödev kaynağı
          final db = m.database;
          if (!await _tableExists(db, 'curriculum_subjects')) {
            await m.createTable(curriculumSubjects);
          }
          if (!await _tableExists(db, 'curriculum_units')) {
            await m.createTable(curriculumUnits);
          }
          if (!await _tableExists(db, 'curriculum_topics')) {
            await m.createTable(curriculumTopics);
          }
          if (!await _tableExists(db, 'curriculum_outcomes')) {
            await m.createTable(curriculumOutcomes);
          }
          await _addColumnIfMissing(
            db,
            'lessons',
            'homework_resource',
            'TEXT',
          );
          await seedDefaultCurriculum(this);
        }
        if (from < 15) {
          await m.createTable(homeworkItems);
        }
        if (from < 16) {
          await _addColumnIfMissing(
            m.database,
            'homework_items',
            'due_at',
            'INTEGER',
          );
          final rows = await (select(homeworkItems)).get();
          for (final item in rows) {
            if (item.dueAt != null) continue;
            final due = DateTime(
              item.assignedAt.year,
              item.assignedAt.month,
              item.assignedAt.day,
            ).add(const Duration(days: 7));
            await (update(homeworkItems)..where((h) => h.id.equals(item.id)))
                .write(
              HomeworkItemsCompanion(
                dueAt: Value(
                  DateTime(due.year, due.month, due.day, 23, 59, 59),
                ),
              ),
            );
          }
        }
        if (from < 17) {
          await m.createTable(teacherTodos);
        }
        if (from < 18) {
          await _addColumnIfMissing(
            m.database,
            'teacher_todos',
            'notify_at',
            'INTEGER',
          );
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ozel_ders_takip.sqlite'));
    return NativeDatabase(file);
  });
}
