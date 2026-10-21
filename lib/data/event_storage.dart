import 'package:shared_preferences/shared_preferences.dart';

/// Saves favorite and joined event IDs on the device so they survive an
/// app restart.
class EventStorage {
  static const _favoritesKey = 'favorite_event_ids';
  static const _joinedKey = 'joined_event_ids';

  Future<({Set<String> favorites, Set<String> joined})> load() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      favorites: (prefs.getStringList(_favoritesKey) ?? const []).toSet(),
      joined: (prefs.getStringList(_joinedKey) ?? const []).toSet(),
    );
  }

  Future<void> save({
    required Set<String> favorites,
    required Set<String> joined,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites.toList());
    await prefs.setStringList(_joinedKey, joined.toList());
  }
}
