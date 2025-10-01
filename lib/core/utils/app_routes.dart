import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Core Pages
import 'package:morphixapp/presentation/pages/auth/forgot_password_page.dart';
import 'package:morphixapp/presentation/pages/auth/login_page.dart';
import 'package:morphixapp/presentation/pages/auth/signup_page.dart';
import 'package:morphixapp/presentation/pages/dashboard/dashboard_page.dart';
import 'package:morphixapp/presentation/pages/onboarding_page.dart';
import 'package:morphixapp/presentation/pages/splash_page.dart';
// New Pages
import 'package:morphixapp/presentation/pages/settings_page.dart'; // NEW
import 'package:morphixapp/presentation/pages/premium_page.dart'; // NEW
// Tool Pages (Partial list for import clarity)
import 'package:morphixapp/presentation/pages/image_tools/compress_image_page.dart';
import 'package:morphixapp/presentation/pages/image_tools/resize_image_page.dart';
import 'package:morphixapp/presentation/pages/image_tools/crop_image_page.dart';
import 'package:morphixapp/presentation/pages/image_tools/convert_to_jpg_page.dart'; // Assuming you created this from Step 6
import 'package:morphixapp/presentation/pages/image_tools/convert_from_jpg_page.dart'; // Assuming you created this from Step 6
import 'package:morphixapp/presentation/pages/image_tools/edit_image_page.dart';
import 'package:morphixapp/presentation/pages/image_tools/add_watermark_page.dart';
import 'package:morphixapp/presentation/pages/image_tools/meme_generator_page.dart';
import 'package:morphixapp/presentation/pages/image_tools/photo_organizer_page.dart';
import 'package:morphixapp/presentation/pages/image_tools/gif_maker_page.dart';
import 'package:morphixapp/presentation/pages/image_tools/image_to_pdf_page.dart';
import 'package:morphixapp/presentation/pages/image_tools/pdf_to_image_page.dart';
import 'package:morphixapp/presentation/pages/image_tools/crop_pdf_page.dart';


class AppRoutes {
  // --- Core Routes ---
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String settings = '/settings';
  static const String premium = '/premium';

  // --- Tool Routes (All 13) ---
  static const String compress = '/tool/compress';
  static const String resize = '/tool/resize';
  static const String crop = '/tool/crop';
  static const String convertToJpg = '/tool/to-jpg';
  static const String convertFromJpg = '/tool/from-jpg';
  static const String imageEditor = '/tool/editor';
  static const String watermark = '/tool/watermark';
  static const String memeGenerator = '/tool/meme';
  static const String photoOrganizer = '/tool/organizer';
  static const String gifMaker = '/tool/gif-maker';
  static const String imageToPdf = '/tool/img-to-pdf';
  static const String pdfToImage = '/tool/pdf-to-img';
  static const String cropPdf = '/tool/crop-pdf';

  static final List<GoRoute> routes = [
    // Core Routes
    GoRoute(path: splash, builder: (context, state) => const SplashPage()),
    GoRoute(path: onboarding, builder: (context, state) => const OnboardingPage()),
    GoRoute(path: login, builder: (context, state) => const LoginPage()),
    GoRoute(path: signup, builder: (context, state) => const SignUpPage()),
    GoRoute(path: forgotPassword, builder: (context, state) => const ForgotPasswordPage()),
    GoRoute(path: dashboard, builder: (context, state) => const DashboardPage()),
    GoRoute(path: settings, builder: (context, state) => const SettingsPage()), // UPDATED
    GoRoute(path: premium, builder: (context, state) => const PremiumPage()), // UPDATED

    // Tool Routes (Fully linked from Step 6 implementations)
    GoRoute(path: compress, builder: (context, state) => const CompressImagePage()),
    GoRoute(path: resize, builder: (context, state) => const ResizeImagePage()),
    GoRoute(path: crop, builder: (context, state) => const CropImagePage()),
    GoRoute(path: convertToJpg, builder: (context, state) => const ConvertToJpgPage()),
    GoRoute(path: convertFromJpg, builder: (context, state) => const ConvertFromJpgPage()),
    GoRoute(path: imageEditor, builder: (context, state) => const EditImagePage()),
    GoRoute(path: watermark, builder: (context, state) => const AddWatermarkPage()),
    GoRoute(path: memeGenerator, builder: (context, state) => const MemeGeneratorPage()),
    GoRoute(path: photoOrganizer, builder: (context, state) => const PhotoOrganizerPage()),
    GoRoute(path: gifMaker, builder: (context, state) => const GIFMakerPage()),
    GoRoute(path: imageToPdf, builder: (context, state) => const ImageToPDFPage()),
    GoRoute(path: pdfToImage, builder: (context, state) => const PDFToImagePage()),
    GoRoute(path: cropPdf, builder: (context, state) => const CropPDFPage()),
  ];
}