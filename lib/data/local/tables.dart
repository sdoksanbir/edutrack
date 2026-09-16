import 'package:drift/drift.dart';

// Students tablosu
class Students extends Table {
  TextColumn get id => text()();
  TextColumn get fullName => text()();
  TextColumn get phone => text().nullable()();
  IntColumn get hourlyRate => integer()(); // Saatlik ücret (TL)
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))(); // Aktif/Pasif durumu
  TextColumn get guardianFullName => text().nullable()(); // Veli ad soyad
  TextColumn get guardianPhone => text().nullable()(); // Veli telefon
  TextColumn get bookResource => text().nullable()(); // SORU BANKASI - KONU ANLATIMLI
  TextColumn get bookResourcePractice => text().nullable()(); // DENEME
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Haftalık program şablonları
class ScheduleTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get studentId => text()(); // Foreign key (Students.id)
  IntColumn get weekday => integer()(); // 1-7 (Pazartesi=1, Pazar=7)
  TextColumn get startTime => text()(); // 'HH:mm' formatında
  IntColumn get durationMin => integer()(); // Dakika cinsinden
  TextColumn get startDate => text()(); // 'YYYY-MM-DD' formatında - başlangıç tarihi (NOT NULL)
  TextColumn get endDate => text().nullable()(); // 'YYYY-MM-DD' formatında - bitiş tarihi (NULL ise AppSettings.default_schedule_end_date kullan)
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
  
  @override
  List<Set<Column>> get uniqueKeys => [
    {studentId, weekday, startTime}, // Aynı öğrenci için aynı gün/saatte birden fazla şablon olmamalı
  ];
}

// Sadece bu hafta değişiklikleri
class ScheduleOverrides extends Table {
  TextColumn get id => text()();
  TextColumn get templateId => text()(); // Foreign key (ScheduleTemplates.id)
  TextColumn get date => text()(); // 'YYYY-MM-DD' formatında
  TextColumn get overrideType => text()(); // 'moved' | 'cancelled' | 'extra'
  IntColumn get newWeekday => integer().nullable()(); // Taşınmışsa yeni gün
  TextColumn get newStartTime => text().nullable()(); // Taşınmışsa yeni saat
  IntColumn get newDurationMin => integer().nullable()(); // Taşınmışsa yeni süre
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Ders oluşumları (planlanan derslerin gerçekleşme durumu)
class SessionOccurrences extends Table {
  TextColumn get id => text()();
  TextColumn get studentId => text()(); // Foreign key (Students.id) - NOT NULL
  TextColumn get templateId => text().nullable()(); // Foreign key (ScheduleTemplates.id) - NULL olabilir (extra/ertelemeler için)
  TextColumn get date => text()(); // 'YYYY-MM-DD' formatında
  TextColumn get startTime => text()(); // 'HH:mm' formatında
  IntColumn get durationMin => integer()();
  TextColumn get status => text()(); // 'planned' | 'done' | 'missed' | 'postponed'
  TextColumn get notDoneReasonType => text().nullable()(); // 'student_cancelled' | 'teacher_cancelled' | 'other'
  TextColumn get notDoneReasonNote => text().nullable()();
  TextColumn get paymentId => text().nullable()(); // Foreign key (Payments.id) - ödeme alındıysa dolu
  DateTimeColumn get completedAt => dateTime().nullable()(); // Ders tamamlanma tarihi (done durumunda)
  TextColumn get postponedFromDate => text().nullable()(); // Ertelemede eski tarih 'YYYY-MM-DD'
  TextColumn get postponedReason => text().nullable()(); // Erteleme sebebi
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
  
