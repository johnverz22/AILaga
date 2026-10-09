import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Brand Palette
const _primary = Color(0xFF0F766E); // Deep Teal
const _accent = Color(0xFF14B8A6);  // Teal Accent
const _background = Color(0xFFF8F5EE); // Warm Minimal Background
const _text = Color(0xFF1F2937); // Dark Gray for strong contrast
const _caution = Color(0xFFD97706); // Amber/Caution

// Semantic colors
const _sosRed = Color(0xFFDC2626); // Distinct but standard red for emergency
const _surface = Colors.white;
const _divider = Color(0xFFE5E7EB);

final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _primary,
    primary: _primary,
    secondary: _accent,
    surface: _surface,
    error: _sosRed,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: _text,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: _background,
  
  // Font: Inter, with consistent weight scale
  textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
    displayLarge: GoogleFonts.inter(color: _text, fontWeight: FontWeight.bold),
    displayMedium: GoogleFonts.inter(color: _text, fontWeight: FontWeight.bold),
    displaySmall: GoogleFonts.inter(color: _text, fontWeight: FontWeight.w600),
    headlineLarge: GoogleFonts.inter(color: _text, fontWeight: FontWeight.w600),
    headlineMedium: GoogleFonts.inter(color: _text, fontWeight: FontWeight.w600),
    headlineSmall: GoogleFonts.inter(color: _text, fontWeight: FontWeight.w600),
    titleLarge: GoogleFonts.inter(color: _text, fontWeight: FontWeight.w600, fontSize: 20),
    titleMedium: GoogleFonts.inter(color: _text, fontWeight: FontWeight.w600, fontSize: 16),
    titleSmall: GoogleFonts.inter(color: _text, fontWeight: FontWeight.w500, fontSize: 14),
    // Base accessible font size (16sp)
    bodyLarge: GoogleFonts.inter(color: _text, fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: GoogleFonts.inter(color: _text, fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: GoogleFonts.inter(color: _text, fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge: GoogleFonts.inter(color: _text, fontSize: 14, fontWeight: FontWeight.w500),
  ),

  // Card-based minimal design
  cardTheme: CardThemeData(
    color: _surface,
    elevation: 0,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: _divider, width: 1), // Subtle border for contrast
    ),
  ),

  // Accessible large touch targets (min 48dp, default to 56dp for main actions)
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 56), 
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    ),
  ),
  
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: _primary,
      minimumSize: const Size(double.infinity, 56),
      side: const BorderSide(color: _primary, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
);
