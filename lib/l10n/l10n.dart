import 'package:flutter/widgets.dart';

import '../models/event.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

/// Short access to the translations and the current language.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// 'en' or 'tr'.
  String get languageCode => Localizations.localeOf(this).languageCode;
}

extension LocalizedTextOf on LocalizedText {
  /// The text in the app's current language.
  String of(BuildContext context) => forLanguage(context.languageCode);
}

extension CategoryLabel on EventCategory {
  String label(BuildContext context) => switch (this) {
    EventCategory.technology => context.l10n.categoryTechnology,
    EventCategory.arts => context.l10n.categoryArts,
    EventCategory.sports => context.l10n.categorySports,
  };
}
