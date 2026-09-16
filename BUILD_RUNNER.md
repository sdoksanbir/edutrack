# Build Runner - Drift Kod Üretimi

Bu proje Drift veritabanı kullanıyor. Drift, kod üretimi (code generation) gerektirir.

## İlk Kurulum

Projeyi ilk kez çalıştırmadan önce build_runner'ı çalıştırmanız gerekiyor:

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## Kod Değişikliklerinden Sonra

Eğer `lib/data/local/tables.dart` veya `lib/data/local/app_database.dart` dosyalarında değişiklik yaptıysanız, tekrar build_runner çalıştırın:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Watch Mode (Geliştirme İçin)

Geliştirme sırasında otomatik kod üretimi için watch mode kullanabilirsiniz:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

Bu komut dosya değişikliklerini izler ve otomatik olarak kod üretir.

## Notlar

- `--delete-conflicting-outputs` parametresi, mevcut üretilmiş dosyaları siler ve yeniden oluşturur.
- Üretilen dosya: `lib/data/local/app_database.g.dart`
- Bu dosya otomatik oluşturulur, manuel düzenlemeyin!
