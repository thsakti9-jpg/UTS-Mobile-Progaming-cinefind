import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'pages/home_page.dart';

void main() => runApp(const CineFindApp());

class CineFindApp extends StatelessWidget {
  const CineFindApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: cineRed,
      brightness: Brightness.dark,
      surface: cineSurface,
    );
    return MaterialApp(
      title: 'CineFind',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: cineBg,
        colorScheme: colorScheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: cineBg,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF111116),
          indicatorColor: cineRed.withValues(alpha: 0.20),
          labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
                fontSize: 11,
                fontWeight: states.contains(WidgetState.selected)
                    ? FontWeight.w700
                    : FontWeight.w500,
              )),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF17171F),
          hintStyle: const TextStyle(color: Colors.white38),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF25252D)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: cineRed, width: 1.2),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}
