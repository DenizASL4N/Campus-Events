import 'package:intl/intl.dart';

/// "Wed, 4 Nov 2026" / "Çar, 4 Kas 2026"
String formatEventDate(DateTime dt, String locale) =>
    DateFormat('EEE, d MMM y', locale).format(dt);

/// "14:00"
String formatEventTime(DateTime dt, String locale) =>
    DateFormat('HH:mm', locale).format(dt);

/// "Wed, 4 Nov 2026 • 14:00"
String formatEventDateTime(DateTime dt, String locale) =>
    '${formatEventDate(dt, locale)} • ${formatEventTime(dt, locale)}';

/// "NOV" / "KAS", used on the calendar tile of a card.
String formatMonthShort(DateTime dt, String locale) =>
    DateFormat('MMM', locale).format(dt).toUpperCase();
