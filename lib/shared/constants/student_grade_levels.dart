/// Öğrenci sınıf / seviye sabitleri ve müfredat ders eşlemesi.
class StudentGradeLevels {
  StudentGradeLevels._();

  static const grade9 = '9';
  static const grade10 = '10';
  static const grade11 = '11';
  static const grade12 = '12';
  static const lgs = 'lgs';
  static const tyt = 'tyt';
  static const ayt = 'ayt';
  static const tytAyt = 'tyt_ayt';

  static const List<({String value, String label})> options = [
    (value: grade9, label: '9. Sınıf'),
    (value: grade10, label: '10. Sınıf'),
    (value: grade11, label: '11. Sınıf'),
    (value: grade12, label: '12. Sınıf'),
    (value: lgs, label: 'LGS'),
    (value: tyt, label: 'TYT'),
    (value: ayt, label: 'AYT'),
    (value: tytAyt, label: 'TYT / AYT'),
  ];

  static String? labelFor(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final o in options) {
      if (o.value == value) return o.label;
    }
    return value;
  }

  /// Konu seçicide grup başlıkları (collapse).
  static const List<String> subjectGroups = [
    'LGS',
    'TYT',
    'AYT',
    '9. Sınıf',
    '10. Sınıf',
    '11. Sınıf',
    'Diğer',
  ];

  static String groupForSubjectName(String name) {
    final n = name.toLowerCase();
    if (n.contains('lgs')) return 'LGS';
    if (n.startsWith('tyt') || n.contains(' tyt')) return 'TYT';
    if (n.startsWith('ayt') || n.contains(' ayt')) return 'AYT';
    if (n.contains('9. sınıf') || n.contains('9.sinif')) return '9. Sınıf';
    if (n.contains('10. sınıf') || n.contains('10.sinif')) return '10. Sınıf';
    if (n.contains('11. sınıf') || n.contains('11.sinif')) return '11. Sınıf';
    return 'Diğer';
  }

  /// Öğrenci sınıfına göre hangi derslerin listeleneceği.
  static bool subjectMatchesGrade(String subjectName, String? gradeLevel) {
    if (gradeLevel == null || gradeLevel.isEmpty) return true;
    final n = subjectName.toLowerCase();
    switch (gradeLevel) {
      case grade9:
        return n.contains('9. sınıf') || n.contains('9.sinif');
      case grade10:
        return n.contains('10. sınıf') || n.contains('10.sinif');
      case grade11:
        return n.contains('11. sınıf') ||
            n.contains('11.sinif') ||
            n.contains('tyt');
      case grade12:
        return n.contains('tyt') || n.contains('ayt');
      case lgs:
        return n.contains('lgs');
      case tyt:
        return n.contains('tyt');
      case ayt:
        return n.contains('ayt');
      case tytAyt:
        return n.contains('tyt') || n.contains('ayt');
      default:
        return true;
    }
  }

  /// Varsayılan açık collapse grubu (öğrenci sınıfı veya öğretmen branşı).
  static Set<String> defaultExpandedGroups(String? gradeLevel) {
    switch (gradeLevel) {
      case grade9:
        return {'9. Sınıf'};
      case grade10:
        return {'10. Sınıf'};
      case grade11:
        return {'11. Sınıf', 'TYT'};
      case grade12:
      case tytAyt:
        return {'TYT', 'AYT'};
      case lgs:
        return {'LGS'};
      case tyt:
        return {'TYT'};
      case ayt:
        return {'AYT'};
      default:
        return {'TYT', 'AYT'};
    }
  }
}
