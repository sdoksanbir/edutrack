# Supabase kurulum (EduTrack)

## 1) SQL şemayı çalıştır

1. [Supabase Dashboard](https://supabase.com/dashboard) → **EDUTRACK** projesi  
2. Sol menü → **SQL Editor** → **New query**  
3. Repodaki dosyayı aç: [`migrations/001_edutrack_schema.sql`](migrations/001_edutrack_schema.sql)  
4. Tüm içeriği yapıştır → **Run**

Bu işlem:
- Drift ile uyumlu tabloları oluşturur (`owner_id` ile öğretmen ayrımı)
- **RLS** politikalarını açar
- `profiles` + auth kullanıcı tetikleyicisi
- Storage bucket: `edutrack` (dosya yolu: `{user_id}/...`)

Mevcut projeye telefon alanı eklemek için ayrıca çalıştırın:  
[`migrations/002_profile_phone.sql`](migrations/002_profile_phone.sql)

## 2) Auth kullanıcısı

**Authentication → Users → Add user** ile bir öğretmen hesabı oluştur  
(veya uygulamadan kayıt).

## 3) Flutter’da bağlantı

Project URL (kök; `/rest/v1` olmadan):

```text
https://YOUR_REF.supabase.co
```

Anon / publishable key (Settings → API Keys → **anon public**).

```bash
flutter run --dart-define=SUPABASE_URL=https://YOUR_REF.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Key yoksa uygulama **yerel Drift** ile çalışır.

## 4) Güvenlik

| Key | Kullanım |
|-----|----------|
| `anon` / publishable | Flutter’da OK (RLS şart) |
| `service_role` | Sadece sunucu / Dashboard; **asla uygulamaya koyma** |

## 5) Giriş ekranı

`flutter run` + dart-define ile açınca `/login` gelir. Dashboard’da oluşturduğun e-posta/şifre ile giriş yap.

**Ayarlar → Çıkış yap** oturumu kapatır.

E-posta onayı açıksa ve giriş reddedilirse: Authentication → Users → kullanıcıyı onayla veya Providers → Email → “Confirm email” kapat.

**Şifremi unuttum (geçici):** Uygulama e-posta linki göndermez.  
Yönetici: **Authentication → Users → kullanıcı → Reset password / yeni şifre**.  
Öğretmen internet varken bu yeni şifreyle giriş yapar.

## 6) Senkron (offline-first)

Uygulama veriyi **önce Drift (SQLite)**’a yazar. Oturum açıkken `CloudSyncService` aynı veriyi Supabase’e mirror eder.

| Veri | Ne zaman |
|------|----------|
| **Profil** (`profiles` + foto) | Profil kaydında push; profil ekranı açılışında pull. Foto: Storage `edutrack/{uid}/avatar.jpg`, DB’de `photo_path` = storage path |
| **Öğrenciler** | CRUD sonrası otomatik upsert/delete. **Ayarlar** → “Öğrencileri buluta yedekle” / “Buluttan öğrencileri çek” |
| Çakışma | Pull: aynı `id` varsa uzak satır yereli ezer. Push: tüm yerel liste upsert |

Kod: [`lib/services/cloud_sync_service.dart`](../lib/services/cloud_sync_service.dart)

Oturum yoksa veya key tanımlı değilse yalnızca yerel çalışır. Sync her zaman `auth.uid()` ile sınırlıdır (RLS).

**Çoklu hesap (aynı telefon):** Her kullanıcı için ayrı SQLite dosyası (`ozel_ders_takip_<uid>.sqlite`). Girişte profil + öğrenciler buluttan çekilir. Ödeme / ödev / yapılacaklar henüz bulutta olmadığı için yeni hesapta bunlar boş görünür (önceki hesabın yerel verisi karışmaz).

## 7) Sonraki adımlar

Dersler, ödemeler, ödev, müfredat, şablonlar — aynı `CloudSyncService` desenine eklenecek.
