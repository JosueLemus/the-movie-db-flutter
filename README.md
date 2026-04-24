# The Movie DB

A Flutter app built for the **PinApp Mobile Architecture Challenge**. Displays movie categories with nested movie lists, full detail screens, a recommendation system backed by Firebase Firestore, and offline support via local caching.

---

## Architecture

The project follows **Clean Architecture** with three clearly separated layers:

```
lib/
├── app/                        # App entry point & theme notifier
├── core/
│   ├── di/                     # Dependency injection (GetIt)
│   ├── env/                    # Flavor configuration (dev/staging/prod)
│   ├── network/                # Dio client, interceptors, NetworkException
│   ├── router/                 # GoRouter routes
│   ├── services/               # RemoteConfigService, ConnectivityService
│   ├── theme/                  # Light & dark themes
│   └── widgets/                # Shared widgets (ConnectivityBanner)
└── features/
    ├── movies/
    │   ├── data/               # Models, DataSources (remote/local), RepositoryImpl
    │   ├── domain/             # Entities, UseCases, Repository interfaces
    │   └── presentation/       # BLoC/Cubits, Pages, Widgets
    └── splash/
        ├── data/               # SplashRepositoryImpl
        ├── domain/             # InitializeApp use case
        └── presentation/       # SplashCubit, SplashPage
```

**Data flow:** `UI → Cubit/BLoC → UseCase → Repository interface → DataSource (remote or local cache)`

---

## Tech Stack

| Category | Library | Version |
|---|---|---|
| State management | `flutter_bloc` / `bloc` | 9.1.1 / 9.2.0 |
| Networking | `dio` | 5.9.1 |
| Firebase | `firebase_core` / `firebase_remote_config` / `cloud_firestore` | 3.13.1 / 5.4.6 / 5.6.9 |
| Analytics | `firebase_analytics` | 11.4.6 |
| Dependency injection | `get_it` | 9.2.0 |
| Navigation | `go_router` | 14.8.1 |
| Local cache | `hive` / `hive_flutter` | 2.2.3 / 1.1.0 |
| Preferences | `shared_preferences` | 2.5.3 |
| Images | `cached_network_image` | 3.4.1 |
| Carousel | `carousel_slider_plus` | 7.1.1 |
| Connectivity | `connectivity_plus` | 6.1.4 |
| Shimmer loading | `shimmer` | 3.0.0 |
| HTML rendering | `flutter_widget_from_html_core` | 0.15.2 |
| Equality | `equatable` | 2.0.7 |
| **Testing** | `bloc_test` / `mocktail` | 10.0.0 / 1.0.5 |

---

## Running the Project

### Prerequisites

- **Flutter:** 3.41.x
- **Dart:** 3.11.x
- A Firebase project with Firestore and Remote Config enabled (see below)

### Steps

```sh
git clone https://github.com/JosueLemus/the-movie-db-flutter.git
cd the-movie-db-flutter
flutter pub get

# Development flavor
flutter run --flavor development --target lib/main_development.dart

# Staging
flutter run --flavor staging --target lib/main_staging.dart

# Production
flutter run --flavor production --target lib/main_production.dart
```

### Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Cloud Firestore** (start in test mode)
3. Enable **Remote Config** and publish at least one value (e.g., `welcome_message`)
4. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) and place them in the respective platform folders
5. Set the following Firestore security rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /recommendations/{movieId}/entries/{entryId} {
      allow read, write: if true;
    }
  }
}
```

### TMDB API Key

The app reads the TMDB Bearer token from each flavor's main file (`lib/main_development.dart`, etc.). Replace the placeholder with your token from [themoviedb.org](https://www.themoviedb.org/settings/api).

---

## API Endpoints

All requests go to `https://api.themoviedb.org/3`:

| Endpoint | Purpose |
|---|---|
| `GET /genre/movie/list` | Load movie genre categories |
| `GET /discover/movie?with_genres={id}` | Movies per genre (page 1 cached) |
| `GET /movie/popular` | Popular movies for home carousel |
| `GET /movie/{id}?append_to_response=credits,images` | Full movie detail + cast + backdrops |

Images: `https://image.tmdb.org/t/p/w500{path}` (posters) · `https://image.tmdb.org/t/p/w1280{path}` (backdrops)

---

## Features

- **Home** — genre categories with nested horizontal movie lists, "Popular Now" carousel with auto-play
- **Movie Detail** — swipeable image carousel (backdrops), title overlay, stats row, genre chips, expandable overview (HTML), horizontal cast list, Hero animation from home card
- **Favorites** — toggle with local persistence via Hive
- **Recommend** — Firestore-backed modal with tags (FilterChip), optional comment, past recommendations list, success toast on submit
- **Offline** — Hive cache for genres and movies, connectivity banner shown when no internet
- **Themes** — dark/light toggle with persistent purple accent scheme
- **Splash** — reads `welcome_message` and `maintenance_mode` from Firebase Remote Config, caches in SharedPreferences

---

## SOLID Principles in Code

All four principles are documented with inline comments at concrete usage points:

| Principle | File | Description |
|---|---|---|
| **S** — Single Responsibility | [`lib/features/movies/domain/usecases/get_movie_detail.dart`](lib/features/movies/domain/usecases/get_movie_detail.dart) | Each use-case class owns exactly one business operation |
| **O** — Open/Closed | [`lib/features/movies/data/repositories/movie_repository_impl.dart`](lib/features/movies/data/repositories/movie_repository_impl.dart) | Swap caching strategy or data source without touching domain layer |
| **I** — Interface Segregation | [`lib/features/movies/domain/repositories/recommendation_repository.dart`](lib/features/movies/domain/repositories/recommendation_repository.dart) | Separate interface so recommendation consumers don't depend on movie operations |
| **D** — Dependency Inversion | [`lib/core/di/injection_container.dart`](lib/core/di/injection_container.dart) | Composition root is the only place with concrete types; use-cases and cubits depend on abstractions |

---

## Running Tests

```sh
flutter test --coverage
```

**Coverage:** 81% (266 tests — unit, widget, bloc, integration-style)

To view the HTML coverage report (requires `lcov`):

```sh
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## CI

GitHub Actions runs on every push/PR to `main` using [Very Good Workflows](https://github.com/VeryGoodOpenSource/very_good_workflows):

- `dart format` check
- `flutter analyze` (zero warnings/infos allowed)
- `bloc lint`
- Tests with `--min-coverage 80`
- Spell check on `.md` files
