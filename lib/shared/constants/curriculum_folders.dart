/// Müfredat klasör (branş) adları — Parametreler ve profil seçimleri.
class CurriculumFolders {
  CurriculumFolders._();

  static const List<String> all = [
    'MATEMATİK',
    'FİZİK',
    'KİMYA',
    'BİYOLOJİ',
    'TÜRKÇE',
    'TARİH',
    'COĞRAFYA',
  ];

  static int compare(String a, String b) {
    final ia = all.indexOf(a);
    final ib = all.indexOf(b);
    if (ia >= 0 && ib >= 0) return ia.compareTo(ib);
    if (ia >= 0) return -1;
    if (ib >= 0) return 1;
    return a.compareTo(b);
  }
}
