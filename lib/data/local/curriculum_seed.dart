import 'package:drift/drift.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/local/curriculum_seed_branches.dart';
import 'package:uuid/uuid.dart';

/// TYT / AYT Matematik + Geometri + LGS + Maarif Model Matematik (9–11) ve
/// Fizik, Kimya, Biyoloji, Türkçe, Tarih, Coğrafya (TYT/AYT + 9–11) varsayılan müfredat.
/// Ders yoksa oluşturur; ders var ama ünite yoksa içeriği doldurur.
Future<void> seedDefaultCurriculum(AppDatabase db) async {
  const uuid = Uuid();
  final now = DateTime.now();

  Future<String> insertSubject(
    String name,
    int order, {
    String folder = 'MATEMATİK',
  }) async {
    final id = uuid.v4();
    await db.into(db.curriculumSubjects).insert(
          CurriculumSubjectsCompanion.insert(
            id: id,
            name: name,
            folder: Value(folder),
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

  Future<String> ensureSubject(
    String name,
    int order, {
    String folder = 'MATEMATİK',
  }) async {
    final target = normalize(name);
    final all = await db.select(db.curriculumSubjects).get();
    for (final s in all) {
      if (normalize(s.name) == target) {
        if (s.folder != folder || s.sortOrder != order) {
          await (db.update(db.curriculumSubjects)
                ..where((t) => t.id.equals(s.id)))
              .write(
            CurriculumSubjectsCompanion(
              folder: Value(folder),
              sortOrder: Value(order),
            ),
          );
        }
        return s.id;
      }
    }
    return insertSubject(name, order, folder: folder);
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
              folder: Value('MATEMATİK'),
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

  // ═══════════════════════════════════════════════════════
  // TYT GEOMETRİ (ÖSYM YKS — tam konu + kazanım)
  // ═══════════════════════════════════════════════════════
  final tytGeo = await ensureSubject('TYT Geometri', 2);
  if (await unitCount(tytGeo) == 0) {
    await addUnitWithTopics(
      subjectId: tytGeo,
      unitOrder: 0,
      unitName: 'Temel Kavramlar ve Açılar',
      topics: [
        (
          name: 'Temel Kavramlar',
          outcomes: [
            'Nokta, doğru, ışın, doğru parçası ve düzlem kavramlarını ayırt eder.',
            'İki nokta arası uzaklık ve doğru parçası uzunluğunu açıklar.',
            'Açı, açıölçü birimleri ve açı çeşitlerini (dar, dik, geniş, doğru, tam) ayırt eder.',
            'Komşu, bütünler, tümler ve zıt açılar arasındaki ilişkileri kullanır.',
          ],
        ),
        (
          name: 'Doğruda Açılar',
          outcomes: [
            'Bir doğru üzerindeki açıların toplamının 180° olduğunu kullanır.',
            'İki doğrunun kesişmesiyle oluşan dikey açılar eşitliğini uygular.',
            'Paralel iki doğrunun bir kesenle oluşturduğu yöndeş, ters ve iç ters açı ilişkilerini kullanır.',
            'Doğruda açı problemlerini çözer.',
          ],
        ),
        (
          name: 'Üçgende Açılar',
          outcomes: [
            'Üçgenin iç açıları toplamının 180° olduğunu kullanır.',
            'Üçgenin dış açıları ile iç açılar arasındaki ilişkileri uygular.',
            'Üçgende açı problemlerini çözer.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: tytGeo,
      unitOrder: 1,
      unitName: 'Üçgenler',
      topics: [
        (
          name: 'Özel Üçgenler — Dik Üçgen',
          outcomes: [
            'Dik üçgende dik kenar ve hipotenüs kavramlarını açıklar.',
            'Pisagor bağıntısını kullanarak kenar uzunluklarını bulur.',
            '30°-60°-90° ve 45°-45°-90° özel dik üçgenlerin kenar oranlarını kullanır.',
          ],
        ),
        (
          name: 'Özel Üçgenler — İkizkenar ve Eşkenar',
          outcomes: [
            'İkizkenar üçgende taban açıları ve simetri özelliklerini kullanır.',
            'Eşkenar üçgende açı ve kenar özelliklerini uygular.',
            'Özel üçgenlerle ilgili problemleri çözer.',
          ],
        ),
        (
          name: 'Açıortay',
          outcomes: [
            'İç ve dış açıortay kavramlarını açıklar.',
            'Açıortay teoremini (kenarların açıortayla oranlı bölünmesi) uygular.',
            'Üçgende açıortay uzunluğu ve özelliklerini kullanarak problem çözer.',
          ],
        ),
        (
          name: 'Kenarortay',
          outcomes: [
            'Kenarortay ve ağırlık merkezi kavramlarını açıklar.',
            'Kenarortayların ağırlık merkezinde 2:1 oranında kesiştiğini kullanır.',
            'Kenarortay uzunluğu bağıntısını uygular.',
          ],
        ),
        (
          name: 'Üçgende Eşlik ve Benzerlik',
          outcomes: [
            'Üçgenlerde eşlik koşullarını (KKK, KAK, AKA, Öklid) ayırt eder.',
            'Üçgenlerde benzerlik koşullarını (AAA, KKK benzerlik, KAK benzerlik) uygular.',
            'Benzer üçgenlerde kenar oranları ve alan oranını ilişkilendirir.',
            'Eşlik ve benzerlik içeren problemleri çözer.',
          ],
        ),
        (
          name: 'Açı – Kenar Bağıntıları',
          outcomes: [
            'Üçgende büyük kenarın karşısında büyük açı olduğunu kullanır.',
            'Üçgen eşitsizliğini (kenar toplamı/farkı) uygular.',
            'Açı-kenar bağıntılı problemleri çözer.',
          ],
        ),
        (
          name: 'Üçgende Alan',
          outcomes: [
            'Üçgende alan bağıntılarını (taban-yükseklik, Heron, iki kenar-sinüs) kullanır.',
            'Ortak taban veya ortak yükseklik durumlarında alan oranlarını bulur.',
            'Üçgende alan problemlerini çözer.',
          ],
        ),
        (
          name: 'Üçgende Merkezler',
          outcomes: [
            'Ağırlık merkezi, iç teğet çember merkezi, çevrel çember merkezi ve diklik merkezini ayırt eder.',
            'Üçgende merkezlerin özelliklerini kullanarak problem çözer.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: tytGeo,
      unitOrder: 2,
      unitName: 'Çokgenler ve Dörtgenler',
      topics: [
        (
          name: 'Çokgenler',
          outcomes: [
            'Düzgün ve düzgün olmayan çokgenleri ayırt eder.',
            'Çokgende iç açılar toplamı ve bir iç açıyı hesaplar.',
            'Çokgende dış açılar toplamını ve bir dış açıyı hesaplar.',
            'Çokgende köşegen sayısını bulur.',
          ],
        ),
        (
          name: 'Dörtgenler — Genel',
          outcomes: [
            'Dörtgenin iç açıları toplamının 360° olduğunu kullanır.',
            'Dörtgende kenar, açı, köşegen ve alan özelliklerini inceler.',
          ],
        ),
        (
          name: 'Paralelkenar',
          outcomes: [
            'Paralelkenarın kenar, açı, köşegen ve alan özelliklerini açıklar.',
            'Paralelkenar problemlerini çözer.',
          ],
        ),
        (
          name: 'Eşkenar Dörtgen',
          outcomes: [
            'Eşkenar dörtgenin kenar, açı, köşegen ve alan özelliklerini kullanır.',
            'Eşkenar dörtgen problemlerini çözer.',
          ],
        ),
        (
          name: 'Dikdörtgen ve Kare',
          outcomes: [
            'Dikdörtgenin kenar, açı, köşegen ve alan özelliklerini kullanır.',
            'Karenin kenar, açı, köşegen, simetri ve alan özelliklerini kullanır.',
            'Dikdörtgen ve kare problemlerini çözer.',
          ],
        ),
        (
          name: 'Deltoid',
          outcomes: [
            'Deltoidin kenar, açı, köşegen, simetri ve alan özelliklerini kullanır.',
            'Deltoid problemlerini çözer.',
          ],
        ),
        (
          name: 'Yamuk',
          outcomes: [
            'Yamuğun kenar, açı, köşegen ve alan özelliklerini kullanır.',
            'İkizkenar yamuk özelliklerini uygular.',
            'Yamuk problemlerini çözer.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: tytGeo,
      unitOrder: 3,
      unitName: 'Çember ve Daire',
      topics: [
        (
          name: 'Çemberin Temel Elemanları',
          outcomes: [
            'Merkez, yarıçap, çap, kiriş, yay, kesen ve teğet kavramlarını ayırt eder.',
            'Çemberde merkez açı ve çevre açı ilişkilerini kullanır.',
          ],
        ),
        (
          name: 'Çemberde Açı',
          outcomes: [
            'Merkez açı, çevre açı, iç açı ve dış açı ölçülerini bulur.',
            'Çemberde açı problemlerini çözer.',
          ],
        ),
        (
          name: 'Çemberde Uzunluk',
          outcomes: [
            'Çemberde teğet uzunlukları eşitliğini kullanır.',
            'İki kirişin kesişiminde uzunluk bağıntısını uygular.',
            'Kesen ve teğet-kesen uzunluk bağıntılarını kullanır.',
          ],
        ),
        (
          name: 'Dairede Çevre ve Alan',
          outcomes: [
            'Dairenin çevresini ve alanını hesaplar.',
            'Daire dilimi ve daire parçası alanlarını hesaplar.',
            'Çember-daire problemlerini çözer.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: tytGeo,
      unitOrder: 4,
      unitName: 'Analitik Geometri',
      topics: [
        (
          name: 'Noktanın Analitiği',
          outcomes: [
            'Dik koordinat sisteminde noktaları gösterir.',
            'İki nokta arasındaki uzaklığı hesaplar.',
            'Doğru parçasını belli oranda (içten/dıştan) bölen noktanın koordinatlarını bulur.',
            'Üçgenin ağırlık merkezi koordinatlarını bulur.',
          ],
        ),
        (
          name: 'Doğrunun Analitiği',
          outcomes: [
            'Doğrunun eğimini hesaplar ve yorumlar.',
            'Doğru denklemlerini (eğim-nokta, iki nokta, genel form) yazar.',
            'Paralel ve dik doğruların eğim koşullarını kullanır.',
            'İki doğrunun kesişim noktasını bulur.',
            'Noktanın doğruya uzaklığını hesaplar.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: tytGeo,
      unitOrder: 5,
      unitName: 'Katı Cisimler',
      topics: [
        (
          name: 'Prizma ve Küp',
          outcomes: [
            'Dikdörtgenler prizmasının elemanlarını, yüzey alanını ve hacmini hesaplar.',
            'Küpün elemanlarını, yüzey alanını ve hacmini hesaplar.',
          ],
        ),
        (
          name: 'Silindir',
          outcomes: [
            'Dik dairesel silindirin elemanlarını, yüzey alanını ve hacmini hesaplar.',
          ],
        ),
        (
          name: 'Piramit ve Koni',
          outcomes: [
            'Dik piramidin elemanlarını, yüzey alanını ve hacmini hesaplar.',
            'Dik dairesel koninin elemanlarını, yüzey alanını ve hacmini hesaplar.',
          ],
        ),
        (
          name: 'Küre',
          outcomes: [
            'Kürenin yüzey alanı ve hacim bağıntılarını kullanır.',
            'Katı cisim problemlerini çözer.',
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // AYT GEOMETRİ (ÖSYM YKS — tam konu + kazanım)
  // ═══════════════════════════════════════════════════════
  final aytGeo = await ensureSubject('AYT Geometri', 3);
  if (await unitCount(aytGeo) == 0) {
    await addUnitWithTopics(
      subjectId: aytGeo,
      unitOrder: 0,
      unitName: 'Üçgenler (İleri)',
      topics: [
        (
          name: 'Doğruda ve Üçgende Açılar',
          outcomes: [
            'Paralel doğrular ve kesenle oluşan açı bağıntılarını ileri düzeyde kullanır.',
            'Üçgende iç-dış açı bağıntılarını problemlerde uygular.',
          ],
        ),
        (
          name: 'Özel Üçgenler',
          outcomes: [
            'Dik, ikizkenar ve eşkenar üçgen özelliklerini birleştirerek problem çözer.',
            'Özel dik üçgen oranlarını (3-4-5, 5-12-13, 30-60-90, 45-45-90) kullanır.',
          ],
        ),
        (
          name: 'Açıortay ve Kenarortay',
          outcomes: [
            'İç/dış açıortay teoremlerini ispat düzeyinde uygular.',
            'Kenarortay ve ağırlık merkezi özelliklerini ileri problemlerde kullanır.',
            'Açıortay-kenarortay birleşik problemlerini çözer.',
          ],
        ),
        (
          name: 'Üçgende Alan ve Benzerlik',
          outcomes: [
            'Benzer üçgenlerde alan oranını kenar oranının karesi ile ilişkilendirir.',
            'Öklid bağıntılarını (yükseklik, dik kenar izdüşümü) kullanır.',
            'Alan ve benzerlik birleşik problemlerini çözer.',
          ],
        ),
        (
          name: 'Açı – Kenar Bağıntıları',
          outcomes: [
            'Sinüs ve kosinüs teoremlerini üçgende uygular.',
            'Üçgende açı-kenar bağıntılı ileri problemleri çözer.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: aytGeo,
      unitOrder: 1,
      unitName: 'Çokgenler ve Özel Dörtgenler',
      topics: [
        (
          name: 'Çokgenler',
          outcomes: [
            'Düzgün çokgenlerde iç/dış açı ve köşegen bağıntılarını kullanır.',
            'Çokgen alan ve çevre problemlerini çözer.',
          ],
        ),
        (
          name: 'Özel Dörtgenler',
          outcomes: [
            'Paralelkenar, eşkenar dörtgen, dikdörtgen, kare, deltoid ve yamuk özelliklerini karşılaştırır.',
            'Özel dörtgenler arasındaki hiyerarşik ilişkileri kullanır.',
            'Özel dörtgenlerde alan, kenar ve köşegen problemlerini çözer.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: aytGeo,
      unitOrder: 2,
      unitName: 'Çember ve Daire (İleri)',
      topics: [
        (
          name: 'Çemberde Açı ve Uzunluk',
          outcomes: [
            'Merkez, çevre, iç ve dış açı bağıntılarını ileri düzeyde kullanır.',
            'Teğet-kiriş, iki kiriş, iki kesen uzunluk bağıntılarını uygular.',
            'İç teğet ve çevrel çember yarıçap bağıntılarını kullanır.',
          ],
        ),
        (
          name: 'Dairede Alan ve Çevre',
          outcomes: [
            'Daire dilimi, daire parçası ve gölgeli alan problemlerini çözer.',
            'Çember-daire birleşik problemlerini çözer.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: aytGeo,
      unitOrder: 3,
      unitName: 'Analitik Geometri',
      topics: [
        (
          name: 'Noktanın Analitiği',
          outcomes: [
            'İki nokta arası uzaklık, orta nokta ve oranlı bölme bağıntılarını kullanır.',
            'Üçgenin ağırlık merkezi ve özel noktalarının koordinatlarını bulur.',
          ],
        ),
        (
          name: 'Doğrunun Analitiği',
          outcomes: [
            'Doğru denklemlerini farklı formlarda yazar ve dönüştürür.',
            'Paralel, dik ve kesişen doğruların koşullarını uygular.',
            'İki doğru arasındaki açıyı bulur.',
            'Nokta-doğru uzaklığı ve iki paralel doğru arası uzaklığı hesaplar.',
          ],
        ),
        (
          name: 'Çemberin Analitiği',
          outcomes: [
            'Çember denklemini (merkez-yarıçap ve genel form) yazar.',
            'Noktanın çembere göre konumunu (iç, üstünde, dış) belirler.',
            'Doğru ile çemberin kesişim durumlarını inceler.',
            'Çembere teğet doğru denklemini bulur.',
            'İki çemberin konum ilişkilerini inceler.',
          ],
        ),
        (
          name: 'Dönüşüm Geometrisi',
          outcomes: [
            'Öteleme, yansıma ve dönme dönüşümlerini koordinat düzleminde uygular.',
            'Dönüşüm sonucu oluşan şekillerin özelliklerini yorumlar.',
            'Dönüşüm geometrisi problemlerini çözer.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: aytGeo,
      unitOrder: 4,
      unitName: 'Katı Cisimler (Uzay Geometri)',
      topics: [
        (
          name: 'Prizma, Küp ve Silindir',
          outcomes: [
            'Dikdörtgenler prizması, küp ve silindirde yüzey alanı ile hacim problemlerini çözer.',
            'Uzayda dik kesit ve açınım yorumlar.',
          ],
        ),
        (
          name: 'Piramit, Koni ve Küre',
          outcomes: [
            'Piramit, koni ve kürede yüzey alanı ile hacim bağıntılarını kullanır.',
            'Katı cisimlerin birleşimi ve farkı ile ilgili hacim-alan problemlerini çözer.',
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // LGS MATEMATİK (MEB 8. Sınıf — tam kazanım)
  // ═══════════════════════════════════════════════════════
  final lgsId = await ensureSubject('LGS Matematik', 4);
  if (await unitCount(lgsId) == 0) {
    await addUnitWithTopics(
      subjectId: lgsId,
      unitOrder: 0,
      unitName: 'Sayılar ve İşlemler',
      topics: [
        (
          name: 'Çarpanlar ve Katlar',
          outcomes: [
            'M.8.1.1.1 Pozitif tam sayıların pozitif tam sayı çarpanlarını bulur; çarpanları üslü çarpım şeklinde yazar; asal çarpanlara ayırır.',
            'M.8.1.1.2 İki doğal sayının EBOB ve EKOK değerlerini hesaplar, ilgili problemleri çözer.',
            'M.8.1.1.3 Verilen iki doğal sayının aralarında asal olup olmadığını belirler.',
          ],
        ),
        (
          name: 'Üslü İfadeler',
          outcomes: [
            'M.8.1.2.1 Tam sayıların tam sayı kuvvetlerini hesaplar.',
            'M.8.1.2.2 Üslü ifadelerle ilgili temel kuralları anlar, birbirine denk ifadeler oluşturur.',
            'M.8.1.2.3 Sayıların ondalık gösterimlerini 10’un tam sayı kuvvetlerini kullanarak çözümler.',
            'M.8.1.2.4 Verilen bir sayıyı 10’un farklı tam sayı kuvvetlerini kullanarak ifade eder.',
            'M.8.1.2.5 Çok büyük ve çok küçük sayıları bilimsel gösterimle ifade eder ve karşılaştırır.',
          ],
        ),
        (
          name: 'Kareköklü İfadeler',
          outcomes: [
            'M.8.1.3.1 Tam kare pozitif tam sayılarla bu sayıların karekökleri arasındaki ilişkiyi belirler.',
            'M.8.1.3.2 Tam kare olmayan kareköklü bir sayının hangi iki doğal sayı arasında olduğunu belirler.',
            'M.8.1.3.3 Kareköklü bir ifadeyi a√b şeklinde yazar; katsayıyı kök içine alır.',
            'M.8.1.3.4 Kareköklü ifadelerde çarpma ve bölme işlemlerini yapar.',
            'M.8.1.3.5 Kareköklü ifadelerde toplama ve çıkarma işlemlerini yapar.',
            'M.8.1.3.6 Kareköklü ifadeyi doğal sayı yapan çarpanlara örnek verir.',
            'M.8.1.3.7 Ondalık ifadelerin kareköklerini belirler.',
            'M.8.1.3.8 Gerçek sayıları tanır; rasyonel ve irrasyonel sayılarla ilişkilendirir.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: lgsId,
      unitOrder: 1,
      unitName: 'Cebir',
      topics: [
        (
          name: 'Cebirsel İfadeler ve Özdeşlikler',
          outcomes: [
            'M.8.2.1.1 Basit cebirsel ifadeleri anlar ve farklı biçimlerde yazar.',
            'M.8.2.1.2 Cebirsel ifadelerin çarpımını yapar.',
            'M.8.2.1.3 Özdeşlikleri modellerle açıklar (tam kare, iki kare farkı vb.).',
            'M.8.2.1.4 Cebirsel ifadeleri çarpanlara ayırır.',
          ],
        ),
        (
          name: 'Doğrusal Denklemler',
          outcomes: [
            'M.8.2.2.1 Birinci dereceden bir bilinmeyenli denklemleri çözer.',
            'M.8.2.2.2 Koordinat sistemini özellikleriyle tanır ve sıralı ikilileri gösterir.',
            'M.8.2.2.3 Doğrunun eğimini hesaplar ve yorumlar.',
            'M.8.2.2.4 Doğrusal denklemlerin grafiğini çizer.',
            'M.8.2.2.5 Doğrusal ilişki içeren gerçek hayat durumlarına ait denklem, tablo ve grafiği oluşturur ve yorumlar.',
          ],
        ),
        (
          name: 'Eşitsizlikler',
          outcomes: [
            'M.8.2.3.1 Birinci dereceden bir bilinmeyenli eşitsizlik içeren günlük hayat durumlarına uygun matematik cümleleri yazar.',
            'M.8.2.3.2 Birinci dereceden bir bilinmeyenli eşitsizlikleri sayı doğrusunda gösterir.',
            'M.8.2.3.3 Birinci dereceden bir bilinmeyenli eşitsizlikleri çözer.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: lgsId,
      unitOrder: 2,
      unitName: 'Geometri ve Ölçme',
      topics: [
        (
          name: 'Üçgenler',
          outcomes: [
            'M.8.3.1.1 Üçgende kenarortay, açıortay ve yüksekliği inşa eder.',
            'M.8.3.1.2 Üçgenin iki kenar uzunluğunun toplamı veya farkı ile üçüncü kenarının uzunluğunu ilişkilendirir.',
            'M.8.3.1.3 Üçgenin kenar uzunlukları ile bu kenarların karşısındaki açıların ölçülerini ilişkilendirir.',
            'M.8.3.1.4 Yeterli sayıda elemanının ölçüleri verilen bir üçgeni çizer.',
            'M.8.3.1.5 Pisagor bağıntısını oluşturur, ilgili problemleri çözer.',
          ],
        ),
        (
          name: 'Dönüşüm Geometrisi',
          outcomes: [
            'M.8.3.2.1 Nokta, doğru parçası ve diğer şekillerin öteleme sonucundaki görüntülerini çizer.',
            'M.8.3.2.2 Nokta, doğru parçası ve diğer şekillerin yansıma sonucu oluşan görüntüsünü oluşturur.',
            'M.8.3.2.3 Çokgenlerin öteleme ve yansımalar sonucunda ortaya çıkan görüntüsünü oluşturur.',
          ],
        ),
        (
          name: 'Eşlik ve Benzerlik',
          outcomes: [
            'M.8.3.3.1 Eşlik ve benzerliği ilişkilendirir; eş ve benzer şekillerin kenar ve açı ilişkilerini belirler.',
            'M.8.3.3.2 Benzer çokgenlerin benzerlik oranını belirler; bir çokgene eş ve benzer çokgenler oluşturur.',
          ],
        ),
        (
          name: 'Geometrik Cisimler',
          outcomes: [
            'M.8.3.4.1 Dik prizmaları tanır; temel elemanlarını belirler, inşa eder ve açınımını çizer.',
            'M.8.3.4.2 Dik dairesel silindirin temel elemanlarını belirler, inşa eder ve açınımını çizer.',
            'M.8.3.4.3 Dik dairesel silindirin yüzey alanı bağıntısını oluşturur; ilgili problemleri çözer.',
            'M.8.3.4.4 Dik dairesel silindirin hacim bağıntısını oluşturur; ilgili problemleri çözer.',
            'M.8.3.4.5 Dik piramidi tanır; temel elemanlarını belirler, inşa eder ve açınımını çizer.',
            'M.8.3.4.6 Dik koniyi tanır; temel elemanlarını belirler, inşa eder ve açınımını çizer.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: lgsId,
      unitOrder: 3,
      unitName: 'Veri İşleme',
      topics: [
        (
          name: 'Veri Analizi',
          outcomes: [
            'M.8.4.1.1 En fazla üç veri grubuna ait çizgi ve sütun grafiklerini yorumlar.',
            'M.8.4.1.2 Verileri sütun, daire veya çizgi grafiği ile gösterir; bu gösterimler arasında uygun dönüşümleri yapar.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: lgsId,
      unitOrder: 4,
      unitName: 'Olasılık',
      topics: [
        (
          name: 'Basit Olayların Olma Olasılığı',
          outcomes: [
            'M.8.5.1.1 Bir olaya ait olası durumları belirler.',
            'M.8.5.1.2 “Daha fazla”, “eşit”, “daha az” olasılıklı olayları ayırt eder; örnek verir.',
            'M.8.5.1.3 Eşit şansa sahip olaylarda her çıktının olasılığının 1/n olduğunu açıklar.',
            'M.8.5.1.4 Olasılık değerinin 0 ile 1 arasında (0 ve 1 dâhil) olduğunu anlar.',
            'M.8.5.1.5 Basit bir olayın olma olasılığını hesaplar.',
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // Türkiye Yüzyılı Maarif Modeli — Matematik (yalnızca)
  // Kaynak: MEB Ortaöğretim Matematik Dersi Öğretim Programı
  // ═══════════════════════════════════════════════════════

  // ── 9. SINIF MATEMATİK ────────────────────────────────
  final m9 = await ensureSubject('9. Sınıf Matematik', 10);
  if (await unitCount(m9) == 0) {
    await addUnitWithTopics(
      subjectId: m9,
      unitOrder: 0,
      unitName: 'Sayılar',
      topics: [
        (
          name: 'Üslü ve Köklü Gösterimler',
          outcomes: [
            'MAT.9.1.1 Gerçek sayıların üslü ve köklü gösterimleriyle yapılan işlemlere dair muhakeme yapar.',
          ],
        ),
        (
          name: 'Gerçek Sayı Aralıkları',
          outcomes: [
            'MAT.9.1.2 Gerçek sayı aralıklarının gösteriminde ve aralıklarla ilgili işlemlerde küme sembol ve işlemlerinden yararlanır.',
          ],
        ),
        (
          name: 'Sayı Kümeleri ve İşlem Özellikleri',
          outcomes: [
            'MAT.9.1.3 Farklı sayı kümelerinin özellikleri hakkında muhakeme yapar.',
            'MAT.9.1.4 Gerçek sayıların işlem özelliklerini cebirsel olarak ifade etmede analojik akıl yürütür.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9,
      unitOrder: 1,
      unitName: 'Nicelikler ve Değişimler',
      topics: [
        (
          name: 'Doğrusal Fonksiyonlar',
          outcomes: [
            'MAT.9.2.1 Doğrusal referans fonksiyon ve türetilen doğrusal fonksiyonların nitel özelliklerine ilişkin muhakeme yapar.',
          ],
        ),
        (
          name: 'Mutlak Değer Fonksiyonu',
          outcomes: [
            'MAT.9.2.2 Mutlak değer fonksiyonlarının nitel özelliklerini doğrusal fonksiyonlara bağlı analojik akıl yürüterek inceler.',
          ],
        ),
        (
          name: 'Doğrusal Denklem ve Eşitsizlikler',
          outcomes: [
            'MAT.9.2.3 Doğrusal fonksiyonlarla ifade edilebilen denklem ve eşitsizlikler içeren problemleri çözer.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9,
      unitOrder: 2,
      unitName: 'Geometrik Şekiller',
      topics: [
        (
          name: 'Üçgende Açı ve Kenar Özellikleri',
          outcomes: [
            'MAT.9.4.1 Üçgende açı ve kenarla ilgili özellikleri, açı-kenar ilişkilerini doğrular veya ispatlar.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9,
      unitOrder: 3,
      unitName: 'Eşlik ve Benzerlik',
      topics: [
        (
          name: 'Geometrik Dönüşümler',
          outcomes: [
            'MAT.9.5.1 Geometrik dönüşümlerle (yansıma, öteleme, dönme) ilgili çıkarım yapar.',
          ],
        ),
        (
          name: 'Üçgenlerde Eşlik ve Benzerlik',
          outcomes: [
            'MAT.9.5.2 İki üçgenin eş veya benzer olması için gerekli asgari koşullarla ilgili çıkarım yapar.',
            'MAT.9.5.3 Bir üçgenden hareketle ona benzer üçgenler oluşturmaya ilişkin yansıtma yapar.',
          ],
        ),
        (
          name: 'Tales, Öklid ve Pisagor',
          outcomes: [
            'MAT.9.5.4 Tales, Öklid ve Pisagor teoremlerini ispatlar.',
            'MAT.9.5.5 Eşlik ve benzerlikle ilgili çıkarım ve teoremleri içeren problemleri çözer.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9,
      unitOrder: 4,
      unitName: 'Algoritma ve Bilişim',
      topics: [
        (
          name: 'Algoritma Temelli Problemler',
          outcomes: [
            'MAT.9.3.1 Algoritma temelli yaklaşımlarla problem çözer.',
          ],
        ),
        (
          name: 'Mantık Bağlaçları ve Niceleyiciler',
          outcomes: [
            'MAT.9.3.2 Algoritmik yapılar içindeki mantık bağlaçlarını ve niceleyicileri çözümler.',
            'MAT.9.3.3 Mantık bağlaçları ve niceleyicilerin algoritmalarda kullanımına yönelik deneyimini farklı görevlere yansıtır.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9,
      unitOrder: 5,
      unitName: 'İstatistiksel Araştırma Süreci',
      topics: [
        (
          name: 'Tek Nicel Değişkenli Veri',
          outcomes: [
            'MAT.9.6.1 Tek nicel değişkenli veri dağılımları ile çalışır ve veriye dayalı karar verir.',
            'MAT.9.6.2 Başkaları tarafından oluşturulan tek nicel değişkenli dağılımlara ilişkin istatistiksel sonuç veya yorumları tartışır.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9,
      unitOrder: 6,
      unitName: 'Veriden Olasılığa',
      topics: [
        (
          name: 'Deneysel ve Teorik Olasılık',
          outcomes: [
            'MAT.9.7.1 Olayların olasılığını gözleme dayalı tahmin eder.',
            'MAT.9.7.2 Olayların olasılığına ilişkin tümevarımsal akıl yürütür.',
          ],
        ),
      ],
    );
  }

  // ── 10. SINIF MATEMATİK ───────────────────────────────
  final m10 = await ensureSubject('10. Sınıf Matematik', 11);
  if (await unitCount(m10) == 0) {
    await addUnitWithTopics(
      subjectId: m10,
      unitOrder: 0,
      unitName: 'Geometrik Şekiller',
      topics: [
        (
          name: 'Dik Üçgende Trigonometrik Oranlar',
          outcomes: [
            'MAT.10.4.1 Dik üçgende trigonometrik oranlara ve trigonometrik özdeşliklere ilişkin çıkarım yapar.',
          ],
        ),
        (
          name: 'Üçgende Yardımcı Elemanlar',
          outcomes: [
            'MAT.10.4.2 Üçgende yardımcı elemanlar (açıortay, kenarortay, yükseklik, kenar orta dikme) ve aralarındaki ilişkileri inceler.',
          ],
        ),
        (
          name: 'Üçgende Alan',
          outcomes: [
            'MAT.10.4.3 Üçgende alan bağıntılarını kullanarak problem çözer.',
          ],
        ),
        (
          name: 'Sinüs ve Kosinüs Teoremleri',
          outcomes: [
            'MAT.10.4.4 Sinüs ve kosinüs teoremlerini ispatlar ve problemlerde kullanır.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m10,
      unitOrder: 1,
      unitName: 'İstatistiksel Araştırma Süreci',
      topics: [
        (
          name: 'İki Kategorik Değişkenli Veri',
          outcomes: [
            'MAT.10.6.1 İki kategorik değişkenli veri ile çalışır ve ilişkililiğe dayalı karar verir.',
            'MAT.10.6.2 Başkaları tarafından oluşturulan iki kategorik değişkenli sonuç veya yorumları tartışır.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m10,
      unitOrder: 2,
      unitName: 'Sayılar',
      topics: [
        (
          name: 'Asal Çarpanlar ve Bölenler',
          outcomes: [
            'MAT.10.1.1 Bir doğal sayı ile asal çarpanları ve bölenleri arasındaki ilişkilere dair çıkarım yapar.',
          ],
        ),
        (
          name: 'EBOB ve EKOK',
          outcomes: [
            'MAT.10.1.2 Ortak bölenler / ortak katlar ile EBOB ve EKOK arasındaki ilişkilere dair muhakeme yapar.',
          ],
        ),
        (
          name: 'Bölünebilme ve Kalanlar',
          outcomes: [
            'MAT.10.1.3 Bir doğal sayının belirli doğal sayılara bölümünden kalanlarına dair muhakeme yapar.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m10,
      unitOrder: 3,
      unitName: 'Nicelikler ve Değişimler',
      topics: [
        (
          name: 'Fonksiyon Olma Şartları ve Nitel Özellikler',
          outcomes: [
            'MAT.10.2.1 Fonksiyon olma şartları ile fonksiyonların nitel özelliklerini matematiksel temsillerle değerlendirir.',
          ],
        ),
        (
          name: 'Karesel Fonksiyonlar',
          outcomes: [
            'MAT.10.2.2 Karesel referans fonksiyon ve türetilen karesel fonksiyonların nitel özelliklerine ilişkin muhakeme yapar.',
          ],
        ),
        (
          name: 'Karekök Fonksiyonları',
          outcomes: [
            'MAT.10.2.3 Karekök fonksiyonlarının nitel özelliklerine ilişkin muhakeme yapar.',
          ],
        ),
        (
          name: 'Rasyonel Fonksiyonlar',
          outcomes: [
            'MAT.10.2.4 Rasyonel referans fonksiyon ve türetilen rasyonel fonksiyonların nitel özelliklerine ilişkin muhakeme yapar.',
          ],
        ),
        (
          name: 'Ters Fonksiyon',
          outcomes: [
            'MAT.10.2.5 Fonksiyonların terslerine ilişkin muhakeme yapar.',
          ],
        ),
        (
          name: 'Denklem ve Eşitsizlik Problemleri',
          outcomes: [
            'MAT.10.2.6 Doğrusal, karesel, karekök ve rasyonel fonksiyonlarla ifade edilen denklem/eşitsizlik problemlerini çözer.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m10,
      unitOrder: 4,
      unitName: 'Sayma, Algoritma ve Bilişim',
      topics: [
        (
          name: 'Sayma Stratejileri',
          outcomes: [
            'MAT.10.3.1 Sayma stratejileri (toplama/çarpma ilkesi, sıralama, seçme, faktöriyel) kullanarak problem çözer.',
          ],
        ),
        (
          name: 'Algoritmik Yapı',
          outcomes: [
            'MAT.10.3.2 Cebirsel ve fonksiyonel işlemleri algoritmik bir dille yapılandırır.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m10,
      unitOrder: 5,
      unitName: 'Analitik İnceleme',
      topics: [
        (
          name: 'Uzaklık ve Oranlı Bölme',
          outcomes: [
            'MAT.10.5.1 İki nokta arası uzaklık ve doğru parçasını belli oranda bölen noktanın koordinatlarıyla ilgili çıkarım yapar.',
          ],
        ),
        (
          name: 'Doğrunun Analitiği',
          outcomes: [
            'MAT.10.5.2 Dik koordinat sistemini doğrunun özelliklerini incelemek ve doğru problemlerini çözmek için kullanır.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m10,
      unitOrder: 6,
      unitName: 'Veriden Olasılığa',
      topics: [
        (
          name: 'Koşullu Olasılık',
          outcomes: [
            'MAT.10.7.1 Koşullu olasılık ile çıkarım yapar.',
          ],
        ),
        (
          name: 'Bağımlı-Bağımsız Olaylar ve Bayes',
          outcomes: [
            'MAT.10.7.2 Bağımlı/bağımsız olaylar ve Bayes teoremi ile olasılıksal problemleri çözer.',
          ],
        ),
      ],
    );
  }

  // ── 11. SINIF MATEMATİK ───────────────────────────────
  final m11 = await ensureSubject('11. Sınıf Matematik', 12);
  if (await unitCount(m11) == 0) {
    await addUnitWithTopics(
      subjectId: m11,
      unitOrder: 0,
      unitName: 'İstatistiksel Araştırma Süreci',
      topics: [
        (
          name: 'İki Nicel Değişkenli Veri',
          outcomes: [
            'MAT.11.3.1 İki nicel değişkenli veri ile çalışır ve ilişkililiğe dayalı karar verir.',
            'MAT.11.3.2 Başkaları tarafından oluşturulan iki nicel değişkenli sonuç veya yorumları tartışır.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m11,
      unitOrder: 1,
      unitName: 'Geometrik Şekiller',
      topics: [
        (
          name: 'Dörtgenlerin Özellikleri',
          outcomes: [
            'MAT.11.2.1 Üçgen özelliklerinden yola çıkarak dörtgenlerin açı, kenar, köşegen, simetri ve alan özelliklerine ilişkin muhakeme yapar.',
          ],
        ),
        (
          name: 'Özel Dörtgenler Arasındaki İlişkiler',
          outcomes: [
            'MAT.11.2.2 Özel dörtgenlerin özelliklerinden hareketle aralarındaki ilişkileri yapılandırır.',
          ],
        ),
        (
          name: 'Çokgenlerin Sınıflandırılması',
          outcomes: [
            'MAT.11.2.3 Çokgenleri içbükey veya dışbükey olarak sınıflandırır.',
          ],
        ),
        (
          name: 'Dışbükey Çokgenlerin Özellikleri',
          outcomes: [
            'MAT.11.2.4 Dışbükey çokgenlerin kenar, açı, köşegen, simetri ve alan özelliklerine dair çıkarım yapar.',
          ],
        ),
        (
          name: 'Çokgen Problemleri',
          outcomes: [
            'MAT.11.2.5 Çokgenlerin özelliklerini içeren problemleri çözer.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m11,
      unitOrder: 2,
      unitName: 'Nicelikler ve Değişimler (1)',
      topics: [
        (
          name: 'Trigonometrik Fonksiyonlar',
          outcomes: [
            'MAT.11.1.1 Trigonometrik referans fonksiyonların (sin, cos, tan, cot) nitel özelliklerine ilişkin muhakeme yapar.',
            'MAT.11.1.2 Trigonometrik fonksiyonlarla ifade edilen denklemleri içeren problemleri çözer.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m11,
      unitOrder: 3,
      unitName: 'Nicelikler ve Değişimler (2)',
      topics: [
        (
          name: 'Üstel Fonksiyonlar',
          outcomes: [
            'MAT.11.1.3 Üstel referans fonksiyon ve türetilen üstel fonksiyonların nitel özelliklerine ilişkin muhakeme yapar.',
          ],
        ),
        (
          name: 'Logaritmik Fonksiyonlar',
          outcomes: [
            'MAT.11.1.5 Logaritmik referans fonksiyon ve türetilen logaritmik fonksiyonların nitel özelliklerine ilişkin muhakeme yapar.',
          ],
        ),
        (
          name: 'Üstel ve Logaritmik Denklemler',
          outcomes: [
            'MAT.11.1.6 Üstel ve logaritmik fonksiyonlarla ifade edilen denklem ve eşitsizlik problemlerini çözer.',
          ],
        ),
        (
          name: 'Üstel-Logaritmik İlişkiler',
          outcomes: [
            'MAT.11.1.4 Üstel ve logaritmik fonksiyonlar arasındaki ters ilişkiyi yorumlar.',
          ],
        ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m11,
      unitOrder: 4,
      unitName: 'Nicelikler ve Değişimler (3)',
      topics: [
        (
          name: 'Fonksiyonların Bileşkesi',
          outcomes: [
            'MAT.11.1.7 Fonksiyonların bileşkelerine ilişkin muhakeme yapar.',
          ],
        ),
        (
          name: 'Fonksiyonlarda Dört İşlem',
          outcomes: [
            'MAT.11.1.8 Fonksiyonlarda dört işlem özelliklerini yorumlar.',
          ],
        ),
      ],
    );
  }

  await seedBranchCurricula(
    ensureSubject: ensureSubject,
    unitCount: unitCount,
    addUnitWithTopics: addUnitWithTopics,
  );
}
