import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:campus_event_explorer/data/sample_events.dart';
import 'package:campus_event_explorer/main.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('sample data covers the key cases', () {
    final events = createSampleEvents();

    expect(events.length, greaterThanOrEqualTo(6));
    expect(
      events.map((e) => e.category).toSet().length,
      greaterThanOrEqualTo(3),
    );
    expect(events.map((e) => e.id).toSet().length, events.length);
    expect(events.any((e) => e.availablePlaces == 0), isTrue);
    expect(events.any((e) => e.availablePlaces == 1), isTrue);
    for (final e in events) {
      expect(e.dateTime.isAfter(DateTime(2026, 10, 25, 23, 59)), isTrue);
      expect(e.availablePlaces, inInclusiveRange(0, e.capacity));
    }
  });

  test('every event has its own bundled image', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final events = createSampleEvents();
    final paths = events.map((e) => e.imagePath).toSet();

    expect(paths.length, events.length);
    for (final path in paths) {
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(0), reason: path);
    }
  });

  testWidgets('app starts on Explore with all events', (tester) async {
    await tester.pumpWidget(const CampusEventApp());

    expect(find.text('6 events found'), findsOneWidget);
    expect(find.text('Joined: 0'), findsOneWidget);
  });

  testWidgets('search ignores case and surrounding spaces', (tester) async {
    await tester.pumpWidget(const CampusEventApp());

    await tester.enterText(find.byType(TextField), '  fLuTtEr  ');
    await tester.pump();

    expect(find.text('1 event found'), findsOneWidget);
    expect(find.text('Flutter Workshop for Beginners'), findsOneWidget);
  });

  testWidgets('search and category filter work together', (tester) async {
    await tester.pumpWidget(const CampusEventApp());

    await tester.tap(find.widgetWithText(ChoiceChip, 'Sports'));
    await tester.pump();
    expect(find.text('2 events found'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'final');
    await tester.pump();
    expect(find.text('1 event found'), findsOneWidget);

    // "Workshop" is Technology, so Sports + "workshop" matches nothing.
    await tester.enterText(find.byType(TextField), 'workshop');
    await tester.pump();
    expect(find.text('0 events found'), findsOneWidget);
    expect(find.text('No events match your search'), findsOneWidget);

    await tester.tap(find.text('Clear search and filters'));
    await tester.pump();
    expect(find.text('6 events found'), findsOneWidget);
  });

  testWidgets('clear button empties the search field', (tester) async {
    await tester.pumpWidget(const CampusEventApp());

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.text('0 events found'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(find.text('6 events found'), findsOneWidget);
    expect(find.byTooltip('Clear search'), findsNothing);
  });

  testWidgets('favorites tab shows empty state, then favorited event', (
    tester,
  ) async {
    await tester.pumpWidget(const CampusEventApp());

    await tester.tap(find.text('Favorites'));
    await tester.pump();
    expect(find.text('No favorite events yet'), findsOneWidget);

    await tester.tap(find.text('Explore'));
    await tester.pump();
    await tester.tap(find.byTooltip('Add to favorites').first);
    await tester.pump();

    await tester.tap(find.text('Favorites'));
    await tester.pump();
    expect(find.text('1 event found'), findsOneWidget);
    expect(find.text('Flutter Workshop for Beginners'), findsOneWidget);
  });

  testWidgets('My Events shows its empty state', (tester) async {
    await tester.pumpWidget(const CampusEventApp());

    await tester.tap(find.text('My Events'));
    await tester.pump();
    expect(find.text('You have not joined any events yet'), findsOneWidget);
  });

  testWidgets('saved favorites and joined events are restored on start', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'favorite_event_ids': ['e2'],
      'joined_event_ids': ['e1'],
    });
    await tester.pumpWidget(const CampusEventApp());
    await tester.pumpAndSettle();

    expect(find.text('Joined: 1'), findsOneWidget);
    expect(find.text('Joined'), findsOneWidget); // e1 card label

    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(find.text('1 event found'), findsOneWidget);
    expect(find.text('AI and Society Panel'), findsOneWidget);
  });

  testWidgets('app follows a Turkish phone language', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('tr')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const CampusEventApp());
    await tester.pumpAndSettle();

    expect(find.text('Etkinlikleri keşfet'), findsOneWidget);
    expect(find.text('6 etkinlik bulundu'), findsOneWidget);
    expect(find.text('Katılım: 0'), findsOneWidget);
    expect(find.text('Yeni Başlayanlar için Flutter Atölyesi'), findsOneWidget);
    expect(find.text('Çar, 4 Kas 2026 • 14:00'), findsOneWidget);

    // Search works on the Turkish titles.
    await tester.enterText(find.byType(TextField), '  basketbol ');
    await tester.pump();
    expect(find.text('1 etkinlik bulundu'), findsOneWidget);
  });

  testWidgets('app follows the phone dark mode', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const CampusEventApp());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(find.text('6 events found'), findsOneWidget);
  });
}
