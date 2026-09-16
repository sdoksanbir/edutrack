/// Uygulama genelinde kullanılan Türkçe metinler (tek kaynak).
abstract class StringsTr {
  // Genel
  static const String cancel = 'İptal';
  static const String save = 'Kaydet';
  static const String delete = 'Sil';
  static const String edit = 'Düzenle';
  static const String search = 'Ara';
  static const String clear = 'Temizle';
  static const String ok = 'Tamam';
  static const String apply = 'Uygula';
  static const String add = 'Ekle';
  static const String loading = 'Yükleniyor...';
  static const String error = 'Hata';
  static const String errorPrefix = 'Hata: ';

  // Takvim
  static const String month = 'Ay';
  static const String week = 'Hafta';
  static const String twoWeeks = '2 Hafta';
  static const String today = 'Bugün';
  static const String goToToday = 'Bugüne Git';
  static const String calendar = 'Takvim';

  // Sekmeler / Ödemeler
  static const String payments = 'Ödemeler';
  static const String doneLessons = 'Yapıldı Dersler';
  static const String cancellations = 'İptaller';
  static const String totalReceived = 'Toplam Alınan';
  static const String totalDue = 'Toplam Alacak';
  static const String totalExpected = 'Toplam Hakediş';
  static const String searchStudentHint = 'Öğrenci adı ile ara...';
  static const String noPaymentRecords = 'Henüz ödeme kaydı yok';
  static const String noSearchResults = 'Arama sonucu bulunamadı';
  static const String noUnpaidLessons = 'Henüz ödeme bekleyen ders yok';
  static const String lessonsSelected = 'ders seçildi';
  static const String makePayment = 'Ödeme Yap';
  static const String clearSelection = 'Temizle';

  // Ders durumları
  static const String planned = 'Planlandı';
  static const String done = 'Yapıldı';
  static const String missed = 'Yapılmadı';
  static const String postponed = 'Ertelendi';
  static const String changeStatus = 'Durum Değiştir';

  // Ders form (yapıldı modal)
  static const String topicLabel = 'Anlatılan Konu';
  static const String homeworkLabel = 'Ödev';
  static const String lessonNotesLabel = 'Ders Notu';
  static const String reasonLabel = 'Sebep';
  static const String noteLabel = 'Ek Not';
  static const String sourceLabel = 'Kaynak';
  static const String teacherSource = 'Öğretmen kaynaklı';
  static const String studentSource = 'Öğrenci kaynaklı';
  static const String reasonRequired = 'Sebep zorunludur';
  static const String previousLessonTitle = 'Bir Önceki Ders';
  static const String lessonDetailTitle = 'Ders Detayı';
  static const String lessonsMenuTitle = 'Dersler';
  static const String homeworksMenuTitle = 'Ödevler';
  static const String studentHomeworksTitle = 'Öğrenci Ödevleri';
  static const String noHomeworksYet = 'Henüz ödev kaydı yok';
  static const String homeworkStatusPending = 'Bekliyor';
  static const String homeworkStatusDone = 'Yapıldı';
  static const String homeworkStatusNotDone = 'Yapmadı';
  static const String homeworkStatusPartial = 'Eksik';
  static const String homeworkStatusNotUnderstood = 'Anlamadı';
  static const String homeworkStatusNoteHint = 'Not ekle (isteğe bağlı)...';
  static const String homeworkAlertBanner =
      'Takip gereken ödevler var. Detay için öğrenciye dokunun.';
  static const String homeworkAlertCount = 'uyarı';
  static const String filterAllHomework = 'Tümü';
  static const String filterAttentionHomework = 'Takip Gereken';
  static const String assignedOn = 'Verildi';
  static const String homeworkDueDate = 'Bitiş tarihi';
  static const String homeworkDueOverdue = 'Süresi geçti';
  static const String homeworkDueNotSet = 'Bitiş tarihi belirlenmedi';
  static const String homeworkSetDueDate = 'Bitiş tarihi seç';
  static const String homeworkChangeDueDate = 'Değiştir';
  static const String homeworkGiveExtension = 'Ek süre ver';
  static const String homeworkExtensionHelp = 'Yeni bitiş tarihi seç';
  static const String homeworkExtensionSaved = 'Ek süre verildi';
  static const String homeworkLessonGroupTitle = 'Ders tarihi';
  static const String todosTitle = 'Yapılacaklar';
  static const String todosEmpty = 'Yapılacak görev yok';
  static const String todosAdd = 'Görev ekle';
  static const String todosAddHint = 'Yapılacak bir şey yazın...';
  static const String todosShowAll = 'Tamamlananları göster';
  static const String todosShowOpen = 'Sadece açık görevler';
  static const String todosAdded = 'Yapılacaklar listesine eklendi';
  static const String todosAddNoteFirst = 'Önce açıklama yazın';
  static const String todosAddToList = 'Listeye ekle';
  static const String todosEdit = 'Görevi düzenle';
  static const String todosUpdated = 'Görev güncellendi';
  static const String todosNotifyAt = 'Bildirim zamanı';
  static const String todosNotifyAtHint = 'Tarih ve saat seç';
  static const String todosNotifyClear = 'Kaldır';
  static const String todosNotifySet = 'Bildirim ayarla';
  static const String todosNotifyScheduled = 'Bildirim planlandı';
  static const String sendWhatsApp = 'WhatsApp ile gönder';
  static const String whatsappNoPhoneShare =
      'Telefon kayıtlı değil. Paylaşım menüsünden WhatsApp seçebilirsiniz.';
  static const String whatsappOpenFailed =
      'WhatsApp açılamadı. Paylaşım menüsü kullanıldı.';
  static const String whatsappSentHint = 'WhatsApp açılıyor...';
  static const String homeTitle = 'Ana Sayfa';
  static const String homeShortcuts = 'Kısayollar';
  static const String homeTodayLessons = 'Bugünkü dersler';
  static const String studentLessonsTitle = 'Öğrenci Dersleri';
  static const String tabDoneLessons = 'Yapılan Dersler';
  static const String tabMissedLessons = 'Yapılmayan Dersler';
  static const String tabCancelledLessons = 'İptal edilenler';
  static const String tabPostponedLessons = 'Ertelenen Dersler';
  static const String cancellationDetailsTitle = 'İptal ayrıntıları';
  static const String postponementDetailsTitle = 'Erteleme ayrıntıları';
  static const String previousDateLabel = 'Önceki tarih';
  static const String newDateLabel = 'Yeni tarih';
  static const String noLessonsInCategory = 'Bu kategoride ders yok';
  static const String lastLessonDate = 'Son ders';
  static const String guardianSectionTitle = 'Veli Bilgileri';
  static const String guardianNameLabel = 'Veli Ad Soyad';
  static const String guardianPhoneLabel = 'Veli Telefon';
  static const String bookResourceLabel = 'Kaynaklar';
  static const String bookResourceTopicLabel = 'SORU BANKASI - KONU ANLATIMLI';
  static const String bookResourcePracticeLabel = 'DENEME';
  static const String bookResourceHint = 'Örn. POLİNOMLAR SORU BANKASI...';
  static const String bookResourcePracticeHint = 'Örn. TYT MATEMATİK DENEME...';
  static const String notEntered = 'Eklenmemiş';
  static const String back = 'Geri';
  static const String reasonAndSource = 'Sebep ve Kaynak';

