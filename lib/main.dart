import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/controllers/cinema_theme_controller.dart';
import 'package:southsea_cinema/views/basket_view.dart';
import 'package:southsea_cinema/views/home_view.dart';
import 'package:southsea_cinema/views/settings_view.dart';

bool isSupportedPlatform() {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (isSupportedPlatform()) {
    runApp(const SouthseaCinemaApp());
  } else {
    runApp(const UnsupportedPlatformApp());
  }
}

class UnsupportedPlatformApp extends StatelessWidget {
  const UnsupportedPlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'This application uses SQLite to save bookings. '
              'For this coursework stage, please run it on '
              'an Android emulator or Android device.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class SouthseaCinemaApp extends StatefulWidget {
  const SouthseaCinemaApp({super.key, this.themeController});

  // Tests can inject a fresh controller instead of reusing the singleton.
  final CinemaThemeController? themeController;

  @override
  State<SouthseaCinemaApp> createState() => _SouthseaCinemaAppState();
}

class _SouthseaCinemaAppState extends State<SouthseaCinemaApp> {
  late final CinemaThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = widget.themeController ?? CinemaThemeController.instance;
    unawaited(_restoreTheme());
  }

  Future<void> _restoreTheme() async {
    try {
      await _themeController.load();
    } catch (error) {
      // Keep the default dark appearance if preferences are unavailable.
      // This also lets older widget tests run without a native plugin.
      debugPrint('Could not load appearance setting: $error');
    }
  }

  ThemeData _darkTheme() {
    final ColorScheme colors = ColorScheme.fromSeed(
      seedColor: cinemaBrand,
      brightness: Brightness.dark,
    ).copyWith(
      primary: cinemaBrand,
      surface: cinemaBackground,
      surfaceContainerLow: cinemaSurface,
      onSurface: cinemaFontWhite,
    );

    return ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: colors,
      scaffoldBackgroundColor: cinemaBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: cinemaSurface,
        foregroundColor: cinemaFontWhite,
        iconTheme: IconThemeData(color: cinemaBrand),
        titleTextStyle: cinemaHeaderStyle,
        elevation: 0,
      ),
    );
  }

  ThemeData _lightTheme() {
    final ColorScheme colors = ColorScheme.fromSeed(
      seedColor: cinemaBrandDark,
      brightness: Brightness.light,
    );

    return ThemeData.light(useMaterial3: true).copyWith(
      colorScheme: colors,
      scaffoldBackgroundColor: colors.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        iconTheme: IconThemeData(color: colors.primary),
        titleTextStyle: TextStyle(
          color: colors.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, child) {
        return MaterialApp(
          title: 'Southsea Cinema & Arts Centre',
          debugShowCheckedModeBanner: false,
          theme: _lightTheme(),
          darkTheme: _darkTheme(),
          themeMode: _themeController.mode,
          initialRoute: '/',
          routes: {
            '/': (context) => const HomeView(),
            '/basket': (context) => const BasketView(),
            '/settings': (context) => SettingsView(
                  themeController: _themeController,
                ),
          },
        );
      },
    );
  }
}
