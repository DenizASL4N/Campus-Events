import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/event.dart';

/// Saves favorite and joined event IDs and the events the user created on the
/// device, so they survive an app restart.
class EventStorage {
  static const _favoritesKey = 'favorite_event_ids';
  static const _joinedKey = 'joined_event_ids';
  static const _customEventsKey = 'custom_events';

  Future<
    ({Set<String> favorites, Set<String> joined, List<Event> customEvents})
  >
  load() async {
    final prefs = await SharedPreferences.getInstance();
    final customEvents = (prefs.getStringList(_customEventsKey) ?? const [])
        .map((s) => Event.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
    return (
      favorites: (prefs.getStringList(_favoritesKey) ?? const []).toSet(),
      joined: (prefs.getStringList(_joinedKey) ?? const []).toSet(),
      customEvents: customEvents,
    );
  }

  Future<void> save({
    required Set<String> favorites,
    required Set<String> joined,
    required List<Event> customEvents,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites.toList());
    await prefs.setStringList(_joinedKey, joined.toList());
    await prefs.setStringList(
      _customEventsKey,
      customEvents.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }
}
