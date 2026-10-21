import '../models/event.dart';

/// Fictional campus events, in English and Turkish.
///
/// - e3 starts full (0 places left).
/// - e5 has exactly one place left.
List<Event> createSampleEvents() => [
  Event(
    id: 'e1',
    title: const LocalizedText(
      en: 'Flutter Workshop for Beginners',
      tr: 'Yeni Başlayanlar için Flutter Atölyesi',
    ),
    category: EventCategory.technology,
    dateTime: DateTime(2026, 11, 4, 14, 0),
    venue: const LocalizedText(
      en: 'Engineering Faculty, Lab B-204',
      tr: 'Mühendislik Fakültesi, Lab B-204',
    ),
    description: const LocalizedText(
      en:
          'A hands-on introduction to Flutter. Build your first mobile app '
          'step by step and learn how widgets, layouts and state work together.',
      tr:
          'Flutter\'a uygulamalı bir giriş. İlk mobil uygulamanı adım adım '
          'geliştir; widget\'ların, yerleşimlerin ve durumun birlikte nasıl '
          'çalıştığını öğren.',
    ),
    imagePath: 'assets/images/flutter_workshop.png',
    capacity: 30,
    availablePlaces: 12,
  ),
  Event(
    id: 'e2',
    title: const LocalizedText(
      en: 'AI and Society Panel',
      tr: 'Yapay Zekâ ve Toplum Paneli',
    ),
    category: EventCategory.technology,
    dateTime: DateTime(2026, 11, 12, 16, 30),
    venue: const LocalizedText(
      en: 'Central Library Conference Hall',
      tr: 'Merkez Kütüphane Konferans Salonu',
    ),
    description: const LocalizedText(
      en:
          'Faculty members and industry guests discuss how artificial '
          'intelligence is changing education, work and daily life.',
      tr:
          'Öğretim üyeleri ve sektörden konuklar, yapay zekânın eğitimi, iş '
          'hayatını ve günlük yaşamı nasıl değiştirdiğini tartışıyor.',
    ),
    imagePath: 'assets/images/ai_panel.png',
    capacity: 120,
    availablePlaces: 45,
  ),
  Event(
    id: 'e3',
    title: const LocalizedText(
      en: 'Autumn Photography Exhibition',
      tr: 'Sonbahar Fotoğraf Sergisi',
    ),
    category: EventCategory.arts,
    dateTime: DateTime(2026, 11, 7, 11, 0),
    venue: const LocalizedText(
      en: 'Fine Arts Gallery',
      tr: 'Güzel Sanatlar Galerisi',
    ),
    description: const LocalizedText(
      en:
          'Students present their best autumn photographs from around the '
          'campus. A short guided tour starts at the opening.',
      tr:
          'Öğrenciler kampüsten çektikleri en iyi sonbahar fotoğraflarını '
          'sergiliyor. Açılışta kısa bir rehberli tur var.',
    ),
    imagePath: 'assets/images/photography_exhibition.png',
    capacity: 40,
    availablePlaces: 0,
  ),
  Event(
    id: 'e4',
    title: const LocalizedText(
      en: 'Campus Choir Concert',
      tr: 'Kampüs Korosu Konseri',
    ),
    category: EventCategory.arts,
    dateTime: DateTime(2026, 11, 20, 19, 0),
    venue: const LocalizedText(
      en: 'Open-Air Amphitheatre',
      tr: 'Açık Hava Amfitiyatrosu',
    ),
    description: const LocalizedText(
      en:
          'The university choir performs a selection of classical and modern '
          'pieces. Warm clothing is recommended for the evening.',
      tr:
          'Üniversite korosu klasik ve modern eserlerden bir seçki sunuyor. '
          'Akşam için kalın giyinmeniz önerilir.',
    ),
    imagePath: 'assets/images/choir_concert.png',
    capacity: 200,
    availablePlaces: 88,
  ),
  Event(
    id: 'e5',
    title: const LocalizedText(
      en: 'Inter-Faculty Basketball Final',
      tr: 'Fakülteler Arası Basketbol Finali',
    ),
    category: EventCategory.sports,
    dateTime: DateTime(2026, 11, 15, 18, 0),
    venue: const LocalizedText(en: 'Sports Hall A', tr: 'Spor Salonu A'),
    description: const LocalizedText(
      en:
          'Engineering meets Economics in this season\'s final. Reserved '
          'seats are limited, so join early.',
      tr:
          'Bu sezonun finalinde Mühendislik ile İktisat karşı karşıya. '
          'Ayrılmış koltuk sayısı sınırlı, erken katıl.',
    ),
    imagePath: 'assets/images/basketball_final.png',
    capacity: 25,
    availablePlaces: 1,
  ),
  Event(
    id: 'e6',
    title: const LocalizedText(
      en: 'Morning Campus Run (5K)',
      tr: 'Sabah Kampüs Koşusu (5K)',
    ),
    category: EventCategory.sports,
    dateTime: DateTime(2026, 11, 28, 8, 30),
    venue: const LocalizedText(
      en: 'Main Gate Running Track',
      tr: 'Ana Kapı Koşu Parkuru',
    ),
    description: const LocalizedText(
      en:
          'A friendly 5 km run around the campus. All levels are welcome; '
          'water and snacks are provided at the finish line.',
      tr:
          'Kampüs çevresinde keyifli bir 5 km koşu. Her seviyeden katılımcıya '
          'açık; bitiş çizgisinde su ve atıştırmalık var.',
    ),
    imagePath: 'assets/images/campus_run.png',
    capacity: 60,
    availablePlaces: 33,
  ),
];
