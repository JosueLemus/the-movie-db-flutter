dev:
	flutter run \
		--flavor development \
		--target lib/main_development.dart \
		--dart-define-from-file=.dart_defines/development.json

stg:
	flutter run \
		--flavor staging \
		--target lib/main_staging.dart \
		--dart-define-from-file=.dart_defines/staging.json

prod:
	flutter run \
		--flavor production \
		--target lib/main_production.dart \
		--dart-define-from-file=.dart_defines/production.json

build-dev:
	flutter build ios \
		--flavor development \
		--target lib/main_development.dart \
		--dart-define-from-file=.dart_defines/development.json

build-prod:
	flutter build ios \
		--flavor production \
		--target lib/main_production.dart \
		--dart-define-from-file=.dart_defines/production.json

.PHONY: dev stg prod build-dev build-prod
