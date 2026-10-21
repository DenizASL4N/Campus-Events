/// Event categories shown in the category filter. Their display names come
/// from the app localizations.
enum EventCategory { technology, arts, sports }

/// A piece of text in every language the app supports.
class LocalizedText {
  const LocalizedText({required this.en, required this.tr});

  final String en;
  final String tr;

  /// Returns the Turkish text for 'tr', English otherwise.
  String forLanguage(String languageCode) => languageCode == 'tr' ? tr : en;
}

/// A single campus event.
///
/// Everything is fixed except [availablePlaces], which changes when the
/// student joins or cancels participation.
class Event {
  Event({
    required this.id,
    required this.title,
    required this.category,
    required this.dateTime,
    required this.venue,
    required this.description,
    required this.imagePath,
    required this.capacity,
    required int availablePlaces,
  }) : assert(capacity > 0),
       assert(availablePlaces >= 0 && availablePlaces <= capacity),
       _availablePlaces = availablePlaces;

  final String id;
  final LocalizedText title;
  final EventCategory category;
  final DateTime dateTime;
  final LocalizedText venue;
  final LocalizedText description;
  final String imagePath;
  final int capacity;

  int _availablePlaces;

  int get availablePlaces => _availablePlaces;

  bool get isFull => _availablePlaces == 0;

  /// Takes one place. Returns false if the event is already full.
  bool takePlace() {
    if (_availablePlaces == 0) return false;
    _availablePlaces--;
    return true;
  }

  /// Gives one place back, never going above [capacity].
  void releasePlace() {
    if (_availablePlaces < capacity) _availablePlaces++;
  }
}
