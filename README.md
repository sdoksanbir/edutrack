# EduTrack — Özel Ders Takip

Özel derslerinizi, öğrencileri, takvimi, ödevleri ve ödemeleri tek yerden yöneten Flutter uygulaması.

Depo: [github.com/sdoksanbir/edutrack](https://github.com/sdoksanbir/edutrack)

---

## Gereksinimler

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (önerilen: **3.24+**, Dart **3.10+**)
- Windows için: [Visual Studio](https://visualstudio.microsoft.com/) (Desktop development with C++) veya Android Studio / cihaz
- Android için: Android Studio + SDK
- Git (klonlamak için)

Kurulumdan sonra kontrol:

```bash
flutter doctor
```

---

## 1) Projeyi indirme

### Seçenek A — Git ile klonlama (önerilen)

```bash
git clone https://github.com/sdoksanbir/edutrack.git
cd edutrack
```

### Seçenek B — ZIP olarak indirme

1. [Depo sayfasına](https://github.com/sdoksanbir/edutrack) gidin  
2. **Code → Download ZIP**  
3. ZIP’i açın ve klasöre girin  

---

## 2) Bağımlılıkları kurma

Proje klasöründe:

```bash
flutter pub get
```

Veritabanı kod üretimi (Drift) gerekirse:

```bash
dart run build_runner build --delete-conflicting-outputs
```

> Şema değiştiğinde (`lib/data/local/tables.dart` veya `app_database.dart`) bu komutu yeniden çalıştırın.

---

## 3) Uygulamayı çalıştırma

Bağlı cihaz / emülatör listesi:

```bash
flutter devices
```

### Windows masaüstü

```bash
flutter run -d windows
```

### Android

```bash
flutter run -d android
```

### Belirli bir cihaz

```bash
flutter run -d <cihaz_id>
```

İlk derleme biraz sürebilir. Hot reload için terminalde `r`, hot restart için `R`.

---

## 4) Derleme (isteğe bağlı)

### Windows release

```bash
flutter build windows
```

Çıktı: `build/windows/x64/runner/Release/`

### Android APK

```bash
flutter build apk --release
```

Çıktı: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (Play Store)

```bash
flutter build appbundle --release
```

---

## 5) Supabase (opsiyonel bulut)

Yerel Drift veritabanı varsayılandır. Bulut için:

1. [supabase.com](https://supabase.com) üzerinde proje oluşturun  
2. **Settings → API** içinden `Project URL` ve `anon` / publishable key alın  
3. Örnek dosya: `supabase.env.example`  
4. Çalıştırırken:

```bash
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Key yoksa uygulama yine açılır (yerel mod). Client: `lib/services/supabase_client.dart`.

Şema + RLS SQL (sırayla çalıştırın):

- `supabase/migrations/001_edutrack_schema.sql`
- `002_profile_phone.sql`
- `003_student_grade_level.sql`
- `004_full_backup_schema.sql` (ödev alanları + bitirilen konular)

Adımlar: `supabase/README.md`

Giriş yaptıktan sonra **Ayarlar → Bulut yedekleme** ile tüm veriyi (takvim, ödevler, konular, ödemeler vb.) yedekleyebilirsiniz. Varsayılan: her gün 22:00 (uygulama açıkken / açılışta zamanı gelmişse çalışır).

Supabase key ile çalıştırınca giriş ekranı açılır. Yerel modda (key yok) giriş atlanır.

---

## Sık karşılaşılan sorunlar

| Sorun | Çözüm |
|--------|--------|
| `flutter` komutu bulunamadı | Flutter’ı PATH’e ekleyin, terminali yeniden açın |
| Bağımlılık / paket hatası | `flutter clean` sonra `flutter pub get` |
| Drift / veritabanı hatası | `dart run build_runner build --delete-conflicting-outputs` |
| Windows derleme hatası | Visual Studio’da “Desktop development with C++” yüklü olmalı |
| Android lisans uyarısı | `flutter doctor --android-licenses` |

---

## Proje yapısı (kısa)

```
lib/
  app/           # Router
  data/          # Veritabanı, repository’ler, provider’lar
  features/      # Ana sayfa, takvim, dersler, ödevler, ödemeler, öğrenciler
  services/      # Bildirimler, Supabase client
  shared/        # Tema, i18n, yardımcılar
```

---

## Lisans

Özel proje — [sdoksanbir/edutrack](https://github.com/sdoksanbir/edutrack).