  @override
  List<Set<Column>> get uniqueKeys => [
    {studentId, date, startTime}, // Aynı öğrenci + tarih + saat için tek ders
  ];
}

// Ders kayıtları (gerçekleşen dersler)
class Lessons extends Table {
  TextColumn get id => text()();
  TextColumn get studentId => text()(); // Foreign key (Students.id)
  TextColumn get occurrenceId => text().nullable()(); // Foreign key (SessionOccurrences.id)
  DateTimeColumn get startDateTime => dateTime()();
  IntColumn get durationMin => integer()();
  TextColumn get topic => text().nullable()();
  TextColumn get homework => text().nullable()();
  TextColumn get homeworkResource => text().nullable()(); // Ödev kaynağı
  IntColumn get feeExpected => integer()(); // Beklenen ücret (TL)
  IntColumn get feePaidAmount => integer()(); // Ödenen miktar (TL)
  TextColumn get note => text().nullable()();
  TextColumn get lessonNotes => text().nullable()(); // Ders notu (multi-line)
  TextColumn get status => text().nullable()(); // 'done' | 'not_done' | 'postponed' | null
  TextColumn get statusReason => text().nullable()(); // erteleme/yapılmadı sebebi
  TextColumn get statusReasonSource => text().nullable()(); // 'TEACHER' | 'STUDENT'
  DateTimeColumn get statusChangedAt => dateTime().nullable()(); // sebep girildiği zaman
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
  
  @override
  List<Set<Column>> get uniqueKeys => [
    {occurrenceId}, // occurrenceId unique (null hariç)
  ];
}

// Ödev takip kalemleri (ders başına konu/kaynak)
class HomeworkItems extends Table {
  TextColumn get id => text()();
  TextColumn get lessonId => text()(); // Foreign key (Lessons.id)
  TextColumn get studentId => text()(); // Foreign key (Students.id)
  DateTimeColumn get assignedAt => dateTime()(); // Ders tarihi
  TextColumn get resource => text().nullable()(); // Kaynak adı
  TextColumn get topic => text()(); // Konu veya deneme
  TextColumn get detail => text().nullable()(); // Sayfa / test açıklaması
  TextColumn get status => text().withDefault(const Constant('pending'))();
  // 'pending' | 'done' | 'not_done' | 'partial' | 'not_understood'
  TextColumn get statusNote => text().nullable()();
  DateTimeColumn get dueAt => dateTime().nullable()(); // Bitiş tarihi
  DateTimeColumn get statusChangedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Öğretmen yapılacaklar listesi
class TeacherTodos extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get studentId => text().nullable()();
  TextColumn get studentName => text().nullable()();
  TextColumn get homeworkItemId => text().nullable()();
  TextColumn get homeworkTopic => text().nullable()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  DateTimeColumn get notifyAt => dateTime().nullable()(); // Bildirim tarihi-saat
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Ders ekleri (fotoğraflar vb.)
class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get lessonId => text()(); // Foreign key (Lessons.id)
  TextColumn get filePath => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Uygulama ayarları (key-value)
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

// Tahsilat kayıtları
class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get studentId => text()(); // Foreign key (Students.id)
  DateTimeColumn get paidAt => dateTime()(); // Ödeme tarihi-saat
  IntColumn get amount => integer()(); // Toplam ödeme tutarı
  TextColumn get method => text()(); // 'cash' | 'transfer'
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Ödeme-Ders ilişki tablosu (join table)
class LessonPayments extends Table {
  TextColumn get id => text()();
  TextColumn get paymentId => text()(); // Foreign key (Payments.id)
  TextColumn get lessonId => text()(); // Foreign key (Lessons.id)
  IntColumn get appliedAmount => integer()(); // Bu ödemenin o derse uygulanan kısmı
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
  
  @override
  List<Set<Column>> get uniqueKeys => [
    {paymentId, lessonId}, // Aynı ödeme aynı derse birden fazla kez uygulanamaz
  ];
}

/// Müfredat: Ders (branş)
class CurriculumSubjects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Müfredat: Ünite (ders altında)
class CurriculumUnits extends Table {
  TextColumn get id => text()();
  TextColumn get subjectId => text()(); // CurriculumSubjects.id
  TextColumn get name => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Müfredat: Konu (ünite altında)
class CurriculumTopics extends Table {
  TextColumn get id => text()();
  TextColumn get unitId => text()(); // CurriculumUnits.id
  TextColumn get name => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Müfredat: Kazanım (konu altında)
class CurriculumOutcomes extends Table {
  TextColumn get id => text()();
  TextColumn get topicId => text()(); // CurriculumTopics.id
  TextColumn get name => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
