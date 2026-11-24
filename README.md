# Southsea Cinema

A Flutter application for browsing cinema screenings and making local ticket bookings. This repository is the student's **Southsea Cinema** coursework project; it is not the Sandwich Shop teaching example.

## Features

- Movie catalogue loaded from the bundled `assets/data/movies.json` file.
- Posters, film synopsis, age rating, running time, screening time and ticket prices.
- Ticket quantity selection, basket totals, per-movie removal and checkout.
- Completed numbered bookings saved locally in SQLite, with booking history on the Basket screen.
- Booking details stored as separate `booking_items` records for new purchases (database schema version 2); older bookings still show their summary.
- Name, address, email and newsletter preference saved using Shared Preferences.
- A persistent **Dark mode** switch in My Settings. Dark is the initial default; switching off selects a light appearance.
- Unit, widget, database, migration and rollback tests.

## Project structure

| Folder | Purpose |
| --- | --- |
| `lib/models/` | Movie, BasketItem, Booking, BookingItem and profile data |
| `lib/repositories/` | Movie loading and the active basket |
| `lib/database/` | SQLite schema, migration, booking history and transactions |
| `lib/controllers/` | Light/dark mode setting |
| `lib/views/` | Home, movie listing, Basket and Settings screens |
| `lib/widgets/` | Reusable buttons, movie cards and drawer |
| `assets/` | Bundled movie JSON and images |
| `test/` | Automated unit and widget tests |

## Requirements

- Flutter SDK and Dart, compatible with the project's `pubspec.yaml` and `pubspec.lock`.
- VS Code with Flutter and Dart extensions (or a comparable IDE).
- A physical Android device with USB debugging, or an Android emulator, to run the **SQLite application**.
- The Android SDK command-line tools and Android toolchain for Android builds. Android Studio itself is not mandatory when these tools are installed separately.

## Install and run

From the existing project directory:

```powershell
flutter pub get
flutter doctor
flutter devices
flutter run -d YOUR_ANDROID_DEVICE_ID
```

Replace `YOUR_ANDROID_DEVICE_ID` with the ID shown by `flutter devices`. Do not add spaces or backslash escapes to the project path when building on Windows; a path such as `D:\FlutterProjects\southsea_cinema` avoids the path-with-spaces build problem experienced during this project.

The Worksheet 7 application deliberately shows an unsupported-platform message when launched on Chrome or non-Android targets. The normal `sqflite` setup is for Android; **a Chrome launch does not demonstrate SQLite bookings**.

## Using the application

1. Browse the two sample films: Interstellar and Inception.
2. Choose **Book tickets** and select a quantity.
3. Press **Add to order**, then open **My Basket**.
4. Review quantities and totals; remove unwanted tickets if necessary.
5. Press **Checkout**. The booking and its movie lines are saved in one SQLite transaction. The active basket is cleared only after a successful save.
6. View **Past Bookings** below the basket. Older bookings retain their one-line summaries; new version-2 bookings show each saved film, quantity and price.
7. Open **My Settings** to edit the customer profile, change newsletter preference and switch light/dark mode.

## Data persistence

- Movie catalogue: bundled JSON asset, read at runtime.
- Open basket: in-memory repository; not restored after a full app restart.
- Booking history: on-device SQLite database (`cinema_data.db`).
- Customer profile and light/dark appearance: `SharedPreferencesAsync`.
- The schema migration from version 1 to version 2 adds `booking_items` without deleting the existing `bookings` table.
- A failed item insert rolls back the booking and item changes together, leaving the basket unchanged.

Reopening the app should preserve the SQLite bookings and preferences. This should be verified on a real Android device without uninstalling the app or clearing its storage. A unit test alone cannot substitute for that manual check.

## Testing and quality checks

Automated tests can run on Windows **without** an emulator or Android Studio. Database tests use `sqflite_common_ffi` and in-memory or temporary file-backed SQLite databases.

```powershell
flutter pub get
dart format lib test
dart analyze
flutter test
flutter test --coverage
```

Coverage is written to `coverage/lcov.info`, which is ignored by Git. Inspect it with the Flutter Coverage extension in VS Code. Record the actual starting and final coverage percentages; do not claim 100% without a report.

To demonstrate that tests catch regressions, temporarily change a line-total multiplication into addition and confirm that a unit test fails, then revert the change. Similarly, temporarily disable a primary button's callback and confirm its widget test fails; revert the change before committing.

## Worksheet 8 learning and demonstration

- Explain how `CinemaThemeController`, `ThemeMode`, `AnimatedBuilder`, and `SharedPreferencesAsync` work together.
- Use VS Code breakpoints and Flutter DevTools Widget Inspector to inspect the movie-booking subtotal row, when an Android run is available.
- Explain parent/child relationships in the widget tree and why `Expanded` prevents horizontal overflow.
- Explain SQLite migrations, foreign keys, transactions and rollback.
- Show source-control changes, analysis results, passing tests and real coverage measurements.
- Keep evidence of the Copilot planning/review workflow required by Worksheet 8. AI-generated code must be reviewed by the student, not just pasted.

## Coursework references

- [University worksheet collection](https://manighahrmani.github.io/sandwich_shop/)
- [Worksheet 8](https://manighahrmani.github.io/sandwich_shop/worksheet-8.html#exercises)
- [Flutter documentation](https://docs.flutter.dev/)
- [Dart documentation](https://dart.dev/)

This README documents implementation intent from the source files. The Android run, complete test suite and coverage percentages must still be verified in the student's own environment before presenting Demo 4.
