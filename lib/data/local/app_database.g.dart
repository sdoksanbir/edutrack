// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $StudentsTable extends Students with TableInfo<$StudentsTable, Student> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hourlyRateMeta = const VerificationMeta(
    'hourlyRate',
  );
  @override
  late final GeneratedColumn<int> hourlyRate = GeneratedColumn<int>(
    'hourly_rate',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _guardianFullNameMeta = const VerificationMeta(
    'guardianFullName',
  );
  @override
  late final GeneratedColumn<String> guardianFullName = GeneratedColumn<String>(
    'guardian_full_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _guardianPhoneMeta = const VerificationMeta(
    'guardianPhone',
  );
  @override
  late final GeneratedColumn<String> guardianPhone = GeneratedColumn<String>(
    'guardian_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bookResourceMeta = const VerificationMeta(
    'bookResource',
  );
  @override
  late final GeneratedColumn<String> bookResource = GeneratedColumn<String>(
    'book_resource',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bookResourcePracticeMeta =
      const VerificationMeta('bookResourcePractice');
  @override
  late final GeneratedColumn<String> bookResourcePractice =
      GeneratedColumn<String>(
        'book_resource_practice',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fullName,
    phone,
    hourlyRate,
    notes,
    isActive,
    guardianFullName,
    guardianPhone,
    bookResource,
    bookResourcePractice,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'students';
  @override
  VerificationContext validateIntegrity(
    Insertable<Student> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('hourly_rate')) {
      context.handle(
        _hourlyRateMeta,
        hourlyRate.isAcceptableOrUnknown(data['hourly_rate']!, _hourlyRateMeta),
      );
    } else if (isInserting) {
      context.missing(_hourlyRateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('guardian_full_name')) {
      context.handle(
        _guardianFullNameMeta,
        guardianFullName.isAcceptableOrUnknown(
          data['guardian_full_name']!,
          _guardianFullNameMeta,
        ),
      );
    }
    if (data.containsKey('guardian_phone')) {
      context.handle(
        _guardianPhoneMeta,
        guardianPhone.isAcceptableOrUnknown(
          data['guardian_phone']!,
          _guardianPhoneMeta,
        ),
      );
    }
    if (data.containsKey('book_resource')) {
      context.handle(
        _bookResourceMeta,
        bookResource.isAcceptableOrUnknown(
          data['book_resource']!,
          _bookResourceMeta,
        ),
      );
    }
    if (data.containsKey('book_resource_practice')) {
      context.handle(
        _bookResourcePracticeMeta,
        bookResourcePractice.isAcceptableOrUnknown(
          data['book_resource_practice']!,
          _bookResourcePracticeMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Student map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Student(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      hourlyRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hourly_rate'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      guardianFullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guardian_full_name'],
      ),
      guardianPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guardian_phone'],
      ),
      bookResource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_resource'],
      ),
      bookResourcePractice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_resource_practice'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StudentsTable createAlias(String alias) {
    return $StudentsTable(attachedDatabase, alias);
  }
}

class Student extends DataClass implements Insertable<Student> {
  final String id;
  final String fullName;
  final String? phone;
  final int hourlyRate;
  final String? notes;
  final bool isActive;
  final String? guardianFullName;
  final String? guardianPhone;
  final String? bookResource;
  final String? bookResourcePractice;
  final DateTime createdAt;
  const Student({
    required this.id,
    required this.fullName,
    this.phone,
    required this.hourlyRate,
    this.notes,
    required this.isActive,
    this.guardianFullName,
    this.guardianPhone,
    this.bookResource,
    this.bookResourcePractice,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['hourly_rate'] = Variable<int>(hourlyRate);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || guardianFullName != null) {
      map['guardian_full_name'] = Variable<String>(guardianFullName);
    }
    if (!nullToAbsent || guardianPhone != null) {
      map['guardian_phone'] = Variable<String>(guardianPhone);
    }
    if (!nullToAbsent || bookResource != null) {
      map['book_resource'] = Variable<String>(bookResource);
    }
    if (!nullToAbsent || bookResourcePractice != null) {
      map['book_resource_practice'] = Variable<String>(bookResourcePractice);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StudentsCompanion toCompanion(bool nullToAbsent) {
    return StudentsCompanion(
      id: Value(id),
      fullName: Value(fullName),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      hourlyRate: Value(hourlyRate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isActive: Value(isActive),
      guardianFullName: guardianFullName == null && nullToAbsent
          ? const Value.absent()
          : Value(guardianFullName),
      guardianPhone: guardianPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(guardianPhone),
      bookResource: bookResource == null && nullToAbsent
          ? const Value.absent()
          : Value(bookResource),
      bookResourcePractice: bookResourcePractice == null && nullToAbsent
          ? const Value.absent()
          : Value(bookResourcePractice),
      createdAt: Value(createdAt),
    );
  }

  factory Student.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Student(
      id: serializer.fromJson<String>(json['id']),
      fullName: serializer.fromJson<String>(json['fullName']),
      phone: serializer.fromJson<String?>(json['phone']),
      hourlyRate: serializer.fromJson<int>(json['hourlyRate']),
      notes: serializer.fromJson<String?>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      guardianFullName: serializer.fromJson<String?>(json['guardianFullName']),
      guardianPhone: serializer.fromJson<String?>(json['guardianPhone']),
      bookResource: serializer.fromJson<String?>(json['bookResource']),
      bookResourcePractice: serializer.fromJson<String?>(
        json['bookResourcePractice'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fullName': serializer.toJson<String>(fullName),
      'phone': serializer.toJson<String?>(phone),
      'hourlyRate': serializer.toJson<int>(hourlyRate),
      'notes': serializer.toJson<String?>(notes),
      'isActive': serializer.toJson<bool>(isActive),
      'guardianFullName': serializer.toJson<String?>(guardianFullName),
      'guardianPhone': serializer.toJson<String?>(guardianPhone),
      'bookResource': serializer.toJson<String?>(bookResource),
      'bookResourcePractice': serializer.toJson<String?>(bookResourcePractice),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Student copyWith({
    String? id,
    String? fullName,
    Value<String?> phone = const Value.absent(),
    int? hourlyRate,
    Value<String?> notes = const Value.absent(),
    bool? isActive,
    Value<String?> guardianFullName = const Value.absent(),
    Value<String?> guardianPhone = const Value.absent(),
    Value<String?> bookResource = const Value.absent(),
    Value<String?> bookResourcePractice = const Value.absent(),
    DateTime? createdAt,
  }) => Student(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    phone: phone.present ? phone.value : this.phone,
    hourlyRate: hourlyRate ?? this.hourlyRate,
    notes: notes.present ? notes.value : this.notes,
    isActive: isActive ?? this.isActive,
    guardianFullName: guardianFullName.present
        ? guardianFullName.value
        : this.guardianFullName,
    guardianPhone: guardianPhone.present
        ? guardianPhone.value
        : this.guardianPhone,
    bookResource: bookResource.present ? bookResource.value : this.bookResource,
    bookResourcePractice: bookResourcePractice.present
        ? bookResourcePractice.value
        : this.bookResourcePractice,
    createdAt: createdAt ?? this.createdAt,
  );
  Student copyWithCompanion(StudentsCompanion data) {
    return Student(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      phone: data.phone.present ? data.phone.value : this.phone,
      hourlyRate: data.hourlyRate.present
          ? data.hourlyRate.value
          : this.hourlyRate,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      guardianFullName: data.guardianFullName.present
          ? data.guardianFullName.value
          : this.guardianFullName,
      guardianPhone: data.guardianPhone.present
          ? data.guardianPhone.value
          : this.guardianPhone,
      bookResource: data.bookResource.present
          ? data.bookResource.value
          : this.bookResource,
      bookResourcePractice: data.bookResourcePractice.present
          ? data.bookResourcePractice.value
          : this.bookResourcePractice,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Student(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('phone: $phone, ')
          ..write('hourlyRate: $hourlyRate, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('guardianFullName: $guardianFullName, ')
          ..write('guardianPhone: $guardianPhone, ')
          ..write('bookResource: $bookResource, ')
          ..write('bookResourcePractice: $bookResourcePractice, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fullName,
    phone,
    hourlyRate,
    notes,
    isActive,
    guardianFullName,
    guardianPhone,
    bookResource,
    bookResourcePractice,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Student &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.phone == this.phone &&
          other.hourlyRate == this.hourlyRate &&
          other.notes == this.notes &&
          other.isActive == this.isActive &&
          other.guardianFullName == this.guardianFullName &&
          other.guardianPhone == this.guardianPhone &&
          other.bookResource == this.bookResource &&
          other.bookResourcePractice == this.bookResourcePractice &&
          other.createdAt == this.createdAt);
}

class StudentsCompanion extends UpdateCompanion<Student> {
  final Value<String> id;
  final Value<String> fullName;
  final Value<String?> phone;
  final Value<int> hourlyRate;
  final Value<String?> notes;
  final Value<bool> isActive;
  final Value<String?> guardianFullName;
  final Value<String?> guardianPhone;
  final Value<String?> bookResource;
  final Value<String?> bookResourcePractice;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StudentsCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.phone = const Value.absent(),
    this.hourlyRate = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.guardianFullName = const Value.absent(),
    this.guardianPhone = const Value.absent(),
    this.bookResource = const Value.absent(),
    this.bookResourcePractice = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudentsCompanion.insert({
    required String id,
    required String fullName,
    this.phone = const Value.absent(),
    required int hourlyRate,
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.guardianFullName = const Value.absent(),
    this.guardianPhone = const Value.absent(),
    this.bookResource = const Value.absent(),
    this.bookResourcePractice = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fullName = Value(fullName),
       hourlyRate = Value(hourlyRate),
       createdAt = Value(createdAt);
  static Insertable<Student> custom({
    Expression<String>? id,
    Expression<String>? fullName,
    Expression<String>? phone,
    Expression<int>? hourlyRate,
    Expression<String>? notes,
    Expression<bool>? isActive,
    Expression<String>? guardianFullName,
    Expression<String>? guardianPhone,
    Expression<String>? bookResource,
    Expression<String>? bookResourcePractice,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (hourlyRate != null) 'hourly_rate': hourlyRate,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (guardianFullName != null) 'guardian_full_name': guardianFullName,
      if (guardianPhone != null) 'guardian_phone': guardianPhone,
      if (bookResource != null) 'book_resource': bookResource,
      if (bookResourcePractice != null)
        'book_resource_practice': bookResourcePractice,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudentsCompanion copyWith({
    Value<String>? id,
    Value<String>? fullName,
    Value<String?>? phone,
    Value<int>? hourlyRate,
    Value<String?>? notes,
    Value<bool>? isActive,
    Value<String?>? guardianFullName,
    Value<String?>? guardianPhone,
    Value<String?>? bookResource,
    Value<String?>? bookResourcePractice,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return StudentsCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      guardianFullName: guardianFullName ?? this.guardianFullName,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      bookResource: bookResource ?? this.bookResource,
      bookResourcePractice: bookResourcePractice ?? this.bookResourcePractice,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (hourlyRate.present) {
      map['hourly_rate'] = Variable<int>(hourlyRate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (guardianFullName.present) {
      map['guardian_full_name'] = Variable<String>(guardianFullName.value);
    }
    if (guardianPhone.present) {
      map['guardian_phone'] = Variable<String>(guardianPhone.value);
    }
    if (bookResource.present) {
      map['book_resource'] = Variable<String>(bookResource.value);
    }
    if (bookResourcePractice.present) {
      map['book_resource_practice'] = Variable<String>(
        bookResourcePractice.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentsCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('phone: $phone, ')
          ..write('hourlyRate: $hourlyRate, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('guardianFullName: $guardianFullName, ')
          ..write('guardianPhone: $guardianPhone, ')
          ..write('bookResource: $bookResource, ')
          ..write('bookResourcePractice: $bookResourcePractice, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduleTemplatesTable extends ScheduleTemplates
    with TableInfo<$ScheduleTemplatesTable, ScheduleTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekdayMeta = const VerificationMeta(
    'weekday',
  );
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinMeta = const VerificationMeta(
    'durationMin',
  );
  @override
  late final GeneratedColumn<int> durationMin = GeneratedColumn<int>(
    'duration_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    weekday,
    startTime,
    durationMin,
    startDate,
    endDate,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('weekday')) {
      context.handle(
        _weekdayMeta,
        weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta),
      );
    } else if (isInserting) {
      context.missing(_weekdayMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('duration_min')) {
      context.handle(
        _durationMinMeta,
        durationMin.isAcceptableOrUnknown(
          data['duration_min']!,
          _durationMinMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {studentId, weekday, startTime},
  ];
  @override
  ScheduleTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleTemplate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      weekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      )!,
      durationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_min'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_date'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ScheduleTemplatesTable createAlias(String alias) {
    return $ScheduleTemplatesTable(attachedDatabase, alias);
  }
}

class ScheduleTemplate extends DataClass
    implements Insertable<ScheduleTemplate> {
  final String id;
  final String studentId;
  final int weekday;
  final String startTime;
  final int durationMin;
  final String startDate;
  final String? endDate;
  final bool isActive;
  final DateTime createdAt;
  const ScheduleTemplate({
    required this.id,
    required this.studentId,
    required this.weekday,
    required this.startTime,
    required this.durationMin,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_id'] = Variable<String>(studentId);
    map['weekday'] = Variable<int>(weekday);
    map['start_time'] = Variable<String>(startTime);
    map['duration_min'] = Variable<int>(durationMin);
    map['start_date'] = Variable<String>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ScheduleTemplatesCompanion toCompanion(bool nullToAbsent) {
    return ScheduleTemplatesCompanion(
      id: Value(id),
      studentId: Value(studentId),
      weekday: Value(weekday),
      startTime: Value(startTime),
      durationMin: Value(durationMin),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory ScheduleTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleTemplate(
      id: serializer.fromJson<String>(json['id']),
      studentId: serializer.fromJson<String>(json['studentId']),
      weekday: serializer.fromJson<int>(json['weekday']),
      startTime: serializer.fromJson<String>(json['startTime']),
      durationMin: serializer.fromJson<int>(json['durationMin']),
      startDate: serializer.fromJson<String>(json['startDate']),
      endDate: serializer.fromJson<String?>(json['endDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studentId': serializer.toJson<String>(studentId),
      'weekday': serializer.toJson<int>(weekday),
      'startTime': serializer.toJson<String>(startTime),
      'durationMin': serializer.toJson<int>(durationMin),
      'startDate': serializer.toJson<String>(startDate),
      'endDate': serializer.toJson<String?>(endDate),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ScheduleTemplate copyWith({
    String? id,
    String? studentId,
    int? weekday,
    String? startTime,
    int? durationMin,
    String? startDate,
    Value<String?> endDate = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
  }) => ScheduleTemplate(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    weekday: weekday ?? this.weekday,
    startTime: startTime ?? this.startTime,
    durationMin: durationMin ?? this.durationMin,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  ScheduleTemplate copyWithCompanion(ScheduleTemplatesCompanion data) {
    return ScheduleTemplate(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      durationMin: data.durationMin.present
          ? data.durationMin.value
          : this.durationMin,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleTemplate(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('weekday: $weekday, ')
          ..write('startTime: $startTime, ')
          ..write('durationMin: $durationMin, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentId,
    weekday,
    startTime,
    durationMin,
    startDate,
    endDate,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleTemplate &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.weekday == this.weekday &&
          other.startTime == this.startTime &&
          other.durationMin == this.durationMin &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class ScheduleTemplatesCompanion extends UpdateCompanion<ScheduleTemplate> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<int> weekday;
  final Value<String> startTime;
  final Value<int> durationMin;
  final Value<String> startDate;
  final Value<String?> endDate;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ScheduleTemplatesCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.weekday = const Value.absent(),
    this.startTime = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScheduleTemplatesCompanion.insert({
    required String id,
    required String studentId,
    required int weekday,
    required String startTime,
    required int durationMin,
    required String startDate,
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       weekday = Value(weekday),
       startTime = Value(startTime),
       durationMin = Value(durationMin),
       startDate = Value(startDate),
       createdAt = Value(createdAt);
  static Insertable<ScheduleTemplate> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<int>? weekday,
    Expression<String>? startTime,
    Expression<int>? durationMin,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (weekday != null) 'weekday': weekday,
      if (startTime != null) 'start_time': startTime,
      if (durationMin != null) 'duration_min': durationMin,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScheduleTemplatesCompanion copyWith({
    Value<String>? id,
    Value<String>? studentId,
    Value<int>? weekday,
    Value<String>? startTime,
    Value<int>? durationMin,
    Value<String>? startDate,
    Value<String?>? endDate,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ScheduleTemplatesCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      weekday: weekday ?? this.weekday,
      startTime: startTime ?? this.startTime,
      durationMin: durationMin ?? this.durationMin,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (durationMin.present) {
      map['duration_min'] = Variable<int>(durationMin.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('weekday: $weekday, ')
          ..write('startTime: $startTime, ')
          ..write('durationMin: $durationMin, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduleOverridesTable extends ScheduleOverrides
    with TableInfo<$ScheduleOverridesTable, ScheduleOverride> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleOverridesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _overrideTypeMeta = const VerificationMeta(
    'overrideType',
  );
  @override
  late final GeneratedColumn<String> overrideType = GeneratedColumn<String>(
    'override_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _newWeekdayMeta = const VerificationMeta(
    'newWeekday',
  );
  @override
  late final GeneratedColumn<int> newWeekday = GeneratedColumn<int>(
    'new_weekday',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newStartTimeMeta = const VerificationMeta(
    'newStartTime',
  );
  @override
  late final GeneratedColumn<String> newStartTime = GeneratedColumn<String>(
    'new_start_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newDurationMinMeta = const VerificationMeta(
    'newDurationMin',
  );
  @override
  late final GeneratedColumn<int> newDurationMin = GeneratedColumn<int>(
    'new_duration_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    templateId,
    date,
    overrideType,
    newWeekday,
    newStartTime,
    newDurationMin,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_overrides';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleOverride> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('override_type')) {
      context.handle(
        _overrideTypeMeta,
        overrideType.isAcceptableOrUnknown(
          data['override_type']!,
          _overrideTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_overrideTypeMeta);
    }
    if (data.containsKey('new_weekday')) {
      context.handle(
        _newWeekdayMeta,
        newWeekday.isAcceptableOrUnknown(data['new_weekday']!, _newWeekdayMeta),
      );
    }
    if (data.containsKey('new_start_time')) {
      context.handle(
        _newStartTimeMeta,
        newStartTime.isAcceptableOrUnknown(
          data['new_start_time']!,
          _newStartTimeMeta,
        ),
      );
    }
    if (data.containsKey('new_duration_min')) {
      context.handle(
        _newDurationMinMeta,
        newDurationMin.isAcceptableOrUnknown(
          data['new_duration_min']!,
          _newDurationMinMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduleOverride map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleOverride(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      overrideType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}override_type'],
      )!,
      newWeekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_weekday'],
      ),
      newStartTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_start_time'],
      ),
      newDurationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_duration_min'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ScheduleOverridesTable createAlias(String alias) {
    return $ScheduleOverridesTable(attachedDatabase, alias);
  }
}

class ScheduleOverride extends DataClass
    implements Insertable<ScheduleOverride> {
  final String id;
  final String templateId;
  final String date;
  final String overrideType;
  final int? newWeekday;
  final String? newStartTime;
  final int? newDurationMin;
  final DateTime createdAt;
  const ScheduleOverride({
    required this.id,
    required this.templateId,
    required this.date,
    required this.overrideType,
    this.newWeekday,
    this.newStartTime,
    this.newDurationMin,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_id'] = Variable<String>(templateId);
    map['date'] = Variable<String>(date);
    map['override_type'] = Variable<String>(overrideType);
    if (!nullToAbsent || newWeekday != null) {
      map['new_weekday'] = Variable<int>(newWeekday);
    }
    if (!nullToAbsent || newStartTime != null) {
      map['new_start_time'] = Variable<String>(newStartTime);
    }
    if (!nullToAbsent || newDurationMin != null) {
      map['new_duration_min'] = Variable<int>(newDurationMin);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ScheduleOverridesCompanion toCompanion(bool nullToAbsent) {
    return ScheduleOverridesCompanion(
      id: Value(id),
      templateId: Value(templateId),
      date: Value(date),
      overrideType: Value(overrideType),
      newWeekday: newWeekday == null && nullToAbsent
          ? const Value.absent()
          : Value(newWeekday),
      newStartTime: newStartTime == null && nullToAbsent
          ? const Value.absent()
          : Value(newStartTime),
      newDurationMin: newDurationMin == null && nullToAbsent
          ? const Value.absent()
          : Value(newDurationMin),
      createdAt: Value(createdAt),
    );
  }

  factory ScheduleOverride.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleOverride(
      id: serializer.fromJson<String>(json['id']),
      templateId: serializer.fromJson<String>(json['templateId']),
      date: serializer.fromJson<String>(json['date']),
      overrideType: serializer.fromJson<String>(json['overrideType']),
      newWeekday: serializer.fromJson<int?>(json['newWeekday']),
      newStartTime: serializer.fromJson<String?>(json['newStartTime']),
      newDurationMin: serializer.fromJson<int?>(json['newDurationMin']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'templateId': serializer.toJson<String>(templateId),
      'date': serializer.toJson<String>(date),
      'overrideType': serializer.toJson<String>(overrideType),
      'newWeekday': serializer.toJson<int?>(newWeekday),
      'newStartTime': serializer.toJson<String?>(newStartTime),
      'newDurationMin': serializer.toJson<int?>(newDurationMin),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ScheduleOverride copyWith({
    String? id,
    String? templateId,
    String? date,
    String? overrideType,
    Value<int?> newWeekday = const Value.absent(),
    Value<String?> newStartTime = const Value.absent(),
    Value<int?> newDurationMin = const Value.absent(),
    DateTime? createdAt,
  }) => ScheduleOverride(
    id: id ?? this.id,
    templateId: templateId ?? this.templateId,
    date: date ?? this.date,
    overrideType: overrideType ?? this.overrideType,
    newWeekday: newWeekday.present ? newWeekday.value : this.newWeekday,
    newStartTime: newStartTime.present ? newStartTime.value : this.newStartTime,
    newDurationMin: newDurationMin.present
        ? newDurationMin.value
        : this.newDurationMin,
    createdAt: createdAt ?? this.createdAt,
  );
  ScheduleOverride copyWithCompanion(ScheduleOverridesCompanion data) {
    return ScheduleOverride(
      id: data.id.present ? data.id.value : this.id,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      date: data.date.present ? data.date.value : this.date,
      overrideType: data.overrideType.present
          ? data.overrideType.value
          : this.overrideType,
      newWeekday: data.newWeekday.present
          ? data.newWeekday.value
          : this.newWeekday,
      newStartTime: data.newStartTime.present
          ? data.newStartTime.value
          : this.newStartTime,
      newDurationMin: data.newDurationMin.present
          ? data.newDurationMin.value
          : this.newDurationMin,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleOverride(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('date: $date, ')
          ..write('overrideType: $overrideType, ')
          ..write('newWeekday: $newWeekday, ')
          ..write('newStartTime: $newStartTime, ')
          ..write('newDurationMin: $newDurationMin, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    templateId,
    date,
    overrideType,
    newWeekday,
    newStartTime,
    newDurationMin,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleOverride &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.date == this.date &&
          other.overrideType == this.overrideType &&
          other.newWeekday == this.newWeekday &&
          other.newStartTime == this.newStartTime &&
          other.newDurationMin == this.newDurationMin &&
          other.createdAt == this.createdAt);
}

class ScheduleOverridesCompanion extends UpdateCompanion<ScheduleOverride> {
  final Value<String> id;
  final Value<String> templateId;
  final Value<String> date;
  final Value<String> overrideType;
  final Value<int?> newWeekday;
  final Value<String?> newStartTime;
  final Value<int?> newDurationMin;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ScheduleOverridesCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.date = const Value.absent(),
    this.overrideType = const Value.absent(),
    this.newWeekday = const Value.absent(),
    this.newStartTime = const Value.absent(),
    this.newDurationMin = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScheduleOverridesCompanion.insert({
    required String id,
    required String templateId,
    required String date,
    required String overrideType,
    this.newWeekday = const Value.absent(),
    this.newStartTime = const Value.absent(),
    this.newDurationMin = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       templateId = Value(templateId),
       date = Value(date),
       overrideType = Value(overrideType),
       createdAt = Value(createdAt);
  static Insertable<ScheduleOverride> custom({
    Expression<String>? id,
    Expression<String>? templateId,
    Expression<String>? date,
    Expression<String>? overrideType,
    Expression<int>? newWeekday,
    Expression<String>? newStartTime,
    Expression<int>? newDurationMin,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (date != null) 'date': date,
      if (overrideType != null) 'override_type': overrideType,
      if (newWeekday != null) 'new_weekday': newWeekday,
      if (newStartTime != null) 'new_start_time': newStartTime,
      if (newDurationMin != null) 'new_duration_min': newDurationMin,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScheduleOverridesCompanion copyWith({
    Value<String>? id,
    Value<String>? templateId,
    Value<String>? date,
    Value<String>? overrideType,
    Value<int?>? newWeekday,
    Value<String?>? newStartTime,
    Value<int?>? newDurationMin,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ScheduleOverridesCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      date: date ?? this.date,
      overrideType: overrideType ?? this.overrideType,
      newWeekday: newWeekday ?? this.newWeekday,
      newStartTime: newStartTime ?? this.newStartTime,
      newDurationMin: newDurationMin ?? this.newDurationMin,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (overrideType.present) {
      map['override_type'] = Variable<String>(overrideType.value);
    }
    if (newWeekday.present) {
      map['new_weekday'] = Variable<int>(newWeekday.value);
    }
    if (newStartTime.present) {
      map['new_start_time'] = Variable<String>(newStartTime.value);
    }
    if (newDurationMin.present) {
      map['new_duration_min'] = Variable<int>(newDurationMin.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleOverridesCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('date: $date, ')
          ..write('overrideType: $overrideType, ')
          ..write('newWeekday: $newWeekday, ')
          ..write('newStartTime: $newStartTime, ')
          ..write('newDurationMin: $newDurationMin, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionOccurrencesTable extends SessionOccurrences
    with TableInfo<$SessionOccurrencesTable, SessionOccurrence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionOccurrencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinMeta = const VerificationMeta(
    'durationMin',
  );
  @override
  late final GeneratedColumn<int> durationMin = GeneratedColumn<int>(
    'duration_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notDoneReasonTypeMeta = const VerificationMeta(
    'notDoneReasonType',
  );
  @override
  late final GeneratedColumn<String> notDoneReasonType =
      GeneratedColumn<String>(
        'not_done_reason_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notDoneReasonNoteMeta = const VerificationMeta(
    'notDoneReasonNote',
  );
  @override
  late final GeneratedColumn<String> notDoneReasonNote =
      GeneratedColumn<String>(
        'not_done_reason_note',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _paymentIdMeta = const VerificationMeta(
    'paymentId',
  );
  @override
  late final GeneratedColumn<String> paymentId = GeneratedColumn<String>(
    'payment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _postponedFromDateMeta = const VerificationMeta(
    'postponedFromDate',
  );
  @override
  late final GeneratedColumn<String> postponedFromDate =
      GeneratedColumn<String>(
        'postponed_from_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _postponedReasonMeta = const VerificationMeta(
    'postponedReason',
  );
  @override
  late final GeneratedColumn<String> postponedReason = GeneratedColumn<String>(
    'postponed_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    templateId,
    date,
    startTime,
    durationMin,
    status,
    notDoneReasonType,
    notDoneReasonNote,
    paymentId,
    completedAt,
    postponedFromDate,
    postponedReason,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_occurrences';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionOccurrence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('duration_min')) {
      context.handle(
        _durationMinMeta,
        durationMin.isAcceptableOrUnknown(
          data['duration_min']!,
          _durationMinMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('not_done_reason_type')) {
      context.handle(
        _notDoneReasonTypeMeta,
        notDoneReasonType.isAcceptableOrUnknown(
          data['not_done_reason_type']!,
          _notDoneReasonTypeMeta,
        ),
      );
    }
    if (data.containsKey('not_done_reason_note')) {
      context.handle(
        _notDoneReasonNoteMeta,
        notDoneReasonNote.isAcceptableOrUnknown(
          data['not_done_reason_note']!,
          _notDoneReasonNoteMeta,
        ),
      );
    }
    if (data.containsKey('payment_id')) {
      context.handle(
        _paymentIdMeta,
        paymentId.isAcceptableOrUnknown(data['payment_id']!, _paymentIdMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('postponed_from_date')) {
      context.handle(
        _postponedFromDateMeta,
        postponedFromDate.isAcceptableOrUnknown(
          data['postponed_from_date']!,
          _postponedFromDateMeta,
        ),
      );
    }
    if (data.containsKey('postponed_reason')) {
      context.handle(
        _postponedReasonMeta,
        postponedReason.isAcceptableOrUnknown(
          data['postponed_reason']!,
          _postponedReasonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {studentId, date, startTime},
  ];
  @override
  SessionOccurrence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionOccurrence(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      )!,
      durationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_min'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notDoneReasonType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}not_done_reason_type'],
      ),
      notDoneReasonNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}not_done_reason_note'],
      ),
      paymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_id'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      postponedFromDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}postponed_from_date'],
      ),
      postponedReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}postponed_reason'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SessionOccurrencesTable createAlias(String alias) {
    return $SessionOccurrencesTable(attachedDatabase, alias);
  }
}

class SessionOccurrence extends DataClass
    implements Insertable<SessionOccurrence> {
  final String id;
  final String studentId;
  final String? templateId;
  final String date;
  final String startTime;
  final int durationMin;
  final String status;
  final String? notDoneReasonType;
  final String? notDoneReasonNote;
  final String? paymentId;
  final DateTime? completedAt;
  final String? postponedFromDate;
  final String? postponedReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SessionOccurrence({
    required this.id,
    required this.studentId,
    this.templateId,
    required this.date,
    required this.startTime,
    required this.durationMin,
    required this.status,
    this.notDoneReasonType,
    this.notDoneReasonNote,
    this.paymentId,
    this.completedAt,
    this.postponedFromDate,
    this.postponedReason,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_id'] = Variable<String>(studentId);
    if (!nullToAbsent || templateId != null) {
      map['template_id'] = Variable<String>(templateId);
    }
    map['date'] = Variable<String>(date);
    map['start_time'] = Variable<String>(startTime);
    map['duration_min'] = Variable<int>(durationMin);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notDoneReasonType != null) {
      map['not_done_reason_type'] = Variable<String>(notDoneReasonType);
    }
    if (!nullToAbsent || notDoneReasonNote != null) {
      map['not_done_reason_note'] = Variable<String>(notDoneReasonNote);
    }
    if (!nullToAbsent || paymentId != null) {
      map['payment_id'] = Variable<String>(paymentId);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || postponedFromDate != null) {
      map['postponed_from_date'] = Variable<String>(postponedFromDate);
    }
    if (!nullToAbsent || postponedReason != null) {
      map['postponed_reason'] = Variable<String>(postponedReason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SessionOccurrencesCompanion toCompanion(bool nullToAbsent) {
    return SessionOccurrencesCompanion(
      id: Value(id),
      studentId: Value(studentId),
      templateId: templateId == null && nullToAbsent
          ? const Value.absent()
          : Value(templateId),
      date: Value(date),
      startTime: Value(startTime),
      durationMin: Value(durationMin),
      status: Value(status),
      notDoneReasonType: notDoneReasonType == null && nullToAbsent
          ? const Value.absent()
          : Value(notDoneReasonType),
      notDoneReasonNote: notDoneReasonNote == null && nullToAbsent
          ? const Value.absent()
          : Value(notDoneReasonNote),
      paymentId: paymentId == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentId),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      postponedFromDate: postponedFromDate == null && nullToAbsent
          ? const Value.absent()
          : Value(postponedFromDate),
      postponedReason: postponedReason == null && nullToAbsent
          ? const Value.absent()
          : Value(postponedReason),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SessionOccurrence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionOccurrence(
      id: serializer.fromJson<String>(json['id']),
      studentId: serializer.fromJson<String>(json['studentId']),
      templateId: serializer.fromJson<String?>(json['templateId']),
      date: serializer.fromJson<String>(json['date']),
      startTime: serializer.fromJson<String>(json['startTime']),
      durationMin: serializer.fromJson<int>(json['durationMin']),
      status: serializer.fromJson<String>(json['status']),
      notDoneReasonType: serializer.fromJson<String?>(
        json['notDoneReasonType'],
      ),
      notDoneReasonNote: serializer.fromJson<String?>(
        json['notDoneReasonNote'],
      ),
      paymentId: serializer.fromJson<String?>(json['paymentId']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      postponedFromDate: serializer.fromJson<String?>(
        json['postponedFromDate'],
      ),
      postponedReason: serializer.fromJson<String?>(json['postponedReason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studentId': serializer.toJson<String>(studentId),
      'templateId': serializer.toJson<String?>(templateId),
      'date': serializer.toJson<String>(date),
      'startTime': serializer.toJson<String>(startTime),
      'durationMin': serializer.toJson<int>(durationMin),
      'status': serializer.toJson<String>(status),
      'notDoneReasonType': serializer.toJson<String?>(notDoneReasonType),
      'notDoneReasonNote': serializer.toJson<String?>(notDoneReasonNote),
      'paymentId': serializer.toJson<String?>(paymentId),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'postponedFromDate': serializer.toJson<String?>(postponedFromDate),
      'postponedReason': serializer.toJson<String?>(postponedReason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SessionOccurrence copyWith({
    String? id,
    String? studentId,
    Value<String?> templateId = const Value.absent(),
    String? date,
    String? startTime,
    int? durationMin,
    String? status,
    Value<String?> notDoneReasonType = const Value.absent(),
    Value<String?> notDoneReasonNote = const Value.absent(),
    Value<String?> paymentId = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> postponedFromDate = const Value.absent(),
    Value<String?> postponedReason = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SessionOccurrence(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    templateId: templateId.present ? templateId.value : this.templateId,
    date: date ?? this.date,
    startTime: startTime ?? this.startTime,
    durationMin: durationMin ?? this.durationMin,
    status: status ?? this.status,
    notDoneReasonType: notDoneReasonType.present
        ? notDoneReasonType.value
        : this.notDoneReasonType,
    notDoneReasonNote: notDoneReasonNote.present
        ? notDoneReasonNote.value
        : this.notDoneReasonNote,
    paymentId: paymentId.present ? paymentId.value : this.paymentId,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    postponedFromDate: postponedFromDate.present
        ? postponedFromDate.value
        : this.postponedFromDate,
    postponedReason: postponedReason.present
        ? postponedReason.value
        : this.postponedReason,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SessionOccurrence copyWithCompanion(SessionOccurrencesCompanion data) {
    return SessionOccurrence(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      date: data.date.present ? data.date.value : this.date,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      durationMin: data.durationMin.present
          ? data.durationMin.value
          : this.durationMin,
      status: data.status.present ? data.status.value : this.status,
      notDoneReasonType: data.notDoneReasonType.present
          ? data.notDoneReasonType.value
          : this.notDoneReasonType,
      notDoneReasonNote: data.notDoneReasonNote.present
          ? data.notDoneReasonNote.value
          : this.notDoneReasonNote,
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      postponedFromDate: data.postponedFromDate.present
          ? data.postponedFromDate.value
          : this.postponedFromDate,
      postponedReason: data.postponedReason.present
          ? data.postponedReason.value
          : this.postponedReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionOccurrence(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('templateId: $templateId, ')
          ..write('date: $date, ')
          ..write('startTime: $startTime, ')
          ..write('durationMin: $durationMin, ')
          ..write('status: $status, ')
          ..write('notDoneReasonType: $notDoneReasonType, ')
          ..write('notDoneReasonNote: $notDoneReasonNote, ')
          ..write('paymentId: $paymentId, ')
          ..write('completedAt: $completedAt, ')
          ..write('postponedFromDate: $postponedFromDate, ')
          ..write('postponedReason: $postponedReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentId,
    templateId,
    date,
    startTime,
    durationMin,
    status,
    notDoneReasonType,
    notDoneReasonNote,
    paymentId,
    completedAt,
    postponedFromDate,
    postponedReason,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionOccurrence &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.templateId == this.templateId &&
          other.date == this.date &&
          other.startTime == this.startTime &&
          other.durationMin == this.durationMin &&
          other.status == this.status &&
          other.notDoneReasonType == this.notDoneReasonType &&
          other.notDoneReasonNote == this.notDoneReasonNote &&
          other.paymentId == this.paymentId &&
          other.completedAt == this.completedAt &&
          other.postponedFromDate == this.postponedFromDate &&
          other.postponedReason == this.postponedReason &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SessionOccurrencesCompanion extends UpdateCompanion<SessionOccurrence> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<String?> templateId;
  final Value<String> date;
  final Value<String> startTime;
  final Value<int> durationMin;
  final Value<String> status;
  final Value<String?> notDoneReasonType;
  final Value<String?> notDoneReasonNote;
  final Value<String?> paymentId;
  final Value<DateTime?> completedAt;
  final Value<String?> postponedFromDate;
  final Value<String?> postponedReason;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SessionOccurrencesCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.templateId = const Value.absent(),
    this.date = const Value.absent(),
    this.startTime = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.status = const Value.absent(),
    this.notDoneReasonType = const Value.absent(),
    this.notDoneReasonNote = const Value.absent(),
    this.paymentId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.postponedFromDate = const Value.absent(),
    this.postponedReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionOccurrencesCompanion.insert({
    required String id,
    required String studentId,
    this.templateId = const Value.absent(),
    required String date,
    required String startTime,
    required int durationMin,
    required String status,
    this.notDoneReasonType = const Value.absent(),
    this.notDoneReasonNote = const Value.absent(),
    this.paymentId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.postponedFromDate = const Value.absent(),
    this.postponedReason = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       date = Value(date),
       startTime = Value(startTime),
       durationMin = Value(durationMin),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SessionOccurrence> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<String>? templateId,
    Expression<String>? date,
    Expression<String>? startTime,
    Expression<int>? durationMin,
    Expression<String>? status,
    Expression<String>? notDoneReasonType,
    Expression<String>? notDoneReasonNote,
    Expression<String>? paymentId,
    Expression<DateTime>? completedAt,
    Expression<String>? postponedFromDate,
    Expression<String>? postponedReason,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (templateId != null) 'template_id': templateId,
      if (date != null) 'date': date,
      if (startTime != null) 'start_time': startTime,
      if (durationMin != null) 'duration_min': durationMin,
      if (status != null) 'status': status,
      if (notDoneReasonType != null) 'not_done_reason_type': notDoneReasonType,
      if (notDoneReasonNote != null) 'not_done_reason_note': notDoneReasonNote,
      if (paymentId != null) 'payment_id': paymentId,
      if (completedAt != null) 'completed_at': completedAt,
      if (postponedFromDate != null) 'postponed_from_date': postponedFromDate,
      if (postponedReason != null) 'postponed_reason': postponedReason,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionOccurrencesCompanion copyWith({
    Value<String>? id,
    Value<String>? studentId,
    Value<String?>? templateId,
    Value<String>? date,
    Value<String>? startTime,
    Value<int>? durationMin,
    Value<String>? status,
    Value<String?>? notDoneReasonType,
    Value<String?>? notDoneReasonNote,
    Value<String?>? paymentId,
    Value<DateTime?>? completedAt,
    Value<String?>? postponedFromDate,
    Value<String?>? postponedReason,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SessionOccurrencesCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      templateId: templateId ?? this.templateId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      durationMin: durationMin ?? this.durationMin,
      status: status ?? this.status,
      notDoneReasonType: notDoneReasonType ?? this.notDoneReasonType,
      notDoneReasonNote: notDoneReasonNote ?? this.notDoneReasonNote,
      paymentId: paymentId ?? this.paymentId,
      completedAt: completedAt ?? this.completedAt,
      postponedFromDate: postponedFromDate ?? this.postponedFromDate,
      postponedReason: postponedReason ?? this.postponedReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (durationMin.present) {
      map['duration_min'] = Variable<int>(durationMin.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notDoneReasonType.present) {
      map['not_done_reason_type'] = Variable<String>(notDoneReasonType.value);
    }
    if (notDoneReasonNote.present) {
      map['not_done_reason_note'] = Variable<String>(notDoneReasonNote.value);
    }
    if (paymentId.present) {
      map['payment_id'] = Variable<String>(paymentId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (postponedFromDate.present) {
      map['postponed_from_date'] = Variable<String>(postponedFromDate.value);
    }
    if (postponedReason.present) {
      map['postponed_reason'] = Variable<String>(postponedReason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionOccurrencesCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('templateId: $templateId, ')
          ..write('date: $date, ')
          ..write('startTime: $startTime, ')
          ..write('durationMin: $durationMin, ')
          ..write('status: $status, ')
          ..write('notDoneReasonType: $notDoneReasonType, ')
          ..write('notDoneReasonNote: $notDoneReasonNote, ')
          ..write('paymentId: $paymentId, ')
          ..write('completedAt: $completedAt, ')
          ..write('postponedFromDate: $postponedFromDate, ')
          ..write('postponedReason: $postponedReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LessonsTable extends Lessons with TableInfo<$LessonsTable, Lesson> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LessonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurrenceIdMeta = const VerificationMeta(
    'occurrenceId',
  );
  @override
  late final GeneratedColumn<String> occurrenceId = GeneratedColumn<String>(
    'occurrence_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateTimeMeta = const VerificationMeta(
    'startDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> startDateTime =
      GeneratedColumn<DateTime>(
        'start_date_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _durationMinMeta = const VerificationMeta(
    'durationMin',
  );
  @override
  late final GeneratedColumn<int> durationMin = GeneratedColumn<int>(
    'duration_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
    'topic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _homeworkMeta = const VerificationMeta(
    'homework',
  );
  @override
  late final GeneratedColumn<String> homework = GeneratedColumn<String>(
    'homework',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _homeworkResourceMeta = const VerificationMeta(
    'homeworkResource',
  );
  @override
  late final GeneratedColumn<String> homeworkResource = GeneratedColumn<String>(
    'homework_resource',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feeExpectedMeta = const VerificationMeta(
    'feeExpected',
  );
  @override
  late final GeneratedColumn<int> feeExpected = GeneratedColumn<int>(
    'fee_expected',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feePaidAmountMeta = const VerificationMeta(
    'feePaidAmount',
  );
  @override
  late final GeneratedColumn<int> feePaidAmount = GeneratedColumn<int>(
    'fee_paid_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lessonNotesMeta = const VerificationMeta(
    'lessonNotes',
  );
  @override
  late final GeneratedColumn<String> lessonNotes = GeneratedColumn<String>(
    'lesson_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusReasonMeta = const VerificationMeta(
    'statusReason',
  );
  @override
  late final GeneratedColumn<String> statusReason = GeneratedColumn<String>(
    'status_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusReasonSourceMeta =
      const VerificationMeta('statusReasonSource');
  @override
  late final GeneratedColumn<String> statusReasonSource =
      GeneratedColumn<String>(
        'status_reason_source',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusChangedAtMeta = const VerificationMeta(
    'statusChangedAt',
  );
  @override
  late final GeneratedColumn<DateTime> statusChangedAt =
      GeneratedColumn<DateTime>(
        'status_changed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    occurrenceId,
    startDateTime,
    durationMin,
    topic,
    homework,
    homeworkResource,
    feeExpected,
    feePaidAmount,
    note,
    lessonNotes,
    status,
    statusReason,
    statusReasonSource,
    statusChangedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lessons';
  @override
  VerificationContext validateIntegrity(
    Insertable<Lesson> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('occurrence_id')) {
      context.handle(
        _occurrenceIdMeta,
        occurrenceId.isAcceptableOrUnknown(
          data['occurrence_id']!,
          _occurrenceIdMeta,
        ),
      );
    }
    if (data.containsKey('start_date_time')) {
      context.handle(
        _startDateTimeMeta,
        startDateTime.isAcceptableOrUnknown(
          data['start_date_time']!,
          _startDateTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startDateTimeMeta);
    }
    if (data.containsKey('duration_min')) {
      context.handle(
        _durationMinMeta,
        durationMin.isAcceptableOrUnknown(
          data['duration_min']!,
          _durationMinMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinMeta);
    }
    if (data.containsKey('topic')) {
      context.handle(
        _topicMeta,
        topic.isAcceptableOrUnknown(data['topic']!, _topicMeta),
      );
    }
    if (data.containsKey('homework')) {
      context.handle(
        _homeworkMeta,
        homework.isAcceptableOrUnknown(data['homework']!, _homeworkMeta),
      );
    }
    if (data.containsKey('homework_resource')) {
      context.handle(
        _homeworkResourceMeta,
        homeworkResource.isAcceptableOrUnknown(
          data['homework_resource']!,
          _homeworkResourceMeta,
        ),
      );
    }
    if (data.containsKey('fee_expected')) {
      context.handle(
        _feeExpectedMeta,
        feeExpected.isAcceptableOrUnknown(
          data['fee_expected']!,
          _feeExpectedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_feeExpectedMeta);
    }
    if (data.containsKey('fee_paid_amount')) {
      context.handle(
        _feePaidAmountMeta,
        feePaidAmount.isAcceptableOrUnknown(
          data['fee_paid_amount']!,
          _feePaidAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_feePaidAmountMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('lesson_notes')) {
      context.handle(
        _lessonNotesMeta,
        lessonNotes.isAcceptableOrUnknown(
          data['lesson_notes']!,
          _lessonNotesMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('status_reason')) {
      context.handle(
        _statusReasonMeta,
        statusReason.isAcceptableOrUnknown(
          data['status_reason']!,
          _statusReasonMeta,
        ),
      );
    }
    if (data.containsKey('status_reason_source')) {
      context.handle(
        _statusReasonSourceMeta,
        statusReasonSource.isAcceptableOrUnknown(
          data['status_reason_source']!,
          _statusReasonSourceMeta,
        ),
      );
    }
    if (data.containsKey('status_changed_at')) {
      context.handle(
        _statusChangedAtMeta,
        statusChangedAt.isAcceptableOrUnknown(
          data['status_changed_at']!,
          _statusChangedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {occurrenceId},
  ];
  @override
  Lesson map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lesson(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      occurrenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurrence_id'],
      ),
      startDateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date_time'],
      )!,
      durationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_min'],
      )!,
      topic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic'],
      ),
      homework: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}homework'],
      ),
      homeworkResource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}homework_resource'],
      ),
      feeExpected: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fee_expected'],
      )!,
      feePaidAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fee_paid_amount'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      lessonNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_notes'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      statusReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_reason'],
      ),
      statusReasonSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_reason_source'],
      ),
      statusChangedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}status_changed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LessonsTable createAlias(String alias) {
    return $LessonsTable(attachedDatabase, alias);
  }
}

class Lesson extends DataClass implements Insertable<Lesson> {
  final String id;
  final String studentId;
  final String? occurrenceId;
  final DateTime startDateTime;
  final int durationMin;
  final String? topic;
  final String? homework;
  final String? homeworkResource;
  final int feeExpected;
  final int feePaidAmount;
  final String? note;
  final String? lessonNotes;
  final String? status;
  final String? statusReason;
  final String? statusReasonSource;
  final DateTime? statusChangedAt;
  final DateTime createdAt;
  const Lesson({
    required this.id,
    required this.studentId,
    this.occurrenceId,
    required this.startDateTime,
    required this.durationMin,
    this.topic,
    this.homework,
    this.homeworkResource,
    required this.feeExpected,
    required this.feePaidAmount,
    this.note,
    this.lessonNotes,
    this.status,
    this.statusReason,
    this.statusReasonSource,
    this.statusChangedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_id'] = Variable<String>(studentId);
    if (!nullToAbsent || occurrenceId != null) {
      map['occurrence_id'] = Variable<String>(occurrenceId);
    }
    map['start_date_time'] = Variable<DateTime>(startDateTime);
    map['duration_min'] = Variable<int>(durationMin);
    if (!nullToAbsent || topic != null) {
      map['topic'] = Variable<String>(topic);
    }
    if (!nullToAbsent || homework != null) {
      map['homework'] = Variable<String>(homework);
    }
    if (!nullToAbsent || homeworkResource != null) {
      map['homework_resource'] = Variable<String>(homeworkResource);
    }
    map['fee_expected'] = Variable<int>(feeExpected);
    map['fee_paid_amount'] = Variable<int>(feePaidAmount);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || lessonNotes != null) {
      map['lesson_notes'] = Variable<String>(lessonNotes);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || statusReason != null) {
      map['status_reason'] = Variable<String>(statusReason);
    }
    if (!nullToAbsent || statusReasonSource != null) {
      map['status_reason_source'] = Variable<String>(statusReasonSource);
    }
    if (!nullToAbsent || statusChangedAt != null) {
      map['status_changed_at'] = Variable<DateTime>(statusChangedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LessonsCompanion toCompanion(bool nullToAbsent) {
    return LessonsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      occurrenceId: occurrenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(occurrenceId),
      startDateTime: Value(startDateTime),
      durationMin: Value(durationMin),
      topic: topic == null && nullToAbsent
          ? const Value.absent()
          : Value(topic),
      homework: homework == null && nullToAbsent
          ? const Value.absent()
          : Value(homework),
      homeworkResource: homeworkResource == null && nullToAbsent
          ? const Value.absent()
          : Value(homeworkResource),
      feeExpected: Value(feeExpected),
      feePaidAmount: Value(feePaidAmount),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      lessonNotes: lessonNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(lessonNotes),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      statusReason: statusReason == null && nullToAbsent
          ? const Value.absent()
          : Value(statusReason),
      statusReasonSource: statusReasonSource == null && nullToAbsent
          ? const Value.absent()
          : Value(statusReasonSource),
      statusChangedAt: statusChangedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(statusChangedAt),
      createdAt: Value(createdAt),
    );
  }

  factory Lesson.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lesson(
      id: serializer.fromJson<String>(json['id']),
      studentId: serializer.fromJson<String>(json['studentId']),
      occurrenceId: serializer.fromJson<String?>(json['occurrenceId']),
      startDateTime: serializer.fromJson<DateTime>(json['startDateTime']),
      durationMin: serializer.fromJson<int>(json['durationMin']),
      topic: serializer.fromJson<String?>(json['topic']),
      homework: serializer.fromJson<String?>(json['homework']),
      homeworkResource: serializer.fromJson<String?>(json['homeworkResource']),
      feeExpected: serializer.fromJson<int>(json['feeExpected']),
      feePaidAmount: serializer.fromJson<int>(json['feePaidAmount']),
      note: serializer.fromJson<String?>(json['note']),
      lessonNotes: serializer.fromJson<String?>(json['lessonNotes']),
      status: serializer.fromJson<String?>(json['status']),
      statusReason: serializer.fromJson<String?>(json['statusReason']),
      statusReasonSource: serializer.fromJson<String?>(
        json['statusReasonSource'],
      ),
      statusChangedAt: serializer.fromJson<DateTime?>(json['statusChangedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studentId': serializer.toJson<String>(studentId),
      'occurrenceId': serializer.toJson<String?>(occurrenceId),
      'startDateTime': serializer.toJson<DateTime>(startDateTime),
      'durationMin': serializer.toJson<int>(durationMin),
      'topic': serializer.toJson<String?>(topic),
      'homework': serializer.toJson<String?>(homework),
      'homeworkResource': serializer.toJson<String?>(homeworkResource),
      'feeExpected': serializer.toJson<int>(feeExpected),
      'feePaidAmount': serializer.toJson<int>(feePaidAmount),
      'note': serializer.toJson<String?>(note),
      'lessonNotes': serializer.toJson<String?>(lessonNotes),
      'status': serializer.toJson<String?>(status),
      'statusReason': serializer.toJson<String?>(statusReason),
      'statusReasonSource': serializer.toJson<String?>(statusReasonSource),
      'statusChangedAt': serializer.toJson<DateTime?>(statusChangedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Lesson copyWith({
    String? id,
    String? studentId,
    Value<String?> occurrenceId = const Value.absent(),
    DateTime? startDateTime,
    int? durationMin,
    Value<String?> topic = const Value.absent(),
    Value<String?> homework = const Value.absent(),
    Value<String?> homeworkResource = const Value.absent(),
    int? feeExpected,
    int? feePaidAmount,
    Value<String?> note = const Value.absent(),
    Value<String?> lessonNotes = const Value.absent(),
    Value<String?> status = const Value.absent(),
    Value<String?> statusReason = const Value.absent(),
    Value<String?> statusReasonSource = const Value.absent(),
    Value<DateTime?> statusChangedAt = const Value.absent(),
    DateTime? createdAt,
  }) => Lesson(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    occurrenceId: occurrenceId.present ? occurrenceId.value : this.occurrenceId,
    startDateTime: startDateTime ?? this.startDateTime,
    durationMin: durationMin ?? this.durationMin,
    topic: topic.present ? topic.value : this.topic,
    homework: homework.present ? homework.value : this.homework,
    homeworkResource: homeworkResource.present
        ? homeworkResource.value
        : this.homeworkResource,
    feeExpected: feeExpected ?? this.feeExpected,
    feePaidAmount: feePaidAmount ?? this.feePaidAmount,
    note: note.present ? note.value : this.note,
    lessonNotes: lessonNotes.present ? lessonNotes.value : this.lessonNotes,
    status: status.present ? status.value : this.status,
    statusReason: statusReason.present ? statusReason.value : this.statusReason,
    statusReasonSource: statusReasonSource.present
        ? statusReasonSource.value
        : this.statusReasonSource,
    statusChangedAt: statusChangedAt.present
        ? statusChangedAt.value
        : this.statusChangedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  Lesson copyWithCompanion(LessonsCompanion data) {
    return Lesson(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      occurrenceId: data.occurrenceId.present
          ? data.occurrenceId.value
          : this.occurrenceId,
      startDateTime: data.startDateTime.present
          ? data.startDateTime.value
          : this.startDateTime,
      durationMin: data.durationMin.present
          ? data.durationMin.value
          : this.durationMin,
      topic: data.topic.present ? data.topic.value : this.topic,
      homework: data.homework.present ? data.homework.value : this.homework,
      homeworkResource: data.homeworkResource.present
          ? data.homeworkResource.value
          : this.homeworkResource,
      feeExpected: data.feeExpected.present
          ? data.feeExpected.value
          : this.feeExpected,
      feePaidAmount: data.feePaidAmount.present
          ? data.feePaidAmount.value
          : this.feePaidAmount,
      note: data.note.present ? data.note.value : this.note,
      lessonNotes: data.lessonNotes.present
          ? data.lessonNotes.value
          : this.lessonNotes,
      status: data.status.present ? data.status.value : this.status,
      statusReason: data.statusReason.present
          ? data.statusReason.value
          : this.statusReason,
      statusReasonSource: data.statusReasonSource.present
          ? data.statusReasonSource.value
          : this.statusReasonSource,
      statusChangedAt: data.statusChangedAt.present
          ? data.statusChangedAt.value
          : this.statusChangedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lesson(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('occurrenceId: $occurrenceId, ')
          ..write('startDateTime: $startDateTime, ')
          ..write('durationMin: $durationMin, ')
          ..write('topic: $topic, ')
          ..write('homework: $homework, ')
          ..write('homeworkResource: $homeworkResource, ')
          ..write('feeExpected: $feeExpected, ')
          ..write('feePaidAmount: $feePaidAmount, ')
          ..write('note: $note, ')
          ..write('lessonNotes: $lessonNotes, ')
          ..write('status: $status, ')
          ..write('statusReason: $statusReason, ')
          ..write('statusReasonSource: $statusReasonSource, ')
          ..write('statusChangedAt: $statusChangedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentId,
    occurrenceId,
    startDateTime,
    durationMin,
    topic,
    homework,
    homeworkResource,
    feeExpected,
    feePaidAmount,
    note,
    lessonNotes,
    status,
    statusReason,
    statusReasonSource,
    statusChangedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lesson &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.occurrenceId == this.occurrenceId &&
          other.startDateTime == this.startDateTime &&
          other.durationMin == this.durationMin &&
          other.topic == this.topic &&
          other.homework == this.homework &&
          other.homeworkResource == this.homeworkResource &&
          other.feeExpected == this.feeExpected &&
          other.feePaidAmount == this.feePaidAmount &&
          other.note == this.note &&
          other.lessonNotes == this.lessonNotes &&
          other.status == this.status &&
          other.statusReason == this.statusReason &&
          other.statusReasonSource == this.statusReasonSource &&
          other.statusChangedAt == this.statusChangedAt &&
          other.createdAt == this.createdAt);
}

class LessonsCompanion extends UpdateCompanion<Lesson> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<String?> occurrenceId;
  final Value<DateTime> startDateTime;
  final Value<int> durationMin;
  final Value<String?> topic;
  final Value<String?> homework;
  final Value<String?> homeworkResource;
  final Value<int> feeExpected;
  final Value<int> feePaidAmount;
  final Value<String?> note;
  final Value<String?> lessonNotes;
  final Value<String?> status;
  final Value<String?> statusReason;
  final Value<String?> statusReasonSource;
  final Value<DateTime?> statusChangedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LessonsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.occurrenceId = const Value.absent(),
    this.startDateTime = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.topic = const Value.absent(),
    this.homework = const Value.absent(),
    this.homeworkResource = const Value.absent(),
    this.feeExpected = const Value.absent(),
    this.feePaidAmount = const Value.absent(),
    this.note = const Value.absent(),
    this.lessonNotes = const Value.absent(),
    this.status = const Value.absent(),
    this.statusReason = const Value.absent(),
    this.statusReasonSource = const Value.absent(),
    this.statusChangedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LessonsCompanion.insert({
    required String id,
    required String studentId,
    this.occurrenceId = const Value.absent(),
    required DateTime startDateTime,
    required int durationMin,
    this.topic = const Value.absent(),
    this.homework = const Value.absent(),
    this.homeworkResource = const Value.absent(),
    required int feeExpected,
    required int feePaidAmount,
    this.note = const Value.absent(),
    this.lessonNotes = const Value.absent(),
    this.status = const Value.absent(),
    this.statusReason = const Value.absent(),
    this.statusReasonSource = const Value.absent(),
    this.statusChangedAt = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       startDateTime = Value(startDateTime),
       durationMin = Value(durationMin),
       feeExpected = Value(feeExpected),
       feePaidAmount = Value(feePaidAmount),
       createdAt = Value(createdAt);
  static Insertable<Lesson> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<String>? occurrenceId,
    Expression<DateTime>? startDateTime,
    Expression<int>? durationMin,
    Expression<String>? topic,
    Expression<String>? homework,
    Expression<String>? homeworkResource,
    Expression<int>? feeExpected,
    Expression<int>? feePaidAmount,
    Expression<String>? note,
    Expression<String>? lessonNotes,
    Expression<String>? status,
    Expression<String>? statusReason,
    Expression<String>? statusReasonSource,
    Expression<DateTime>? statusChangedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (occurrenceId != null) 'occurrence_id': occurrenceId,
      if (startDateTime != null) 'start_date_time': startDateTime,
      if (durationMin != null) 'duration_min': durationMin,
      if (topic != null) 'topic': topic,
      if (homework != null) 'homework': homework,
      if (homeworkResource != null) 'homework_resource': homeworkResource,
      if (feeExpected != null) 'fee_expected': feeExpected,
      if (feePaidAmount != null) 'fee_paid_amount': feePaidAmount,
      if (note != null) 'note': note,
      if (lessonNotes != null) 'lesson_notes': lessonNotes,
      if (status != null) 'status': status,
      if (statusReason != null) 'status_reason': statusReason,
      if (statusReasonSource != null)
        'status_reason_source': statusReasonSource,
      if (statusChangedAt != null) 'status_changed_at': statusChangedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LessonsCompanion copyWith({
    Value<String>? id,
    Value<String>? studentId,
    Value<String?>? occurrenceId,
    Value<DateTime>? startDateTime,
    Value<int>? durationMin,
    Value<String?>? topic,
    Value<String?>? homework,
    Value<String?>? homeworkResource,
    Value<int>? feeExpected,
    Value<int>? feePaidAmount,
    Value<String?>? note,
    Value<String?>? lessonNotes,
    Value<String?>? status,
    Value<String?>? statusReason,
    Value<String?>? statusReasonSource,
    Value<DateTime?>? statusChangedAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LessonsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      occurrenceId: occurrenceId ?? this.occurrenceId,
      startDateTime: startDateTime ?? this.startDateTime,
      durationMin: durationMin ?? this.durationMin,
      topic: topic ?? this.topic,
      homework: homework ?? this.homework,
      homeworkResource: homeworkResource ?? this.homeworkResource,
      feeExpected: feeExpected ?? this.feeExpected,
      feePaidAmount: feePaidAmount ?? this.feePaidAmount,
      note: note ?? this.note,
      lessonNotes: lessonNotes ?? this.lessonNotes,
      status: status ?? this.status,
      statusReason: statusReason ?? this.statusReason,
      statusReasonSource: statusReasonSource ?? this.statusReasonSource,
      statusChangedAt: statusChangedAt ?? this.statusChangedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (occurrenceId.present) {
      map['occurrence_id'] = Variable<String>(occurrenceId.value);
    }
    if (startDateTime.present) {
      map['start_date_time'] = Variable<DateTime>(startDateTime.value);
    }
    if (durationMin.present) {
      map['duration_min'] = Variable<int>(durationMin.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (homework.present) {
      map['homework'] = Variable<String>(homework.value);
    }
    if (homeworkResource.present) {
      map['homework_resource'] = Variable<String>(homeworkResource.value);
    }
    if (feeExpected.present) {
      map['fee_expected'] = Variable<int>(feeExpected.value);
    }
    if (feePaidAmount.present) {
      map['fee_paid_amount'] = Variable<int>(feePaidAmount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (lessonNotes.present) {
      map['lesson_notes'] = Variable<String>(lessonNotes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (statusReason.present) {
      map['status_reason'] = Variable<String>(statusReason.value);
    }
    if (statusReasonSource.present) {
      map['status_reason_source'] = Variable<String>(statusReasonSource.value);
    }
    if (statusChangedAt.present) {
      map['status_changed_at'] = Variable<DateTime>(statusChangedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LessonsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('occurrenceId: $occurrenceId, ')
          ..write('startDateTime: $startDateTime, ')
          ..write('durationMin: $durationMin, ')
          ..write('topic: $topic, ')
          ..write('homework: $homework, ')
          ..write('homeworkResource: $homeworkResource, ')
          ..write('feeExpected: $feeExpected, ')
          ..write('feePaidAmount: $feePaidAmount, ')
          ..write('note: $note, ')
          ..write('lessonNotes: $lessonNotes, ')
          ..write('status: $status, ')
          ..write('statusReason: $statusReason, ')
          ..write('statusReasonSource: $statusReasonSource, ')
          ..write('statusChangedAt: $statusChangedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, Attachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, lessonId, filePath, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class Attachment extends DataClass implements Insertable<Attachment> {
  final String id;
  final String lessonId;
  final String filePath;
  final DateTime createdAt;
  const Attachment({
    required this.id,
    required this.lessonId,
    required this.filePath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['lesson_id'] = Variable<String>(lessonId);
    map['file_path'] = Variable<String>(filePath);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      lessonId: Value(lessonId),
      filePath: Value(filePath),
      createdAt: Value(createdAt),
    );
  }

  factory Attachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attachment(
      id: serializer.fromJson<String>(json['id']),
      lessonId: serializer.fromJson<String>(json['lessonId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lessonId': serializer.toJson<String>(lessonId),
      'filePath': serializer.toJson<String>(filePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Attachment copyWith({
    String? id,
    String? lessonId,
    String? filePath,
    DateTime? createdAt,
  }) => Attachment(
    id: id ?? this.id,
    lessonId: lessonId ?? this.lessonId,
    filePath: filePath ?? this.filePath,
    createdAt: createdAt ?? this.createdAt,
  );
  Attachment copyWithCompanion(AttachmentsCompanion data) {
    return Attachment(
      id: data.id.present ? data.id.value : this.id,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attachment(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lessonId, filePath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attachment &&
          other.id == this.id &&
          other.lessonId == this.lessonId &&
          other.filePath == this.filePath &&
          other.createdAt == this.createdAt);
}

class AttachmentsCompanion extends UpdateCompanion<Attachment> {
  final Value<String> id;
  final Value<String> lessonId;
  final Value<String> filePath;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    required String id,
    required String lessonId,
    required String filePath,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       lessonId = Value(lessonId),
       filePath = Value(filePath),
       createdAt = Value(createdAt);
  static Insertable<Attachment> custom({
    Expression<String>? id,
    Expression<String>? lessonId,
    Expression<String>? filePath,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lessonId != null) 'lesson_id': lessonId,
      if (filePath != null) 'file_path': filePath,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? lessonId,
    Value<String>? filePath,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<DateTime> paidAt = GeneratedColumn<DateTime>(
    'paid_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    paidAt,
    amount,
    method,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Payment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('paid_at')) {
      context.handle(
        _paidAtMeta,
        paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta),
      );
    } else if (isInserting) {
      context.missing(_paidAtMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      paidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_at'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final String id;
  final String studentId;
  final DateTime paidAt;
  final int amount;
  final String method;
  final String? note;
  final DateTime createdAt;
  const Payment({
    required this.id,
    required this.studentId,
    required this.paidAt,
    required this.amount,
    required this.method,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_id'] = Variable<String>(studentId);
    map['paid_at'] = Variable<DateTime>(paidAt);
    map['amount'] = Variable<int>(amount);
    map['method'] = Variable<String>(method);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      paidAt: Value(paidAt),
      amount: Value(amount),
      method: Value(method),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory Payment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<String>(json['id']),
      studentId: serializer.fromJson<String>(json['studentId']),
      paidAt: serializer.fromJson<DateTime>(json['paidAt']),
      amount: serializer.fromJson<int>(json['amount']),
      method: serializer.fromJson<String>(json['method']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studentId': serializer.toJson<String>(studentId),
      'paidAt': serializer.toJson<DateTime>(paidAt),
      'amount': serializer.toJson<int>(amount),
      'method': serializer.toJson<String>(method),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Payment copyWith({
    String? id,
    String? studentId,
    DateTime? paidAt,
    int? amount,
    String? method,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => Payment(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    paidAt: paidAt ?? this.paidAt,
    amount: amount ?? this.amount,
    method: method ?? this.method,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
      amount: data.amount.present ? data.amount.value : this.amount,
      method: data.method.present ? data.method.value : this.method,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('paidAt: $paidAt, ')
          ..write('amount: $amount, ')
          ..write('method: $method, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, studentId, paidAt, amount, method, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.paidAt == this.paidAt &&
          other.amount == this.amount &&
          other.method == this.method &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<DateTime> paidAt;
  final Value<int> amount;
  final Value<String> method;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.amount = const Value.absent(),
    this.method = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    required String studentId,
    required DateTime paidAt,
    required int amount,
    required String method,
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       paidAt = Value(paidAt),
       amount = Value(amount),
       method = Value(method),
       createdAt = Value(createdAt);
  static Insertable<Payment> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<DateTime>? paidAt,
    Expression<int>? amount,
    Expression<String>? method,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (paidAt != null) 'paid_at': paidAt,
      if (amount != null) 'amount': amount,
      if (method != null) 'method': method,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? studentId,
    Value<DateTime>? paidAt,
    Value<int>? amount,
    Value<String>? method,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      paidAt: paidAt ?? this.paidAt,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<DateTime>(paidAt.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('paidAt: $paidAt, ')
          ..write('amount: $amount, ')
          ..write('method: $method, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LessonPaymentsTable extends LessonPayments
    with TableInfo<$LessonPaymentsTable, LessonPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LessonPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentIdMeta = const VerificationMeta(
    'paymentId',
  );
  @override
  late final GeneratedColumn<String> paymentId = GeneratedColumn<String>(
    'payment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedAmountMeta = const VerificationMeta(
    'appliedAmount',
  );
  @override
  late final GeneratedColumn<int> appliedAmount = GeneratedColumn<int>(
    'applied_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    paymentId,
    lessonId,
    appliedAmount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lesson_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<LessonPayment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payment_id')) {
      context.handle(
        _paymentIdMeta,
        paymentId.isAcceptableOrUnknown(data['payment_id']!, _paymentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_paymentIdMeta);
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('applied_amount')) {
      context.handle(
        _appliedAmountMeta,
        appliedAmount.isAcceptableOrUnknown(
          data['applied_amount']!,
          _appliedAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_appliedAmountMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {paymentId, lessonId},
  ];
  @override
  LessonPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LessonPayment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      paymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      )!,
      appliedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}applied_amount'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LessonPaymentsTable createAlias(String alias) {
    return $LessonPaymentsTable(attachedDatabase, alias);
  }
}

class LessonPayment extends DataClass implements Insertable<LessonPayment> {
  final String id;
  final String paymentId;
  final String lessonId;
  final int appliedAmount;
  final DateTime createdAt;
  const LessonPayment({
    required this.id,
    required this.paymentId,
    required this.lessonId,
    required this.appliedAmount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payment_id'] = Variable<String>(paymentId);
    map['lesson_id'] = Variable<String>(lessonId);
    map['applied_amount'] = Variable<int>(appliedAmount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LessonPaymentsCompanion toCompanion(bool nullToAbsent) {
    return LessonPaymentsCompanion(
      id: Value(id),
      paymentId: Value(paymentId),
      lessonId: Value(lessonId),
      appliedAmount: Value(appliedAmount),
      createdAt: Value(createdAt),
    );
  }

  factory LessonPayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LessonPayment(
      id: serializer.fromJson<String>(json['id']),
      paymentId: serializer.fromJson<String>(json['paymentId']),
      lessonId: serializer.fromJson<String>(json['lessonId']),
      appliedAmount: serializer.fromJson<int>(json['appliedAmount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'paymentId': serializer.toJson<String>(paymentId),
      'lessonId': serializer.toJson<String>(lessonId),
      'appliedAmount': serializer.toJson<int>(appliedAmount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LessonPayment copyWith({
    String? id,
    String? paymentId,
    String? lessonId,
    int? appliedAmount,
    DateTime? createdAt,
  }) => LessonPayment(
    id: id ?? this.id,
    paymentId: paymentId ?? this.paymentId,
    lessonId: lessonId ?? this.lessonId,
    appliedAmount: appliedAmount ?? this.appliedAmount,
    createdAt: createdAt ?? this.createdAt,
  );
  LessonPayment copyWithCompanion(LessonPaymentsCompanion data) {
    return LessonPayment(
      id: data.id.present ? data.id.value : this.id,
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      appliedAmount: data.appliedAmount.present
          ? data.appliedAmount.value
          : this.appliedAmount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LessonPayment(')
          ..write('id: $id, ')
          ..write('paymentId: $paymentId, ')
          ..write('lessonId: $lessonId, ')
          ..write('appliedAmount: $appliedAmount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, paymentId, lessonId, appliedAmount, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LessonPayment &&
          other.id == this.id &&
          other.paymentId == this.paymentId &&
          other.lessonId == this.lessonId &&
          other.appliedAmount == this.appliedAmount &&
          other.createdAt == this.createdAt);
}

class LessonPaymentsCompanion extends UpdateCompanion<LessonPayment> {
  final Value<String> id;
  final Value<String> paymentId;
  final Value<String> lessonId;
  final Value<int> appliedAmount;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LessonPaymentsCompanion({
    this.id = const Value.absent(),
    this.paymentId = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.appliedAmount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LessonPaymentsCompanion.insert({
    required String id,
    required String paymentId,
    required String lessonId,
    required int appliedAmount,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       paymentId = Value(paymentId),
       lessonId = Value(lessonId),
       appliedAmount = Value(appliedAmount),
       createdAt = Value(createdAt);
  static Insertable<LessonPayment> custom({
    Expression<String>? id,
    Expression<String>? paymentId,
    Expression<String>? lessonId,
    Expression<int>? appliedAmount,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (paymentId != null) 'payment_id': paymentId,
      if (lessonId != null) 'lesson_id': lessonId,
      if (appliedAmount != null) 'applied_amount': appliedAmount,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LessonPaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? paymentId,
    Value<String>? lessonId,
    Value<int>? appliedAmount,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LessonPaymentsCompanion(
      id: id ?? this.id,
      paymentId: paymentId ?? this.paymentId,
      lessonId: lessonId ?? this.lessonId,
      appliedAmount: appliedAmount ?? this.appliedAmount,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (paymentId.present) {
      map['payment_id'] = Variable<String>(paymentId.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (appliedAmount.present) {
      map['applied_amount'] = Variable<int>(appliedAmount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LessonPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('paymentId: $paymentId, ')
          ..write('lessonId: $lessonId, ')
          ..write('appliedAmount: $appliedAmount, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CurriculumSubjectsTable extends CurriculumSubjects
    with TableInfo<$CurriculumSubjectsTable, CurriculumSubject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CurriculumSubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, sortOrder, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'curriculum_subjects';
  @override
  VerificationContext validateIntegrity(
    Insertable<CurriculumSubject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CurriculumSubject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CurriculumSubject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CurriculumSubjectsTable createAlias(String alias) {
    return $CurriculumSubjectsTable(attachedDatabase, alias);
  }
}

class CurriculumSubject extends DataClass
    implements Insertable<CurriculumSubject> {
  final String id;
  final String name;
  final int sortOrder;
  final DateTime createdAt;
  const CurriculumSubject({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CurriculumSubjectsCompanion toCompanion(bool nullToAbsent) {
    return CurriculumSubjectsCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory CurriculumSubject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CurriculumSubject(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CurriculumSubject copyWith({
    String? id,
    String? name,
    int? sortOrder,
    DateTime? createdAt,
  }) => CurriculumSubject(
    id: id ?? this.id,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  CurriculumSubject copyWithCompanion(CurriculumSubjectsCompanion data) {
    return CurriculumSubject(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CurriculumSubject(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CurriculumSubject &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class CurriculumSubjectsCompanion extends UpdateCompanion<CurriculumSubject> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CurriculumSubjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CurriculumSubjectsCompanion.insert({
    required String id,
    required String name,
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<CurriculumSubject> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CurriculumSubjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CurriculumSubjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CurriculumSubjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CurriculumUnitsTable extends CurriculumUnits
    with TableInfo<$CurriculumUnitsTable, CurriculumUnit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CurriculumUnitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    subjectId,
    name,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'curriculum_units';
  @override
  VerificationContext validateIntegrity(
    Insertable<CurriculumUnit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CurriculumUnit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CurriculumUnit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CurriculumUnitsTable createAlias(String alias) {
    return $CurriculumUnitsTable(attachedDatabase, alias);
  }
}

class CurriculumUnit extends DataClass implements Insertable<CurriculumUnit> {
  final String id;
  final String subjectId;
  final String name;
  final int sortOrder;
  final DateTime createdAt;
  const CurriculumUnit({
    required this.id,
    required this.subjectId,
    required this.name,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subject_id'] = Variable<String>(subjectId);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CurriculumUnitsCompanion toCompanion(bool nullToAbsent) {
    return CurriculumUnitsCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      name: Value(name),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory CurriculumUnit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CurriculumUnit(
      id: serializer.fromJson<String>(json['id']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subjectId': serializer.toJson<String>(subjectId),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CurriculumUnit copyWith({
    String? id,
    String? subjectId,
    String? name,
    int? sortOrder,
    DateTime? createdAt,
  }) => CurriculumUnit(
    id: id ?? this.id,
    subjectId: subjectId ?? this.subjectId,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  CurriculumUnit copyWithCompanion(CurriculumUnitsCompanion data) {
    return CurriculumUnit(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CurriculumUnit(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, subjectId, name, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CurriculumUnit &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class CurriculumUnitsCompanion extends UpdateCompanion<CurriculumUnit> {
  final Value<String> id;
  final Value<String> subjectId;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CurriculumUnitsCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CurriculumUnitsCompanion.insert({
    required String id,
    required String subjectId,
    required String name,
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       subjectId = Value(subjectId),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<CurriculumUnit> custom({
    Expression<String>? id,
    Expression<String>? subjectId,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CurriculumUnitsCompanion copyWith({
    Value<String>? id,
    Value<String>? subjectId,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CurriculumUnitsCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CurriculumUnitsCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CurriculumTopicsTable extends CurriculumTopics
    with TableInfo<$CurriculumTopicsTable, CurriculumTopic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CurriculumTopicsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
    'unit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    unitId,
    name,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'curriculum_topics';
  @override
  VerificationContext validateIntegrity(
    Insertable<CurriculumTopic> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('unit_id')) {
      context.handle(
        _unitIdMeta,
        unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_unitIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CurriculumTopic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CurriculumTopic(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      unitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CurriculumTopicsTable createAlias(String alias) {
    return $CurriculumTopicsTable(attachedDatabase, alias);
  }
}

class CurriculumTopic extends DataClass implements Insertable<CurriculumTopic> {
  final String id;
  final String unitId;
  final String name;
  final int sortOrder;
  final DateTime createdAt;
  const CurriculumTopic({
    required this.id,
    required this.unitId,
    required this.name,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['unit_id'] = Variable<String>(unitId);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CurriculumTopicsCompanion toCompanion(bool nullToAbsent) {
    return CurriculumTopicsCompanion(
      id: Value(id),
      unitId: Value(unitId),
      name: Value(name),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory CurriculumTopic.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CurriculumTopic(
      id: serializer.fromJson<String>(json['id']),
      unitId: serializer.fromJson<String>(json['unitId']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'unitId': serializer.toJson<String>(unitId),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CurriculumTopic copyWith({
    String? id,
    String? unitId,
    String? name,
    int? sortOrder,
    DateTime? createdAt,
  }) => CurriculumTopic(
    id: id ?? this.id,
    unitId: unitId ?? this.unitId,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  CurriculumTopic copyWithCompanion(CurriculumTopicsCompanion data) {
    return CurriculumTopic(
      id: data.id.present ? data.id.value : this.id,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CurriculumTopic(')
          ..write('id: $id, ')
          ..write('unitId: $unitId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, unitId, name, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CurriculumTopic &&
          other.id == this.id &&
          other.unitId == this.unitId &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class CurriculumTopicsCompanion extends UpdateCompanion<CurriculumTopic> {
  final Value<String> id;
  final Value<String> unitId;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CurriculumTopicsCompanion({
    this.id = const Value.absent(),
    this.unitId = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CurriculumTopicsCompanion.insert({
    required String id,
    required String unitId,
    required String name,
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       unitId = Value(unitId),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<CurriculumTopic> custom({
    Expression<String>? id,
    Expression<String>? unitId,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (unitId != null) 'unit_id': unitId,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CurriculumTopicsCompanion copyWith({
    Value<String>? id,
    Value<String>? unitId,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CurriculumTopicsCompanion(
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CurriculumTopicsCompanion(')
          ..write('id: $id, ')
          ..write('unitId: $unitId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CurriculumOutcomesTable extends CurriculumOutcomes
    with TableInfo<$CurriculumOutcomesTable, CurriculumOutcome> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CurriculumOutcomesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topicIdMeta = const VerificationMeta(
    'topicId',
  );
  @override
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
    'topic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    topicId,
    name,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'curriculum_outcomes';
  @override
  VerificationContext validateIntegrity(
    Insertable<CurriculumOutcome> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('topic_id')) {
      context.handle(
        _topicIdMeta,
        topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CurriculumOutcome map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CurriculumOutcome(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      topicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CurriculumOutcomesTable createAlias(String alias) {
    return $CurriculumOutcomesTable(attachedDatabase, alias);
  }
}

class CurriculumOutcome extends DataClass
    implements Insertable<CurriculumOutcome> {
  final String id;
  final String topicId;
  final String name;
  final int sortOrder;
  final DateTime createdAt;
  const CurriculumOutcome({
    required this.id,
    required this.topicId,
    required this.name,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['topic_id'] = Variable<String>(topicId);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CurriculumOutcomesCompanion toCompanion(bool nullToAbsent) {
    return CurriculumOutcomesCompanion(
      id: Value(id),
      topicId: Value(topicId),
      name: Value(name),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory CurriculumOutcome.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CurriculumOutcome(
      id: serializer.fromJson<String>(json['id']),
      topicId: serializer.fromJson<String>(json['topicId']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'topicId': serializer.toJson<String>(topicId),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CurriculumOutcome copyWith({
    String? id,
    String? topicId,
    String? name,
    int? sortOrder,
    DateTime? createdAt,
  }) => CurriculumOutcome(
    id: id ?? this.id,
    topicId: topicId ?? this.topicId,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  CurriculumOutcome copyWithCompanion(CurriculumOutcomesCompanion data) {
    return CurriculumOutcome(
      id: data.id.present ? data.id.value : this.id,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CurriculumOutcome(')
          ..write('id: $id, ')
          ..write('topicId: $topicId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, topicId, name, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CurriculumOutcome &&
          other.id == this.id &&
          other.topicId == this.topicId &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class CurriculumOutcomesCompanion extends UpdateCompanion<CurriculumOutcome> {
  final Value<String> id;
  final Value<String> topicId;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CurriculumOutcomesCompanion({
    this.id = const Value.absent(),
    this.topicId = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CurriculumOutcomesCompanion.insert({
    required String id,
    required String topicId,
    required String name,
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       topicId = Value(topicId),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<CurriculumOutcome> custom({
    Expression<String>? id,
    Expression<String>? topicId,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (topicId != null) 'topic_id': topicId,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CurriculumOutcomesCompanion copyWith({
    Value<String>? id,
    Value<String>? topicId,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CurriculumOutcomesCompanion(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CurriculumOutcomesCompanion(')
          ..write('id: $id, ')
          ..write('topicId: $topicId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HomeworkItemsTable extends HomeworkItems
    with TableInfo<$HomeworkItemsTable, HomeworkItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HomeworkItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assignedAtMeta = const VerificationMeta(
    'assignedAt',
  );
  @override
  late final GeneratedColumn<DateTime> assignedAt = GeneratedColumn<DateTime>(
    'assigned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resourceMeta = const VerificationMeta(
    'resource',
  );
  @override
  late final GeneratedColumn<String> resource = GeneratedColumn<String>(
    'resource',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
    'topic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
    'detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _statusNoteMeta = const VerificationMeta(
    'statusNote',
  );
  @override
  late final GeneratedColumn<String> statusNote = GeneratedColumn<String>(
    'status_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusChangedAtMeta = const VerificationMeta(
    'statusChangedAt',
  );
  @override
  late final GeneratedColumn<DateTime> statusChangedAt =
      GeneratedColumn<DateTime>(
        'status_changed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lessonId,
    studentId,
    assignedAt,
    resource,
    topic,
    detail,
    status,
    statusNote,
    dueAt,
    statusChangedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'homework_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<HomeworkItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('assigned_at')) {
      context.handle(
        _assignedAtMeta,
        assignedAt.isAcceptableOrUnknown(data['assigned_at']!, _assignedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_assignedAtMeta);
    }
    if (data.containsKey('resource')) {
      context.handle(
        _resourceMeta,
        resource.isAcceptableOrUnknown(data['resource']!, _resourceMeta),
      );
    }
    if (data.containsKey('topic')) {
      context.handle(
        _topicMeta,
        topic.isAcceptableOrUnknown(data['topic']!, _topicMeta),
      );
    } else if (isInserting) {
      context.missing(_topicMeta);
    }
    if (data.containsKey('detail')) {
      context.handle(
        _detailMeta,
        detail.isAcceptableOrUnknown(data['detail']!, _detailMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('status_note')) {
      context.handle(
        _statusNoteMeta,
        statusNote.isAcceptableOrUnknown(data['status_note']!, _statusNoteMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('status_changed_at')) {
      context.handle(
        _statusChangedAtMeta,
        statusChangedAt.isAcceptableOrUnknown(
          data['status_changed_at']!,
          _statusChangedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HomeworkItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HomeworkItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      assignedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}assigned_at'],
      )!,
      resource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource'],
      ),
      topic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic'],
      )!,
      detail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      statusNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_note'],
      ),
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      ),
      statusChangedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}status_changed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HomeworkItemsTable createAlias(String alias) {
    return $HomeworkItemsTable(attachedDatabase, alias);
  }
}

class HomeworkItem extends DataClass implements Insertable<HomeworkItem> {
  final String id;
  final String lessonId;
  final String studentId;
  final DateTime assignedAt;
  final String? resource;
  final String topic;
  final String? detail;
  final String status;
  final String? statusNote;
  final DateTime? dueAt;
  final DateTime? statusChangedAt;
  final DateTime createdAt;
  const HomeworkItem({
    required this.id,
    required this.lessonId,
    required this.studentId,
    required this.assignedAt,
    this.resource,
    required this.topic,
    this.detail,
    required this.status,
    this.statusNote,
    this.dueAt,
    this.statusChangedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['lesson_id'] = Variable<String>(lessonId);
    map['student_id'] = Variable<String>(studentId);
    map['assigned_at'] = Variable<DateTime>(assignedAt);
    if (!nullToAbsent || resource != null) {
      map['resource'] = Variable<String>(resource);
    }
    map['topic'] = Variable<String>(topic);
    if (!nullToAbsent || detail != null) {
      map['detail'] = Variable<String>(detail);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || statusNote != null) {
      map['status_note'] = Variable<String>(statusNote);
    }
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    if (!nullToAbsent || statusChangedAt != null) {
      map['status_changed_at'] = Variable<DateTime>(statusChangedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HomeworkItemsCompanion toCompanion(bool nullToAbsent) {
    return HomeworkItemsCompanion(
      id: Value(id),
      lessonId: Value(lessonId),
      studentId: Value(studentId),
      assignedAt: Value(assignedAt),
      resource: resource == null && nullToAbsent
          ? const Value.absent()
          : Value(resource),
      topic: Value(topic),
      detail: detail == null && nullToAbsent
          ? const Value.absent()
          : Value(detail),
      status: Value(status),
      statusNote: statusNote == null && nullToAbsent
          ? const Value.absent()
          : Value(statusNote),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      statusChangedAt: statusChangedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(statusChangedAt),
      createdAt: Value(createdAt),
    );
  }

  factory HomeworkItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HomeworkItem(
      id: serializer.fromJson<String>(json['id']),
      lessonId: serializer.fromJson<String>(json['lessonId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      assignedAt: serializer.fromJson<DateTime>(json['assignedAt']),
      resource: serializer.fromJson<String?>(json['resource']),
      topic: serializer.fromJson<String>(json['topic']),
      detail: serializer.fromJson<String?>(json['detail']),
      status: serializer.fromJson<String>(json['status']),
      statusNote: serializer.fromJson<String?>(json['statusNote']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      statusChangedAt: serializer.fromJson<DateTime?>(json['statusChangedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lessonId': serializer.toJson<String>(lessonId),
      'studentId': serializer.toJson<String>(studentId),
      'assignedAt': serializer.toJson<DateTime>(assignedAt),
      'resource': serializer.toJson<String?>(resource),
      'topic': serializer.toJson<String>(topic),
      'detail': serializer.toJson<String?>(detail),
      'status': serializer.toJson<String>(status),
      'statusNote': serializer.toJson<String?>(statusNote),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'statusChangedAt': serializer.toJson<DateTime?>(statusChangedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HomeworkItem copyWith({
    String? id,
    String? lessonId,
    String? studentId,
    DateTime? assignedAt,
    Value<String?> resource = const Value.absent(),
    String? topic,
    Value<String?> detail = const Value.absent(),
    String? status,
    Value<String?> statusNote = const Value.absent(),
    Value<DateTime?> dueAt = const Value.absent(),
    Value<DateTime?> statusChangedAt = const Value.absent(),
    DateTime? createdAt,
  }) => HomeworkItem(
    id: id ?? this.id,
    lessonId: lessonId ?? this.lessonId,
    studentId: studentId ?? this.studentId,
    assignedAt: assignedAt ?? this.assignedAt,
    resource: resource.present ? resource.value : this.resource,
    topic: topic ?? this.topic,
    detail: detail.present ? detail.value : this.detail,
    status: status ?? this.status,
    statusNote: statusNote.present ? statusNote.value : this.statusNote,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    statusChangedAt: statusChangedAt.present
        ? statusChangedAt.value
        : this.statusChangedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  HomeworkItem copyWithCompanion(HomeworkItemsCompanion data) {
    return HomeworkItem(
      id: data.id.present ? data.id.value : this.id,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      assignedAt: data.assignedAt.present
          ? data.assignedAt.value
          : this.assignedAt,
      resource: data.resource.present ? data.resource.value : this.resource,
      topic: data.topic.present ? data.topic.value : this.topic,
      detail: data.detail.present ? data.detail.value : this.detail,
      status: data.status.present ? data.status.value : this.status,
      statusNote: data.statusNote.present
          ? data.statusNote.value
          : this.statusNote,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      statusChangedAt: data.statusChangedAt.present
          ? data.statusChangedAt.value
          : this.statusChangedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HomeworkItem(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('studentId: $studentId, ')
          ..write('assignedAt: $assignedAt, ')
          ..write('resource: $resource, ')
          ..write('topic: $topic, ')
          ..write('detail: $detail, ')
          ..write('status: $status, ')
          ..write('statusNote: $statusNote, ')
          ..write('dueAt: $dueAt, ')
          ..write('statusChangedAt: $statusChangedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lessonId,
    studentId,
    assignedAt,
    resource,
    topic,
    detail,
    status,
    statusNote,
    dueAt,
    statusChangedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HomeworkItem &&
          other.id == this.id &&
          other.lessonId == this.lessonId &&
          other.studentId == this.studentId &&
          other.assignedAt == this.assignedAt &&
          other.resource == this.resource &&
          other.topic == this.topic &&
          other.detail == this.detail &&
          other.status == this.status &&
          other.statusNote == this.statusNote &&
          other.dueAt == this.dueAt &&
          other.statusChangedAt == this.statusChangedAt &&
          other.createdAt == this.createdAt);
}

class HomeworkItemsCompanion extends UpdateCompanion<HomeworkItem> {
  final Value<String> id;
  final Value<String> lessonId;
  final Value<String> studentId;
  final Value<DateTime> assignedAt;
  final Value<String?> resource;
  final Value<String> topic;
  final Value<String?> detail;
  final Value<String> status;
  final Value<String?> statusNote;
  final Value<DateTime?> dueAt;
  final Value<DateTime?> statusChangedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const HomeworkItemsCompanion({
    this.id = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.assignedAt = const Value.absent(),
    this.resource = const Value.absent(),
    this.topic = const Value.absent(),
    this.detail = const Value.absent(),
    this.status = const Value.absent(),
    this.statusNote = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.statusChangedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HomeworkItemsCompanion.insert({
    required String id,
    required String lessonId,
    required String studentId,
    required DateTime assignedAt,
    this.resource = const Value.absent(),
    required String topic,
    this.detail = const Value.absent(),
    this.status = const Value.absent(),
    this.statusNote = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.statusChangedAt = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       lessonId = Value(lessonId),
       studentId = Value(studentId),
       assignedAt = Value(assignedAt),
       topic = Value(topic),
       createdAt = Value(createdAt);
  static Insertable<HomeworkItem> custom({
    Expression<String>? id,
    Expression<String>? lessonId,
    Expression<String>? studentId,
    Expression<DateTime>? assignedAt,
    Expression<String>? resource,
    Expression<String>? topic,
    Expression<String>? detail,
    Expression<String>? status,
    Expression<String>? statusNote,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? statusChangedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lessonId != null) 'lesson_id': lessonId,
      if (studentId != null) 'student_id': studentId,
      if (assignedAt != null) 'assigned_at': assignedAt,
      if (resource != null) 'resource': resource,
      if (topic != null) 'topic': topic,
      if (detail != null) 'detail': detail,
      if (status != null) 'status': status,
      if (statusNote != null) 'status_note': statusNote,
      if (dueAt != null) 'due_at': dueAt,
      if (statusChangedAt != null) 'status_changed_at': statusChangedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HomeworkItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? lessonId,
    Value<String>? studentId,
    Value<DateTime>? assignedAt,
    Value<String?>? resource,
    Value<String>? topic,
    Value<String?>? detail,
    Value<String>? status,
    Value<String?>? statusNote,
    Value<DateTime?>? dueAt,
    Value<DateTime?>? statusChangedAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return HomeworkItemsCompanion(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      studentId: studentId ?? this.studentId,
      assignedAt: assignedAt ?? this.assignedAt,
      resource: resource ?? this.resource,
      topic: topic ?? this.topic,
      detail: detail ?? this.detail,
      status: status ?? this.status,
      statusNote: statusNote ?? this.statusNote,
      dueAt: dueAt ?? this.dueAt,
      statusChangedAt: statusChangedAt ?? this.statusChangedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (assignedAt.present) {
      map['assigned_at'] = Variable<DateTime>(assignedAt.value);
    }
    if (resource.present) {
      map['resource'] = Variable<String>(resource.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (statusNote.present) {
      map['status_note'] = Variable<String>(statusNote.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (statusChangedAt.present) {
      map['status_changed_at'] = Variable<DateTime>(statusChangedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HomeworkItemsCompanion(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('studentId: $studentId, ')
          ..write('assignedAt: $assignedAt, ')
          ..write('resource: $resource, ')
          ..write('topic: $topic, ')
          ..write('detail: $detail, ')
          ..write('status: $status, ')
          ..write('statusNote: $statusNote, ')
          ..write('dueAt: $dueAt, ')
          ..write('statusChangedAt: $statusChangedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TeacherTodosTable extends TeacherTodos
    with TableInfo<$TeacherTodosTable, TeacherTodo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeacherTodosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _studentNameMeta = const VerificationMeta(
    'studentName',
  );
  @override
  late final GeneratedColumn<String> studentName = GeneratedColumn<String>(
    'student_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _homeworkItemIdMeta = const VerificationMeta(
    'homeworkItemId',
  );
  @override
  late final GeneratedColumn<String> homeworkItemId = GeneratedColumn<String>(
    'homework_item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _homeworkTopicMeta = const VerificationMeta(
    'homeworkTopic',
  );
  @override
  late final GeneratedColumn<String> homeworkTopic = GeneratedColumn<String>(
    'homework_topic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
    'is_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notifyAtMeta = const VerificationMeta(
    'notifyAt',
  );
  @override
  late final GeneratedColumn<DateTime> notifyAt = GeneratedColumn<DateTime>(
    'notify_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    studentId,
    studentName,
    homeworkItemId,
    homeworkTopic,
    isDone,
    notifyAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teacher_todos';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeacherTodo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    }
    if (data.containsKey('student_name')) {
      context.handle(
        _studentNameMeta,
        studentName.isAcceptableOrUnknown(
          data['student_name']!,
          _studentNameMeta,
        ),
      );
    }
    if (data.containsKey('homework_item_id')) {
      context.handle(
        _homeworkItemIdMeta,
        homeworkItemId.isAcceptableOrUnknown(
          data['homework_item_id']!,
          _homeworkItemIdMeta,
        ),
      );
    }
    if (data.containsKey('homework_topic')) {
      context.handle(
        _homeworkTopicMeta,
        homeworkTopic.isAcceptableOrUnknown(
          data['homework_topic']!,
          _homeworkTopicMeta,
        ),
      );
    }
    if (data.containsKey('is_done')) {
      context.handle(
        _isDoneMeta,
        isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta),
      );
    }
    if (data.containsKey('notify_at')) {
      context.handle(
        _notifyAtMeta,
        notifyAt.isAcceptableOrUnknown(data['notify_at']!, _notifyAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TeacherTodo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeacherTodo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      ),
      studentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_name'],
      ),
      homeworkItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}homework_item_id'],
      ),
      homeworkTopic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}homework_topic'],
      ),
      isDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_done'],
      )!,
      notifyAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}notify_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TeacherTodosTable createAlias(String alias) {
    return $TeacherTodosTable(attachedDatabase, alias);
  }
}

class TeacherTodo extends DataClass implements Insertable<TeacherTodo> {
  final String id;
  final String title;
  final String? studentId;
  final String? studentName;
  final String? homeworkItemId;
  final String? homeworkTopic;
  final bool isDone;
  final DateTime? notifyAt;
  final DateTime createdAt;
  const TeacherTodo({
    required this.id,
    required this.title,
    this.studentId,
    this.studentName,
    this.homeworkItemId,
    this.homeworkTopic,
    required this.isDone,
    this.notifyAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || studentId != null) {
      map['student_id'] = Variable<String>(studentId);
    }
    if (!nullToAbsent || studentName != null) {
      map['student_name'] = Variable<String>(studentName);
    }
    if (!nullToAbsent || homeworkItemId != null) {
      map['homework_item_id'] = Variable<String>(homeworkItemId);
    }
    if (!nullToAbsent || homeworkTopic != null) {
      map['homework_topic'] = Variable<String>(homeworkTopic);
    }
    map['is_done'] = Variable<bool>(isDone);
    if (!nullToAbsent || notifyAt != null) {
      map['notify_at'] = Variable<DateTime>(notifyAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TeacherTodosCompanion toCompanion(bool nullToAbsent) {
    return TeacherTodosCompanion(
      id: Value(id),
      title: Value(title),
      studentId: studentId == null && nullToAbsent
          ? const Value.absent()
          : Value(studentId),
      studentName: studentName == null && nullToAbsent
          ? const Value.absent()
          : Value(studentName),
      homeworkItemId: homeworkItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(homeworkItemId),
      homeworkTopic: homeworkTopic == null && nullToAbsent
          ? const Value.absent()
          : Value(homeworkTopic),
      isDone: Value(isDone),
      notifyAt: notifyAt == null && nullToAbsent
          ? const Value.absent()
          : Value(notifyAt),
      createdAt: Value(createdAt),
    );
  }

  factory TeacherTodo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeacherTodo(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      studentId: serializer.fromJson<String?>(json['studentId']),
      studentName: serializer.fromJson<String?>(json['studentName']),
      homeworkItemId: serializer.fromJson<String?>(json['homeworkItemId']),
      homeworkTopic: serializer.fromJson<String?>(json['homeworkTopic']),
      isDone: serializer.fromJson<bool>(json['isDone']),
      notifyAt: serializer.fromJson<DateTime?>(json['notifyAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'studentId': serializer.toJson<String?>(studentId),
      'studentName': serializer.toJson<String?>(studentName),
      'homeworkItemId': serializer.toJson<String?>(homeworkItemId),
      'homeworkTopic': serializer.toJson<String?>(homeworkTopic),
      'isDone': serializer.toJson<bool>(isDone),
      'notifyAt': serializer.toJson<DateTime?>(notifyAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TeacherTodo copyWith({
    String? id,
    String? title,
    Value<String?> studentId = const Value.absent(),
    Value<String?> studentName = const Value.absent(),
    Value<String?> homeworkItemId = const Value.absent(),
    Value<String?> homeworkTopic = const Value.absent(),
    bool? isDone,
    Value<DateTime?> notifyAt = const Value.absent(),
    DateTime? createdAt,
  }) => TeacherTodo(
    id: id ?? this.id,
    title: title ?? this.title,
    studentId: studentId.present ? studentId.value : this.studentId,
    studentName: studentName.present ? studentName.value : this.studentName,
    homeworkItemId: homeworkItemId.present
        ? homeworkItemId.value
        : this.homeworkItemId,
    homeworkTopic: homeworkTopic.present
        ? homeworkTopic.value
        : this.homeworkTopic,
    isDone: isDone ?? this.isDone,
    notifyAt: notifyAt.present ? notifyAt.value : this.notifyAt,
    createdAt: createdAt ?? this.createdAt,
  );
  TeacherTodo copyWithCompanion(TeacherTodosCompanion data) {
    return TeacherTodo(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      studentName: data.studentName.present
          ? data.studentName.value
          : this.studentName,
      homeworkItemId: data.homeworkItemId.present
          ? data.homeworkItemId.value
          : this.homeworkItemId,
      homeworkTopic: data.homeworkTopic.present
          ? data.homeworkTopic.value
          : this.homeworkTopic,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      notifyAt: data.notifyAt.present ? data.notifyAt.value : this.notifyAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeacherTodo(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('studentId: $studentId, ')
          ..write('studentName: $studentName, ')
          ..write('homeworkItemId: $homeworkItemId, ')
          ..write('homeworkTopic: $homeworkTopic, ')
          ..write('isDone: $isDone, ')
          ..write('notifyAt: $notifyAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    studentId,
    studentName,
    homeworkItemId,
    homeworkTopic,
    isDone,
    notifyAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeacherTodo &&
          other.id == this.id &&
          other.title == this.title &&
          other.studentId == this.studentId &&
          other.studentName == this.studentName &&
          other.homeworkItemId == this.homeworkItemId &&
          other.homeworkTopic == this.homeworkTopic &&
          other.isDone == this.isDone &&
          other.notifyAt == this.notifyAt &&
          other.createdAt == this.createdAt);
}

class TeacherTodosCompanion extends UpdateCompanion<TeacherTodo> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> studentId;
  final Value<String?> studentName;
  final Value<String?> homeworkItemId;
  final Value<String?> homeworkTopic;
  final Value<bool> isDone;
  final Value<DateTime?> notifyAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TeacherTodosCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.studentId = const Value.absent(),
    this.studentName = const Value.absent(),
    this.homeworkItemId = const Value.absent(),
    this.homeworkTopic = const Value.absent(),
    this.isDone = const Value.absent(),
    this.notifyAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeacherTodosCompanion.insert({
    required String id,
    required String title,
    this.studentId = const Value.absent(),
    this.studentName = const Value.absent(),
    this.homeworkItemId = const Value.absent(),
    this.homeworkTopic = const Value.absent(),
    this.isDone = const Value.absent(),
    this.notifyAt = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<TeacherTodo> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? studentId,
    Expression<String>? studentName,
    Expression<String>? homeworkItemId,
    Expression<String>? homeworkTopic,
    Expression<bool>? isDone,
    Expression<DateTime>? notifyAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (studentId != null) 'student_id': studentId,
      if (studentName != null) 'student_name': studentName,
      if (homeworkItemId != null) 'homework_item_id': homeworkItemId,
      if (homeworkTopic != null) 'homework_topic': homeworkTopic,
      if (isDone != null) 'is_done': isDone,
      if (notifyAt != null) 'notify_at': notifyAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeacherTodosCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? studentId,
    Value<String?>? studentName,
    Value<String?>? homeworkItemId,
    Value<String?>? homeworkTopic,
    Value<bool>? isDone,
    Value<DateTime?>? notifyAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TeacherTodosCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      homeworkItemId: homeworkItemId ?? this.homeworkItemId,
      homeworkTopic: homeworkTopic ?? this.homeworkTopic,
      isDone: isDone ?? this.isDone,
      notifyAt: notifyAt ?? this.notifyAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (studentName.present) {
      map['student_name'] = Variable<String>(studentName.value);
    }
    if (homeworkItemId.present) {
      map['homework_item_id'] = Variable<String>(homeworkItemId.value);
    }
    if (homeworkTopic.present) {
      map['homework_topic'] = Variable<String>(homeworkTopic.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (notifyAt.present) {
      map['notify_at'] = Variable<DateTime>(notifyAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeacherTodosCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('studentId: $studentId, ')
          ..write('studentName: $studentName, ')
          ..write('homeworkItemId: $homeworkItemId, ')
          ..write('homeworkTopic: $homeworkTopic, ')
          ..write('isDone: $isDone, ')
          ..write('notifyAt: $notifyAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $StudentsTable students = $StudentsTable(this);
  late final $ScheduleTemplatesTable scheduleTemplates =
      $ScheduleTemplatesTable(this);
  late final $ScheduleOverridesTable scheduleOverrides =
      $ScheduleOverridesTable(this);
  late final $SessionOccurrencesTable sessionOccurrences =
      $SessionOccurrencesTable(this);
  late final $LessonsTable lessons = $LessonsTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $LessonPaymentsTable lessonPayments = $LessonPaymentsTable(this);
  late final $CurriculumSubjectsTable curriculumSubjects =
      $CurriculumSubjectsTable(this);
  late final $CurriculumUnitsTable curriculumUnits = $CurriculumUnitsTable(
    this,
  );
  late final $CurriculumTopicsTable curriculumTopics = $CurriculumTopicsTable(
    this,
  );
  late final $CurriculumOutcomesTable curriculumOutcomes =
      $CurriculumOutcomesTable(this);
  late final $HomeworkItemsTable homeworkItems = $HomeworkItemsTable(this);
  late final $TeacherTodosTable teacherTodos = $TeacherTodosTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    students,
    scheduleTemplates,
    scheduleOverrides,
    sessionOccurrences,
    lessons,
    attachments,
    appSettings,
    payments,
    lessonPayments,
    curriculumSubjects,
    curriculumUnits,
    curriculumTopics,
    curriculumOutcomes,
    homeworkItems,
    teacherTodos,
  ];
}

typedef $$StudentsTableCreateCompanionBuilder =
    StudentsCompanion Function({
      required String id,
      required String fullName,
      Value<String?> phone,
      required int hourlyRate,
      Value<String?> notes,
      Value<bool> isActive,
      Value<String?> guardianFullName,
      Value<String?> guardianPhone,
      Value<String?> bookResource,
      Value<String?> bookResourcePractice,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$StudentsTableUpdateCompanionBuilder =
    StudentsCompanion Function({
      Value<String> id,
      Value<String> fullName,
      Value<String?> phone,
      Value<int> hourlyRate,
      Value<String?> notes,
      Value<bool> isActive,
      Value<String?> guardianFullName,
      Value<String?> guardianPhone,
      Value<String?> bookResource,
      Value<String?> bookResourcePractice,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$StudentsTableFilterComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hourlyRate => $composableBuilder(
    column: $table.hourlyRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guardianFullName => $composableBuilder(
    column: $table.guardianFullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guardianPhone => $composableBuilder(
    column: $table.guardianPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookResource => $composableBuilder(
    column: $table.bookResource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookResourcePractice => $composableBuilder(
    column: $table.bookResourcePractice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudentsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hourlyRate => $composableBuilder(
    column: $table.hourlyRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guardianFullName => $composableBuilder(
    column: $table.guardianFullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guardianPhone => $composableBuilder(
    column: $table.guardianPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookResource => $composableBuilder(
    column: $table.bookResource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookResourcePractice => $composableBuilder(
    column: $table.bookResourcePractice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<int> get hourlyRate => $composableBuilder(
    column: $table.hourlyRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get guardianFullName => $composableBuilder(
    column: $table.guardianFullName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get guardianPhone => $composableBuilder(
    column: $table.guardianPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bookResource => $composableBuilder(
    column: $table.bookResource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bookResourcePractice => $composableBuilder(
    column: $table.bookResourcePractice,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$StudentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudentsTable,
          Student,
          $$StudentsTableFilterComposer,
          $$StudentsTableOrderingComposer,
          $$StudentsTableAnnotationComposer,
          $$StudentsTableCreateCompanionBuilder,
          $$StudentsTableUpdateCompanionBuilder,
          (Student, BaseReferences<_$AppDatabase, $StudentsTable, Student>),
          Student,
          PrefetchHooks Function()
        > {
  $$StudentsTableTableManager(_$AppDatabase db, $StudentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<int> hourlyRate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> guardianFullName = const Value.absent(),
                Value<String?> guardianPhone = const Value.absent(),
                Value<String?> bookResource = const Value.absent(),
                Value<String?> bookResourcePractice = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentsCompanion(
                id: id,
                fullName: fullName,
                phone: phone,
                hourlyRate: hourlyRate,
                notes: notes,
                isActive: isActive,
                guardianFullName: guardianFullName,
                guardianPhone: guardianPhone,
                bookResource: bookResource,
                bookResourcePractice: bookResourcePractice,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fullName,
                Value<String?> phone = const Value.absent(),
                required int hourlyRate,
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> guardianFullName = const Value.absent(),
                Value<String?> guardianPhone = const Value.absent(),
                Value<String?> bookResource = const Value.absent(),
                Value<String?> bookResourcePractice = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => StudentsCompanion.insert(
                id: id,
                fullName: fullName,
                phone: phone,
                hourlyRate: hourlyRate,
                notes: notes,
                isActive: isActive,
                guardianFullName: guardianFullName,
                guardianPhone: guardianPhone,
                bookResource: bookResource,
                bookResourcePractice: bookResourcePractice,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudentsTable,
      Student,
      $$StudentsTableFilterComposer,
      $$StudentsTableOrderingComposer,
      $$StudentsTableAnnotationComposer,
      $$StudentsTableCreateCompanionBuilder,
      $$StudentsTableUpdateCompanionBuilder,
      (Student, BaseReferences<_$AppDatabase, $StudentsTable, Student>),
      Student,
      PrefetchHooks Function()
    >;
typedef $$ScheduleTemplatesTableCreateCompanionBuilder =
    ScheduleTemplatesCompanion Function({
      required String id,
      required String studentId,
      required int weekday,
      required String startTime,
      required int durationMin,
      required String startDate,
      Value<String?> endDate,
      Value<bool> isActive,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ScheduleTemplatesTableUpdateCompanionBuilder =
    ScheduleTemplatesCompanion Function({
      Value<String> id,
      Value<String> studentId,
      Value<int> weekday,
      Value<String> startTime,
      Value<int> durationMin,
      Value<String> startDate,
      Value<String?> endDate,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ScheduleTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduleTemplatesTable> {
  $$ScheduleTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScheduleTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduleTemplatesTable> {
  $$ScheduleTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScheduleTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduleTemplatesTable> {
  $$ScheduleTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ScheduleTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScheduleTemplatesTable,
          ScheduleTemplate,
          $$ScheduleTemplatesTableFilterComposer,
          $$ScheduleTemplatesTableOrderingComposer,
          $$ScheduleTemplatesTableAnnotationComposer,
          $$ScheduleTemplatesTableCreateCompanionBuilder,
          $$ScheduleTemplatesTableUpdateCompanionBuilder,
          (
            ScheduleTemplate,
            BaseReferences<
              _$AppDatabase,
              $ScheduleTemplatesTable,
              ScheduleTemplate
            >,
          ),
          ScheduleTemplate,
          PrefetchHooks Function()
        > {
  $$ScheduleTemplatesTableTableManager(
    _$AppDatabase db,
    $ScheduleTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduleTemplatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<int> weekday = const Value.absent(),
                Value<String> startTime = const Value.absent(),
                Value<int> durationMin = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduleTemplatesCompanion(
                id: id,
                studentId: studentId,
                weekday: weekday,
                startTime: startTime,
                durationMin: durationMin,
                startDate: startDate,
                endDate: endDate,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentId,
                required int weekday,
                required String startTime,
                required int durationMin,
                required String startDate,
                Value<String?> endDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ScheduleTemplatesCompanion.insert(
                id: id,
                studentId: studentId,
                weekday: weekday,
                startTime: startTime,
                durationMin: durationMin,
                startDate: startDate,
                endDate: endDate,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScheduleTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScheduleTemplatesTable,
      ScheduleTemplate,
      $$ScheduleTemplatesTableFilterComposer,
      $$ScheduleTemplatesTableOrderingComposer,
      $$ScheduleTemplatesTableAnnotationComposer,
      $$ScheduleTemplatesTableCreateCompanionBuilder,
      $$ScheduleTemplatesTableUpdateCompanionBuilder,
      (
        ScheduleTemplate,
        BaseReferences<
          _$AppDatabase,
          $ScheduleTemplatesTable,
          ScheduleTemplate
        >,
      ),
      ScheduleTemplate,
      PrefetchHooks Function()
    >;
typedef $$ScheduleOverridesTableCreateCompanionBuilder =
    ScheduleOverridesCompanion Function({
      required String id,
      required String templateId,
      required String date,
      required String overrideType,
      Value<int?> newWeekday,
      Value<String?> newStartTime,
      Value<int?> newDurationMin,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ScheduleOverridesTableUpdateCompanionBuilder =
    ScheduleOverridesCompanion Function({
      Value<String> id,
      Value<String> templateId,
      Value<String> date,
      Value<String> overrideType,
      Value<int?> newWeekday,
      Value<String?> newStartTime,
      Value<int?> newDurationMin,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ScheduleOverridesTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduleOverridesTable> {
  $$ScheduleOverridesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overrideType => $composableBuilder(
    column: $table.overrideType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newWeekday => $composableBuilder(
    column: $table.newWeekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newStartTime => $composableBuilder(
    column: $table.newStartTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newDurationMin => $composableBuilder(
    column: $table.newDurationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScheduleOverridesTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduleOverridesTable> {
  $$ScheduleOverridesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overrideType => $composableBuilder(
    column: $table.overrideType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newWeekday => $composableBuilder(
    column: $table.newWeekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newStartTime => $composableBuilder(
    column: $table.newStartTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newDurationMin => $composableBuilder(
    column: $table.newDurationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScheduleOverridesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduleOverridesTable> {
  $$ScheduleOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get overrideType => $composableBuilder(
    column: $table.overrideType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get newWeekday => $composableBuilder(
    column: $table.newWeekday,
    builder: (column) => column,
  );

  GeneratedColumn<String> get newStartTime => $composableBuilder(
    column: $table.newStartTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get newDurationMin => $composableBuilder(
    column: $table.newDurationMin,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ScheduleOverridesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScheduleOverridesTable,
          ScheduleOverride,
          $$ScheduleOverridesTableFilterComposer,
          $$ScheduleOverridesTableOrderingComposer,
          $$ScheduleOverridesTableAnnotationComposer,
          $$ScheduleOverridesTableCreateCompanionBuilder,
          $$ScheduleOverridesTableUpdateCompanionBuilder,
          (
            ScheduleOverride,
            BaseReferences<
              _$AppDatabase,
              $ScheduleOverridesTable,
              ScheduleOverride
            >,
          ),
          ScheduleOverride,
          PrefetchHooks Function()
        > {
  $$ScheduleOverridesTableTableManager(
    _$AppDatabase db,
    $ScheduleOverridesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleOverridesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleOverridesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduleOverridesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> templateId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> overrideType = const Value.absent(),
                Value<int?> newWeekday = const Value.absent(),
                Value<String?> newStartTime = const Value.absent(),
                Value<int?> newDurationMin = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduleOverridesCompanion(
                id: id,
                templateId: templateId,
                date: date,
                overrideType: overrideType,
                newWeekday: newWeekday,
                newStartTime: newStartTime,
                newDurationMin: newDurationMin,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String templateId,
                required String date,
                required String overrideType,
                Value<int?> newWeekday = const Value.absent(),
                Value<String?> newStartTime = const Value.absent(),
                Value<int?> newDurationMin = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ScheduleOverridesCompanion.insert(
                id: id,
                templateId: templateId,
                date: date,
                overrideType: overrideType,
                newWeekday: newWeekday,
                newStartTime: newStartTime,
                newDurationMin: newDurationMin,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScheduleOverridesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScheduleOverridesTable,
      ScheduleOverride,
      $$ScheduleOverridesTableFilterComposer,
      $$ScheduleOverridesTableOrderingComposer,
      $$ScheduleOverridesTableAnnotationComposer,
      $$ScheduleOverridesTableCreateCompanionBuilder,
      $$ScheduleOverridesTableUpdateCompanionBuilder,
      (
        ScheduleOverride,
        BaseReferences<
          _$AppDatabase,
          $ScheduleOverridesTable,
          ScheduleOverride
        >,
      ),
      ScheduleOverride,
      PrefetchHooks Function()
    >;
typedef $$SessionOccurrencesTableCreateCompanionBuilder =
    SessionOccurrencesCompanion Function({
      required String id,
      required String studentId,
      Value<String?> templateId,
      required String date,
      required String startTime,
      required int durationMin,
      required String status,
      Value<String?> notDoneReasonType,
      Value<String?> notDoneReasonNote,
      Value<String?> paymentId,
      Value<DateTime?> completedAt,
      Value<String?> postponedFromDate,
      Value<String?> postponedReason,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SessionOccurrencesTableUpdateCompanionBuilder =
    SessionOccurrencesCompanion Function({
      Value<String> id,
      Value<String> studentId,
      Value<String?> templateId,
      Value<String> date,
      Value<String> startTime,
      Value<int> durationMin,
      Value<String> status,
      Value<String?> notDoneReasonType,
      Value<String?> notDoneReasonNote,
      Value<String?> paymentId,
      Value<DateTime?> completedAt,
      Value<String?> postponedFromDate,
      Value<String?> postponedReason,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SessionOccurrencesTableFilterComposer
    extends Composer<_$AppDatabase, $SessionOccurrencesTable> {
  $$SessionOccurrencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notDoneReasonType => $composableBuilder(
    column: $table.notDoneReasonType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notDoneReasonNote => $composableBuilder(
    column: $table.notDoneReasonNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postponedFromDate => $composableBuilder(
    column: $table.postponedFromDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postponedReason => $composableBuilder(
    column: $table.postponedReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionOccurrencesTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionOccurrencesTable> {
  $$SessionOccurrencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notDoneReasonType => $composableBuilder(
    column: $table.notDoneReasonType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notDoneReasonNote => $composableBuilder(
    column: $table.notDoneReasonNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postponedFromDate => $composableBuilder(
    column: $table.postponedFromDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postponedReason => $composableBuilder(
    column: $table.postponedReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionOccurrencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionOccurrencesTable> {
  $$SessionOccurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notDoneReasonType => $composableBuilder(
    column: $table.notDoneReasonType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notDoneReasonNote => $composableBuilder(
    column: $table.notDoneReasonNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentId =>
      $composableBuilder(column: $table.paymentId, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get postponedFromDate => $composableBuilder(
    column: $table.postponedFromDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get postponedReason => $composableBuilder(
    column: $table.postponedReason,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SessionOccurrencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionOccurrencesTable,
          SessionOccurrence,
          $$SessionOccurrencesTableFilterComposer,
          $$SessionOccurrencesTableOrderingComposer,
          $$SessionOccurrencesTableAnnotationComposer,
          $$SessionOccurrencesTableCreateCompanionBuilder,
          $$SessionOccurrencesTableUpdateCompanionBuilder,
          (
            SessionOccurrence,
            BaseReferences<
              _$AppDatabase,
              $SessionOccurrencesTable,
              SessionOccurrence
            >,
          ),
          SessionOccurrence,
          PrefetchHooks Function()
        > {
  $$SessionOccurrencesTableTableManager(
    _$AppDatabase db,
    $SessionOccurrencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionOccurrencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionOccurrencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionOccurrencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String?> templateId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> startTime = const Value.absent(),
                Value<int> durationMin = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notDoneReasonType = const Value.absent(),
                Value<String?> notDoneReasonNote = const Value.absent(),
                Value<String?> paymentId = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> postponedFromDate = const Value.absent(),
                Value<String?> postponedReason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionOccurrencesCompanion(
                id: id,
                studentId: studentId,
                templateId: templateId,
                date: date,
                startTime: startTime,
                durationMin: durationMin,
                status: status,
                notDoneReasonType: notDoneReasonType,
                notDoneReasonNote: notDoneReasonNote,
                paymentId: paymentId,
                completedAt: completedAt,
                postponedFromDate: postponedFromDate,
                postponedReason: postponedReason,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentId,
                Value<String?> templateId = const Value.absent(),
                required String date,
                required String startTime,
                required int durationMin,
                required String status,
                Value<String?> notDoneReasonType = const Value.absent(),
                Value<String?> notDoneReasonNote = const Value.absent(),
                Value<String?> paymentId = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> postponedFromDate = const Value.absent(),
                Value<String?> postponedReason = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SessionOccurrencesCompanion.insert(
                id: id,
                studentId: studentId,
                templateId: templateId,
                date: date,
                startTime: startTime,
                durationMin: durationMin,
                status: status,
                notDoneReasonType: notDoneReasonType,
                notDoneReasonNote: notDoneReasonNote,
                paymentId: paymentId,
                completedAt: completedAt,
                postponedFromDate: postponedFromDate,
                postponedReason: postponedReason,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionOccurrencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionOccurrencesTable,
      SessionOccurrence,
      $$SessionOccurrencesTableFilterComposer,
      $$SessionOccurrencesTableOrderingComposer,
      $$SessionOccurrencesTableAnnotationComposer,
      $$SessionOccurrencesTableCreateCompanionBuilder,
      $$SessionOccurrencesTableUpdateCompanionBuilder,
      (
        SessionOccurrence,
        BaseReferences<
          _$AppDatabase,
          $SessionOccurrencesTable,
          SessionOccurrence
        >,
      ),
      SessionOccurrence,
      PrefetchHooks Function()
    >;
typedef $$LessonsTableCreateCompanionBuilder =
    LessonsCompanion Function({
      required String id,
      required String studentId,
      Value<String?> occurrenceId,
      required DateTime startDateTime,
      required int durationMin,
      Value<String?> topic,
      Value<String?> homework,
      Value<String?> homeworkResource,
      required int feeExpected,
      required int feePaidAmount,
      Value<String?> note,
      Value<String?> lessonNotes,
      Value<String?> status,
      Value<String?> statusReason,
      Value<String?> statusReasonSource,
      Value<DateTime?> statusChangedAt,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LessonsTableUpdateCompanionBuilder =
    LessonsCompanion Function({
      Value<String> id,
      Value<String> studentId,
      Value<String?> occurrenceId,
      Value<DateTime> startDateTime,
      Value<int> durationMin,
      Value<String?> topic,
      Value<String?> homework,
      Value<String?> homeworkResource,
      Value<int> feeExpected,
      Value<int> feePaidAmount,
      Value<String?> note,
      Value<String?> lessonNotes,
      Value<String?> status,
      Value<String?> statusReason,
      Value<String?> statusReasonSource,
      Value<DateTime?> statusChangedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LessonsTableFilterComposer
    extends Composer<_$AppDatabase, $LessonsTable> {
  $$LessonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occurrenceId => $composableBuilder(
    column: $table.occurrenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDateTime => $composableBuilder(
    column: $table.startDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homework => $composableBuilder(
    column: $table.homework,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homeworkResource => $composableBuilder(
    column: $table.homeworkResource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get feeExpected => $composableBuilder(
    column: $table.feeExpected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get feePaidAmount => $composableBuilder(
    column: $table.feePaidAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lessonNotes => $composableBuilder(
    column: $table.lessonNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusReason => $composableBuilder(
    column: $table.statusReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusReasonSource => $composableBuilder(
    column: $table.statusReasonSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get statusChangedAt => $composableBuilder(
    column: $table.statusChangedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LessonsTableOrderingComposer
    extends Composer<_$AppDatabase, $LessonsTable> {
  $$LessonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurrenceId => $composableBuilder(
    column: $table.occurrenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDateTime => $composableBuilder(
    column: $table.startDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homework => $composableBuilder(
    column: $table.homework,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homeworkResource => $composableBuilder(
    column: $table.homeworkResource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get feeExpected => $composableBuilder(
    column: $table.feeExpected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get feePaidAmount => $composableBuilder(
    column: $table.feePaidAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lessonNotes => $composableBuilder(
    column: $table.lessonNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusReason => $composableBuilder(
    column: $table.statusReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusReasonSource => $composableBuilder(
    column: $table.statusReasonSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get statusChangedAt => $composableBuilder(
    column: $table.statusChangedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LessonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LessonsTable> {
  $$LessonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get occurrenceId => $composableBuilder(
    column: $table.occurrenceId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDateTime => $composableBuilder(
    column: $table.startDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => column,
  );

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<String> get homework =>
      $composableBuilder(column: $table.homework, builder: (column) => column);

  GeneratedColumn<String> get homeworkResource => $composableBuilder(
    column: $table.homeworkResource,
    builder: (column) => column,
  );

  GeneratedColumn<int> get feeExpected => $composableBuilder(
    column: $table.feeExpected,
    builder: (column) => column,
  );

  GeneratedColumn<int> get feePaidAmount => $composableBuilder(
    column: $table.feePaidAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get lessonNotes => $composableBuilder(
    column: $table.lessonNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get statusReason => $composableBuilder(
    column: $table.statusReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get statusReasonSource => $composableBuilder(
    column: $table.statusReasonSource,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get statusChangedAt => $composableBuilder(
    column: $table.statusChangedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LessonsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LessonsTable,
          Lesson,
          $$LessonsTableFilterComposer,
          $$LessonsTableOrderingComposer,
          $$LessonsTableAnnotationComposer,
          $$LessonsTableCreateCompanionBuilder,
          $$LessonsTableUpdateCompanionBuilder,
          (Lesson, BaseReferences<_$AppDatabase, $LessonsTable, Lesson>),
          Lesson,
          PrefetchHooks Function()
        > {
  $$LessonsTableTableManager(_$AppDatabase db, $LessonsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LessonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LessonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LessonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String?> occurrenceId = const Value.absent(),
                Value<DateTime> startDateTime = const Value.absent(),
                Value<int> durationMin = const Value.absent(),
                Value<String?> topic = const Value.absent(),
                Value<String?> homework = const Value.absent(),
                Value<String?> homeworkResource = const Value.absent(),
                Value<int> feeExpected = const Value.absent(),
                Value<int> feePaidAmount = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> lessonNotes = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> statusReason = const Value.absent(),
                Value<String?> statusReasonSource = const Value.absent(),
                Value<DateTime?> statusChangedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LessonsCompanion(
                id: id,
                studentId: studentId,
                occurrenceId: occurrenceId,
                startDateTime: startDateTime,
                durationMin: durationMin,
                topic: topic,
                homework: homework,
                homeworkResource: homeworkResource,
                feeExpected: feeExpected,
                feePaidAmount: feePaidAmount,
                note: note,
                lessonNotes: lessonNotes,
                status: status,
                statusReason: statusReason,
                statusReasonSource: statusReasonSource,
                statusChangedAt: statusChangedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentId,
                Value<String?> occurrenceId = const Value.absent(),
                required DateTime startDateTime,
                required int durationMin,
                Value<String?> topic = const Value.absent(),
                Value<String?> homework = const Value.absent(),
                Value<String?> homeworkResource = const Value.absent(),
                required int feeExpected,
                required int feePaidAmount,
                Value<String?> note = const Value.absent(),
                Value<String?> lessonNotes = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> statusReason = const Value.absent(),
                Value<String?> statusReasonSource = const Value.absent(),
                Value<DateTime?> statusChangedAt = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LessonsCompanion.insert(
                id: id,
                studentId: studentId,
                occurrenceId: occurrenceId,
                startDateTime: startDateTime,
                durationMin: durationMin,
                topic: topic,
                homework: homework,
                homeworkResource: homeworkResource,
                feeExpected: feeExpected,
                feePaidAmount: feePaidAmount,
                note: note,
                lessonNotes: lessonNotes,
                status: status,
                statusReason: statusReason,
                statusReasonSource: statusReasonSource,
                statusChangedAt: statusChangedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LessonsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LessonsTable,
      Lesson,
      $$LessonsTableFilterComposer,
      $$LessonsTableOrderingComposer,
      $$LessonsTableAnnotationComposer,
      $$LessonsTableCreateCompanionBuilder,
      $$LessonsTableUpdateCompanionBuilder,
      (Lesson, BaseReferences<_$AppDatabase, $LessonsTable, Lesson>),
      Lesson,
      PrefetchHooks Function()
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      required String id,
      required String lessonId,
      required String filePath,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<String> id,
      Value<String> lessonId,
      Value<String> filePath,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentsTable,
          Attachment,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (
            Attachment,
            BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment>,
          ),
          Attachment,
          PrefetchHooks Function()
        > {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> lessonId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                lessonId: lessonId,
                filePath: filePath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String lessonId,
                required String filePath,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                id: id,
                lessonId: lessonId,
                filePath: filePath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentsTable,
      Attachment,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (
        Attachment,
        BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment>,
      ),
      Attachment,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$PaymentsTableCreateCompanionBuilder =
    PaymentsCompanion Function({
      required String id,
      required String studentId,
      required DateTime paidAt,
      required int amount,
      required String method,
      Value<String?> note,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PaymentsTableUpdateCompanionBuilder =
    PaymentsCompanion Function({
      Value<String> id,
      Value<String> studentId,
      Value<DateTime> paidAt,
      Value<int> amount,
      Value<String> method,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<DateTime> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          Payment,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
          Payment,
          PrefetchHooks Function()
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<DateTime> paidAt = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                studentId: studentId,
                paidAt: paidAt,
                amount: amount,
                method: method,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentId,
                required DateTime paidAt,
                required int amount,
                required String method,
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                studentId: studentId,
                paidAt: paidAt,
                amount: amount,
                method: method,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      Payment,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
      Payment,
      PrefetchHooks Function()
    >;
typedef $$LessonPaymentsTableCreateCompanionBuilder =
    LessonPaymentsCompanion Function({
      required String id,
      required String paymentId,
      required String lessonId,
      required int appliedAmount,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LessonPaymentsTableUpdateCompanionBuilder =
    LessonPaymentsCompanion Function({
      Value<String> id,
      Value<String> paymentId,
      Value<String> lessonId,
      Value<int> appliedAmount,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LessonPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $LessonPaymentsTable> {
  $$LessonPaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get appliedAmount => $composableBuilder(
    column: $table.appliedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LessonPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $LessonPaymentsTable> {
  $$LessonPaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get appliedAmount => $composableBuilder(
    column: $table.appliedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LessonPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LessonPaymentsTable> {
  $$LessonPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get paymentId =>
      $composableBuilder(column: $table.paymentId, builder: (column) => column);

  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<int> get appliedAmount => $composableBuilder(
    column: $table.appliedAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LessonPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LessonPaymentsTable,
          LessonPayment,
          $$LessonPaymentsTableFilterComposer,
          $$LessonPaymentsTableOrderingComposer,
          $$LessonPaymentsTableAnnotationComposer,
          $$LessonPaymentsTableCreateCompanionBuilder,
          $$LessonPaymentsTableUpdateCompanionBuilder,
          (
            LessonPayment,
            BaseReferences<_$AppDatabase, $LessonPaymentsTable, LessonPayment>,
          ),
          LessonPayment,
          PrefetchHooks Function()
        > {
  $$LessonPaymentsTableTableManager(
    _$AppDatabase db,
    $LessonPaymentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LessonPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LessonPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LessonPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> paymentId = const Value.absent(),
                Value<String> lessonId = const Value.absent(),
                Value<int> appliedAmount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LessonPaymentsCompanion(
                id: id,
                paymentId: paymentId,
                lessonId: lessonId,
                appliedAmount: appliedAmount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String paymentId,
                required String lessonId,
                required int appliedAmount,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LessonPaymentsCompanion.insert(
                id: id,
                paymentId: paymentId,
                lessonId: lessonId,
                appliedAmount: appliedAmount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LessonPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LessonPaymentsTable,
      LessonPayment,
      $$LessonPaymentsTableFilterComposer,
      $$LessonPaymentsTableOrderingComposer,
      $$LessonPaymentsTableAnnotationComposer,
      $$LessonPaymentsTableCreateCompanionBuilder,
      $$LessonPaymentsTableUpdateCompanionBuilder,
      (
        LessonPayment,
        BaseReferences<_$AppDatabase, $LessonPaymentsTable, LessonPayment>,
      ),
      LessonPayment,
      PrefetchHooks Function()
    >;
typedef $$CurriculumSubjectsTableCreateCompanionBuilder =
    CurriculumSubjectsCompanion Function({
      required String id,
      required String name,
      Value<int> sortOrder,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CurriculumSubjectsTableUpdateCompanionBuilder =
    CurriculumSubjectsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CurriculumSubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $CurriculumSubjectsTable> {
  $$CurriculumSubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CurriculumSubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $CurriculumSubjectsTable> {
  $$CurriculumSubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CurriculumSubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CurriculumSubjectsTable> {
  $$CurriculumSubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CurriculumSubjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CurriculumSubjectsTable,
          CurriculumSubject,
          $$CurriculumSubjectsTableFilterComposer,
          $$CurriculumSubjectsTableOrderingComposer,
          $$CurriculumSubjectsTableAnnotationComposer,
          $$CurriculumSubjectsTableCreateCompanionBuilder,
          $$CurriculumSubjectsTableUpdateCompanionBuilder,
          (
            CurriculumSubject,
            BaseReferences<
              _$AppDatabase,
              $CurriculumSubjectsTable,
              CurriculumSubject
            >,
          ),
          CurriculumSubject,
          PrefetchHooks Function()
        > {
  $$CurriculumSubjectsTableTableManager(
    _$AppDatabase db,
    $CurriculumSubjectsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CurriculumSubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CurriculumSubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CurriculumSubjectsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CurriculumSubjectsCompanion(
                id: id,
                name: name,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CurriculumSubjectsCompanion.insert(
                id: id,
                name: name,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CurriculumSubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CurriculumSubjectsTable,
      CurriculumSubject,
      $$CurriculumSubjectsTableFilterComposer,
      $$CurriculumSubjectsTableOrderingComposer,
      $$CurriculumSubjectsTableAnnotationComposer,
      $$CurriculumSubjectsTableCreateCompanionBuilder,
      $$CurriculumSubjectsTableUpdateCompanionBuilder,
      (
        CurriculumSubject,
        BaseReferences<
          _$AppDatabase,
          $CurriculumSubjectsTable,
          CurriculumSubject
        >,
      ),
      CurriculumSubject,
      PrefetchHooks Function()
    >;
typedef $$CurriculumUnitsTableCreateCompanionBuilder =
    CurriculumUnitsCompanion Function({
      required String id,
      required String subjectId,
      required String name,
      Value<int> sortOrder,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CurriculumUnitsTableUpdateCompanionBuilder =
    CurriculumUnitsCompanion Function({
      Value<String> id,
      Value<String> subjectId,
      Value<String> name,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CurriculumUnitsTableFilterComposer
    extends Composer<_$AppDatabase, $CurriculumUnitsTable> {
  $$CurriculumUnitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CurriculumUnitsTableOrderingComposer
    extends Composer<_$AppDatabase, $CurriculumUnitsTable> {
  $$CurriculumUnitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CurriculumUnitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CurriculumUnitsTable> {
  $$CurriculumUnitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CurriculumUnitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CurriculumUnitsTable,
          CurriculumUnit,
          $$CurriculumUnitsTableFilterComposer,
          $$CurriculumUnitsTableOrderingComposer,
          $$CurriculumUnitsTableAnnotationComposer,
          $$CurriculumUnitsTableCreateCompanionBuilder,
          $$CurriculumUnitsTableUpdateCompanionBuilder,
          (
            CurriculumUnit,
            BaseReferences<
              _$AppDatabase,
              $CurriculumUnitsTable,
              CurriculumUnit
            >,
          ),
          CurriculumUnit,
          PrefetchHooks Function()
        > {
  $$CurriculumUnitsTableTableManager(
    _$AppDatabase db,
    $CurriculumUnitsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CurriculumUnitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CurriculumUnitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CurriculumUnitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CurriculumUnitsCompanion(
                id: id,
                subjectId: subjectId,
                name: name,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String subjectId,
                required String name,
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CurriculumUnitsCompanion.insert(
                id: id,
                subjectId: subjectId,
                name: name,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CurriculumUnitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CurriculumUnitsTable,
      CurriculumUnit,
      $$CurriculumUnitsTableFilterComposer,
      $$CurriculumUnitsTableOrderingComposer,
      $$CurriculumUnitsTableAnnotationComposer,
      $$CurriculumUnitsTableCreateCompanionBuilder,
      $$CurriculumUnitsTableUpdateCompanionBuilder,
      (
        CurriculumUnit,
        BaseReferences<_$AppDatabase, $CurriculumUnitsTable, CurriculumUnit>,
      ),
      CurriculumUnit,
      PrefetchHooks Function()
    >;
typedef $$CurriculumTopicsTableCreateCompanionBuilder =
    CurriculumTopicsCompanion Function({
      required String id,
      required String unitId,
      required String name,
      Value<int> sortOrder,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CurriculumTopicsTableUpdateCompanionBuilder =
    CurriculumTopicsCompanion Function({
      Value<String> id,
      Value<String> unitId,
      Value<String> name,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CurriculumTopicsTableFilterComposer
    extends Composer<_$AppDatabase, $CurriculumTopicsTable> {
  $$CurriculumTopicsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitId => $composableBuilder(
    column: $table.unitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CurriculumTopicsTableOrderingComposer
    extends Composer<_$AppDatabase, $CurriculumTopicsTable> {
  $$CurriculumTopicsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitId => $composableBuilder(
    column: $table.unitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CurriculumTopicsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CurriculumTopicsTable> {
  $$CurriculumTopicsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get unitId =>
      $composableBuilder(column: $table.unitId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CurriculumTopicsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CurriculumTopicsTable,
          CurriculumTopic,
          $$CurriculumTopicsTableFilterComposer,
          $$CurriculumTopicsTableOrderingComposer,
          $$CurriculumTopicsTableAnnotationComposer,
          $$CurriculumTopicsTableCreateCompanionBuilder,
          $$CurriculumTopicsTableUpdateCompanionBuilder,
          (
            CurriculumTopic,
            BaseReferences<
              _$AppDatabase,
              $CurriculumTopicsTable,
              CurriculumTopic
            >,
          ),
          CurriculumTopic,
          PrefetchHooks Function()
        > {
  $$CurriculumTopicsTableTableManager(
    _$AppDatabase db,
    $CurriculumTopicsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CurriculumTopicsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CurriculumTopicsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CurriculumTopicsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> unitId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CurriculumTopicsCompanion(
                id: id,
                unitId: unitId,
                name: name,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String unitId,
                required String name,
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CurriculumTopicsCompanion.insert(
                id: id,
                unitId: unitId,
                name: name,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CurriculumTopicsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CurriculumTopicsTable,
      CurriculumTopic,
      $$CurriculumTopicsTableFilterComposer,
      $$CurriculumTopicsTableOrderingComposer,
      $$CurriculumTopicsTableAnnotationComposer,
      $$CurriculumTopicsTableCreateCompanionBuilder,
      $$CurriculumTopicsTableUpdateCompanionBuilder,
      (
        CurriculumTopic,
        BaseReferences<_$AppDatabase, $CurriculumTopicsTable, CurriculumTopic>,
      ),
      CurriculumTopic,
      PrefetchHooks Function()
    >;
typedef $$CurriculumOutcomesTableCreateCompanionBuilder =
    CurriculumOutcomesCompanion Function({
      required String id,
      required String topicId,
      required String name,
      Value<int> sortOrder,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CurriculumOutcomesTableUpdateCompanionBuilder =
    CurriculumOutcomesCompanion Function({
      Value<String> id,
      Value<String> topicId,
      Value<String> name,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CurriculumOutcomesTableFilterComposer
    extends Composer<_$AppDatabase, $CurriculumOutcomesTable> {
  $$CurriculumOutcomesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topicId => $composableBuilder(
    column: $table.topicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CurriculumOutcomesTableOrderingComposer
    extends Composer<_$AppDatabase, $CurriculumOutcomesTable> {
  $$CurriculumOutcomesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topicId => $composableBuilder(
    column: $table.topicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CurriculumOutcomesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CurriculumOutcomesTable> {
  $$CurriculumOutcomesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CurriculumOutcomesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CurriculumOutcomesTable,
          CurriculumOutcome,
          $$CurriculumOutcomesTableFilterComposer,
          $$CurriculumOutcomesTableOrderingComposer,
          $$CurriculumOutcomesTableAnnotationComposer,
          $$CurriculumOutcomesTableCreateCompanionBuilder,
          $$CurriculumOutcomesTableUpdateCompanionBuilder,
          (
            CurriculumOutcome,
            BaseReferences<
              _$AppDatabase,
              $CurriculumOutcomesTable,
              CurriculumOutcome
            >,
          ),
          CurriculumOutcome,
          PrefetchHooks Function()
        > {
  $$CurriculumOutcomesTableTableManager(
    _$AppDatabase db,
    $CurriculumOutcomesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CurriculumOutcomesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CurriculumOutcomesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CurriculumOutcomesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> topicId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CurriculumOutcomesCompanion(
                id: id,
                topicId: topicId,
                name: name,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String topicId,
                required String name,
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CurriculumOutcomesCompanion.insert(
                id: id,
                topicId: topicId,
                name: name,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CurriculumOutcomesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CurriculumOutcomesTable,
      CurriculumOutcome,
      $$CurriculumOutcomesTableFilterComposer,
      $$CurriculumOutcomesTableOrderingComposer,
      $$CurriculumOutcomesTableAnnotationComposer,
      $$CurriculumOutcomesTableCreateCompanionBuilder,
      $$CurriculumOutcomesTableUpdateCompanionBuilder,
      (
        CurriculumOutcome,
        BaseReferences<
          _$AppDatabase,
          $CurriculumOutcomesTable,
          CurriculumOutcome
        >,
      ),
      CurriculumOutcome,
      PrefetchHooks Function()
    >;
typedef $$HomeworkItemsTableCreateCompanionBuilder =
    HomeworkItemsCompanion Function({
      required String id,
      required String lessonId,
      required String studentId,
      required DateTime assignedAt,
      Value<String?> resource,
      required String topic,
      Value<String?> detail,
      Value<String> status,
      Value<String?> statusNote,
      Value<DateTime?> dueAt,
      Value<DateTime?> statusChangedAt,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$HomeworkItemsTableUpdateCompanionBuilder =
    HomeworkItemsCompanion Function({
      Value<String> id,
      Value<String> lessonId,
      Value<String> studentId,
      Value<DateTime> assignedAt,
      Value<String?> resource,
      Value<String> topic,
      Value<String?> detail,
      Value<String> status,
      Value<String?> statusNote,
      Value<DateTime?> dueAt,
      Value<DateTime?> statusChangedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$HomeworkItemsTableFilterComposer
    extends Composer<_$AppDatabase, $HomeworkItemsTable> {
  $$HomeworkItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get assignedAt => $composableBuilder(
    column: $table.assignedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resource => $composableBuilder(
    column: $table.resource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusNote => $composableBuilder(
    column: $table.statusNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get statusChangedAt => $composableBuilder(
    column: $table.statusChangedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HomeworkItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $HomeworkItemsTable> {
  $$HomeworkItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get assignedAt => $composableBuilder(
    column: $table.assignedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resource => $composableBuilder(
    column: $table.resource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusNote => $composableBuilder(
    column: $table.statusNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get statusChangedAt => $composableBuilder(
    column: $table.statusChangedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HomeworkItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HomeworkItemsTable> {
  $$HomeworkItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<DateTime> get assignedAt => $composableBuilder(
    column: $table.assignedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resource =>
      $composableBuilder(column: $table.resource, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get statusNote => $composableBuilder(
    column: $table.statusNote,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get statusChangedAt => $composableBuilder(
    column: $table.statusChangedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HomeworkItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HomeworkItemsTable,
          HomeworkItem,
          $$HomeworkItemsTableFilterComposer,
          $$HomeworkItemsTableOrderingComposer,
          $$HomeworkItemsTableAnnotationComposer,
          $$HomeworkItemsTableCreateCompanionBuilder,
          $$HomeworkItemsTableUpdateCompanionBuilder,
          (
            HomeworkItem,
            BaseReferences<_$AppDatabase, $HomeworkItemsTable, HomeworkItem>,
          ),
          HomeworkItem,
          PrefetchHooks Function()
        > {
  $$HomeworkItemsTableTableManager(_$AppDatabase db, $HomeworkItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HomeworkItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HomeworkItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HomeworkItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> lessonId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<DateTime> assignedAt = const Value.absent(),
                Value<String?> resource = const Value.absent(),
                Value<String> topic = const Value.absent(),
                Value<String?> detail = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> statusNote = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime?> statusChangedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HomeworkItemsCompanion(
                id: id,
                lessonId: lessonId,
                studentId: studentId,
                assignedAt: assignedAt,
                resource: resource,
                topic: topic,
                detail: detail,
                status: status,
                statusNote: statusNote,
                dueAt: dueAt,
                statusChangedAt: statusChangedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String lessonId,
                required String studentId,
                required DateTime assignedAt,
                Value<String?> resource = const Value.absent(),
                required String topic,
                Value<String?> detail = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> statusNote = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime?> statusChangedAt = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => HomeworkItemsCompanion.insert(
                id: id,
                lessonId: lessonId,
                studentId: studentId,
                assignedAt: assignedAt,
                resource: resource,
                topic: topic,
                detail: detail,
                status: status,
                statusNote: statusNote,
                dueAt: dueAt,
                statusChangedAt: statusChangedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HomeworkItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HomeworkItemsTable,
      HomeworkItem,
      $$HomeworkItemsTableFilterComposer,
      $$HomeworkItemsTableOrderingComposer,
      $$HomeworkItemsTableAnnotationComposer,
      $$HomeworkItemsTableCreateCompanionBuilder,
      $$HomeworkItemsTableUpdateCompanionBuilder,
      (
        HomeworkItem,
        BaseReferences<_$AppDatabase, $HomeworkItemsTable, HomeworkItem>,
      ),
      HomeworkItem,
      PrefetchHooks Function()
    >;
typedef $$TeacherTodosTableCreateCompanionBuilder =
    TeacherTodosCompanion Function({
      required String id,
      required String title,
      Value<String?> studentId,
      Value<String?> studentName,
      Value<String?> homeworkItemId,
      Value<String?> homeworkTopic,
      Value<bool> isDone,
      Value<DateTime?> notifyAt,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$TeacherTodosTableUpdateCompanionBuilder =
    TeacherTodosCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> studentId,
      Value<String?> studentName,
      Value<String?> homeworkItemId,
      Value<String?> homeworkTopic,
      Value<bool> isDone,
      Value<DateTime?> notifyAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$TeacherTodosTableFilterComposer
    extends Composer<_$AppDatabase, $TeacherTodosTable> {
  $$TeacherTodosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentName => $composableBuilder(
    column: $table.studentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homeworkItemId => $composableBuilder(
    column: $table.homeworkItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homeworkTopic => $composableBuilder(
    column: $table.homeworkTopic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get notifyAt => $composableBuilder(
    column: $table.notifyAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TeacherTodosTableOrderingComposer
    extends Composer<_$AppDatabase, $TeacherTodosTable> {
  $$TeacherTodosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentName => $composableBuilder(
    column: $table.studentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homeworkItemId => $composableBuilder(
    column: $table.homeworkItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homeworkTopic => $composableBuilder(
    column: $table.homeworkTopic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get notifyAt => $composableBuilder(
    column: $table.notifyAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TeacherTodosTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeacherTodosTable> {
  $$TeacherTodosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get studentName => $composableBuilder(
    column: $table.studentName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get homeworkItemId => $composableBuilder(
    column: $table.homeworkItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get homeworkTopic => $composableBuilder(
    column: $table.homeworkTopic,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  GeneratedColumn<DateTime> get notifyAt =>
      $composableBuilder(column: $table.notifyAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TeacherTodosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TeacherTodosTable,
          TeacherTodo,
          $$TeacherTodosTableFilterComposer,
          $$TeacherTodosTableOrderingComposer,
          $$TeacherTodosTableAnnotationComposer,
          $$TeacherTodosTableCreateCompanionBuilder,
          $$TeacherTodosTableUpdateCompanionBuilder,
          (
            TeacherTodo,
            BaseReferences<_$AppDatabase, $TeacherTodosTable, TeacherTodo>,
          ),
          TeacherTodo,
          PrefetchHooks Function()
        > {
  $$TeacherTodosTableTableManager(_$AppDatabase db, $TeacherTodosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeacherTodosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeacherTodosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeacherTodosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> studentId = const Value.absent(),
                Value<String?> studentName = const Value.absent(),
                Value<String?> homeworkItemId = const Value.absent(),
                Value<String?> homeworkTopic = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<DateTime?> notifyAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeacherTodosCompanion(
                id: id,
                title: title,
                studentId: studentId,
                studentName: studentName,
                homeworkItemId: homeworkItemId,
                homeworkTopic: homeworkTopic,
                isDone: isDone,
                notifyAt: notifyAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> studentId = const Value.absent(),
                Value<String?> studentName = const Value.absent(),
                Value<String?> homeworkItemId = const Value.absent(),
                Value<String?> homeworkTopic = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<DateTime?> notifyAt = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TeacherTodosCompanion.insert(
                id: id,
                title: title,
                studentId: studentId,
                studentName: studentName,
                homeworkItemId: homeworkItemId,
                homeworkTopic: homeworkTopic,
                isDone: isDone,
                notifyAt: notifyAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TeacherTodosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TeacherTodosTable,
      TeacherTodo,
      $$TeacherTodosTableFilterComposer,
      $$TeacherTodosTableOrderingComposer,
      $$TeacherTodosTableAnnotationComposer,
      $$TeacherTodosTableCreateCompanionBuilder,
      $$TeacherTodosTableUpdateCompanionBuilder,
      (
        TeacherTodo,
        BaseReferences<_$AppDatabase, $TeacherTodosTable, TeacherTodo>,
      ),
      TeacherTodo,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db, _db.students);
  $$ScheduleTemplatesTableTableManager get scheduleTemplates =>
      $$ScheduleTemplatesTableTableManager(_db, _db.scheduleTemplates);
  $$ScheduleOverridesTableTableManager get scheduleOverrides =>
      $$ScheduleOverridesTableTableManager(_db, _db.scheduleOverrides);
  $$SessionOccurrencesTableTableManager get sessionOccurrences =>
      $$SessionOccurrencesTableTableManager(_db, _db.sessionOccurrences);
  $$LessonsTableTableManager get lessons =>
      $$LessonsTableTableManager(_db, _db.lessons);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$LessonPaymentsTableTableManager get lessonPayments =>
      $$LessonPaymentsTableTableManager(_db, _db.lessonPayments);
  $$CurriculumSubjectsTableTableManager get curriculumSubjects =>
      $$CurriculumSubjectsTableTableManager(_db, _db.curriculumSubjects);
  $$CurriculumUnitsTableTableManager get curriculumUnits =>
      $$CurriculumUnitsTableTableManager(_db, _db.curriculumUnits);
  $$CurriculumTopicsTableTableManager get curriculumTopics =>
      $$CurriculumTopicsTableTableManager(_db, _db.curriculumTopics);
  $$CurriculumOutcomesTableTableManager get curriculumOutcomes =>
      $$CurriculumOutcomesTableTableManager(_db, _db.curriculumOutcomes);
  $$HomeworkItemsTableTableManager get homeworkItems =>
      $$HomeworkItemsTableTableManager(_db, _db.homeworkItems);
  $$TeacherTodosTableTableManager get teacherTodos =>
      $$TeacherTodosTableTableManager(_db, _db.teacherTodos);
}
