import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// AILaga palette (docs/UI_PROMPT.md §3.2)
const _primary = Color(0xFF0B6B6B); // Teal — main actions
const _helperIndigo = Color(0xFF2F4B8A); // Helper-mode accent
const _background = Color(0xFFFFFDF8); // Warm white
const _card = Color(0xFFF3EFE6); // Card fill
const _border = Color(0xFFD9D2C3); // Card/divider border
const _text = Color(0xFF1A1A1A); // Body text
const _error = Color(0xFFB3261E); // Out-of-range / errors
// SOS red #C62828 is used only by emergency widgets, not the theme.

const _radius = 24.0;

TextTheme _textTheme(TextTheme base, Color color) {
  final atkinson = GoogleFonts.atkinsonHyperlegibleTextTheme(base);
  return atkinson.copyWith(
    displayLarge: atkinson.displayLarge?.copyWith(
        color: color, fontWeight: FontWeight.bold, fontSize: 40),
    displayMedium: atkinson.displayMedium?.copyWith(
        color: color, fontWeight: FontWeight.bold, fontSize: 36),
    displaySmall: atkinson.displaySmall?.copyWith(
        color: color, fontWeight: FontWeight.bold, fontSize: 32),
    headlineLarge: atkinson.headlineLarge?.copyWith(
        color: color, fontWeight: FontWeight.bold, fontSize: 32),
    headlineMedium: atkinson.headlineMedium?.copyWith(
        color: color, fontWeight: FontWeight.bold, fontSize: 28),
    headlineSmall: atkinson.headlineSmall?.copyWith(
        color: color, fontWeight: FontWeight.bold, fontSize: 26),
    titleLarge: atkinson.titleLarge?.copyWith(
        color: color, fontWeight: FontWeight.bold, fontSize: 24),
    titleMedium: atkinson.titleMedium?.copyWith(
        color: color, fontWeight: FontWeight.w600, fontSize: 20),
    titleSmall: atkinson.titleSmall?.copyWith(
        color: color, fontWeight: FontWeight.w600, fontSize: 18),
    bodyLarge: atkinson.bodyLarge?.copyWith(color: color, fontSize: 20),
    bodyMedium: atkinson.bodyMedium?.copyWith(color: color, fontSize: 18),
    bodySmall: atkinson.bodySmall?.copyWith(color: color, fontSize: 16),
    labelLarge: atkinson.labelLarge?.copyWith(
        color: color, fontSize: 18, fontWeight: FontWeight.w600),
    labelMedium: atkinson.labelMedium?.copyWith(color: color, fontSize: 16),
    labelSmall: atkinson.labelSmall?.copyWith(color: color, fontSize: 14),
  );
}

final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _primary,
    primary: _primary,
    secondary: _helperIndigo,
    surface: _background,
    error: _error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: _text,
    onError: Colors.white,
  ).copyWith(
    surfaceContainerHighest: _card,
    outline: _border,
  ),
  scaffoldBackgroundColor: _background,

  // Font: Atkinson Hyperlegible — designed for low-vision readers.
  textTheme: _textTheme(ThemeData.light().textTheme, _text),

  // Cards: warm fill, 2dp border, 24dp radius, no soft shadows.
  cardTheme: CardThemeData(
    color: _card,
    elevation: 0,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_radius),
      side: const BorderSide(color: _border, width: 2),
    ),
  ),

  dialogTheme: DialogThemeData(
    backgroundColor: _background,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_radius),
      side: const BorderSide(color: _border, width: 2),
    ),
    titleTextStyle: const TextStyle(
        color: _text, fontSize: 24, fontWeight: FontWeight.bold),
    contentTextStyle: const TextStyle(color: _text, fontSize: 18),
  ),

  // Buttons: large targets (min 56dp tall, helper-mode primary is 64dp),
  // bold 20sp labels, 24dp radius. Width stays bounded so app-bar
  // buttons (e.g. SOS) never overflow.
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      minimumSize: const Size(64, 56),
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius)),
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      minimumSize: const Size(64, 56),
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius)),
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: _primary,
      minimumSize: const Size(64, 56),
      side: const BorderSide(color: _primary, width: 2),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius)),
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _primary,
      minimumSize: const Size(48, 48),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius)),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: _primary,
    foregroundColor: Colors.white,
    elevation: 0,
    extendedTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  ),

  // Form inputs: white on the warm background, 2dp border, big labels.
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _border, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _border, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _error, width: 2),
    ),
    labelStyle: const TextStyle(color: Color(0xFF4A453C), fontSize: 18),
    hintStyle: const TextStyle(color: Color(0xFF6B6557), fontSize: 18),
    floatingLabelStyle:
        const TextStyle(color: _primary, fontWeight: FontWeight.w600),
  ),

  listTileTheme: const ListTileThemeData(
    iconColor: _text,
    textColor: _text,
    titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: _text),
    subtitleTextStyle: TextStyle(fontSize: 16, color: Color(0xFF4A453C)),
    minVerticalPadding: 12,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: _background,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: _text),
    titleTextStyle: TextStyle(
      color: _text,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),

  dividerTheme: const DividerThemeData(
    color: _border,
    thickness: 1.5,
    space: 24,
  ),

  tabBarTheme: const TabBarThemeData(
    labelColor: _primary,
    unselectedLabelColor: Color(0xFF5E5748),
    labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    unselectedLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
    indicatorSize: TabBarIndicatorSize.tab,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(color: _primary, width: 3),
    ),
  ),

  snackBarTheme: const SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: _text,
    contentTextStyle: TextStyle(color: Colors.white, fontSize: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: _background,
    selectedItemColor: _primary,
    unselectedItemColor: Color(0xFF5E5748),
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    selectedLabelStyle:
        TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    unselectedLabelStyle:
        TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
  ),
);

