import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Campus Events'**
  String get appTitle;

  /// No description provided for @headerExploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover events'**
  String get headerExploreTitle;

  /// No description provided for @headerExploreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What is happening on campus'**
  String get headerExploreSubtitle;

  /// No description provided for @headerFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your favorites'**
  String get headerFavoritesTitle;

  /// No description provided for @headerFavoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Events you saved for later'**
  String get headerFavoritesSubtitle;

  /// No description provided for @headerMyEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your events'**
  String get headerMyEventsTitle;

  /// No description provided for @headerMyEventsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Events you are joining'**
  String get headerMyEventsSubtitle;

  /// No description provided for @joinedCount.
  ///
  /// In en, this message translates to:
  /// **'Joined: {count}'**
  String joinedCount(int count);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search events by title'**
  String get searchHint;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryTechnology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get categoryTechnology;

  /// No description provided for @categoryArts.
  ///
  /// In en, this message translates to:
  /// **'Arts'**
  String get categoryArts;

  /// No description provided for @categorySports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get categorySports;

  /// No description provided for @eventsFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 event found} other{{count} events found}}'**
  String eventsFound(int count);

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navMyEvents.
  ///
  /// In en, this message translates to:
  /// **'My Events'**
  String get navMyEvents;

  /// No description provided for @noFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorite events yet'**
  String get noFavoritesTitle;

  /// No description provided for @noFavoritesMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on an event to save it here.'**
  String get noFavoritesMessage;

  /// No description provided for @noJoinedTitle.
  ///
  /// In en, this message translates to:
  /// **'You have not joined any events yet'**
  String get noJoinedTitle;

  /// No description provided for @noJoinedMessage.
  ///
  /// In en, this message translates to:
  /// **'Join an event and it will appear here.'**
  String get noJoinedMessage;

  /// No description provided for @noResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No events match your search'**
  String get noResultsTitle;

  /// No description provided for @noResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a different title or choose another category.'**
  String get noResultsMessage;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear search and filters'**
  String get clearFilters;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @eventDetails.
  ///
  /// In en, this message translates to:
  /// **'Event Details'**
  String get eventDetails;

  /// No description provided for @doubleTapToEnlarge.
  ///
  /// In en, this message translates to:
  /// **'Double-tap to enlarge'**
  String get doubleTapToEnlarge;

  /// No description provided for @statusJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get statusJoined;

  /// No description provided for @statusFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get statusFull;

  /// No description provided for @statusOnePlaceLeft.
  ///
  /// In en, this message translates to:
  /// **'Only 1 place left'**
  String get statusOnePlaceLeft;

  /// No description provided for @statusPlacesLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} places left'**
  String statusPlacesLeft(int count);

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @venueLabel.
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get venueLabel;

  /// No description provided for @availablePlaces.
  ///
  /// In en, this message translates to:
  /// **'Available places: {available} of {capacity}'**
  String availablePlaces(int available, int capacity);

  /// No description provided for @placesTaken.
  ///
  /// In en, this message translates to:
  /// **'{taken} of {capacity} places taken'**
  String placesTaken(int taken, int capacity);

  /// No description provided for @aboutEvent.
  ///
  /// In en, this message translates to:
  /// **'About this event'**
  String get aboutEvent;

  /// No description provided for @joinEvent.
  ///
  /// In en, this message translates to:
  /// **'Join event'**
  String get joinEvent;

  /// No description provided for @cancelParticipation.
  ///
  /// In en, this message translates to:
  /// **'Cancel participation'**
  String get cancelParticipation;

  /// No description provided for @joinQuestion.
  ///
  /// In en, this message translates to:
  /// **'Join this event?'**
  String get joinQuestion;

  /// No description provided for @cancelQuestion.
  ///
  /// In en, this message translates to:
  /// **'Cancel participation?'**
  String get cancelQuestion;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @joinedMessage.
  ///
  /// In en, this message translates to:
  /// **'You joined \"{title}\".'**
  String joinedMessage(String title);

  /// No description provided for @fullMessage.
  ///
  /// In en, this message translates to:
  /// **'Sorry, \"{title}\" is already full.'**
  String fullMessage(String title);

  /// No description provided for @cancelledMessage.
  ///
  /// In en, this message translates to:
  /// **'Your participation in \"{title}\" was cancelled.'**
  String cancelledMessage(String title);

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get addEvent;

  /// No description provided for @newEvent.
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get newEvent;

  /// No description provided for @fieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get fieldTitle;

  /// No description provided for @fieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get fieldCategory;

  /// No description provided for @fieldImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get fieldImage;

  /// No description provided for @fieldCapacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get fieldCapacity;

  /// No description provided for @fieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get fieldDescription;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @invalidCapacity.
  ///
  /// In en, this message translates to:
  /// **'Enter a number between 1 and 1000'**
  String get invalidCapacity;

  /// No description provided for @pastDate.
  ///
  /// In en, this message translates to:
  /// **'Choose a date and time in the future'**
  String get pastDate;

  /// No description provided for @saveEvent.
  ///
  /// In en, this message translates to:
  /// **'Save event'**
  String get saveEvent;

  /// No description provided for @eventAdded.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" was added.'**
  String eventAdded(String title);

  /// No description provided for @deleteEvent.
  ///
  /// In en, this message translates to:
  /// **'Delete event'**
  String get deleteEvent;

  /// No description provided for @deleteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete this event?'**
  String get deleteQuestion;

  /// No description provided for @eventDeleted.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" was deleted.'**
  String eventDeleted(String title);

  /// No description provided for @createdByYou.
  ///
  /// In en, this message translates to:
  /// **'Created by you'**
  String get createdByYou;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description.'**
  String get noDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
