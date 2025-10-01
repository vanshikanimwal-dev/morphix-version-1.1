import 'package:flutter/material.dart';
import 'package:morphixapp/core/utils/colors.dart';
import 'package:morphixapp/core/utils/styles.dart';

// 1. DEFINE A DARK COLORSCHEME FIRST
final morphixDarkColorScheme = ColorScheme.dark(
  primary: AppColors.neonTeal,
  // The background and surface colors help theme other widgets
  background: AppColors.backgroundMatteBlack,
  surface: AppColors.accentCharcoal,
  error: Colors.redAccent,
  onPrimary: AppColors.textWhite,
  onSurface: AppColors.textWhite,
  onBackground: AppColors.textWhite,
  brightness: Brightness.dark, // Ensure the scheme is explicitly dark
);

final morphixDarkTheme = ThemeData(
  // Core Settings
  // FIX 1: Set brightness from the color scheme to ensure the assertion passes.
  brightness: morphixDarkColorScheme.brightness,

  // FIX 2: Pass the explicitly defined dark ColorScheme.
  colorScheme: morphixDarkColorScheme,

  // primaryColor is deprecated when colorScheme is used, but we keep scaffold
  scaffoldBackgroundColor: AppColors.backgroundMatteBlack,
  useMaterial3: true,

  // Typography
  textTheme: morphixTextTheme.apply(
    bodyColor: AppColors.textWhite,
    displayColor: AppColors.textWhite,
  ),

  // AppBar Theme
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.backgroundMatteBlack,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(color: AppColors.neonTeal, fontSize: 20, fontWeight: FontWeight.bold),
  ),

  // Card Theme (Glassmorphism inspired Charcoal)
  // 💥 NOTE: Changed 'CardTheme' to 'CardThemeData' is correct for older versions,
  // but newer Material 3 uses 'CardTheme'. We'll stick to 'CardThemeData'
  // to avoid further runtime errors if the Flutter version is slightly older.
  cardTheme: CardThemeData(
    // The color is now set to use the colorScheme surface color for consistency
    color: morphixDarkColorScheme.surface,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
      side: const BorderSide(color: AppColors.neonTeal, width: 0.5), // Subtle border
    ),
    shadowColor: AppColors.neonTeal.withOpacity(0.2),
    margin: const EdgeInsets.all(8),
  ),

  // Input Field Decoration (Neon Glow Focus)
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.accentCharcoal,
    hintStyle: TextStyle(color: AppColors.textGray.withOpacity(0.7)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: AppColors.accentCharcoal),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: AppColors.neonTeal, width: 2), // Neon border on focus
    ),
  ),
);