// Dark Theme (basic support — same readable type scale)
final darkAppTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: _primary,
    primary: const Color(0xFF5FBFBF),
    secondary: const Color(0xFF8FA3D9),
    surface: const Color(0xFF1F1D18),
    error: const Color(0xFFF28B82),
    onPrimary: _text,
    onSecondary: _text,
    onSurface: Colors.white,
    onError: _text,
  ).copyWith(
    surfaceContainerHighest: const Color(0xFF2A2721),
    outline: const Color(0xFF4A453C),
  ),
  scaffoldBackgroundColor: const Color(0xFF1F1D18),

  textTheme: _textTheme(ThemeData.dark().textTheme, Colors.white),

  cardTheme: CardThemeData(
    color: const Color(0xFF2A2721),
    elevation: 0,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_radius),
      side: const BorderSide(color: Color(0xFF4A453C), width: 2),
    ),
  ),

  dialogTheme: DialogThemeData(
    backgroundColor: const Color(0xFF2A2721),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_radius),
      side: const BorderSide(color: Color(0xFF4A453C), width: 2),
    ),
    titleTextStyle: const TextStyle(
        color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
    contentTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF5FBFBF),
      foregroundColor: _text,
      minimumSize: const Size(64, 56),
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius)),
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: const Color(0xFF5FBFBF),
      foregroundColor: _text,
      minimumSize: const Size(64, 56),
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius)),
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF5FBFBF),
      minimumSize: const Size(64, 56),
      side: const BorderSide(color: Color(0xFF5FBFBF), width: 2),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius)),
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF5FBFBF),
      minimumSize: const Size(48, 48),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius)),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF5FBFBF),
    foregroundColor: _text,
    elevation: 0,
    extendedTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2A2721),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF4A453C), width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF4A453C), width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF5FBFBF), width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFF28B82), width: 2),
    ),
    labelStyle: const TextStyle(color: Color(0xFFC9C2B2), fontSize: 18),
    hintStyle: const TextStyle(color: Color(0xFF9A927E), fontSize: 18),
    floatingLabelStyle: const TextStyle(
        color: Color(0xFF5FBFBF), fontWeight: FontWeight.w600),
  ),

  listTileTheme: const ListTileThemeData(
    iconColor: Colors.white,
    textColor: Colors.white,
    titleTextStyle: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
    subtitleTextStyle: TextStyle(fontSize: 16, color: Color(0xFFC9C2B2)),
    minVerticalPadding: 12,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1F1D18),
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),

  dividerTheme: const DividerThemeData(
    color: Color(0xFF4A453C),
    thickness: 1.5,
    space: 24,
  ),

  tabBarTheme: const TabBarThemeData(
    labelColor: Color(0xFF5FBFBF),
    unselectedLabelColor: Color(0xFFC9C2B2),
    labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    unselectedLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
    indicatorSize: TabBarIndicatorSize.tab,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(color: Color(0xFF5FBFBF), width: 3),
    ),
  ),

  snackBarTheme: const SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Color(0xFF3A362D),
    contentTextStyle: TextStyle(color: Colors.white, fontSize: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1F1D18),
    selectedItemColor: Color(0xFF5FBFBF),
    unselectedItemColor: Color(0xFFC9C2B2),
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    selectedLabelStyle:
        TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    unselectedLabelStyle:
        TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
  ),
);
