// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Campus Events';

  @override
  String get headerExploreTitle => 'Discover events';

  @override
  String get headerExploreSubtitle => 'What is happening on campus';

  @override
  String get headerFavoritesTitle => 'Your favorites';

  @override
  String get headerFavoritesSubtitle => 'Events you saved for later';

  @override
  String get headerMyEventsTitle => 'Your events';

  @override
  String get headerMyEventsSubtitle => 'Events you are joining';

  @override
  String joinedCount(int count) {
    return 'Joined: $count';
  }

  @override
  String get searchHint => 'Search events by title';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryTechnology => 'Technology';

  @override
  String get categoryArts => 'Arts';

  @override
  String get categorySports => 'Sports';

  @override
  String eventsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events found',
      one: '1 event found',
    );
    return '$_temp0';
  }

  @override
  String get navExplore => 'Explore';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navMyEvents => 'My Events';

  @override
  String get noFavoritesTitle => 'No favorite events yet';

  @override
  String get noFavoritesMessage => 'Tap the heart on an event to save it here.';

  @override
  String get noJoinedTitle => 'You have not joined any events yet';

  @override
  String get noJoinedMessage => 'Join an event and it will appear here.';

  @override
  String get noResultsTitle => 'No events match your search';

  @override
  String get noResultsMessage =>
      'Try a different title or choose another category.';

  @override
  String get clearFilters => 'Clear search and filters';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get details => 'Details';

  @override
  String get eventDetails => 'Event Details';

  @override
  String get doubleTapToEnlarge => 'Double-tap to enlarge';

  @override
  String get statusJoined => 'Joined';

  @override
  String get statusFull => 'Full';

  @override
  String get statusOnePlaceLeft => 'Only 1 place left';

  @override
  String statusPlacesLeft(int count) {
    return '$count places left';
  }

  @override
  String get dateLabel => 'Date';

  @override
  String get timeLabel => 'Time';

  @override
  String get venueLabel => 'Venue';

  @override
  String availablePlaces(int available, int capacity) {
    return 'Available places: $available of $capacity';
  }

  @override
  String placesTaken(int taken, int capacity) {
    return '$taken of $capacity places taken';
  }

  @override
  String get aboutEvent => 'About this event';

  @override
  String get joinEvent => 'Join event';

  @override
  String get cancelParticipation => 'Cancel participation';

  @override
  String get joinQuestion => 'Join this event?';

  @override
  String get cancelQuestion => 'Cancel participation?';

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String joinedMessage(String title) {
    return 'You joined \"$title\".';
  }

  @override
  String fullMessage(String title) {
    return 'Sorry, \"$title\" is already full.';
  }

  @override
  String cancelledMessage(String title) {
    return 'Your participation in \"$title\" was cancelled.';
  }
}
