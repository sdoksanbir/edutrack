# ozel_ders_takip

Özel Ders Takip Uygulaması

## Veritabanı Schema Güncellemeleri

**ÖNEMLİ:** Veritabanı şeması değiştiğinde (tables.dart veya app_database.dart güncellendiğinde) aşağıdaki komutu çalıştırın:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Bu komut `app_database.g.dart` dosyasını yeniden oluşturur ve veritabanı migration'larını uygular.

## Son Yapılan Değişiklikler

- SessionOccurrences tablosu eklendi (planlanan derslerin gerçekleşme durumu)
- Lessons tablosuna occurrenceId alanı eklendi
- Planlanan dersler ile gerçekleşen ders kayıtları ayrıldı
- Takvim ekranında "Yapıldı" / "Yapılmadı" seçenekleri eklendi
- Öğrenci detay ekranına "Geçmiş Dersler" bölümü eklendi
- Dersler ekranı "Yapılmayan Dersler" raporuna dönüştürüldü

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
