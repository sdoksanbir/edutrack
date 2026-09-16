import 'dart:io';

/// Öğretmen profili (yerel ayarlar).
class TeacherProfile {
  const TeacherProfile({
    this.fullName = '',
    this.phone,
    this.photoPath,
    this.branches = const [],
    this.visibleFolders = const [],
  });

  final String fullName;
  final String? phone;
  final String? photoPath;

  /// Branşlar: Parametreler'de başlangıçta açık kalacak klasörler.
  final List<String> branches;

  /// Görünecek ders klasörleri; boşsa hepsi görünür.
  final List<String> visibleFolders;

  bool get hasPhoto {
    final path = photoPath;
    return path != null && path.isNotEmpty && File(path).existsSync();
  }

  String get displayName {
    final n = fullName.trim();
    return n.isEmpty ? 'Öğretmen' : n;
  }

  String get branchesLabel {
    if (branches.isEmpty) return 'Branş seçilmedi';
    return branches.join(' · ');
  }

  TeacherProfile copyWith({
    String? fullName,
    String? phone,
    bool clearPhone = false,
    String? photoPath,
    bool clearPhoto = false,
    List<String>? branches,
    List<String>? visibleFolders,
  }) {
    return TeacherProfile(
      fullName: fullName ?? this.fullName,
      phone: clearPhone ? null : (phone ?? this.phone),
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      branches: branches ?? this.branches,
      visibleFolders: visibleFolders ?? this.visibleFolders,
    );
  }
}
