import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/event_storage.dart';
import '../data/sample_events.dart';
import '../models/event.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_card.dart';
import '../widgets/search_filter_bar.dart';
import 'event_details_screen.dart';
import '../l10n/l10n.dart';

/// The three main views reachable from the bottom navigation bar.
enum HomeTab { explore, favorites, myEvents }

/// Holds all app state: the events, favorites, joined events and the shared
/// search/category filter. Child widgets receive data and callbacks from here
/// and changes go through setState. Favorites and joined events are saved on
/// the device with [EventStorage].
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Event> _events = createSampleEvents();
  final Set<String> _favoriteIds = {};
  final Set<String> _joinedIds = {};

  // Shared by Explore, Favorites and My Events.
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  EventCategory? _selectedCategory; // null means "All"

  HomeTab _currentTab = HomeTab.explore;

  final EventStorage _storage = EventStorage();

  @override
  void initState() {
    super.initState();
    _restore();
  }

  /// Loads favorites and joined events saved in an earlier session.
  Future<void> _restore() async {
    final saved = await _storage.load();
    if (!mounted) return;
    setState(() {
      _favoriteIds.addAll(saved.favorites);
      for (final event in _events) {
        if (saved.joined.contains(event.id) && event.takePlace()) {
          _joinedIds.add(event.id);
        }
      }
    });
  }

  void _persist() {
    _storage.save(favorites: _favoriteIds, joined: _joinedIds);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilter =>
      _searchQuery.trim().isNotEmpty || _selectedCategory != null;

  /// Events in the current tab that match the search text and category.
  List<Event> get _visibleEvents {
    final query = _searchQuery.trim().toLowerCase();
    return _events.where((event) {
      final inTab = switch (_currentTab) {
        HomeTab.explore => true,
        HomeTab.favorites => _favoriteIds.contains(event.id),
        HomeTab.myEvents => _joinedIds.contains(event.id),
      };
      final matchesCategory =
          _selectedCategory == null || event.category == _selectedCategory;
      final matchesSearch =
          query.isEmpty ||
          event.title.of(context).toLowerCase().contains(query);
      return inTab && matchesCategory && matchesSearch;
    }).toList();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  void _clearAllFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedCategory = null;
    });
  }

  void _toggleFavorite(Event event) {
    setState(() {
      if (!_favoriteIds.remove(event.id)) _favoriteIds.add(event.id);
    });
    _persist();
  }

  /// Joins once: an already joined or full event is left unchanged.
  bool _join(Event event) {
    if (_joinedIds.contains(event.id)) return true;
    if (!event.takePlace()) return false;
    setState(() => _joinedIds.add(event.id));
    _persist();
    return true;
  }

  /// Cancels participation and gives the place back.
  void _cancel(Event event) {
    if (!_joinedIds.contains(event.id)) return;
    setState(() {
      _joinedIds.remove(event.id);
      event.releasePlace();
    });
    _persist();
  }

  void _openDetails(Event event) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EventDetailsScreen(
          event: event,
          isFavorite: () => _favoriteIds.contains(event.id),
          isJoined: () => _joinedIds.contains(event.id),
          onToggleFavorite: () => _toggleFavorite(event),
          onJoin: () => _join(event),
          onCancel: () => _cancel(event),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = _visibleEvents;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 14),
          CategoryChips(
            selectedCategory: _selectedCategory,
            onSelected: (category) =>
                setState(() => _selectedCategory = category),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Text(
              context.l10n.eventsFound(events.length),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: events.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return EventCard(
                        event: event,
                        isFavorite: _favoriteIds.contains(event.id),
                        isJoined: _joinedIds.contains(event.id),
                        onFavoriteToggle: () => _toggleFavorite(event),
                        onOpenDetails: () => _openDetails(event),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab.index,
        onDestinationSelected: (index) {
          setState(() => _currentTab = HomeTab.values[index]);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: const Icon(Icons.explore_rounded),
            label: context.l10n.navExplore,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border_rounded),
            selectedIcon: const Icon(Icons.favorite_rounded),
            label: context.l10n.navFavorites,
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_available_outlined),
            selectedIcon: const Icon(Icons.event_available_rounded),
            label: context.l10n.navMyEvents,
          ),
        ],
      ),
    );
  }

  /// Gradient header with the tab title, joined counter and search field.
  Widget _buildHeader(BuildContext context) {
    final l10n = context.l10n;
    final (String title, String subtitle) = switch (_currentTab) {
      HomeTab.explore => (l10n.headerExploreTitle, l10n.headerExploreSubtitle),
      HomeTab.favorites => (
        l10n.headerFavoritesTitle,
        l10n.headerFavoritesSubtitle,
      ),
      HomeTab.myEvents => (
        l10n.headerMyEventsTitle,
        l10n.headerMyEventsSubtitle,
      ),
    };

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.headerGradient,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subtitle,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.event_available_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.joinedCount(_joinedIds.length),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                EventSearchField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  onClear: _clearSearch,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    // The tab itself is empty: explain how to fill it.
    if (_currentTab == HomeTab.favorites && _favoriteIds.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        title: context.l10n.noFavoritesTitle,
        message: context.l10n.noFavoritesMessage,
      );
    }
    if (_currentTab == HomeTab.myEvents && _joinedIds.isEmpty) {
      return EmptyState(
        icon: Icons.event_busy,
        title: context.l10n.noJoinedTitle,
        message: context.l10n.noJoinedMessage,
      );
    }
    // The tab has events, but none match the search/category.
    return EmptyState(
      icon: Icons.search_off,
      title: context.l10n.noResultsTitle,
      message: context.l10n.noResultsMessage,
      actionLabel: _hasActiveFilter ? context.l10n.clearFilters : null,
      onAction: _hasActiveFilter ? _clearAllFilters : null,
    );
  }
}
