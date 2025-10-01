import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morphixapp/core/utils/app_routes.dart';
// NOTE: We don't need colors.dart and its constants here anymore
// because morphixDarkTheme already contains all the styling.
// import 'package:morphixapp/core/utils/colors.dart';
import 'package:morphixapp/core/theme/theme_data.dart'; // <-- IMPORT YOUR CUSTOM THEME
import 'package:morphixapp/data/auth/auth_model.dart';
import 'package:morphixapp/data/auth/auth_notifier.dart';
import 'package:morphixapp/data/services/image_service.dart';
import 'package:morphixapp/data/services/pdf_service.dart';

// -----------------------------------------------------------------------------
// --- 1. Global Providers (State & Services) ---
// -----------------------------------------------------------------------------

/// Manages the authentication state (simulated user object).
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier();
});

/// A convenience provider to easily access the current authentication state.
final authStateProvider = Provider<AsyncValue<User?>>((ref) {
  return ref.watch(authNotifierProvider);
});

/// Provides the image processing service for all tools.
final imageServiceProvider = Provider<ImageService>((ref) => ImageService());

/// Provides the PDF processing service.
final pdfServiceProvider = Provider<PDFService>((ref) => PDFService());

// -----------------------------------------------------------------------------
// --- 2. Application Entry Point ---
// -----------------------------------------------------------------------------

void main() {
  // Enables Riverpod for the entire application
  runApp(const ProviderScope(child: MyApp()));
}

// -----------------------------------------------------------------------------
// --- 3. Main Widget (Router & Theme Setup) ---
// -----------------------------------------------------------------------------

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the auth state to determine routing behavior (logged in vs. guest)
    final authState = ref.watch(authStateProvider);

    // --- GoRouter Configuration ---
    final router = GoRouter(
      routes: AppRoutes.routes,
      initialLocation: AppRoutes.splash,

      // --- Authentication Redirect Logic ---
      redirect: (context, state) {
        // Check for loading state or initial un-resolved state
        final isAuthLoading = authState.isLoading || (authState.value == null && authState.hasValue == false);
        final isLoggedIn = authState.value != null;

        final path = state.uri.path;

        // Define common path categories
        final isAuthPath = [AppRoutes.login, AppRoutes.signup, AppRoutes.forgotPassword].contains(path);
        final isSplashOrOnboarding = path == AppRoutes.splash || path == AppRoutes.onboarding;
        final isToolPage = path.startsWith('/tool'); // Allow guests to use tool pages

        // 1. Wait for AuthState to initialize
        if (isAuthLoading && !isSplashOrOnboarding) {
          return null; // Stay on the current path
        }

        // 2. Unauthenticated User
        if (!isLoggedIn) {
          if (isSplashOrOnboarding || isAuthPath || isToolPage) {
            return null; // Allow access to non-authenticated paths
          }
          // Redirect unauthorized access to the Login page
          return AppRoutes.login;
        }

        // 3. Authenticated User
        if (isAuthPath) {
          // If logged in, redirect away from login/signup pages to the Dashboard
          return AppRoutes.dashboard;
        }

        // No redirect needed, proceed to the requested path
        return null;
      },
    );

    // --- Material App Setup (Black Aesthetic Theme) ---
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Morphix Pro',
      // FIX: Use the fully defined and corrected custom dark theme
      theme: morphixDarkTheme,
      // FIX: Explicitly set the mode to dark to ensure the app starts with this theme
      themeMode: ThemeMode.dark,

      // If you implement a light theme later, you can switch this to ThemeMode.system
      // or use darkTheme: morphixDarkTheme if you want a light theme fallback.

      routerConfig: router,
    );
  }
}
