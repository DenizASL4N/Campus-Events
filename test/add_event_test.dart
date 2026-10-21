import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:campus_event_explorer/main.dart';
import 'package:campus_event_explorer/models/event.dart';

Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const CampusEventApp());
  await tester.pumpAndSettle();
}

Finder field(String label) => find.widgetWithText(TextFormField, label);

/// Scrolls the first card's Details button to the top and taps it.
Future<void> openFirstDetails(WidgetTester tester) async {
  final details = find.text('Details').first;
  await tester.ensureVisible(details);
  await tester.pumpAndSettle();
  await tester.tap(details);
  await tester.pumpAndSettle();
  expect(find.text('Event Details'), findsOneWidget);
}

/// Opens the form, fills the required fields and saves.
Future<void> addEvent(WidgetTester tester, String title) async {
  await tester.tap(find.text('Add event'));
  await tester.pumpAndSettle();
  await tester.enterText(field('Title'), title);
  await tester.enterText(field('Venue'), 'Student Center');
  await tester.enterText(field('Capacity'), '15');
  await tester.tap(find.text('Save event'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('created events survive a JSON round trip', () {
    final event = Event(
      id: 'u1',
      title: const LocalizedText.same('Chess Night'),
      category: EventCategory.arts,
      dateTime: DateTime(2027, 1, 5, 19, 30),
      venue: const LocalizedText.same('Library'),
      description: const LocalizedText.same(''),
      imagePath: 'assets/images/ai_panel.png',
      capacity: 12,
      availablePlaces: 12,
      isCustom: true,
    );

    final copy = Event.fromJson(event.toJson());
    expect(copy.id, 'u1');
    expect(copy.title.forLanguage('tr'), 'Chess Night');
    expect(copy.category, EventCategory.arts);
    expect(copy.dateTime, DateTime(2027, 1, 5, 19, 30));
    expect(copy.capacity, 12);
    expect(copy.availablePlaces, 12);
    expect(copy.isCustom, isTrue);
  });

  testWidgets('empty required fields show errors', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Add event'));
    await tester.pumpAndSettle();

    await tester.enterText(field('Capacity'), '0');
    await tester.tap(find.text('Save event'));
    await tester.pumpAndSettle();

    expect(find.text('This field is required'), findsNWidgets(2));
    expect(find.text('Enter a number between 1 and 1000'), findsOneWidget);
    expect(find.text('New event'), findsOneWidget); // still on the form
  });

  testWidgets('a new event appears first and is saved', (tester) async {
    await pumpApp(tester);
    await addEvent(tester, 'Board Game Night');

    expect(find.text('7 events found'), findsOneWidget);
    expect(find.text('Board Game Night'), findsOneWidget);
    expect(find.textContaining('was added'), findsOneWidget);

    // Start the app again: the event is loaded from storage.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(const CampusEventApp());
    await tester.pumpAndSettle();
    expect(find.text('7 events found'), findsOneWidget);
    expect(find.text('Board Game Night'), findsOneWidget);
  });

  testWidgets('a created event can be joined and deleted', (tester) async {
    await pumpApp(tester);
    await addEvent(tester, 'Board Game Night');
    await tester.pump(const Duration(seconds: 5)); // let the snackbar go
    await tester.pumpAndSettle();

    await openFirstDetails(tester);
    expect(find.text('Created by you'), findsOneWidget);
    expect(find.text('Available places: 15 of 15'), findsOneWidget);

    await tester.tap(find.text('Join event'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(find.text('Available places: 14 of 15'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete event'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this event?'), findsOneWidget);
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    expect(find.text('6 events found'), findsOneWidget);
    expect(find.text('Board Game Night'), findsNothing);
    expect(find.text('Joined: 0'), findsOneWidget);
  });

  testWidgets('sample events cannot be deleted', (tester) async {
    await pumpApp(tester);
    await openFirstDetails(tester);
    expect(find.byTooltip('Delete event'), findsNothing);
  });
}