  // Müfredat / Parametreler
  static const String parameters = 'Parametreler';
  static const String parametersSubtitle = 'Ders, ünite, konu ve kazanım';
  static const String curriculumSubject = 'Ders';
  static const String curriculumUnit = 'Ünite';
  static const String curriculumTopic = 'Konu';
  static const String curriculumOutcome = 'Kazanım';
  static const String addSubject = 'Ders Ekle';
  static const String addUnit = 'Ünite Ekle';
  static const String addTopic = 'Konu Ekle';
  static const String addOutcome = 'Kazanım Ekle';
  static const String noSubjectsYet = 'Henüz ders eklenmemiş';
  static const String pickTopicFromSystem = 'Parametrelerden konu seç';
  static const String defineMyself = 'Kendim belirleyeceğim';
  static const String homeworkResourceLabel = 'Kaynak';
  static const String pickFromMyResources = 'Kendi kaynaklarımdan seç';
  static const String noStudentResources = 'Bu öğrenciye kayıtlı kaynak yok';
  static const String customTopicHint = 'Konu adını yazın...';
  static const String customResourceHint = 'Kaynak adını yazın...';
  static const String taughtTopicsLabel = 'Anlatılan konular';
  static const String addTopicAction = 'Konu ekle';
  static const String pickTopicsForResource = 'Bu kaynak için konu seç';
  static const String selectTaughtTopicsFirst = 'Önce anlatılan konuları seçin';
  static const String topicsFromParameters = 'Parametrelerden konu seç';
  static const String topicAddedToSelection = 'Konu seçime eklendi';
  static const String multiSelectTopicsHint =
      'Birden fazla konu seçebilirsiniz. Bitince Kaydet\'e basın.';
  static const String homeworkTopicNoteLabel = 'Sayfa / test / açıklama';
  static const String homeworkTopicNoteHint =
      'Örn. sf. 45-60, test 3, soru 1-20...';
  static const String selectedHomeworkLabel = 'Seçilen ödevler';
  static const String noHomeworkSelected = 'Henüz ödev seçilmedi';
  static const String noTopicsAssigned = 'Konu atanmadı';
  static const String denemeNumberLabel = 'Deneme no';
  static const String denemeNumberEmpty = 'Boş';
  static const String pickDenemeNumber = 'Deneme numarası seç';
  static const String curriculumPickerHint =
      'TYT / AYT Matematik · Ders › Ünite › Konu › Kazanım';

  // Ayarlar
  static const String settings = 'Ayarlar';
  static const String notificationSettings = 'Bildirim Ayarları';
  static const String dailySummaryTime = 'Günlük Özet Saati';
  static const String weeklyScheduleSettings = 'Haftalık Ders Ayarları';
  static const String defaultEndDate = 'Varsayılan Bitiş Tarihi';

  // Öğrenciler
  static const String students = 'Öğrenciler';
  static const String addStudent = 'Yeni Öğrenci Ekle';
  static const String onlyActiveStudents = 'Sadece Aktif Öğrenciler';
  static const String allStudentsIncludingInactive = 'Tüm Öğrenciler (Pasif Dahil)';
  static const String noStudentsYet = 'Henüz öğrenci eklenmemiş';
  static const String addFirstStudent = 'İlk Öğrenciyi Ekle';
  static const String active = 'Aktif';
  static const String inactive = 'Pasif';
}
