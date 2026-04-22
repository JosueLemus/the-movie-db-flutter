import 'package:flutter/widgets.dart';
import 'package:the_movie_db/l10n/gen/app_localizations.dart';

export 'package:the_movie_db/l10n/gen/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
