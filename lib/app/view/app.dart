import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:the_movie_db/core/router/app_router.dart';
import 'package:the_movie_db/core/theme/app_theme.dart';
import 'package:the_movie_db/core/widgets/connectivity_banner.dart';

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
        locale: const Locale('es', 'AR'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es', 'AR')],
        builder: (context, child) =>
            ConnectivityBanner(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
