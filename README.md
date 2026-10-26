# SitePlus — mobile app

Flutter app for SitePlus field staff. Staff receive survey tasks, record sites, write survey reports with photos and track site deals.

**Status:** Graduation project, FPT University, 2025 — archived. The backend is offline, so the app cannot sign in or load data.

Related: [SitePlus-FE](https://github.com/Let-cal/SitePlus-FE) (web front end for brands, admins and managers). The backend repository is private.

## Screenshots

Screenshots are not available. The app needs the backend to get past the sign-in screen, and the backend is offline.

## My role

Team Lead of a team of 5. I designed the mobile UI in Figma and wrote all of the code in this repository (every commit is mine):

- Sign-in screen and session storage.
- Home screen with weekly task and site summaries and statistics charts.
- Task list and task detail with filters, status tabs and a map of the task location.
- Site list, site detail, site creation and photo upload.
- Survey report form: site and building details, seven site attributes (traffic, customer model, visibility and others), photos, notes; view and edit a report.
- Site deal screens: create, edit, filter and view deals.
- Notifications pushed over SignalR.
- Vietnamese interface text.

## Team

Team of 5. Commits in this repository: [@Let-cal](https://github.com/Let-cal).

## Stack

Flutter (Dart SDK ^3.7), Provider, SignalR client (`signalr_netcore`), flutter_map with OpenStreetMap tiles, fl_chart, image_picker, file_picker, shared_preferences.

## How to run

The repository contains `lib/` and `pubspec.yaml` only. Generate the platform folders first:

```sh
flutter create .
flutter pub get
flutter run
```

The API base URL is hard-coded in `lib/service/api_link.dart`. It points to the old Azure backend, which no longer exists.

## Known limitations

- The backend is offline, so the app stops at sign-in.
- No platform folders (`android/`, `ios/`) and no app icon file in the repository.
- No automated tests.
