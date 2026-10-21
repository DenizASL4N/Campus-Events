// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Kampüs Etkinlikleri';

  @override
  String get headerExploreTitle => 'Etkinlikleri keşfet';

  @override
  String get headerExploreSubtitle => 'Kampüste neler oluyor';

  @override
  String get headerFavoritesTitle => 'Favorilerin';

  @override
  String get headerFavoritesSubtitle => 'Sonraya kaydettiğin etkinlikler';

  @override
  String get headerMyEventsTitle => 'Etkinliklerin';

  @override
  String get headerMyEventsSubtitle => 'Katıldığın etkinlikler';

  @override
  String joinedCount(int count) {
    return 'Katılım: $count';
  }

  @override
  String get searchHint => 'Etkinlik adıyla ara';

  @override
  String get clearSearch => 'Aramayı temizle';

  @override
  String get categoryAll => 'Tümü';

  @override
  String get categoryTechnology => 'Teknoloji';

  @override
  String get categoryArts => 'Sanat';

  @override
  String get categorySports => 'Spor';

  @override
  String eventsFound(int count) {
    return '$count etkinlik bulundu';
  }

  @override
  String get navExplore => 'Keşfet';

  @override
  String get navFavorites => 'Favoriler';

  @override
  String get navMyEvents => 'Etkinliklerim';

  @override
  String get noFavoritesTitle => 'Henüz favori etkinliğin yok';

  @override
  String get noFavoritesMessage =>
      'Bir etkinliği buraya kaydetmek için kalbe dokun.';

  @override
  String get noJoinedTitle => 'Henüz hiçbir etkinliğe katılmadın';

  @override
  String get noJoinedMessage => 'Bir etkinliğe katıldığında burada görünecek.';

  @override
  String get noResultsTitle => 'Aramana uygun etkinlik yok';

  @override
  String get noResultsMessage =>
      'Farklı bir başlık dene ya da başka bir kategori seç.';

  @override
  String get clearFilters => 'Aramayı ve filtreleri temizle';

  @override
  String get addToFavorites => 'Favorilere ekle';

  @override
  String get removeFromFavorites => 'Favorilerden çıkar';

  @override
  String get details => 'Detaylar';

  @override
  String get eventDetails => 'Etkinlik Detayı';

  @override
  String get doubleTapToEnlarge => 'Büyütmek için çift dokun';

  @override
  String get statusJoined => 'Katıldın';

  @override
  String get statusFull => 'Dolu';

  @override
  String get statusOnePlaceLeft => 'Son 1 yer';

  @override
  String statusPlacesLeft(int count) {
    return '$count yer kaldı';
  }

  @override
  String get dateLabel => 'Tarih';

  @override
  String get timeLabel => 'Saat';

  @override
  String get venueLabel => 'Mekân';

  @override
  String availablePlaces(int available, int capacity) {
    return 'Boş yer: $available / $capacity';
  }

  @override
  String placesTaken(int taken, int capacity) {
    return '$capacity yerin $taken tanesi dolu';
  }

  @override
  String get aboutEvent => 'Etkinlik hakkında';

  @override
  String get joinEvent => 'Etkinliğe katıl';

  @override
  String get cancelParticipation => 'Katılımı iptal et';

  @override
  String get joinQuestion => 'Bu etkinliğe katılmak istiyor musun?';

  @override
  String get cancelQuestion => 'Katılımını iptal etmek istiyor musun?';

  @override
  String get no => 'Hayır';

  @override
  String get yes => 'Evet';

  @override
  String joinedMessage(String title) {
    return '\"$title\" etkinliğine katıldın.';
  }

  @override
  String fullMessage(String title) {
    return 'Üzgünüz, \"$title\" dolu.';
  }

  @override
  String cancelledMessage(String title) {
    return '\"$title\" etkinliğine katılımın iptal edildi.';
  }

  @override
  String get addEvent => 'Etkinlik ekle';

  @override
  String get newEvent => 'Yeni etkinlik';

  @override
  String get fieldTitle => 'Başlık';

  @override
  String get fieldCategory => 'Kategori';

  @override
  String get fieldImage => 'Görsel';

  @override
  String get fieldCapacity => 'Kontenjan';

  @override
  String get fieldDescription => 'Açıklama (isteğe bağlı)';

  @override
  String get requiredField => 'Bu alan zorunlu';

  @override
  String get invalidCapacity => '1 ile 1000 arasında bir sayı gir';

  @override
  String get pastDate => 'İleri bir tarih ve saat seç';

  @override
  String get saveEvent => 'Etkinliği kaydet';

  @override
  String eventAdded(String title) {
    return '\"$title\" eklendi.';
  }

  @override
  String get deleteEvent => 'Etkinliği sil';

  @override
  String get deleteQuestion => 'Bu etkinliği silmek istiyor musun?';

  @override
  String eventDeleted(String title) {
    return '\"$title\" silindi.';
  }

  @override
  String get createdByYou => 'Senin etkinliğin';

  @override
  String get noDescription => 'Açıklama yok.';
}
