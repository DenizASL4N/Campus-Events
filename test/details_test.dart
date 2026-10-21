import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:campus_event_explorer/main.dart';
import 'package:campus_event_explorer/models/event.dart';
import 'package:campus_event_explorer/screens/image_viewer_screen.dart';

/// Starts the app on a phone-sized screen.
Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const CampusEventApp());
}

/// Searches for one event and opens its details screen.
Future<void> openDetails(WidgetTester tester, String query) async {
  await tester.enterText(find.byType(TextField), query);
  await tester.pump();
  expect(find.text('1 event found'), findsOneWidget);
  await tapDetails(tester);
}

/// Scrolls the only card's Details button into view, like a user would, and
/// taps it.
Future<void> tapDetails(WidgetTester tester) async {
  // A floating snackbar from an earlier action may cover the button.
  if (find.byType(SnackBar).evaluate().isNotEmpty) {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(find.text('Details'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Details'));
  await tester.pumpAndSettle();
  expect(find.text('Event Details'), findsOneWidget);
}

Future<void> goBack(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Back'));
  await tester.pumpAndSettle();
}

Finder inDialog(String text) =>
    find.descendant(of: find.byType(AlertDialog), matching: find.text(text));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Event never goes below zero or above capacity', () {
    final event = Event(
      id: 'x',
      title: const LocalizedText(en: 't', tr: 't'),
      category: EventCategory.arts,
      dateTime: DateTime(2026, 11, 1),
      venue: const LocalizedText(en: 'v', tr: 'v'),
      description: const LocalizedText(en: 'd', tr: 'd'),
      imagePath: 'p',
      capacity: 2,
      availablePlaces: 1,
    );

    expect(event.takePlace(), isTrue);
    expect(event.availablePlaces, 0);
    expect(event.takePlace(), isFalse);
    expect(event.availablePlaces, 0);
    event.releasePlace();
    event.releasePlace();
    event.releasePlace();
    expect(event.availablePlaces, 2);
  });

  testWidgets('details show all information and Back returns', (tester) async {
    await pumpApp(tester);
    await openDetails(tester, 'flutter');

    expect(find.text('Flutter Workshop for Beginners'), findsOneWidget);
    expect(find.text('Technology'), findsOneWidget);
    expect(find.text('Wed, 4 Nov 2026'), findsOneWidget);
    expect(find.text('14:00'), findsOneWidget);
    expect(find.text('Engineering Faculty, Lab B-204'), findsOneWidget);
    expect(find.text('Available places: 12 of 30'), findsOneWidget);
    expect(find.textContaining('hands-on introduction'), findsOneWidget);
    expect(find.text('Join event'), findsOneWidget);

    await goBack(tester);
    expect(find.text('1 event found'), findsOneWidget);
  });

  testWidgets('No or dismissing the join dialog changes nothing', (
    tester,
  ) async {
    await pumpApp(tester);
    await openDetails(tester, 'flutter');

    await tester.tap(find.text('Join event'));
    await tester.pumpAndSettle();
    expect(inDialog('Join this event?'), findsOneWidget);
    expect(inDialog('Flutter Workshop for Beginners'), findsOneWidget);
    expect(inDialog('Wed, 4 Nov 2026 • 14:00'), findsOneWidget);
    expect(inDialog('Engineering Faculty, Lab B-204'), findsOneWidget);

    await tester.tap(inDialog('No'));
    await tester.pumpAndSettle();
    expect(find.text('Available places: 12 of 30'), findsOneWidget);

    await tester.tap(find.text('Join event'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10)); // outside the dialog
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Available places: 12 of 30'), findsOneWidget);
    expect(find.text('Join event'), findsOneWidget);
  });

  testWidgets('Yes joins once, updates every view, cancel restores place', (
    tester,
  ) async {
    await pumpApp(tester);
    await openDetails(tester, 'flutter');

    await tester.tap(find.text('Join event'));
    await tester.pumpAndSettle();
    await tester.tap(inDialog('Yes'));
    await tester.pumpAndSettle();

    expect(find.text('Available places: 11 of 30'), findsOneWidget);
    expect(find.textContaining('You joined'), findsOneWidget);
    expect(find.text('Cancel participation'), findsOneWidget);
    expect(find.text('Join event'), findsNothing); // cannot join twice

    await goBack(tester);
    expect(find.text('Joined: 1'), findsOneWidget);
    expect(find.text('Joined'), findsOneWidget); // card label

    await tester.tap(find.text('My Events'));
    await tester.pumpAndSettle();
    expect(find.text('1 event found'), findsOneWidget);

    // Cancel from details opened in My Events.
    await tapDetails(tester);
    await tester.tap(find.text('Cancel participation'));
    await tester.pumpAndSettle();
    expect(inDialog('Cancel participation?'), findsOneWidget);
    await tester.tap(inDialog('No'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel participation'), findsOneWidget);

    await tester.tap(find.text('Cancel participation'));
    await tester.pumpAndSettle();
    await tester.tap(inDialog('Yes'));
    await tester.pumpAndSettle();
    expect(find.text('Available places: 12 of 30'), findsOneWidget);
    expect(find.text('Join event'), findsOneWidget);

    await goBack(tester);
    expect(find.text('Joined: 0'), findsOneWidget);
    expect(find.text('You have not joined any events yet'), findsOneWidget);
  });

  testWidgets('a full event cannot be joined', (tester) async {
    await pumpApp(tester);
    await openDetails(tester, 'photography');

    expect(find.text('Available places: 0 of 40'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Full'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('taking the last place still allows cancelling', (tester) async {
    await pumpApp(tester);
    await openDetails(tester, 'basketball');

    await tester.tap(find.text('Join event'));
    await tester.pumpAndSettle();
    await tester.tap(inDialog('Yes'));
    await tester.pumpAndSettle();
    expect(find.text('Available places: 0 of 25'), findsOneWidget);
    expect(find.text('Joined'), findsOneWidget); // not "Full"

    await tester.tap(find.text('Cancel participation'));
    await tester.pumpAndSettle();
    await tester.tap(inDialog('Yes'));
    await tester.pumpAndSettle();
    expect(find.text('Available places: 1 of 25'), findsOneWidget);
    expect(find.text('Only 1 place left'), findsOneWidget);
  });

  testWidgets('favorite from details shows up in Favorites', (tester) async {
    await pumpApp(tester);
    await openDetails(tester, 'flutter');

    await tester.tap(find.byTooltip('Add to favorites'));
    await tester.pump();
    expect(find.byTooltip('Remove from favorites'), findsOneWidget);

    await goBack(tester);
    expect(find.byTooltip('Remove from favorites'), findsOneWidget);
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(find.text('1 event found'), findsOneWidget);
  });

  testWidgets('double-tap opens the enlarged image, Back returns', (
    tester,
  ) async {
    await pumpApp(tester);
    await openDetails(tester, 'flutter');

    final image = find.text('Double-tap to enlarge');
    await tester.tap(image);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(image);
    await tester.pumpAndSettle();
    expect(find.byType(ImageViewerScreen), findsOneWidget);

    await goBack(tester);
    expect(find.byType(ImageViewerScreen), findsNothing);
    expect(find.text('Event Details'), findsOneWidget);
  });
}
