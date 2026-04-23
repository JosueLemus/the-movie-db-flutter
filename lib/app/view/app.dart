import 'package:flutter/material.dart';
import 'package:the_movie_db/core/router/app_router.dart';
import 'package:the_movie_db/core/theme/app_theme.dart';
import 'package:the_movie_db/l10n/l10n.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, _) => MaterialApp.router(
        routerConfig: appRouter,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: mode,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
