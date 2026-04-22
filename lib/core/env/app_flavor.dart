enum AppFlavor { development, staging, production }

class AppConfig {
  AppConfig._();

  static late AppFlavor flavor;

  // ISP: each flavor exposes only what it needs
  static bool get isDevelopment => flavor == AppFlavor.development;
  static bool get isProduction => flavor == AppFlavor.production;

  static String get tmdbBaseUrl => 'https://api.themoviedb.org/3';
  static String get tmdbImageBaseUrl => 'https://image.tmdb.org/t/p/w500';

  // OCP: add new flavors without modifying callers
  static String get flavorName => switch (flavor) {
        AppFlavor.development => 'DEV',
        AppFlavor.staging => 'STG',
        AppFlavor.production => 'PROD',
      };
}
