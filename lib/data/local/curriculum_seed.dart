import 'package:drift/drift.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:uuid/uuid.dart';

/// TYT / AYT Matematik varsayılan müfredat (MEB YKS konu çerçevesine uygun özet).
/// Ders yoksa oluşturur; ders var ama ünite yoksa içeriği doldurur.
Future<void> seedDefaultCurriculum(AppDatabase db) async {
  const uuid = Uuid();
  final now = DateTime.now();

  Future<String> insertSubject(String name, int order) async {
    final id = uuid.v4();
    await db.into(db.curriculumSubjects).insert(
          CurriculumSubjectsCompanion.insert(
            id: id,
            name: name,
            sortOrder: Value(order),
            createdAt: now,
          ),
        );
    return id;
  }

  String normalize(String s) => s
      .trim()
      .toLowerCase()
      .replaceAll('ı', 'i')
      .replaceAll('İ', 'i');

  Future<String> ensureSubject(String name, int order) async {
    final target = normalize(name);
    final all = await db.select(db.curriculumSubjects).get();
    for (final s in all) {
      if (normalize(s.name) == target) return s.id;
    }
    return insertSubject(name, order);
  }

  Future<int> unitCount(String subjectId) async {
    final rows = await (db.select(db.curriculumUnits)
          ..where((t) => t.subjectId.equals(subjectId)))
        .get();
    return rows.length;
  }

  Future<String> insertUnit(String subjectId, String name, int order) async {
    final id = uuid.v4();
    await db.into(db.curriculumUnits).insert(
          CurriculumUnitsCompanion.insert(
            id: id,
            subjectId: subjectId,
            name: name,
            sortOrder: Value(order),
            createdAt: now,
          ),
        );
    return id;
  }

  Future<String> insertTopic(String unitId, String name, int order) async {
    final id = uuid.v4();
    await db.into(db.curriculumTopics).insert(
          CurriculumTopicsCompanion.insert(
            id: id,
            unitId: unitId,
            name: name,
            sortOrder: Value(order),
            createdAt: now,
          ),
        );
    return id;
  }

  Future<void> insertOutcomes(String topicId, List<String> outcomes) async {
    for (var i = 0; i < outcomes.length; i++) {
      await db.into(db.curriculumOutcomes).insert(
            CurriculumOutcomesCompanion.insert(
              id: uuid.v4(),
              topicId: topicId,
              name: outcomes[i],
              sortOrder: Value(i),
              createdAt: now,
            ),
          );
    }
  }

  Future<void> addUnitWithTopics({
    required String subjectId,
    required int unitOrder,
    required String unitName,
    required List<({String name, List<String> outcomes})> topics,
  }) async {
    final unitId = await insertUnit(subjectId, unitName, unitOrder);
    for (var i = 0; i < topics.length; i++) {
      final t = topics[i];
      final topicId = await insertTopic(unitId, t.name, i);
      await insertOutcomes(topicId, t.outcomes);
    }
  }

  // Elle eklenmiş boş "Matematik" → TYT Matematik
  final allSubjects = await db.select(db.curriculumSubjects).get();
  final bare = allSubjects.cast<CurriculumSubject?>().firstWhere(
        (s) => normalize(s!.name) == 'matematik',
        orElse: () => null,
      );
  if (bare != null) {
    final tytExists = allSubjects.any(
      (s) => normalize(s.name) == 'tyt matematik',
    );
    if (!tytExists) {
      await (db.update(db.curriculumSubjects)
            ..where((t) => t.id.equals(bare.id)))
          .write(
            const CurriculumSubjectsCompanion(
              name: Value('TYT Matematik'),
              sortOrder: Value(0),
            ),
          );
    } else if (await unitCount(bare.id) == 0) {
      // TYT zaten var; boş Matematik kaydını sil
      await (db.delete(db.curriculumSubjects)
            ..where((t) => t.id.equals(bare.id)))
          .go();
    }
  }

  // ── TYT MATEMATİK ─────────────────────────────────────
  final tytId = await ensureSubject('TYT Matematik', 0);
  if (await unitCount(tytId) == 0) {
  await addUnitWithTopics(
    subjectId: tytId,
    unitOrder: 0,
    unitName: 'Sayılar ve Temel Kavramlar',
    topics: [
      (
        name: 'Temel Kavramlar ve Sayı Kümeleri',
        outcomes: [
          'Sayı kümelerini birbirleriyle ilişkilendirir.',
          'Doğal, tam, rasyonel, irrasyonel ve gerçek sayıları ayırt eder.',
          'İşlem önceliğine uygun işlemler yapar.',
        ],
      ),
      (
        name: 'Sayı Basamakları',
        outcomes: [
          'Basamak ve sayı değerini ayırt eder.',
          'Sayıları çözümler ve basamaklarla ilgili problemleri çözer.',
        ],
      ),
      (
        name: 'Bölme ve Bölünebilme',
        outcomes: [
          'Bölünebilme kurallarını açıklar ve uygular.',
          'Asal ve aralarında asal sayıları ayırt eder.',
        ],
      ),
      (
        name: 'EBOB – EKOK',
        outcomes: [
          'EBOB ve EKOK kavramlarını açıklar.',
          'EBOB-EKOK ile ilgili problemleri çözer.',
        ],
      ),
      (
        name: 'Rasyonel Sayılar',
        outcomes: [
          'Rasyonel sayılarda dört işlem yapar.',
          'Devirli ondalık sayıları rasyonel forma dönüştürür.',
        ],
      ),
      (
        name: 'Üslü İfadeler',
        outcomes: [
          'Üslü sayıların özelliklerini kullanarak işlemler yapar.',
          'Üslü ifadelerle ilgili problemleri çözer.',
        ],
      ),
      (
        name: 'Köklü İfadeler',
        outcomes: [
          'Köklü ifadeleri sadeleştirir ve işlemler yapar.',
          'Köklü ifadeleri üslü forma dönüştürür.',
        ],
      ),
      (
        name: 'Çarpanlara Ayırma',
        outcomes: [
          'Cebirsel ifadeleri çarpanlarına ayırır.',
          'Özdeşlikleri kullanarak çarpanlara ayırma yapar.',
        ],
      ),
    ],
  );

  await addUnitWithTopics(
    subjectId: tytId,
    unitOrder: 1,
    unitName: 'Denklem ve Eşitsizlikler',
    topics: [
      (
        name: 'Birinci Dereceden Denklemler',
        outcomes: [
          'Bir bilinmeyenli birinci dereceden denklemleri çözer.',
          'Denklemlerle modellenebilen problemleri çözer.',
        ],
      ),
      (
        name: 'Basit Eşitsizlikler',
        outcomes: [
          'Bir bilinmeyenli eşitsizlikleri çözer.',
          'Eşitsizlik çözüm kümelerini sayı doğrusunda gösterir.',
        ],
      ),
      (
        name: 'Mutlak Değer',
        outcomes: [
          'Mutlak değer kavramını açıklar.',
          'Mutlak değerli denklem ve eşitsizlikleri çözer.',
        ],
      ),
      (
        name: 'Oran – Orantı',
        outcomes: [
          'Oran ve orantı kavramlarını açıklar.',
          'Doğru ve ters orantı problemlerini çözer.',
        ],
      ),
    ],
  );

  await addUnitWithTopics(
    subjectId: tytId,
    unitOrder: 2,
    unitName: 'Problemler',
    topics: [
      (
        name: 'Sayı ve Kesir Problemleri',
        outcomes: [
          'Sayı problemlerini cebirsel olarak modeller ve çözer.',
          'Kesir problemlerini çözer.',
        ],
      ),
      (
        name: 'Yaş Problemleri',
        outcomes: ['Yaş problemlerini çözer.'],
      ),
      (
        name: 'Hareket Problemleri',
        outcomes: [
          'Hız-yol-zaman ilişkisini kullanarak problem çözer.',
        ],
      ),
      (
        name: 'Karışım Problemleri',
        outcomes: ['Karışım problemlerini çözer.'],
      ),
      (
        name: 'Yüzde ve Faiz Problemleri',
        outcomes: [
          'Yüzde problemlerini çözer.',
          'Basit faiz problemlerini çözer.',
        ],
      ),
      (
        name: 'Tablo – Grafik Problemleri',
        outcomes: [
          'Tablo ve grafiklerde verilen bilgileri yorumlar.',
        ],
      ),
      (
        name: 'Rutin Olmayan Problemler',
        outcomes: [
          'Rutin olmayan problemlerde uygun strateji seçer.',
        ],
      ),
    ],
  );

  await addUnitWithTopics(
    subjectId: tytId,
    unitOrder: 3,
    unitName: 'Mantık ve Kümeler',
    topics: [
      (
        name: 'Mantık',
        outcomes: [
          'Önerme, doğruluk değeri ve değil kavramlarını açıklar.',
          'Bileşik önermeleri ve bağlaçları kullanır.',
        ],
      ),
      (
        name: 'Kümeler',
        outcomes: [
          'Küme işlemlerini yapar.',
          'Kümelerle ilgili problemleri çözer.',
        ],
      ),
    ],
  );

  await addUnitWithTopics(
    subjectId: tytId,
    unitOrder: 4,
    unitName: 'Fonksiyonlar ve Polinomlar',
    topics: [
      (
        name: 'Fonksiyonlar',
        outcomes: [
          'Fonksiyon kavramını açıklar.',
          'Fonksiyon işlemleri ve bileşke fonksiyonu hesaplar.',
        ],
      ),
      (
        name: 'Polinomlar',
        outcomes: [
          'Polinomlarda işlemler yapar.',
          'Polinomların kökleriyle ilgili problemleri çözer.',
        ],
      ),
      (
        name: 'İkinci Dereceden Denklemler',
        outcomes: [
          'İkinci dereceden denklemleri çözer.',
          'Diskriminantı yorumlar.',
        ],
      ),
      (
        name: 'Karmaşık Sayılar',
        outcomes: [
          'Karmaşık sayılarda dört işlem yapar.',
          'Karmaşık sayıları kutupsal forma dönüştürür.',
        ],
      ),
    ],
  );

  await addUnitWithTopics(
    subjectId: tytId,
    unitOrder: 5,
    unitName: 'Sayma, Olasılık ve Veri',
    topics: [
      (
        name: 'Permütasyon',
        outcomes: [
          'Permütasyon kavramını açıklar ve hesaplar.',
        ],
      ),
      (
        name: 'Kombinasyon',
        outcomes: [
          'Kombinasyon kavramını açıklar ve hesaplar.',
        ],
      ),
      (
        name: 'Binom ve Pascal Üçgeni',
        outcomes: [
          'Binom açılımını uygular.',
          'Pascal üçgeni ile katsayıları ilişkilendirir.',
        ],
      ),
      (
        name: 'Olasılık',
        outcomes: [
          'Olasılık kavramını açıklar.',
          'Basit olayların olasılığını hesaplar.',
        ],
      ),
      (
        name: 'Veri ve İstatistik',
        outcomes: [
          'Merkezi eğilim ölçülerini hesaplar.',
          'Verileri tablo ve grafiklerle yorumlar.',
        ],
      ),
    ],
  );
  } // end TYT unit seed

  // ── AYT MATEMATİK ─────────────────────────────────────
  final aytId = await ensureSubject('AYT Matematik', 1);
  if (await unitCount(aytId) == 0) {
  await addUnitWithTopics(
    subjectId: aytId,
    unitOrder: 0,
    unitName: 'Fonksiyonlar ve Polinomlar',
    topics: [
      (
        name: 'Fonksiyonlar (İleri)',
        outcomes: [
          'Fonksiyon grafiklerini yorumlar.',
          'Birebir, örten ve ters fonksiyonları ayırt eder.',
        ],
      ),
      (
        name: 'Polinomlar (İleri)',
        outcomes: [
          'Polinom bölmesi ve kalan teoremini uygular.',
          'Çarpan teoremini kullanarak problem çözer.',
        ],
      ),
      (
        name: 'İkinci Dereceden Denklemler ve Eşitsizlikler',
        outcomes: [
          'İkinci dereceden eşitsizlikleri çözer.',
          'İkinci dereceden ifadelerle problem modeller.',
        ],
      ),
      (
        name: 'Parabol',
        outcomes: [
          'Parabolün tepe noktası ve eksenlerini bulur.',
          'Parabol ile doğru konumlarını yorumlar.',
        ],
      ),
    ],
  );

  await addUnitWithTopics(
    subjectId: aytId,
    unitOrder: 1,
    unitName: 'Trigonometri',
    topics: [
      (
        name: 'Yönlü Açılar ve Birim Çember',
        outcomes: [
          'Yönlü açıları birim çember üzerinde gösterir.',
          'Birim çemberde trigonometrik değerleri bulur.',
        ],
      ),
      (
        name: 'Trigonometrik Fonksiyonlar',
        outcomes: [
          'Sinüs, kosinüs, tanjant fonksiyonlarını açıklar.',
          'Trigonometrik fonksiyon grafiklerini çizer.',
        ],
      ),
      (
        name: 'Sinüs ve Kosinüs Teoremleri',
        outcomes: [
          'Sinüs teoremiyle ilgili problemleri çözer.',
          'Kosinüs teoremiyle ilgili problemleri çözer.',
        ],
      ),
      (
        name: 'Toplam-Fark ve İki Kat Açı Formülleri',
        outcomes: [
          'Toplam-fark formüllerini uygular.',
          'İki kat açı formüllerini uygular.',
        ],
      ),
      (
        name: 'Trigonometrik Denklemler',
        outcomes: [
          'Trigonometrik denklemleri çözer.',
        ],
      ),
    ],
  );

  await addUnitWithTopics(
    subjectId: aytId,
    unitOrder: 2,
    unitName: 'Üstel ve Logaritmik Fonksiyonlar',
    topics: [
      (
        name: 'Üstel Fonksiyonlar',
        outcomes: [
          'Üstel fonksiyonu tanımlar ve grafiğini yorumlar.',
          'Üstel denklemleri çözer.',
        ],
      ),
      (
        name: 'Logaritma Fonksiyonu',
        outcomes: [
          'Logaritma ile üstel fonksiyonu ilişkilendirir.',
          '10 ve e tabanında logaritma işlemleri yapar.',
        ],
      ),
      (
        name: 'Logaritma Özellikleri ve Denklemler',
        outcomes: [
          'Logaritma özelliklerini kullanarak işlem yapar.',
          'Logaritmik denklem ve eşitsizlikleri çözer.',
        ],
      ),
    ],
  );

  await addUnitWithTopics(
    subjectId: aytId,
    unitOrder: 3,
    unitName: 'Diziler',
    topics: [
      (
        name: 'Dizi Kavramı',
        outcomes: [
          'Dizi kavramını açıklar.',
          'Dizinin genel terimini bulur.',
        ],
      ),
      (
        name: 'Aritmetik ve Geometrik Diziler',
        outcomes: [
          'Aritmetik dizi problemlerini çözer.',
          'Geometrik dizi problemlerini çözer.',
        ],
      ),
    ],
  );

  await addUnitWithTopics(
    subjectId: aytId,
    unitOrder: 4,
    unitName: 'Limit ve Süreklilik',
    topics: [
      (
        name: 'Limit Kavramı',
        outcomes: [
          'Bir noktadaki limit, soldan ve sağdan limiti açıklar.',
          'Limit özelliklerini kullanarak hesap yapar.',
        ],
      ),
      (
        name: 'Belirsizlikler ve Süreklilik',
        outcomes: [
          'Limitte belirsizlik durumlarını giderir.',
          'Bir fonksiyonun bir noktadaki sürekliliğini inceler.',
        ],
      ),
    ],
  );

  await addUnitWithTopics(
    subjectId: aytId,
    unitOrder: 5,
    unitName: 'Türev',
    topics: [
      (
        name: 'Türev Kavramı ve Kurallar',
        outcomes: [
          'Türev kavramını açıklar.',
          'Toplam, çarpım, bölüm ve zincir kuralını uygular.',
        ],
      ),
      (
        name: 'Türevin Uygulamaları',
        outcomes: [
          'Artan-azalan aralıkları belirler.',
          'Maksimum-minimum problemlerini çözer.',
          'Türev yardımıyla grafik çizer.',
        ],
      ),
    ],
  );

  await addUnitWithTopics(
    subjectId: aytId,
    unitOrder: 6,
    unitName: 'İntegral',
    topics: [
      (
        name: 'Belirsiz İntegral',
        outcomes: [
          'Belirsiz integral kavramını açıklar.',
          'Temel integral alma kurallarını uygular.',
        ],
      ),
      (
        name: 'Değişken Değiştirme',
        outcomes: [
          'Değişken değiştirme ile integral alır.',
        ],
      ),
      (
        name: 'Belirli İntegral ve Alan',
        outcomes: [
          'Belirli integral hesaplar.',
          'Eğriler arasında kalan alanı hesaplar.',
        ],
      ),
    ],
  );

  await addUnitWithTopics(
    subjectId: aytId,
    unitOrder: 7,
    unitName: 'Olasılık ve Karmaşık Sayılar',
    topics: [
      (
        name: 'Koşullu Olasılık',
        outcomes: [
          'Koşullu olasılığı açıklar ve hesaplar.',
          'Bağımlı ve bağımsız olayları ayırt eder.',
        ],
      ),
      (
        name: 'Bileşik Olaylar',
        outcomes: [
          'Bileşik olayların olasılığını hesaplar.',
        ],
      ),
      (
        name: 'Karmaşık Sayılar (AYT)',
        outcomes: [
          'Karmaşık sayılarda ileri düzey işlemler yapar.',
          'Kutupsal gösterim ve De Moivre uygular.',
        ],
      ),
    ],
  );
  } // end AYT unit seed
}
