import 'dart:io';
import 'package:drift/drift.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class AttachmentsRepository {
  final AppDatabase _db;
  final ImagePicker _imagePicker;
  final _uuid = const Uuid();

  AttachmentsRepository(this._db) : _imagePicker = ImagePicker();

  /// Galeriden foto ekle
  Future<String> addAttachmentFromGallery(String lessonId) async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) {
      throw Exception('Fotoğraf seçilmedi');
    }

    return await _saveAttachment(lessonId, image);
  }

  /// Kameradan foto ekle
  Future<String> addAttachmentFromCamera(String lessonId) async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image == null) {
      throw Exception('Fotoğraf çekilmedi');
    }

    return await _saveAttachment(lessonId, image);
  }

  /// Fotoğrafı kaydet ve veritabanına ekle
  Future<String> _saveAttachment(String lessonId, XFile image) async {
    // Uygulama dokümanları dizinini al
    final appDir = await getApplicationDocumentsDirectory();
    final attachmentsDir = Directory(p.join(appDir.path, 'attachments'));

    // Dizin yoksa oluştur
    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }

    // Dosya adı: uuid.jpg
    final fileName = '${_uuid.v4()}.jpg';
    final targetPath = p.join(attachmentsDir.path, fileName);

    // Dosyayı kopyala
    final sourceFile = File(image.path);
    await sourceFile.copy(targetPath);

    // Veritabanına kaydet
    final id = _uuid.v4();
    final now = DateTime.now();

    await _db.into(_db.attachments).insert(
          AttachmentsCompanion.insert(
            id: id,
            lessonId: lessonId,
            filePath: targetPath,
            createdAt: now,
          ),
        );

    return id;
  }

  /// Derse ait ekleri stream olarak döndürür
  Stream<List<Attachment>> watchAttachments(String lessonId) {
    return (_db.select(_db.attachments)
          ..where((a) => a.lessonId.equals(lessonId))
          ..orderBy([(a) => OrderingTerm(expression: a.createdAt, mode: OrderingMode.desc)]))
        .watch();
  }

  /// Eki siler (dosyayı da siler)
  Future<void> deleteAttachment(String id) async {
    // Önce dosya yolunu al
    final attachment = await (_db.select(_db.attachments)
          ..where((a) => a.id.equals(id)))
        .getSingleOrNull();

    if (attachment != null) {
      // Dosyayı sil
      final file = File(attachment.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Veritabanından sil
      await (_db.delete(_db.attachments)..where((a) => a.id.equals(id))).go();
    }
  }
}
