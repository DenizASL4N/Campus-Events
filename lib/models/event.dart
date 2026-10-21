/// Event categories shown in the category filter. Their display names come
/// from the app localizations.
enum EventCategory { technology, arts, sports }

/// A piece of text in every language the app supports.
class LocalizedText {
  const LocalizedText({required this.en, required this.tr});

  /// The same text in every language (used for events the user creates).
  const LocalizedText.same(String text) : en = text, tr = text;

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
    this.isCustom = false,
  }) : assert(capacity > 0),
       assert(availablePlaces >= 0 && availablePlaces <= capacity),
       _availablePlaces = availablePlaces;

  /// Restores an event the user created (see [toJson]). It starts with all
  /// places free; joined events take their place again when they are loaded.
  factory Event.fromJson(Map<String, dynamic> json) {
    final capacity = json['capacity'] as int;
    return Event(
      id: json['id'] as String,
      title: LocalizedText.same(json['title'] as String),
      category: EventCategory.values.byName(json['category'] as String),
      dateTime: DateTime.parse(json['dateTime'] as String),
      venue: LocalizedText.same(json['venue'] as String),
      description: LocalizedText.same(json['description'] as String),
      imagePath: json['imagePath'] as String,
      capacity: capacity,
      availablePlaces: capacity,
      isCustom: true,
    );
  }

  /// Only used for events the user created; their texts are the same in
  /// every language.
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title.en,
    'category': category.name,
    'dateTime': dateTime.toIso8601String(),
    'venue': venue.en,
    'description': description.en,
    'imagePath': imagePath,
    'capacity': capacity,
  };

  final String id;
  final LocalizedText title;
  final EventCategory category;
  final DateTime dateTime;
  final LocalizedText venue;
  final LocalizedText description;
  final String imagePath;
  final int capacity;

  /// True for events the user added; only these can be deleted.
  final bool isCustom;

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
