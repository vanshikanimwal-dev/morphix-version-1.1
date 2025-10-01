import 'package:flutter/material.dart';
import 'package:morphixapp/core/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Neon Glow Shadow Effect ---
BoxShadow neonGlowShadow({Color color = AppColors.neonTeal, double blur = 10, double spread = 2}) {
  return BoxShadow(
    color: color.withOpacity(0.5),
    blurRadius: blur,
    spreadRadius: spread,
    offset: const Offset(0, 0),
  );
}

// --- Text Styles (Poppins/Inter) ---
final TextTheme morphixTextTheme = GoogleFonts.poppinsTextTheme().copyWith(
    headlineLarge: GoogleFonts.poppins(
      color: AppColors.textWhite,
      fontWeight: FontWeight.w900,
    ),
    bodyMedium: GoogleFonts.poppins(
      color: AppColors.textWhite,
    ),
    titleMedium: GoogleFonts.poppins(
      color: AppColors.textGray,
    )
);