import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Brand Palette
const _primary = Color(0xFF00695C); // Deep Teal
const _secondary = Color(0xFFFFB300); // Warm Amber
const _background = Color(0xFFF8F5EE); // Warm Minimal Background
const _text = Color(0xFF1F2937); // Dark Gray for strong contrast
const _sosRed = Color(0xFFD32F2F); // Strong red
const _surface = Colors.white;
const _divider = Color(0xFFE5E7EB);

final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _primary,
    primary: _primary,
    secondary: _secondary,
    surface: _surface,
    error: _sosRed,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: _text,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: _background,
  
  // Font: Inter, with consistent weight scale
  textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
    displayLarge: GoogleFonts.inter(color: _text, fontWeight: FontWeight.bold),
    displayMedium: GoogleFonts.inter(color: _text, fontWeight: FontWeight.bold),
    displaySmall: GoogleFonts.inter(color: _text, fontWeight: FontWeight.w600),
    headlineLarge: GoogleFonts.inter(color: _text, fontWeight: FontWeight.w600, fontSize: 32),
    headlineMedium: GoogleFonts.inter(color: _text, fontWeight: FontWeight.w600, fontSize: 28),
    headlineSmall: GoogleFonts.inter(color: _text, fontWeight: FontWeight.w600, fontSize: 24), // headline 24sp
    titleLarge: GoogleFonts.inter(color: _text, fontWeight: FontWeight.w600, fontSize: 20), // title 20sp
    titleMedium: GoogleFonts.inter(color: _text, fontWeight: FontWeight.w600, fontSize: 16),
    titleSmall: GoogleFonts.inter(color: _text, fontWeight: FontWeight.w500, fontSize: 14),
    // Base accessible font size (16sp)
    bodyLarge: GoogleFonts.inter(color: _text, fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: GoogleFonts.inter(color: _text, fontSize: 14, fontWeight: FontWeight.w400), // subtitle 14sp
    bodySmall: GoogleFonts.inter(color: _text, fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge: GoogleFonts.inter(color: _text, fontSize: 14, fontWeight: FontWeight.w500),
  ),

  // Card-based minimal design
  cardTheme: CardThemeData(
    color: _surface,
    elevation: 0,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: _divider, width: 1), // Subtle border for contrast
    ),
  ),

  // Accessible large touch targets (min 48dp)
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 48), 
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: _primary,
      minimumSize: const Size(double.infinity, 48),
      side: const BorderSide(color: _primary, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _primary,
      minimumSize: const Size(64, 48), // Standard min touch target
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),

  // Clear accessible labels and form inputs
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _divider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _sosRed, width: 1),
    ),
    labelStyle: GoogleFonts.inter(color: const Color(0xFF4B5563), fontSize: 16),
    floatingLabelStyle: GoogleFonts.inter(color: _primary, fontWeight: FontWeight.w500),
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: _background,
    elevation: 0,
    centerTitle: true,
    iconTheme: const IconThemeData(color: _text),
    titleTextStyle: GoogleFonts.inter(
      color: _text,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),

  dividerTheme: const DividerThemeData(
    color: _divider,
    thickness: 1,
    space: 24,
  ),
  
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: _surface,
    selectedItemColor: _primary,
    unselectedItemColor: Color(0xFF9CA3AF),
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
);

// Dark Theme (basic support)
final darkAppTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: _primary,
    primary: _primary,
    secondary: _secondary,
    surface: const Color(0xFF1F2937),
    error: _sosRed,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Colors.white,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFF111827),
  
  textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
    headlineSmall: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 24),
    titleLarge: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),
    titleMedium: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
    titleSmall: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
    bodyLarge: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
  ),

  cardTheme: CardThemeData(
    color: const Color(0xFF1F2937),
    elevation: 0,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFF374151), width: 1),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 48), 
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1F2937),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF374151)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF374151)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _sosRed, width: 1),
    ),
    labelStyle: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 16),
    floatingLabelStyle: GoogleFonts.inter(color: _primary, fontWeight: FontWeight.w500),
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFF111827),
    elevation: 0,
    centerTitle: true,
    iconTheme: const IconThemeData(color: Colors.white),
    titleTextStyle: GoogleFonts.inter(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1F2937),
    selectedItemColor: _primary,
    unselectedItemColor: Color(0xFF9CA3AF),
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
);
