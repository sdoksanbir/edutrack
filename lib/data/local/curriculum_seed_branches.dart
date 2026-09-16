typedef EnsureSubjectFn = Future<String> Function(
  String name,
  int order, {
  String folder,
});
typedef UnitCountFn = Future<int> Function(String subjectId);
typedef AddUnitWithTopicsFn = Future<void> Function({
  required String subjectId,
  required int unitOrder,
  required String unitName,
  required List<({String name, List<String> outcomes})> topics,
});

/// Fizik, Kimya, Biyoloji, Türkçe, Tarih, Coğrafya:
/// TYT / AYT + 9–11. sınıf (MEB / Maarif Model ünite yapısı) müfredatı.
Future<void> seedBranchCurricula({
  required EnsureSubjectFn ensureSubject,
  required UnitCountFn unitCount,
  required AddUnitWithTopicsFn addUnitWithTopics,
}) async {
  // ── TYT Fizik ──
  final tytFiz = await ensureSubject('TYT Fizik', 20, folder: 'FİZİK');
  if (await unitCount(tytFiz) == 0) {
    await addUnitWithTopics(
      subjectId: tytFiz,
      unitOrder: 0,
      unitName: 'Fizik Bilimine Giriş',
      topics: [
      (
        name: 'Fizik Biliminin Önemi',
        outcomes: [
          'Fiziğin evreni açıklamadaki rolünü yorumlar.',
          'Fiziğin alt dallarını ve meslek alanlarını ilişkilendirir.',
        ],
      ),
      (
        name: 'Fiziksel Nicelikler',
        outcomes: [
          'Temel ve türetilmiş büyüklükleri ayırt eder.',
          'Skaler ve vektörel büyüklükleri örneklerle açıklar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: tytFiz,
      unitOrder: 1,
      unitName: 'Madde ve Özellikleri',
      topics: [
      (
        name: 'Madde ve Özkütle',
        outcomes: [
          'Özkütle kavramını açıklar ve hesaplar yapar.',
          'Kütle-hacim-özkütle ilişkisini yorumlar.',
        ],
      ),
      (
        name: 'Dayanıklılık',
        outcomes: [
          'Dayanıklılık kavramını madde özellikleri ile ilişkilendirir.',
        ],
      ),
      (
        name: 'Yapışma ve Birbirini Tutma',
        outcomes: [
          'Yapışma ve birbirini tutma kuvvetlerini örneklerle açıklar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: tytFiz,
      unitOrder: 2,
      unitName: 'Hareket ve Kuvvet',
      topics: [
      (
        name: 'Hareket',
        outcomes: [
          'Konum, yol, yer değiştirme, hız ve ivme kavramlarını açıklar.',
          'Hareket grafiklerini yorumlar.',
        ],
      ),
      (
        name: 'Kuvvet',
        outcomes: [
          'Kuvvetin etkilerini ve bileşke kuvveti açıklar.',
        ],
      ),
      (
        name: 'Sürtünme Kuvveti',
        outcomes: [
          'Sürtünme türlerini ayırt eder ve etkilerini yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: tytFiz,
      unitOrder: 3,
      unitName: 'İş, Güç ve Enerji',
      topics: [
      (
        name: 'İş, Enerji ve Güç',
        outcomes: [
          'İş, güç ve enerji kavramlarını ilişkilendirir.',
        ],
      ),
      (
        name: 'Mekanik Enerji',
        outcomes: [
          'Kinetik ve potansiyel enerjiyi hesaplar.',
        ],
      ),
      (
        name: 'Enerjinin Korunumu',
        outcomes: [
          'Enerji dönüşümlerini ve korunumunu açıklar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: tytFiz,
      unitOrder: 4,
      unitName: 'Isı, Basınç ve Kaldırma',
      topics: [
      (
        name: 'Isı ve Sıcaklık',
        outcomes: [
          'Isı ile sıcaklığı ayırt eder.',
          'Genleşme olaylarını açıklar.',
        ],
      ),
      (
        name: 'Basınç',
        outcomes: [
          'Katı, sıvı ve gaz basıncını açıklar.',
        ],
      ),
      (
        name: 'Kaldırma Kuvveti',
        outcomes: [
          'Kaldırma kuvveti ve yüzme/batma durumlarını yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: tytFiz,
      unitOrder: 5,
      unitName: 'Elektrik, Dalgalar ve Optik',
      topics: [
      (
        name: 'Elektrostatik',
        outcomes: [
          'Elektrik yüklerini ve etkileşimlerini açıklar.',
        ],
      ),
      (
        name: 'Elektrik ve Manyetizma',
        outcomes: [
          'Akım, direnç, devre ve manyetik alan temel kavramlarını açıklar.',
        ],
      ),
      (
        name: 'Dalgalar',
        outcomes: [
          'Dalga türlerini ve özelliklerini açıklar.',
        ],
      ),
      (
        name: 'Optik',
        outcomes: [
          'Yansıma, kırılma ve mercek/ayna olaylarını yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── AYT Fizik ──
  final aytFiz = await ensureSubject('AYT Fizik', 21, folder: 'FİZİK');
  if (await unitCount(aytFiz) == 0) {
    await addUnitWithTopics(
      subjectId: aytFiz,
      unitOrder: 0,
      unitName: 'Mekanik',
      topics: [
      (
        name: 'Vektörler',
        outcomes: [
          'Vektörel işlemleri uygular.',
        ],
      ),
      (
        name: 'Bağıl Hareket',
        outcomes: [
          'Bağıl hız ve hareket problemlerini çözer.',
        ],
      ),
      (
        name: 'Newton’un Hareket Yasaları',
        outcomes: [
          'Newton yasalarını problemlerde uygular.',
        ],
      ),
      (
        name: 'Bir Boyutta Sabit İvmeli Hareket',
        outcomes: [
          'Sabit ivmeli hareket denklemlerini kullanır.',
        ],
      ),
      (
        name: 'Atışlar',
        outcomes: [
          'Yatay ve eğik atış problemlerini çözer.',
        ],
      ),
      (
        name: 'İş, Güç ve Enerji II',
        outcomes: [
          'İleri düzey iş-enerji problemlerini çözer.',
        ],
      ),
      (
        name: 'İtme ve Momentum',
        outcomes: [
          'İtme-momentum ve çarpışmaları analiz eder.',
        ],
      ),
      (
        name: 'Kuvvet, Tork ve Denge',
        outcomes: [
          'Tork ve denge şartlarını uygular.',
        ],
      ),
      (
        name: 'Çembersel Hareket',
        outcomes: [
          'Düzgün çembersel hareketi açıklar.',
        ],
      ),
      (
        name: 'Dönme ve Açısal Momentum',
        outcomes: [
          'Dönme dinamiği ve açısal momentumu yorumlar.',
        ],
      ),
      (
        name: 'Basit Harmonik Hareket',
        outcomes: [
          'BHH özelliklerini ve enerjisini açıklar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: aytFiz,
      unitOrder: 1,
      unitName: 'Elektrik ve Manyetizma',
      topics: [
      (
        name: 'Elektrik Alan ve Potansiyel',
        outcomes: [
          'Elektrik alan ve potansiyeli hesaplar.',
        ],
      ),
      (
        name: 'Paralel Levhalar ve Sığa',
        outcomes: [
          'Sığa ve kondansatör kavramlarını açıklar.',
        ],
      ),
      (
        name: 'Manyetik Alan ve Kuvvet',
        outcomes: [
          'Manyetik alanda yüklü parçacık ve akım elemanına etkiyen kuvveti inceler.',
        ],
      ),
      (
        name: 'İndüksiyon ve Alternatif Akım',
        outcomes: [
          'İndüksiyon, AA ve transformatörleri açıklar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: aytFiz,
      unitOrder: 2,
      unitName: 'Dalgalar ve Modern Fizik',
      topics: [
      (
        name: 'Dalga Mekaniği ve EM Dalgalar',
        outcomes: [
          'Dalga özellikleri ve EM spektrumu yorumlar.',
        ],
      ),
      (
        name: 'Atom Modelleri',
        outcomes: [
          'Atom modellerinin gelişimini açıklar.',
        ],
      ),
      (
        name: 'Radyoaktivite',
        outcomes: [
          'Radyoaktif bozunma türlerini açıklar.',
        ],
      ),
      (
        name: 'Fotoelektrik ve Compton',
        outcomes: [
          'Kuantum olaylarını yorumlar.',
        ],
      ),
      (
        name: 'Özel Görelilik',
        outcomes: [
          'Özel görelilik temel sonuçlarını açıklar.',
        ],
      ),
      (
        name: 'Modern Fiziğin Uygulamaları',
        outcomes: [
          'Modern fizik uygulamalarına örnekler verir.',
        ],
      ),
      ],
    );
  }

  // ── 9. Sınıf Fizik ──
  final m9Fiz = await ensureSubject('9. Sınıf Fizik', 22, folder: 'FİZİK');
  if (await unitCount(m9Fiz) == 0) {
    await addUnitWithTopics(
      subjectId: m9Fiz,
      unitOrder: 0,
      unitName: 'Fizik Bilimine Giriş',
      topics: [
      (
        name: 'Fizik Biliminin Önemi',
        outcomes: [
          'Fizik Biliminin Önemi ile ilgili temel kavramları açıklar.',
          'Fizik Biliminin Önemi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Fiziğin Uygulama Alanları',
        outcomes: [
          'Fiziğin Uygulama Alanları ile ilgili temel kavramları açıklar.',
          'Fiziğin Uygulama Alanları konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Fiziksel Niceliklerin Sınıflandırılması',
        outcomes: [
          'Fiziksel Niceliklerin Sınıflandırılması ile ilgili temel kavramları açıklar.',
          'Fiziksel Niceliklerin Sınıflandırılması konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Bilim Araştırma Merkezleri',
        outcomes: [
          'Bilim Araştırma Merkezleri ile ilgili temel kavramları açıklar.',
          'Bilim Araştırma Merkezleri konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9Fiz,
      unitOrder: 1,
      unitName: 'Madde ve Özellikleri',
      topics: [
      (
        name: 'Madde ve Özkütle',
        outcomes: [
          'Madde ve Özkütle ile ilgili temel kavramları açıklar.',
          'Madde ve Özkütle konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Dayanıklılık',
        outcomes: [
          'Dayanıklılık ile ilgili temel kavramları açıklar.',
          'Dayanıklılık konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Yapışma ve Birbirini Tutma',
        outcomes: [
          'Yapışma ve Birbirini Tutma ile ilgili temel kavramları açıklar.',
          'Yapışma ve Birbirini Tutma konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9Fiz,
      unitOrder: 2,
      unitName: 'Hareket ve Kuvvet',
      topics: [
      (
        name: 'Hareket',
        outcomes: [
          'Hareket ile ilgili temel kavramları açıklar.',
          'Hareket konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Kuvvet',
        outcomes: [
          'Kuvvet ile ilgili temel kavramları açıklar.',
          'Kuvvet konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Sürtünme Kuvveti',
        outcomes: [
          'Sürtünme Kuvveti ile ilgili temel kavramları açıklar.',
          'Sürtünme Kuvveti konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9Fiz,
      unitOrder: 3,
      unitName: 'Enerji',
      topics: [
      (
        name: 'İş, Enerji ve Güç',
        outcomes: [
          'İş, Enerji ve Güç ile ilgili temel kavramları açıklar.',
          'İş, Enerji ve Güç konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Mekanik Enerji',
        outcomes: [
          'Mekanik Enerji ile ilgili temel kavramları açıklar.',
          'Mekanik Enerji konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Enerjinin Korunumu ve Dönüşümleri',
        outcomes: [
          'Enerjinin Korunumu ve Dönüşümleri ile ilgili temel kavramları açıklar.',
          'Enerjinin Korunumu ve Dönüşümleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Verim',
        outcomes: [
          'Verim ile ilgili temel kavramları açıklar.',
          'Verim konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Enerji Kaynakları',
        outcomes: [
          'Enerji Kaynakları ile ilgili temel kavramları açıklar.',
          'Enerji Kaynakları konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9Fiz,
      unitOrder: 4,
      unitName: 'Isı ve Sıcaklık',
      topics: [
      (
        name: 'Isı ve Sıcaklık',
        outcomes: [
          'Isı ve Sıcaklık ile ilgili temel kavramları açıklar.',
          'Isı ve Sıcaklık konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Isıl Denge',
        outcomes: [
          'Isıl Denge ile ilgili temel kavramları açıklar.',
          'Isıl Denge konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Enerji İletim Yolları',
        outcomes: [
          'Enerji İletim Yolları ile ilgili temel kavramları açıklar.',
          'Enerji İletim Yolları konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Genleşme',
        outcomes: [
          'Genleşme ile ilgili temel kavramları açıklar.',
          'Genleşme konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9Fiz,
      unitOrder: 5,
      unitName: 'Elektrostatik',
      topics: [
      (
        name: 'Elektrik Yükleri',
        outcomes: [
          'Elektrik Yükleri ile ilgili temel kavramları açıklar.',
          'Elektrik Yükleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Elektriklenme',
        outcomes: [
          'Elektriklenme ile ilgili temel kavramları açıklar.',
          'Elektriklenme konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Coulomb Kuvveti',
        outcomes: [
          'Coulomb Kuvveti ile ilgili temel kavramları açıklar.',
          'Coulomb Kuvveti konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── 10. Sınıf Fizik ──
  final m10Fiz = await ensureSubject('10. Sınıf Fizik', 23, folder: 'FİZİK');
  if (await unitCount(m10Fiz) == 0) {
    await addUnitWithTopics(
      subjectId: m10Fiz,
      unitOrder: 0,
      unitName: 'Elektrik ve Manyetizma',
      topics: [
      (
        name: 'Elektrik Akımı, Potansiyel Farkı ve Direnç',
        outcomes: [
          'Elektrik Akımı, Potansiyel Farkı ve Direnç ile ilgili temel kavramları açıklar.',
          'Elektrik Akımı, Potansiyel Farkı ve Direnç konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Elektrik Devreleri',
        outcomes: [
          'Elektrik Devreleri ile ilgili temel kavramları açıklar.',
          'Elektrik Devreleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Mıknatıs ve Manyetik Alan',
        outcomes: [
          'Mıknatıs ve Manyetik Alan ile ilgili temel kavramları açıklar.',
          'Mıknatıs ve Manyetik Alan konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Akım ve Manyetik Alan',
        outcomes: [
          'Akım ve Manyetik Alan ile ilgili temel kavramları açıklar.',
          'Akım ve Manyetik Alan konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m10Fiz,
      unitOrder: 1,
      unitName: 'Basınç ve Kaldırma Kuvveti',
      topics: [
      (
        name: 'Basınç',
        outcomes: [
          'Basınç ile ilgili temel kavramları açıklar.',
          'Basınç konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Kaldırma Kuvveti',
        outcomes: [
          'Kaldırma Kuvveti ile ilgili temel kavramları açıklar.',
          'Kaldırma Kuvveti konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m10Fiz,
      unitOrder: 2,
      unitName: 'Dalgalar',
      topics: [
      (
        name: 'Dalgalar',
        outcomes: [
          'Dalgalar ile ilgili temel kavramları açıklar.',
          'Dalgalar konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Yay Dalgası',
        outcomes: [
          'Yay Dalgası ile ilgili temel kavramları açıklar.',
          'Yay Dalgası konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Su Dalgası',
        outcomes: [
          'Su Dalgası ile ilgili temel kavramları açıklar.',
          'Su Dalgası konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Ses Dalgası',
        outcomes: [
          'Ses Dalgası ile ilgili temel kavramları açıklar.',
          'Ses Dalgası konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Deprem Dalgası',
        outcomes: [
          'Deprem Dalgası ile ilgili temel kavramları açıklar.',
          'Deprem Dalgası konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m10Fiz,
      unitOrder: 3,
      unitName: 'Optik',
      topics: [
      (
        name: 'Aydınlanma',
        outcomes: [
          'Aydınlanma ile ilgili temel kavramları açıklar.',
          'Aydınlanma konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Gölge',
        outcomes: [
          'Gölge ile ilgili temel kavramları açıklar.',
          'Gölge konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Yansıma',
        outcomes: [
          'Yansıma ile ilgili temel kavramları açıklar.',
          'Yansıma konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Düzlem Ayna',
        outcomes: [
          'Düzlem Ayna ile ilgili temel kavramları açıklar.',
          'Düzlem Ayna konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Küresel Aynalar',
        outcomes: [
          'Küresel Aynalar ile ilgili temel kavramları açıklar.',
          'Küresel Aynalar konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Kırılma',
        outcomes: [
          'Kırılma ile ilgili temel kavramları açıklar.',
          'Kırılma konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Mercekler',
        outcomes: [
          'Mercekler ile ilgili temel kavramları açıklar.',
          'Mercekler konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Renk',
        outcomes: [
          'Renk ile ilgili temel kavramları açıklar.',
          'Renk konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── 11. Sınıf Fizik ──
  final m11Fiz = await ensureSubject('11. Sınıf Fizik', 24, folder: 'FİZİK');
  if (await unitCount(m11Fiz) == 0) {
    await addUnitWithTopics(
      subjectId: m11Fiz,
      unitOrder: 0,
      unitName: 'Kuvvet ve Hareket',
      topics: [
      (
        name: 'Vektörler',
        outcomes: [
          'Vektörler ile ilgili temel kavramları açıklar.',
          'Vektörler konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Bağıl Hareket',
        outcomes: [
          'Bağıl Hareket ile ilgili temel kavramları açıklar.',
          'Bağıl Hareket konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Newton’un Yasaları',
        outcomes: [
          'Newton’un Yasaları ile ilgili temel kavramları açıklar.',
          'Newton’un Yasaları konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Bir Boyutta Sabit İvmeli Hareket',
        outcomes: [
          'Bir Boyutta Sabit İvmeli Hareket ile ilgili temel kavramları açıklar.',
          'Bir Boyutta Sabit İvmeli Hareket konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Atışlar',
        outcomes: [
          'Atışlar ile ilgili temel kavramları açıklar.',
          'Atışlar konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m11Fiz,
      unitOrder: 1,
      unitName: 'Enerji ve Momentum',
      topics: [
      (
        name: 'İş, Güç, Enerji',
        outcomes: [
          'İş, Güç, Enerji ile ilgili temel kavramları açıklar.',
          'İş, Güç, Enerji konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'İtme ve Momentum',
        outcomes: [
          'İtme ve Momentum ile ilgili temel kavramları açıklar.',
          'İtme ve Momentum konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m11Fiz,
      unitOrder: 2,
      unitName: 'Tork ve Denge',
      topics: [
      (
        name: 'Kuvvet, Tork ve Denge',
        outcomes: [
          'Kuvvet, Tork ve Denge ile ilgili temel kavramları açıklar.',
          'Kuvvet, Tork ve Denge konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Kütle Merkezi',
        outcomes: [
          'Kütle Merkezi ile ilgili temel kavramları açıklar.',
          'Kütle Merkezi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Basit Makineler',
        outcomes: [
          'Basit Makineler ile ilgili temel kavramları açıklar.',
          'Basit Makineler konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m11Fiz,
      unitOrder: 3,
      unitName: 'Elektrik ve Manyetizma',
      topics: [
      (
        name: 'Elektrik Alan',
        outcomes: [
          'Elektrik Alan ile ilgili temel kavramları açıklar.',
          'Elektrik Alan konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Elektrik Potansiyel',
        outcomes: [
          'Elektrik Potansiyel ile ilgili temel kavramları açıklar.',
          'Elektrik Potansiyel konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Düzgün Elektrik Alan ve Sığa',
        outcomes: [
          'Düzgün Elektrik Alan ve Sığa ile ilgili temel kavramları açıklar.',
          'Düzgün Elektrik Alan ve Sığa konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Manyetizma ve EM İndüksiyon',
        outcomes: [
          'Manyetizma ve EM İndüksiyon ile ilgili temel kavramları açıklar.',
          'Manyetizma ve EM İndüksiyon konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── TYT Kimya ──
  final tytKim = await ensureSubject('TYT Kimya', 30, folder: 'KİMYA');
  if (await unitCount(tytKim) == 0) {
    await addUnitWithTopics(
      subjectId: tytKim,
      unitOrder: 0,
      unitName: 'Kimya Bilimi ve Atom',
      topics: [
      (
        name: 'Kimya Bilimi',
        outcomes: [
          'Kimyanın çalışma alanlarını ve sembolik dilini açıklar.',
        ],
      ),
      (
        name: 'Atom ve Periyodik Sistem',
        outcomes: [
          'Atomun yapısını ve periyodik özellikleri yorumlar.',
        ],
      ),
      (
        name: 'Kimyasal Türler Arası Etkileşimler',
        outcomes: [
          'Güçlü ve zayıf etkileşimleri ayırt eder.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: tytKim,
      unitOrder: 1,
      unitName: 'Madde, Karışımlar ve Hesaplamalar',
      topics: [
      (
        name: 'Maddenin Halleri',
        outcomes: [
          'Katı, sıvı, gaz ve plazma özelliklerini karşılaştırır.',
        ],
      ),
      (
        name: 'Kimyanın Temel Kanunları',
        outcomes: [
          'Kütlenin korunumu, sabit oranlar ve katlı oranlar kanunlarını uygular.',
        ],
      ),
      (
        name: 'Kimyasal Hesaplamalar',
        outcomes: [
          'Mol kavramı ve tepkime hesaplamalarını yapar.',
        ],
      ),
      (
        name: 'Karışımlar',
        outcomes: [
          'Homojen/heterojen karışımları ve ayırma yöntemlerini açıklar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: tytKim,
      unitOrder: 2,
      unitName: 'Asit-Baz ve Günlük Hayat',
      topics: [
      (
        name: 'Asit, Baz ve Tuz',
        outcomes: [
          'Asit-baz özelliklerini ve tuz oluşumunu açıklar.',
        ],
      ),
      (
        name: 'Doğa ve Kimya',
        outcomes: [
          'Su ve çevre kimyası konularını yorumlar.',
        ],
      ),
      (
        name: 'Kimya Her Yerde',
        outcomes: [
          'Günlük hayat kimyasallarını örneklerle açıklar.',
        ],
      ),
      ],
    );
  }

  // ── AYT Kimya ──
  final aytKim = await ensureSubject('AYT Kimya', 31, folder: 'KİMYA');
  if (await unitCount(aytKim) == 0) {
    await addUnitWithTopics(
      subjectId: aytKim,
      unitOrder: 0,
      unitName: 'Atom ve Maddenin Halleri',
      topics: [
      (
        name: 'Modern Atom Teorisi',
        outcomes: [
          'Kuantum modelini ve elektron dizilimini açıklar.',
        ],
      ),
      (
        name: 'Gazlar',
        outcomes: [
          'Gaz yasalarını ve kinetik teoriyi uygular.',
        ],
      ),
      (
        name: 'Sıvı Çözeltiler',
        outcomes: [
          'Derişim birimleri ve kolligatif özellikleri açıklar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: aytKim,
      unitOrder: 1,
      unitName: 'Tepkimeler ve Denge',
      topics: [
      (
        name: 'Kimyasal Tepkimelerde Enerji',
        outcomes: [
          'Endotermik/ekzotermik tepkimeleri ve entalpiyi yorumlar.',
        ],
      ),
      (
        name: 'Kimyasal Tepkimelerde Hız',
        outcomes: [
          'Tepkime hızını etkileyen faktörleri açıklar.',
        ],
      ),
      (
        name: 'Kimyasal Tepkimelerde Denge',
        outcomes: [
          'Denge sabitini ve Le Chatelier ilkesini uygular.',
        ],
      ),
      (
        name: 'Asit-Baz Dengesi',
        outcomes: [
          'pH, kuvvetli/zayıf asit-baz ve tamponları açıklar.',
        ],
      ),
      (
        name: 'Çözünürlük Dengesi',
        outcomes: [
          'Çözünürlük çarpımını yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: aytKim,
      unitOrder: 2,
      unitName: 'Elektrokimya ve Organik',
      topics: [
      (
        name: 'Kimya ve Elektrik',
        outcomes: [
          'Redoks, piller ve elektrolizi açıklar.',
        ],
      ),
      (
        name: 'Organik Kimya',
        outcomes: [
          'Karbon kimyası temel sınıflarını ve tepkimelerini açıklar.',
        ],
      ),
      ],
    );
  }

  // ── 9. Sınıf Kimya ──
  final m9Kim = await ensureSubject('9. Sınıf Kimya', 32, folder: 'KİMYA');
  if (await unitCount(m9Kim) == 0) {
    await addUnitWithTopics(
      subjectId: m9Kim,
      unitOrder: 0,
      unitName: 'Kimya Bilimi',
      topics: [
      (
        name: 'Simyadan Kimyaya',
        outcomes: [
          'Simyadan Kimyaya ile ilgili temel kavramları açıklar.',
          'Simyadan Kimyaya konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Kimya Disiplinleri',
        outcomes: [
          'Kimya Disiplinleri ile ilgili temel kavramları açıklar.',
          'Kimya Disiplinleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Kimyanın Sembolik Dili',
        outcomes: [
          'Kimyanın Sembolik Dili ile ilgili temel kavramları açıklar.',
          'Kimyanın Sembolik Dili konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'İş Sağlığı ve Güvenliği',
        outcomes: [
          'İş Sağlığı ve Güvenliği ile ilgili temel kavramları açıklar.',
          'İş Sağlığı ve Güvenliği konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9Kim,
      unitOrder: 1,
      unitName: 'Atom ve Periyodik Sistem',
      topics: [
      (
        name: 'Atom Modelleri',
        outcomes: [
          'Atom Modelleri ile ilgili temel kavramları açıklar.',
          'Atom Modelleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Atomun Yapısı',
        outcomes: [
          'Atomun Yapısı ile ilgili temel kavramları açıklar.',
          'Atomun Yapısı konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Periyodik Sistem',
        outcomes: [
          'Periyodik Sistem ile ilgili temel kavramları açıklar.',
          'Periyodik Sistem konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9Kim,
      unitOrder: 2,
      unitName: 'Kimyasal Türler Arası Etkileşimler',
      topics: [
      (
        name: 'Kimyasal Tür',
        outcomes: [
          'Kimyasal Tür ile ilgili temel kavramları açıklar.',
          'Kimyasal Tür konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Güçlü Etkileşimler',
        outcomes: [
          'Güçlü Etkileşimler ile ilgili temel kavramları açıklar.',
          'Güçlü Etkileşimler konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Zayıf Etkileşimler',
        outcomes: [
          'Zayıf Etkileşimler ile ilgili temel kavramları açıklar.',
          'Zayıf Etkileşimler konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Fiziksel ve Kimyasal Değişimler',
        outcomes: [
          'Fiziksel ve Kimyasal Değişimler ile ilgili temel kavramları açıklar.',
          'Fiziksel ve Kimyasal Değişimler konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9Kim,
      unitOrder: 3,
      unitName: 'Maddenin Halleri',
      topics: [
      (
        name: 'Katılar',
        outcomes: [
          'Katılar ile ilgili temel kavramları açıklar.',
          'Katılar konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Sıvılar',
        outcomes: [
          'Sıvılar ile ilgili temel kavramları açıklar.',
          'Sıvılar konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Gazlar',
        outcomes: [
          'Gazlar ile ilgili temel kavramları açıklar.',
          'Gazlar konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Plazma',
        outcomes: [
          'Plazma ile ilgili temel kavramları açıklar.',
          'Plazma konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9Kim,
      unitOrder: 4,
      unitName: 'Doğa ve Kimya',
      topics: [
      (
        name: 'Su ve Hayat',
        outcomes: [
          'Su ve Hayat ile ilgili temel kavramları açıklar.',
          'Su ve Hayat konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Çevre Kimyası',
        outcomes: [
          'Çevre Kimyası ile ilgili temel kavramları açıklar.',
          'Çevre Kimyası konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── 10. Sınıf Kimya ──
  final m10Kim = await ensureSubject('10. Sınıf Kimya', 33, folder: 'KİMYA');
  if (await unitCount(m10Kim) == 0) {
    await addUnitWithTopics(
      subjectId: m10Kim,
      unitOrder: 0,
      unitName: 'Kimyanın Temel Kanunları ve Hesaplamalar',
      topics: [
      (
        name: 'Kimyanın Temel Kanunları',
        outcomes: [
          'Kimyanın Temel Kanunları ile ilgili temel kavramları açıklar.',
          'Kimyanın Temel Kanunları konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Mol Kavramı',
        outcomes: [
          'Mol Kavramı ile ilgili temel kavramları açıklar.',
          'Mol Kavramı konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Kimyasal Tepkimeler ve Denklemler',
        outcomes: [
          'Kimyasal Tepkimeler ve Denklemler ile ilgili temel kavramları açıklar.',
          'Kimyasal Tepkimeler ve Denklemler konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Kimyasal Tepkimelerde Hesaplamalar',
        outcomes: [
          'Kimyasal Tepkimelerde Hesaplamalar ile ilgili temel kavramları açıklar.',
          'Kimyasal Tepkimelerde Hesaplamalar konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m10Kim,
      unitOrder: 1,
      unitName: 'Karışımlar',
      topics: [
      (
        name: 'Homojen ve Heterojen Karışımlar',
        outcomes: [
          'Homojen ve Heterojen Karışımlar ile ilgili temel kavramları açıklar.',
          'Homojen ve Heterojen Karışımlar konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Ayırma ve Saflaştırma Teknikleri',
        outcomes: [
          'Ayırma ve Saflaştırma Teknikleri ile ilgili temel kavramları açıklar.',
          'Ayırma ve Saflaştırma Teknikleri konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m10Kim,
      unitOrder: 2,
      unitName: 'Asitler, Bazlar ve Tuzlar',
      topics: [
      (
        name: 'Asitler ve Bazlar',
        outcomes: [
          'Asitler ve Bazlar ile ilgili temel kavramları açıklar.',
          'Asitler ve Bazlar konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Asit-Baz Tepkimeleri',
        outcomes: [
          'Asit-Baz Tepkimeleri ile ilgili temel kavramları açıklar.',
          'Asit-Baz Tepkimeleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Hayatımızda Asitler ve Bazlar',
        outcomes: [
          'Hayatımızda Asitler ve Bazlar ile ilgili temel kavramları açıklar.',
          'Hayatımızda Asitler ve Bazlar konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Tuzlar',
        outcomes: [
          'Tuzlar ile ilgili temel kavramları açıklar.',
          'Tuzlar konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m10Kim,
      unitOrder: 3,
      unitName: 'Kimya Her Yerde',
      topics: [
      (
        name: 'Yaygın Günlük Hayat Kimyasalları',
        outcomes: [
          'Yaygın Günlük Hayat Kimyasalları ile ilgili temel kavramları açıklar.',
          'Yaygın Günlük Hayat Kimyasalları konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Gıdalar',
        outcomes: [
          'Gıdalar ile ilgili temel kavramları açıklar.',
          'Gıdalar konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── 11. Sınıf Kimya ──
  final m11Kim = await ensureSubject('11. Sınıf Kimya', 34, folder: 'KİMYA');
  if (await unitCount(m11Kim) == 0) {
    await addUnitWithTopics(
      subjectId: m11Kim,
      unitOrder: 0,
      unitName: 'Modern Atom Teorisi',
      topics: [
      (
        name: 'Atomun Kuantum Modeli',
        outcomes: [
          'Atomun Kuantum Modeli ile ilgili temel kavramları açıklar.',
          'Atomun Kuantum Modeli konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Periyodik Özellikler',
        outcomes: [
          'Periyodik Özellikler ile ilgili temel kavramları açıklar.',
          'Periyodik Özellikler konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Yükseltgenme Basamakları',
        outcomes: [
          'Yükseltgenme Basamakları ile ilgili temel kavramları açıklar.',
          'Yükseltgenme Basamakları konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m11Kim,
      unitOrder: 1,
      unitName: 'Gazlar',
      topics: [
      (
        name: 'Gaz Yasaları',
        outcomes: [
          'Gaz Yasaları ile ilgili temel kavramları açıklar.',
          'Gaz Yasaları konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'İdeal Gaz Denklemi',
        outcomes: [
          'İdeal Gaz Denklemi ile ilgili temel kavramları açıklar.',
          'İdeal Gaz Denklemi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Gazlarda Enerji',
        outcomes: [
          'Gazlarda Enerji ile ilgili temel kavramları açıklar.',
          'Gazlarda Enerji konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m11Kim,
      unitOrder: 2,
      unitName: 'Sıvı Çözeltiler ve Denge',
      topics: [
      (
        name: 'Çözelti ve Derişim',
        outcomes: [
          'Çözelti ve Derişim ile ilgili temel kavramları açıklar.',
          'Çözelti ve Derişim konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Kolligatif Özellikler',
        outcomes: [
          'Kolligatif Özellikler ile ilgili temel kavramları açıklar.',
          'Kolligatif Özellikler konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Tepkimelerde Enerji',
        outcomes: [
          'Tepkimelerde Enerji ile ilgili temel kavramları açıklar.',
          'Tepkimelerde Enerji konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Tepkime Hızı',
        outcomes: [
          'Tepkime Hızı ile ilgili temel kavramları açıklar.',
          'Tepkime Hızı konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Kimyasal Denge',
        outcomes: [
          'Kimyasal Denge ile ilgili temel kavramları açıklar.',
          'Kimyasal Denge konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── TYT Biyoloji ──
  final tytBio = await ensureSubject('TYT Biyoloji', 40, folder: 'BİYOLOJİ');
  if (await unitCount(tytBio) == 0) {
    await addUnitWithTopics(
      subjectId: tytBio,
      unitOrder: 0,
      unitName: 'Canlılığın Temelleri',
      topics: [
      (
        name: 'Canlıların Ortak Özellikleri',
        outcomes: [
          'Canlıların Ortak Özellikleri ile ilgili temel kavramları açıklar.',
          'Canlıların Ortak Özellikleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Canlıların Temel Bileşenleri',
        outcomes: [
          'Canlıların Temel Bileşenleri ile ilgili temel kavramları açıklar.',
          'Canlıların Temel Bileşenleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Hücre ve Organelleri',
        outcomes: [
          'Hücre ve Organelleri ile ilgili temel kavramları açıklar.',
          'Hücre ve Organelleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Hücre Zarından Madde Geçişi',
        outcomes: [
          'Hücre Zarından Madde Geçişi ile ilgili temel kavramları açıklar.',
          'Hücre Zarından Madde Geçişi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Canlıların Sınıflandırılması',
        outcomes: [
          'Canlıların Sınıflandırılması ile ilgili temel kavramları açıklar.',
          'Canlıların Sınıflandırılması konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: tytBio,
      unitOrder: 1,
      unitName: 'Üreme, Kalıtım ve Ekoloji',
      topics: [
      (
        name: 'Mitoz ve Eşeysiz Üreme',
        outcomes: [
          'Mitoz ve Eşeysiz Üreme ile ilgili temel kavramları açıklar.',
          'Mitoz ve Eşeysiz Üreme konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Mayoz ve Eşeyli Üreme',
        outcomes: [
          'Mayoz ve Eşeyli Üreme ile ilgili temel kavramları açıklar.',
          'Mayoz ve Eşeyli Üreme konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Kalıtım',
        outcomes: [
          'Kalıtım ile ilgili temel kavramları açıklar.',
          'Kalıtım konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Ekosistem Ekolojisi',
        outcomes: [
          'Ekosistem Ekolojisi ile ilgili temel kavramları açıklar.',
          'Ekosistem Ekolojisi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Güncel Çevre Sorunları',
        outcomes: [
          'Güncel Çevre Sorunları ile ilgili temel kavramları açıklar.',
          'Güncel Çevre Sorunları konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── AYT Biyoloji ──
  final aytBio = await ensureSubject('AYT Biyoloji', 41, folder: 'BİYOLOJİ');
  if (await unitCount(aytBio) == 0) {
    await addUnitWithTopics(
      subjectId: aytBio,
      unitOrder: 0,
      unitName: 'İnsan Fizyolojisi',
      topics: [
      (
        name: 'Sinir Sistemi',
        outcomes: [
          'Sinir Sistemi ile ilgili temel kavramları açıklar.',
          'Sinir Sistemi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Endokrin Sistem',
        outcomes: [
          'Endokrin Sistem ile ilgili temel kavramları açıklar.',
          'Endokrin Sistem konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Duyu Organları',
        outcomes: [
          'Duyu Organları ile ilgili temel kavramları açıklar.',
          'Duyu Organları konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Destek ve Hareket Sistemi',
        outcomes: [
          'Destek ve Hareket Sistemi ile ilgili temel kavramları açıklar.',
          'Destek ve Hareket Sistemi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Sindirim Sistemi',
        outcomes: [
          'Sindirim Sistemi ile ilgili temel kavramları açıklar.',
          'Sindirim Sistemi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Dolaşım ve Bağışıklık Sistemi',
        outcomes: [
          'Dolaşım ve Bağışıklık Sistemi ile ilgili temel kavramları açıklar.',
          'Dolaşım ve Bağışıklık Sistemi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Solunum Sistemi',
        outcomes: [
          'Solunum Sistemi ile ilgili temel kavramları açıklar.',
          'Solunum Sistemi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Üriner Sistem',
        outcomes: [
          'Üriner Sistem ile ilgili temel kavramları açıklar.',
          'Üriner Sistem konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Üreme Sistemi ve Embriyonik Gelişim',
        outcomes: [
          'Üreme Sistemi ve Embriyonik Gelişim ile ilgili temel kavramları açıklar.',
          'Üreme Sistemi ve Embriyonik Gelişim konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: aytBio,
      unitOrder: 1,
      unitName: 'Enerji, Genetik ve Bitkiler',
      topics: [
      (
        name: 'Nükleik Asitler',
        outcomes: [
          'Nükleik Asitler ile ilgili temel kavramları açıklar.',
          'Nükleik Asitler konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Genetik Şifre ve Protein Sintezi',
        outcomes: [
          'Genetik Şifre ve Protein Sintezi ile ilgili temel kavramları açıklar.',
          'Genetik Şifre ve Protein Sintezi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Canlılık ve Enerji',
        outcomes: [
          'Canlılık ve Enerji ile ilgili temel kavramları açıklar.',
          'Canlılık ve Enerji konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Fotosentez ve Kemosentez',
        outcomes: [
          'Fotosentez ve Kemosentez ile ilgili temel kavramları açıklar.',
          'Fotosentez ve Kemosentez konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Hücresel Solunum',
        outcomes: [
          'Hücresel Solunum ile ilgili temel kavramları açıklar.',
          'Hücresel Solunum konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Bitki Biyolojisi',
        outcomes: [
          'Bitki Biyolojisi ile ilgili temel kavramları açıklar.',
          'Bitki Biyolojisi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Komünite ve Popülasyon Ekolojisi',
        outcomes: [
          'Komünite ve Popülasyon Ekolojisi ile ilgili temel kavramları açıklar.',
          'Komünite ve Popülasyon Ekolojisi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Canlılar ve Çevre',
        outcomes: [
          'Canlılar ve Çevre ile ilgili temel kavramları açıklar.',
          'Canlılar ve Çevre konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── 9. Sınıf Biyoloji ──
  final m9Bio = await ensureSubject('9. Sınıf Biyoloji', 42, folder: 'BİYOLOJİ');
  if (await unitCount(m9Bio) == 0) {
    await addUnitWithTopics(
      subjectId: m9Bio,
      unitOrder: 0,
      unitName: 'Yaşam Bilimi Biyoloji',
      topics: [
      (
        name: 'Biyoloji ve Canlıların Ortak Özellikleri',
        outcomes: [
          'Biyoloji ve Canlıların Ortak Özellikleri ile ilgili temel kavramları açıklar.',
          'Biyoloji ve Canlıların Ortak Özellikleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Canlıların Yapısında Bulunan Temel Bileşikler',
        outcomes: [
          'Canlıların Yapısında Bulunan Temel Bileşikler ile ilgili temel kavramları açıklar.',
          'Canlıların Yapısında Bulunan Temel Bileşikler konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9Bio,
      unitOrder: 1,
      unitName: 'Hücre',
      topics: [
      (
        name: 'Hücre Teorisi ve Hücre Tipleri',
        outcomes: [
          'Hücre Teorisi ve Hücre Tipleri ile ilgili temel kavramları açıklar.',
          'Hücre Teorisi ve Hücre Tipleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Organeller',
        outcomes: [
          'Organeller ile ilgili temel kavramları açıklar.',
          'Organeller konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Madde Geçişleri',
        outcomes: [
          'Madde Geçişleri ile ilgili temel kavramları açıklar.',
          'Madde Geçişleri konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9Bio,
      unitOrder: 2,
      unitName: 'Canlılar Dünyası',
      topics: [
      (
        name: 'Canlıların Çeşitliliği ve Sınıflandırılması',
        outcomes: [
          'Canlıların Çeşitliliği ve Sınıflandırılması ile ilgili temel kavramları açıklar.',
          'Canlıların Çeşitliliği ve Sınıflandırılması konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Bakteriler, Arkeler, Protistalar',
        outcomes: [
          'Bakteriler, Arkeler, Protistalar ile ilgili temel kavramları açıklar.',
          'Bakteriler, Arkeler, Protistalar konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Bitkiler, Mantarlar ve Hayvanlar',
        outcomes: [
          'Bitkiler, Mantarlar ve Hayvanlar ile ilgili temel kavramları açıklar.',
          'Bitkiler, Mantarlar ve Hayvanlar konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── 10. Sınıf Biyoloji ──
  final m10Bio = await ensureSubject('10. Sınıf Biyoloji', 43, folder: 'BİYOLOJİ');
  if (await unitCount(m10Bio) == 0) {
    await addUnitWithTopics(
      subjectId: m10Bio,
      unitOrder: 0,
      unitName: 'Hücre Bölünmeleri',
      topics: [
      (
        name: 'Mitoz ve Eşeysiz Üreme',
        outcomes: [
          'Mitoz ve Eşeysiz Üreme ile ilgili temel kavramları açıklar.',
          'Mitoz ve Eşeysiz Üreme konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Mayoz ve Eşeyli Üreme',
        outcomes: [
          'Mayoz ve Eşeyli Üreme ile ilgili temel kavramları açıklar.',
          'Mayoz ve Eşeyli Üreme konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m10Bio,
      unitOrder: 1,
      unitName: 'Kalıtımın Genel İlkeleri',
      topics: [
      (
        name: 'Mendel Genetiği',
        outcomes: [
          'Mendel Genetiği ile ilgili temel kavramları açıklar.',
          'Mendel Genetiği konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Modern Genetik Uygulamaları',
        outcomes: [
          'Modern Genetik Uygulamaları ile ilgili temel kavramları açıklar.',
          'Modern Genetik Uygulamaları konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m10Bio,
      unitOrder: 2,
      unitName: 'Ekosistem Ekolojisi ve Çevre',
      topics: [
      (
        name: 'Ekosistem Ekolojisi',
        outcomes: [
          'Ekosistem Ekolojisi ile ilgili temel kavramları açıklar.',
          'Ekosistem Ekolojisi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Güncel Çevre Sorunları',
        outcomes: [
          'Güncel Çevre Sorunları ile ilgili temel kavramları açıklar.',
          'Güncel Çevre Sorunları konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Doğal Kaynaklar ve Biyolojik Çeşitlilik',
        outcomes: [
          'Doğal Kaynaklar ve Biyolojik Çeşitlilik ile ilgili temel kavramları açıklar.',
          'Doğal Kaynaklar ve Biyolojik Çeşitlilik konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── 11. Sınıf Biyoloji ──
  final m11Bio = await ensureSubject('11. Sınıf Biyoloji', 44, folder: 'BİYOLOJİ');
  if (await unitCount(m11Bio) == 0) {
    await addUnitWithTopics(
      subjectId: m11Bio,
      unitOrder: 0,
      unitName: 'İnsan Fizyolojisi',
      topics: [
      (
        name: 'Sinir Sistemi',
        outcomes: [
          'Sinir Sistemi ile ilgili temel kavramları açıklar.',
          'Sinir Sistemi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Endokrin Sistem',
        outcomes: [
          'Endokrin Sistem ile ilgili temel kavramları açıklar.',
          'Endokrin Sistem konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Duyu Organları',
        outcomes: [
          'Duyu Organları ile ilgili temel kavramları açıklar.',
          'Duyu Organları konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Destek ve Hareket',
        outcomes: [
          'Destek ve Hareket ile ilgili temel kavramları açıklar.',
          'Destek ve Hareket konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Sindirim',
        outcomes: [
          'Sindirim ile ilgili temel kavramları açıklar.',
          'Sindirim konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Dolaşım-Bağışıklık',
        outcomes: [
          'Dolaşım-Bağışıklık ile ilgili temel kavramları açıklar.',
          'Dolaşım-Bağışıklık konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Solunum',
        outcomes: [
          'Solunum ile ilgili temel kavramları açıklar.',
          'Solunum konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Üriner Sistem',
        outcomes: [
          'Üriner Sistem ile ilgili temel kavramları açıklar.',
          'Üriner Sistem konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Üreme ve Embriyonik Gelişim',
        outcomes: [
          'Üreme ve Embriyonik Gelişim ile ilgili temel kavramları açıklar.',
          'Üreme ve Embriyonik Gelişim konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m11Bio,
      unitOrder: 1,
      unitName: 'Komünite ve Popülasyon Ekolojisi',
      topics: [
      (
        name: 'Komünite Ekolojisi',
        outcomes: [
          'Komünite Ekolojisi ile ilgili temel kavramları açıklar.',
          'Komünite Ekolojisi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Popülasyon Ekolojisi',
        outcomes: [
          'Popülasyon Ekolojisi ile ilgili temel kavramları açıklar.',
          'Popülasyon Ekolojisi konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── TYT Türkçe ──
  final tytTur = await ensureSubject('TYT Türkçe', 50, folder: 'TÜRKÇE');
  if (await unitCount(tytTur) == 0) {
    await addUnitWithTopics(
      subjectId: tytTur,
      unitOrder: 0,
      unitName: 'Anlam Bilgisi',
      topics: [
      (
        name: 'Sözcükte Anlam',
        outcomes: [
          'Sözcükte Anlam ile ilgili temel kavramları açıklar.',
          'Sözcükte Anlam konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Cümlede Anlam',
        outcomes: [
          'Cümlede Anlam ile ilgili temel kavramları açıklar.',
          'Cümlede Anlam konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Paragrafta Anlam',
        outcomes: [
          'Paragrafta Anlam ile ilgili temel kavramları açıklar.',
          'Paragrafta Anlam konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Paragrafta Yapı',
        outcomes: [
          'Paragrafta Yapı ile ilgili temel kavramları açıklar.',
          'Paragrafta Yapı konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Anlatım Teknikleri ve Düşünceyi Geliştirme',
        outcomes: [
          'Anlatım Teknikleri ve Düşünceyi Geliştirme ile ilgili temel kavramları açıklar.',
          'Anlatım Teknikleri ve Düşünceyi Geliştirme konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: tytTur,
      unitOrder: 1,
      unitName: 'Dil Bilgisi',
      topics: [
      (
        name: 'Ses Bilgisi',
        outcomes: [
          'Ses Bilgisi ile ilgili temel kavramları açıklar.',
          'Ses Bilgisi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Yazım Kuralları',
        outcomes: [
          'Yazım Kuralları ile ilgili temel kavramları açıklar.',
          'Yazım Kuralları konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Noktalama İşaretleri',
        outcomes: [
          'Noktalama İşaretleri ile ilgili temel kavramları açıklar.',
          'Noktalama İşaretleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Sözcükte Yapı',
        outcomes: [
          'Sözcükte Yapı ile ilgili temel kavramları açıklar.',
          'Sözcükte Yapı konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Sözcük Türleri',
        outcomes: [
          'Sözcük Türleri ile ilgili temel kavramları açıklar.',
          'Sözcük Türleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Fiiller',
        outcomes: [
          'Fiiller ile ilgili temel kavramları açıklar.',
          'Fiiller konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Cümlenin Ögeleri',
        outcomes: [
          'Cümlenin Ögeleri ile ilgili temel kavramları açıklar.',
          'Cümlenin Ögeleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Cümle Türleri',
        outcomes: [
          'Cümle Türleri ile ilgili temel kavramları açıklar.',
          'Cümle Türleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Anlatım Bozukluğu',
        outcomes: [
          'Anlatım Bozukluğu ile ilgili temel kavramları açıklar.',
          'Anlatım Bozukluğu konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── AYT Edebiyat ──
  final aytEde = await ensureSubject('AYT Edebiyat', 51, folder: 'TÜRKÇE');
  if (await unitCount(aytEde) == 0) {
    await addUnitWithTopics(
      subjectId: aytEde,
      unitOrder: 0,
      unitName: 'Edebiyat Bilgisi',
      topics: [
      (
        name: 'Anlam Bilgisi',
        outcomes: [
          'Anlam Bilgisi ile ilgili temel kavramları açıklar.',
          'Anlam Bilgisi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Şiir Bilgisi',
        outcomes: [
          'Şiir Bilgisi ile ilgili temel kavramları açıklar.',
          'Şiir Bilgisi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Söz Sanatları',
        outcomes: [
          'Söz Sanatları ile ilgili temel kavramları açıklar.',
          'Söz Sanatları konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Edebi Akımlar',
        outcomes: [
          'Edebi Akımlar ile ilgili temel kavramları açıklar.',
          'Edebi Akımlar konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Dünya Edebiyatı',
        outcomes: [
          'Dünya Edebiyatı ile ilgili temel kavramları açıklar.',
          'Dünya Edebiyatı konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: aytEde,
      unitOrder: 1,
      unitName: 'Türk Edebiyatı Dönemleri',
      topics: [
      (
        name: 'İslamiyet Öncesi Türk Edebiyatı ve Geçiş Dönemi',
        outcomes: [
          'İslamiyet Öncesi Türk Edebiyatı ve Geçiş Dönemi ile ilgili temel kavramları açıklar.',
          'İslamiyet Öncesi Türk Edebiyatı ve Geçiş Dönemi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Halk Edebiyatı',
        outcomes: [
          'Halk Edebiyatı ile ilgili temel kavramları açıklar.',
          'Halk Edebiyatı konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Divan Edebiyatı',
        outcomes: [
          'Divan Edebiyatı ile ilgili temel kavramları açıklar.',
          'Divan Edebiyatı konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Tanzimat Edebiyatı',
        outcomes: [
          'Tanzimat Edebiyatı ile ilgili temel kavramları açıklar.',
          'Tanzimat Edebiyatı konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Servet-i Fünun Edebiyatı',
        outcomes: [
          'Servet-i Fünun Edebiyatı ile ilgili temel kavramları açıklar.',
          'Servet-i Fünun Edebiyatı konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Fecr-i Ati Edebiyatı',
        outcomes: [
          'Fecr-i Ati Edebiyatı ile ilgili temel kavramları açıklar.',
          'Fecr-i Ati Edebiyatı konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Millî Edebiyat',
        outcomes: [
          'Millî Edebiyat ile ilgili temel kavramları açıklar.',
          'Millî Edebiyat konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Cumhuriyet Dönemi Edebiyatı',
        outcomes: [
          'Cumhuriyet Dönemi Edebiyatı ile ilgili temel kavramları açıklar.',
          'Cumhuriyet Dönemi Edebiyatı konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── 9. Sınıf Türk Dili ve Edebiyatı ──
  final m9Tur = await ensureSubject('9. Sınıf Türk Dili ve Edebiyatı', 52, folder: 'TÜRKÇE');
  if (await unitCount(m9Tur) == 0) {
    await addUnitWithTopics(
      subjectId: m9Tur,
      unitOrder: 0,
      unitName: 'Giriş',
      topics: [
      (
        name: 'Edebiyatın Bilimlerle İlişkisi',
        outcomes: [
          'Edebiyatın Bilimlerle İlişkisi ile ilgili temel kavramları açıklar.',
          'Edebiyatın Bilimlerle İlişkisi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Türk Edebiyatının Dönemleri',
        outcomes: [
          'Türk Edebiyatının Dönemleri ile ilgili temel kavramları açıklar.',
          'Türk Edebiyatının Dönemleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Türkçenin Tarihî Gelişimi',
        outcomes: [
          'Türkçenin Tarihî Gelişimi ile ilgili temel kavramları açıklar.',
          'Türkçenin Tarihî Gelişimi konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9Tur,
      unitOrder: 1,
      unitName: 'Hikâye ve Şiir',
      topics: [
      (
        name: 'Hikâye',
        outcomes: [
          'Hikâye ile ilgili temel kavramları açıklar.',
          'Hikâye konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Şiir',
        outcomes: [
          'Şiir ile ilgili temel kavramları açıklar.',
          'Şiir konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9Tur,
      unitOrder: 2,
      unitName: 'Masal, Roman ve Tiyatro',
      topics: [
      (
        name: 'Masal / Fabl',
        outcomes: [
          'Masal / Fabl ile ilgili temel kavramları açıklar.',
          'Masal / Fabl konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Roman',
        outcomes: [
          'Roman ile ilgili temel kavramları açıklar.',
          'Roman konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Tiyatro',
        outcomes: [
          'Tiyatro ile ilgili temel kavramları açıklar.',
          'Tiyatro konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9Tur,
      unitOrder: 3,
      unitName: 'Öğretici Metinler',
      topics: [
      (
        name: 'Biyografi / Otobiyografi',
        outcomes: [
          'Biyografi / Otobiyografi ile ilgili temel kavramları açıklar.',
          'Biyografi / Otobiyografi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Mektup / E-posta',
        outcomes: [
          'Mektup / E-posta ile ilgili temel kavramları açıklar.',
          'Mektup / E-posta konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Günlük / Blog',
        outcomes: [
          'Günlük / Blog ile ilgili temel kavramları açıklar.',
          'Günlük / Blog konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── 10. Sınıf Türk Dili ve Edebiyatı ──
  final m10Tur = await ensureSubject('10. Sınıf Türk Dili ve Edebiyatı', 53, folder: 'TÜRKÇE');
  if (await unitCount(m10Tur) == 0) {
    await addUnitWithTopics(
      subjectId: m10Tur,
      unitOrder: 0,
      unitName: 'Giriş',
      topics: [
      (
        name: 'Edebiyat-Tarih-Din İlişkisi',
        outcomes: [
          'Edebiyat-Tarih-Din İlişkisi ile ilgili temel kavramları açıklar.',
          'Edebiyat-Tarih-Din İlişkisi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Türk Edebiyatının Dönemleri',
        outcomes: [
          'Türk Edebiyatının Dönemleri ile ilgili temel kavramları açıklar.',
          'Türk Edebiyatının Dönemleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Türkçenin Tarihî Gelişimi',
        outcomes: [
          'Türkçenin Tarihî Gelişimi ile ilgili temel kavramları açıklar.',
          'Türkçenin Tarihî Gelişimi konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m10Tur,
      unitOrder: 1,
      unitName: 'Anlatmaya Bağlı Türler',
      topics: [
      (
        name: 'Hikâye',
        outcomes: [
          'Hikâye ile ilgili temel kavramları açıklar.',
          'Hikâye konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Şiir',
        outcomes: [
          'Şiir ile ilgili temel kavramları açıklar.',
          'Şiir konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Destan / Efsane',
        outcomes: [
          'Destan / Efsane ile ilgili temel kavramları açıklar.',
          'Destan / Efsane konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Roman',
        outcomes: [
          'Roman ile ilgili temel kavramları açıklar.',
          'Roman konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m10Tur,
      unitOrder: 2,
      unitName: 'Göstermeye Bağlı ve Öğretici Türler',
      topics: [
      (
        name: 'Tiyatro',
        outcomes: [
          'Tiyatro ile ilgili temel kavramları açıklar.',
          'Tiyatro konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Anı',
        outcomes: [
          'Anı ile ilgili temel kavramları açıklar.',
          'Anı konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Haber Metni',
        outcomes: [
          'Haber Metni ile ilgili temel kavramları açıklar.',
          'Haber Metni konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Gezi Yazısı',
        outcomes: [
          'Gezi Yazısı ile ilgili temel kavramları açıklar.',
          'Gezi Yazısı konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── 11. Sınıf Türk Dili ve Edebiyatı ──
  final m11Tur = await ensureSubject('11. Sınıf Türk Dili ve Edebiyatı', 54, folder: 'TÜRKÇE');
  if (await unitCount(m11Tur) == 0) {
    await addUnitWithTopics(
      subjectId: m11Tur,
      unitOrder: 0,
      unitName: 'Giriş',
      topics: [
      (
        name: 'Edebiyat Bilgileri',
        outcomes: [
          'Edebiyat Bilgileri ile ilgili temel kavramları açıklar.',
          'Edebiyat Bilgileri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Şiir Dilinin Özellikleri',
        outcomes: [
          'Şiir Dilinin Özellikleri ile ilgili temel kavramları açıklar.',
          'Şiir Dilinin Özellikleri konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m11Tur,
      unitOrder: 1,
      unitName: 'Metin Türleri',
      topics: [
      (
        name: 'Hikâye',
        outcomes: [
          'Hikâye ile ilgili temel kavramları açıklar.',
          'Hikâye konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Şiir',
        outcomes: [
          'Şiir ile ilgili temel kavramları açıklar.',
          'Şiir konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Makale',
        outcomes: [
          'Makale ile ilgili temel kavramları açıklar.',
          'Makale konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Sohbet ve Fıkra',
        outcomes: [
          'Sohbet ve Fıkra ile ilgili temel kavramları açıklar.',
          'Sohbet ve Fıkra konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Roman',
        outcomes: [
          'Roman ile ilgili temel kavramları açıklar.',
          'Roman konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m11Tur,
      unitOrder: 2,
      unitName: 'Tiyatro ve Eleştiri',
      topics: [
      (
        name: 'Tiyatro',
        outcomes: [
          'Tiyatro ile ilgili temel kavramları açıklar.',
          'Tiyatro konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Eleştiri',
        outcomes: [
          'Eleştiri ile ilgili temel kavramları açıklar.',
          'Eleştiri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Mülakat / Röportaj',
        outcomes: [
          'Mülakat / Röportaj ile ilgili temel kavramları açıklar.',
          'Mülakat / Röportaj konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── TYT Tarih ──
  final tytTar = await ensureSubject('TYT Tarih', 60, folder: 'TARİH');
  if (await unitCount(tytTar) == 0) {
    await addUnitWithTopics(
      subjectId: tytTar,
      unitOrder: 0,
      unitName: 'İlkçağ ve Türk-İslam Tarihi',
      topics: [
      (
        name: 'Tarih ve Zaman',
        outcomes: [
          'Tarih ve Zaman ile ilgili temel kavramları açıklar.',
          'Tarih ve Zaman konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'İnsanlığın İlk Dönemleri',
        outcomes: [
          'İnsanlığın İlk Dönemleri ile ilgili temel kavramları açıklar.',
          'İnsanlığın İlk Dönemleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'İlk ve Orta Çağlarda Türk Dünyası',
        outcomes: [
          'İlk ve Orta Çağlarda Türk Dünyası ile ilgili temel kavramları açıklar.',
          'İlk ve Orta Çağlarda Türk Dünyası konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'İslam Medeniyetinin Doğuşu',
        outcomes: [
          'İslam Medeniyetinin Doğuşu ile ilgili temel kavramları açıklar.',
          'İslam Medeniyetinin Doğuşu konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Türklerin İslamiyet’i Kabulü ve İlk Türk-İslam Devletleri',
        outcomes: [
          'Türklerin İslamiyet’i Kabulü ve İlk Türk-İslam Devletleri ile ilgili temel kavramları açıklar.',
          'Türklerin İslamiyet’i Kabulü ve İlk Türk-İslam Devletleri konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: tytTar,
      unitOrder: 1,
      unitName: 'Osmanlı’dan Millî Mücadele’ye',
      topics: [
      (
        name: 'Selçuklu ve Beylikler Dönemi',
        outcomes: [
          'Selçuklu ve Beylikler Dönemi ile ilgili temel kavramları açıklar.',
          'Selçuklu ve Beylikler Dönemi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Osmanlı Devleti’nin Kuruluşu ve Yükselişi',
        outcomes: [
          'Osmanlı Devleti’nin Kuruluşu ve Yükselişi ile ilgili temel kavramları açıklar.',
          'Osmanlı Devleti’nin Kuruluşu ve Yükselişi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Osmanlı’da Gerileme ve Reformlar',
        outcomes: [
          'Osmanlı’da Gerileme ve Reformlar ile ilgili temel kavramları açıklar.',
          'Osmanlı’da Gerileme ve Reformlar konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'XX. Yüzyıl Başlarında Osmanlı ve Dünya',
        outcomes: [
          'XX. Yüzyıl Başlarında Osmanlı ve Dünya ile ilgili temel kavramları açıklar.',
          'XX. Yüzyıl Başlarında Osmanlı ve Dünya konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Millî Mücadele',
        outcomes: [
          'Millî Mücadele ile ilgili temel kavramları açıklar.',
          'Millî Mücadele konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── AYT Tarih ──
  final aytTar = await ensureSubject('AYT Tarih', 61, folder: 'TARİH');
  if (await unitCount(aytTar) == 0) {
    await addUnitWithTopics(
      subjectId: aytTar,
      unitOrder: 0,
      unitName: 'Başlangıçtan Osmanlı Klasik Çağına',
      topics: [
      (
        name: 'Tarih ve Zaman',
        outcomes: [
          'Tarih ve Zaman ile ilgili temel kavramları açıklar.',
          'Tarih ve Zaman konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'İnsanlığın İlk Dönemleri',
        outcomes: [
          'İnsanlığın İlk Dönemleri ile ilgili temel kavramları açıklar.',
          'İnsanlığın İlk Dönemleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'İlk ve Orta Çağlarda Türk Dünyası',
        outcomes: [
          'İlk ve Orta Çağlarda Türk Dünyası ile ilgili temel kavramları açıklar.',
          'İlk ve Orta Çağlarda Türk Dünyası konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'İslam Medeniyetinin Doğuşu ve İlk İslam Devletleri',
        outcomes: [
          'İslam Medeniyetinin Doğuşu ve İlk İslam Devletleri ile ilgili temel kavramları açıklar.',
          'İslam Medeniyetinin Doğuşu ve İlk İslam Devletleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Türklerin İslamiyet’i Kabulü ve İlk Türk İslam Devletleri',
        outcomes: [
          'Türklerin İslamiyet’i Kabulü ve İlk Türk İslam Devletleri ile ilgili temel kavramları açıklar.',
          'Türklerin İslamiyet’i Kabulü ve İlk Türk İslam Devletleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Yerleşme ve Devletleşme Sürecinde Selçuklu Türkiyesi',
        outcomes: [
          'Yerleşme ve Devletleşme Sürecinde Selçuklu Türkiyesi ile ilgili temel kavramları açıklar.',
          'Yerleşme ve Devletleşme Sürecinde Selçuklu Türkiyesi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Beylikten Devlete Osmanlı Siyaseti',
        outcomes: [
          'Beylikten Devlete Osmanlı Siyaseti ile ilgili temel kavramları açıklar.',
          'Beylikten Devlete Osmanlı Siyaseti konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Devletleşme Sürecinde Savaşçılar ve Askerler',
        outcomes: [
          'Devletleşme Sürecinde Savaşçılar ve Askerler ile ilgili temel kavramları açıklar.',
          'Devletleşme Sürecinde Savaşçılar ve Askerler konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Beylikten Devlete Osmanlı Medeniyeti',
        outcomes: [
          'Beylikten Devlete Osmanlı Medeniyeti ile ilgili temel kavramları açıklar.',
          'Beylikten Devlete Osmanlı Medeniyeti konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Dünya Gücü Osmanlı',
        outcomes: [
          'Dünya Gücü Osmanlı ile ilgili temel kavramları açıklar.',
          'Dünya Gücü Osmanlı konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Sultan ve Osmanlı Merkez Teşkilatı',
        outcomes: [
          'Sultan ve Osmanlı Merkez Teşkilatı ile ilgili temel kavramları açıklar.',
          'Sultan ve Osmanlı Merkez Teşkilatı konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Klasik Çağda Osmanlı Toplum Düzeni',
        outcomes: [
          'Klasik Çağda Osmanlı Toplum Düzeni ile ilgili temel kavramları açıklar.',
          'Klasik Çağda Osmanlı Toplum Düzeni konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: aytTar,
      unitOrder: 1,
      unitName: 'Yeniçağ’dan Günümüze',
      topics: [
      (
        name: 'Değişen Dünya Dengeleri Karşısında Osmanlı Siyaseti',
        outcomes: [
          'Değişen Dünya Dengeleri Karşısında Osmanlı Siyaseti ile ilgili temel kavramları açıklar.',
          'Değişen Dünya Dengeleri Karşısında Osmanlı Siyaseti konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Değişim Çağında Avrupa ve Osmanlı',
        outcomes: [
          'Değişim Çağında Avrupa ve Osmanlı ile ilgili temel kavramları açıklar.',
          'Değişim Çağında Avrupa ve Osmanlı konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Uluslararası İlişkilerde Denge Stratejisi (1774-1914)',
        outcomes: [
          'Uluslararası İlişkilerde Denge Stratejisi (1774-1914) ile ilgili temel kavramları açıklar.',
          'Uluslararası İlişkilerde Denge Stratejisi (1774-1914) konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Devrimler Çağında Değişen Devlet-Toplum İlişkileri',
        outcomes: [
          'Devrimler Çağında Değişen Devlet-Toplum İlişkileri ile ilgili temel kavramları açıklar.',
          'Devrimler Çağında Değişen Devlet-Toplum İlişkileri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'XIX. ve XX. Yüzyılda Değişen Sosyo-Ekonomik Hayat',
        outcomes: [
          'XIX. ve XX. Yüzyılda Değişen Sosyo-Ekonomik Hayat ile ilgili temel kavramları açıklar.',
          'XIX. ve XX. Yüzyılda Değişen Sosyo-Ekonomik Hayat konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'XX. Yüzyıl Başlarında Osmanlı Devleti ve Dünya',
        outcomes: [
          'XX. Yüzyıl Başlarında Osmanlı Devleti ve Dünya ile ilgili temel kavramları açıklar.',
          'XX. Yüzyıl Başlarında Osmanlı Devleti ve Dünya konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Millî Mücadele',
        outcomes: [
          'Millî Mücadele ile ilgili temel kavramları açıklar.',
          'Millî Mücadele konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Atatürkçülük ve Türk İnkılabı',
        outcomes: [
          'Atatürkçülük ve Türk İnkılabı ile ilgili temel kavramları açıklar.',
          'Atatürkçülük ve Türk İnkılabı konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'İki Savaş Arasındaki Dönemde Türkiye ve Dünya',
        outcomes: [
          'İki Savaş Arasındaki Dönemde Türkiye ve Dünya ile ilgili temel kavramları açıklar.',
          'İki Savaş Arasındaki Dönemde Türkiye ve Dünya konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'II. Dünya Savaşı Sürecinde Türkiye ve Dünya',
        outcomes: [
          'II. Dünya Savaşı Sürecinde Türkiye ve Dünya ile ilgili temel kavramları açıklar.',
          'II. Dünya Savaşı Sürecinde Türkiye ve Dünya konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'II. Dünya Savaşı Sonrasında Türkiye ve Dünya',
        outcomes: [
          'II. Dünya Savaşı Sonrasında Türkiye ve Dünya ile ilgili temel kavramları açıklar.',
          'II. Dünya Savaşı Sonrasında Türkiye ve Dünya konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Toplumsal Devrim Çağında Dünya ve Türkiye',
        outcomes: [
          'Toplumsal Devrim Çağında Dünya ve Türkiye ile ilgili temel kavramları açıklar.',
          'Toplumsal Devrim Çağında Dünya ve Türkiye konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'XXI. Yüzyılın Eşiğinde Türkiye ve Dünya',
        outcomes: [
          'XXI. Yüzyılın Eşiğinde Türkiye ve Dünya ile ilgili temel kavramları açıklar.',
          'XXI. Yüzyılın Eşiğinde Türkiye ve Dünya konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── 9. Sınıf Tarih ──
  final m9Tar = await ensureSubject('9. Sınıf Tarih', 62, folder: 'TARİH');
  if (await unitCount(m9Tar) == 0) {
    await addUnitWithTopics(
      subjectId: m9Tar,
      unitOrder: 0,
      unitName: 'Tarih ve Zaman',
      topics: [
      (
        name: 'Tarih Bilimi',
        outcomes: [
          'Tarih Bilimi ile ilgili temel kavramları açıklar.',
          'Tarih Bilimi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Zaman ve Takvim',
        outcomes: [
          'Zaman ve Takvim ile ilgili temel kavramları açıklar.',
          'Zaman ve Takvim konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9Tar,
      unitOrder: 1,
      unitName: 'İnsanlığın İlk Dönemleri',
      topics: [
      (
        name: 'Tarih Öncesi Çağlar',
        outcomes: [
          'Tarih Öncesi Çağlar ile ilgili temel kavramları açıklar.',
          'Tarih Öncesi Çağlar konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'İlk Çağ Uygarlıkları',
        outcomes: [
          'İlk Çağ Uygarlıkları ile ilgili temel kavramları açıklar.',
          'İlk Çağ Uygarlıkları konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9Tar,
      unitOrder: 2,
      unitName: 'Orta Çağ’da Dünya',
      topics: [
      (
        name: 'Orta Çağ Avrupa’sı',
        outcomes: [
          'Orta Çağ Avrupa’sı ile ilgili temel kavramları açıklar.',
          'Orta Çağ Avrupa’sı konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'İslam Medeniyetinin Doğuşu',
        outcomes: [
          'İslam Medeniyetinin Doğuşu ile ilgili temel kavramları açıklar.',
          'İslam Medeniyetinin Doğuşu konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9Tar,
      unitOrder: 3,
      unitName: 'İlk ve Orta Çağlarda Türk Dünyası',
      topics: [
      (
        name: 'Orta Asya Türk Devletleri',
        outcomes: [
          'Orta Asya Türk Devletleri ile ilgili temel kavramları açıklar.',
          'Orta Asya Türk Devletleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Türk Kültür ve Medeniyeti',
        outcomes: [
          'Türk Kültür ve Medeniyeti ile ilgili temel kavramları açıklar.',
          'Türk Kültür ve Medeniyeti konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9Tar,
      unitOrder: 4,
      unitName: 'Türk-İslam Devletleri',
      topics: [
      (
        name: 'Türklerin İslamiyet’i Kabulü',
        outcomes: [
          'Türklerin İslamiyet’i Kabulü ile ilgili temel kavramları açıklar.',
          'Türklerin İslamiyet’i Kabulü konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'İlk Türk-İslam Devletleri',
        outcomes: [
          'İlk Türk-İslam Devletleri ile ilgili temel kavramları açıklar.',
          'İlk Türk-İslam Devletleri konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── 10. Sınıf Tarih ──
  final m10Tar = await ensureSubject('10. Sınıf Tarih', 63, folder: 'TARİH');
  if (await unitCount(m10Tar) == 0) {
    await addUnitWithTopics(
      subjectId: m10Tar,
      unitOrder: 0,
      unitName: 'Selçuklu Türkiyesi',
      topics: [
      (
        name: 'Yerleşme ve Devletleşme',
        outcomes: [
          'Yerleşme ve Devletleşme ile ilgili temel kavramları açıklar.',
          'Yerleşme ve Devletleşme konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Türkiye Selçuklu Devleti',
        outcomes: [
          'Türkiye Selçuklu Devleti ile ilgili temel kavramları açıklar.',
          'Türkiye Selçuklu Devleti konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m10Tar,
      unitOrder: 1,
      unitName: 'Beylikten Devlete Osmanlı',
      topics: [
      (
        name: 'Osmanlı Siyaseti (1302-1453)',
        outcomes: [
          'Osmanlı Siyaseti (1302-1453) ile ilgili temel kavramları açıklar.',
          'Osmanlı Siyaseti (1302-1453) konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Osmanlı Medeniyeti',
        outcomes: [
          'Osmanlı Medeniyeti ile ilgili temel kavramları açıklar.',
          'Osmanlı Medeniyeti konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Savaşçılar ve Askerler',
        outcomes: [
          'Savaşçılar ve Askerler ile ilgili temel kavramları açıklar.',
          'Savaşçılar ve Askerler konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m10Tar,
      unitOrder: 2,
      unitName: 'Dünya Gücü Osmanlı',
      topics: [
      (
        name: 'Dünya Gücü Osmanlı (1453-1595)',
        outcomes: [
          'Dünya Gücü Osmanlı (1453-1595) ile ilgili temel kavramları açıklar.',
          'Dünya Gücü Osmanlı (1453-1595) konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Sultan ve Merkez Teşkilatı',
        outcomes: [
          'Sultan ve Merkez Teşkilatı ile ilgili temel kavramları açıklar.',
          'Sultan ve Merkez Teşkilatı konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Klasik Çağda Osmanlı Toplum Düzeni',
        outcomes: [
          'Klasik Çağda Osmanlı Toplum Düzeni ile ilgili temel kavramları açıklar.',
          'Klasik Çağda Osmanlı Toplum Düzeni konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── 11. Sınıf Tarih ──
  final m11Tar = await ensureSubject('11. Sınıf Tarih', 64, folder: 'TARİH');
  if (await unitCount(m11Tar) == 0) {
    await addUnitWithTopics(
      subjectId: m11Tar,
      unitOrder: 0,
      unitName: 'Osmanlı’da Değişim',
      topics: [
      (
        name: 'Değişen Dünya Dengeleri (1595-1774)',
        outcomes: [
          'Değişen Dünya Dengeleri (1595-1774) ile ilgili temel kavramları açıklar.',
          'Değişen Dünya Dengeleri (1595-1774) konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Değişim Çağında Avrupa ve Osmanlı',
        outcomes: [
          'Değişim Çağında Avrupa ve Osmanlı ile ilgili temel kavramları açıklar.',
          'Değişim Çağında Avrupa ve Osmanlı konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Denge Stratejisi (1774-1914)',
        outcomes: [
          'Denge Stratejisi (1774-1914) ile ilgili temel kavramları açıklar.',
          'Denge Stratejisi (1774-1914) konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m11Tar,
      unitOrder: 1,
      unitName: 'Devrimler ve Toplum',
      topics: [
      (
        name: 'Devrimler Çağında Devlet-Toplum',
        outcomes: [
          'Devrimler Çağında Devlet-Toplum ile ilgili temel kavramları açıklar.',
          'Devrimler Çağında Devlet-Toplum konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'XIX-XX. Yüzyılda Sosyo-Ekonomik Hayat',
        outcomes: [
          'XIX-XX. Yüzyılda Sosyo-Ekonomik Hayat ile ilgili temel kavramları açıklar.',
          'XIX-XX. Yüzyılda Sosyo-Ekonomik Hayat konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── TYT Coğrafya ──
  final tytCog = await ensureSubject('TYT Coğrafya', 70, folder: 'COĞRAFYA');
  if (await unitCount(tytCog) == 0) {
    await addUnitWithTopics(
      subjectId: tytCog,
      unitOrder: 0,
      unitName: 'Doğal Sistemler',
      topics: [
      (
        name: 'Doğa ve İnsan',
        outcomes: [
          'Doğa ve İnsan ile ilgili temel kavramları açıklar.',
          'Doğa ve İnsan konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Dünya’nın Şekli ve Hareketleri',
        outcomes: [
          'Dünya’nın Şekli ve Hareketleri ile ilgili temel kavramları açıklar.',
          'Dünya’nın Şekli ve Hareketleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Coğrafi Konum',
        outcomes: [
          'Coğrafi Konum ile ilgili temel kavramları açıklar.',
          'Coğrafi Konum konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Harita Bilgisi',
        outcomes: [
          'Harita Bilgisi ile ilgili temel kavramları açıklar.',
          'Harita Bilgisi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'İklim Bilgisi',
        outcomes: [
          'İklim Bilgisi ile ilgili temel kavramları açıklar.',
          'İklim Bilgisi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Dünya’nın Tektonik Oluşumu',
        outcomes: [
          'Dünya’nın Tektonik Oluşumu ile ilgili temel kavramları açıklar.',
          'Dünya’nın Tektonik Oluşumu konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Jeolojik Zamanlar',
        outcomes: [
          'Jeolojik Zamanlar ile ilgili temel kavramları açıklar.',
          'Jeolojik Zamanlar konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'İç ve Dış Kuvvetler',
        outcomes: [
          'İç ve Dış Kuvvetler ile ilgili temel kavramları açıklar.',
          'İç ve Dış Kuvvetler konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Kayaçlar',
        outcomes: [
          'Kayaçlar ile ilgili temel kavramları açıklar.',
          'Kayaçlar konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Türkiye’nin Yer Şekilleri',
        outcomes: [
          'Türkiye’nin Yer Şekilleri ile ilgili temel kavramları açıklar.',
          'Türkiye’nin Yer Şekilleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Su, Toprak ve Bitkiler',
        outcomes: [
          'Su, Toprak ve Bitkiler ile ilgili temel kavramları açıklar.',
          'Su, Toprak ve Bitkiler konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: tytCog,
      unitOrder: 1,
      unitName: 'Beşerî ve Ekonomik Coğrafya',
      topics: [
      (
        name: 'Nüfus',
        outcomes: [
          'Nüfus ile ilgili temel kavramları açıklar.',
          'Nüfus konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Türkiye’de Nüfus',
        outcomes: [
          'Türkiye’de Nüfus ile ilgili temel kavramları açıklar.',
          'Türkiye’de Nüfus konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Göç',
        outcomes: [
          'Göç ile ilgili temel kavramları açıklar.',
          'Göç konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Ekonomik Faaliyetler',
        outcomes: [
          'Ekonomik Faaliyetler ile ilgili temel kavramları açıklar.',
          'Ekonomik Faaliyetler konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Bölgeler',
        outcomes: [
          'Bölgeler ile ilgili temel kavramları açıklar.',
          'Bölgeler konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Uluslararası Ulaşım Hatları',
        outcomes: [
          'Uluslararası Ulaşım Hatları ile ilgili temel kavramları açıklar.',
          'Uluslararası Ulaşım Hatları konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Çevre ve Toplum',
        outcomes: [
          'Çevre ve Toplum ile ilgili temel kavramları açıklar.',
          'Çevre ve Toplum konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Doğal Afetler',
        outcomes: [
          'Doğal Afetler ile ilgili temel kavramları açıklar.',
          'Doğal Afetler konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── AYT Coğrafya ──
  final aytCog = await ensureSubject('AYT Coğrafya', 71, folder: 'COĞRAFYA');
  if (await unitCount(aytCog) == 0) {
    await addUnitWithTopics(
      subjectId: aytCog,
      unitOrder: 0,
      unitName: 'Ekosistem ve Nüfus',
      topics: [
      (
        name: 'Ekosistemlerin Özellikleri ve İşleyişi',
        outcomes: [
          'Ekosistemlerin Özellikleri ve İşleyişi ile ilgili temel kavramları açıklar.',
          'Ekosistemlerin Özellikleri ve İşleyişi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Biyoçeşitlilik ve Madde Döngüleri',
        outcomes: [
          'Biyoçeşitlilik ve Madde Döngüleri ile ilgili temel kavramları açıklar.',
          'Biyoçeşitlilik ve Madde Döngüleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Ekstrem Doğa Olayları ve İklim Değişimi',
        outcomes: [
          'Ekstrem Doğa Olayları ve İklim Değişimi ile ilgili temel kavramları açıklar.',
          'Ekstrem Doğa Olayları ve İklim Değişimi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Nüfus Politikaları',
        outcomes: [
          'Nüfus Politikaları ile ilgili temel kavramları açıklar.',
          'Nüfus Politikaları konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Yerleşmelerin Özellikleri',
        outcomes: [
          'Yerleşmelerin Özellikleri ile ilgili temel kavramları açıklar.',
          'Yerleşmelerin Özellikleri konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: aytCog,
      unitOrder: 1,
      unitName: 'Ekonomi, Bölgeler ve Çevre',
      topics: [
      (
        name: 'Ekonomik Faaliyetler ve Doğal Kaynaklar',
        outcomes: [
          'Ekonomik Faaliyetler ve Doğal Kaynaklar ile ilgili temel kavramları açıklar.',
          'Ekonomik Faaliyetler ve Doğal Kaynaklar konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Türkiye’de Ekonomi',
        outcomes: [
          'Türkiye’de Ekonomi ile ilgili temel kavramları açıklar.',
          'Türkiye’de Ekonomi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Şehir ve Ekonomi',
        outcomes: [
          'Şehir ve Ekonomi ile ilgili temel kavramları açıklar.',
          'Şehir ve Ekonomi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Türkiye’nin İşlevsel Bölgeleri ve Kalkınma Projeleri',
        outcomes: [
          'Türkiye’nin İşlevsel Bölgeleri ve Kalkınma Projeleri ile ilgili temel kavramları açıklar.',
          'Türkiye’nin İşlevsel Bölgeleri ve Kalkınma Projeleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Hizmet Sektörü ve Küresel Ticaret',
        outcomes: [
          'Hizmet Sektörü ve Küresel Ticaret ile ilgili temel kavramları açıklar.',
          'Hizmet Sektörü ve Küresel Ticaret konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Türkiye Turizmi',
        outcomes: [
          'Türkiye Turizmi ile ilgili temel kavramları açıklar.',
          'Türkiye Turizmi konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Kültür Bölgeleri',
        outcomes: [
          'Kültür Bölgeleri ile ilgili temel kavramları açıklar.',
          'Kültür Bölgeleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Jeopolitik Konum',
        outcomes: [
          'Jeopolitik Konum ile ilgili temel kavramları açıklar.',
          'Jeopolitik Konum konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Ülkeler Arası Etkileşim',
        outcomes: [
          'Ülkeler Arası Etkileşim ile ilgili temel kavramları açıklar.',
          'Ülkeler Arası Etkileşim konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Çevre Sorunları ve Sürdürülebilirlik',
        outcomes: [
          'Çevre Sorunları ve Sürdürülebilirlik ile ilgili temel kavramları açıklar.',
          'Çevre Sorunları ve Sürdürülebilirlik konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── 9. Sınıf Coğrafya ──
  final m9Cog = await ensureSubject('9. Sınıf Coğrafya', 72, folder: 'COĞRAFYA');
  if (await unitCount(m9Cog) == 0) {
    await addUnitWithTopics(
      subjectId: m9Cog,
      unitOrder: 0,
      unitName: 'Doğal Sistemler',
      topics: [
      (
        name: 'Doğa ve İnsan',
        outcomes: [
          'Doğa ve İnsan ile ilgili temel kavramları açıklar.',
          'Doğa ve İnsan konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Dünya’nın Şekli ve Hareketleri',
        outcomes: [
          'Dünya’nın Şekli ve Hareketleri ile ilgili temel kavramları açıklar.',
          'Dünya’nın Şekli ve Hareketleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Coğrafi Konum',
        outcomes: [
          'Coğrafi Konum ile ilgili temel kavramları açıklar.',
          'Coğrafi Konum konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Harita Bilgisi',
        outcomes: [
          'Harita Bilgisi ile ilgili temel kavramları açıklar.',
          'Harita Bilgisi konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9Cog,
      unitOrder: 1,
      unitName: 'İklim ve Yeryüzü',
      topics: [
      (
        name: 'İklim Elemanları',
        outcomes: [
          'İklim Elemanları ile ilgili temel kavramları açıklar.',
          'İklim Elemanları konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'İklim Tipleri',
        outcomes: [
          'İklim Tipleri ile ilgili temel kavramları açıklar.',
          'İklim Tipleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'İç Kuvvetler',
        outcomes: [
          'İç Kuvvetler ile ilgili temel kavramları açıklar.',
          'İç Kuvvetler konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Dış Kuvvetler',
        outcomes: [
          'Dış Kuvvetler ile ilgili temel kavramları açıklar.',
          'Dış Kuvvetler konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Kayaçlar ve Yer Şekilleri',
        outcomes: [
          'Kayaçlar ve Yer Şekilleri ile ilgili temel kavramları açıklar.',
          'Kayaçlar ve Yer Şekilleri konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m9Cog,
      unitOrder: 2,
      unitName: 'Beşerî Sistemler',
      topics: [
      (
        name: 'Nüfus Özellikleri',
        outcomes: [
          'Nüfus Özellikleri ile ilgili temel kavramları açıklar.',
          'Nüfus Özellikleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Yerleşme',
        outcomes: [
          'Yerleşme ile ilgili temel kavramları açıklar.',
          'Yerleşme konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── 10. Sınıf Coğrafya ──
  final m10Cog = await ensureSubject('10. Sınıf Coğrafya', 73, folder: 'COĞRAFYA');
  if (await unitCount(m10Cog) == 0) {
    await addUnitWithTopics(
      subjectId: m10Cog,
      unitOrder: 0,
      unitName: 'Doğal Sistemler',
      topics: [
      (
        name: 'Türkiye’nin Yeryüzü Şekilleri',
        outcomes: [
          'Türkiye’nin Yeryüzü Şekilleri ile ilgili temel kavramları açıklar.',
          'Türkiye’nin Yeryüzü Şekilleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Türkiye’de İklim',
        outcomes: [
          'Türkiye’de İklim ile ilgili temel kavramları açıklar.',
          'Türkiye’de İklim konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Türkiye’de Su, Toprak ve Bitki Örtüsü',
        outcomes: [
          'Türkiye’de Su, Toprak ve Bitki Örtüsü ile ilgili temel kavramları açıklar.',
          'Türkiye’de Su, Toprak ve Bitki Örtüsü konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m10Cog,
      unitOrder: 1,
      unitName: 'Beşerî Sistemler',
      topics: [
      (
        name: 'Türkiye’de Nüfus ve Yerleşme',
        outcomes: [
          'Türkiye’de Nüfus ve Yerleşme ile ilgili temel kavramları açıklar.',
          'Türkiye’de Nüfus ve Yerleşme konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Göç',
        outcomes: [
          'Göç ile ilgili temel kavramları açıklar.',
          'Göç konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m10Cog,
      unitOrder: 2,
      unitName: 'Mekânsal Bir Örgütlenme: Bölge',
      topics: [
      (
        name: 'Bölge Türleri',
        outcomes: [
          'Bölge Türleri ile ilgili temel kavramları açıklar.',
          'Bölge Türleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Türkiye’de Bölgeler',
        outcomes: [
          'Türkiye’de Bölgeler ile ilgili temel kavramları açıklar.',
          'Türkiye’de Bölgeler konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }

  // ── 11. Sınıf Coğrafya ──
  final m11Cog = await ensureSubject('11. Sınıf Coğrafya', 74, folder: 'COĞRAFYA');
  if (await unitCount(m11Cog) == 0) {
    await addUnitWithTopics(
      subjectId: m11Cog,
      unitOrder: 0,
      unitName: 'Doğal Sistemler',
      topics: [
      (
        name: 'Biyoçeşitlilik',
        outcomes: [
          'Biyoçeşitlilik ile ilgili temel kavramları açıklar.',
          'Biyoçeşitlilik konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Ekosistemler',
        outcomes: [
          'Ekosistemler ile ilgili temel kavramları açıklar.',
          'Ekosistemler konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Enerji Akışı ve Madde Döngüleri',
        outcomes: [
          'Enerji Akışı ve Madde Döngüleri ile ilgili temel kavramları açıklar.',
          'Enerji Akışı ve Madde Döngüleri konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m11Cog,
      unitOrder: 1,
      unitName: 'Beşerî Sistemler',
      topics: [
      (
        name: 'Nüfus Politikaları',
        outcomes: [
          'Nüfus Politikaları ile ilgili temel kavramları açıklar.',
          'Nüfus Politikaları konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Yerleşmelerin Özellikleri',
        outcomes: [
          'Yerleşmelerin Özellikleri ile ilgili temel kavramları açıklar.',
          'Yerleşmelerin Özellikleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Ekonomik Faaliyetler',
        outcomes: [
          'Ekonomik Faaliyetler ile ilgili temel kavramları açıklar.',
          'Ekonomik Faaliyetler konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m11Cog,
      unitOrder: 2,
      unitName: 'Küresel Ortam: Bölgeler ve Ülkeler',
      topics: [
      (
        name: 'Türkiye’nin İşlevsel Bölgeleri',
        outcomes: [
          'Türkiye’nin İşlevsel Bölgeleri ile ilgili temel kavramları açıklar.',
          'Türkiye’nin İşlevsel Bölgeleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Kalkınma Projeleri',
        outcomes: [
          'Kalkınma Projeleri ile ilgili temel kavramları açıklar.',
          'Kalkınma Projeleri konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Küresel Ticaret ve Jeopolitik',
        outcomes: [
          'Küresel Ticaret ve Jeopolitik ile ilgili temel kavramları açıklar.',
          'Küresel Ticaret ve Jeopolitik konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
    await addUnitWithTopics(
      subjectId: m11Cog,
      unitOrder: 3,
      unitName: 'Çevre ve Toplum',
      topics: [
      (
        name: 'Çevre Sorunları',
        outcomes: [
          'Çevre Sorunları ile ilgili temel kavramları açıklar.',
          'Çevre Sorunları konularında problem çözer / yorumlar.',
        ],
      ),
      (
        name: 'Doğal Kaynakların Sürdürülebilir Kullanımı',
        outcomes: [
          'Doğal Kaynakların Sürdürülebilir Kullanımı ile ilgili temel kavramları açıklar.',
          'Doğal Kaynakların Sürdürülebilir Kullanımı konularında problem çözer / yorumlar.',
        ],
      ),
      ],
    );
  }
}
