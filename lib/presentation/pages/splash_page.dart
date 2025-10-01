import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morphixapp/core/utils/app_routes.dart';
import 'package:morphixapp/core/utils/colors.dart';
import 'package:morphixapp/core/utils/styles.dart';
import 'package:morphixapp/main.dart';
import 'dart:async';

// Provider to check if onboarding has been viewed (using shared_preferences)
final hasViewedOnboardingProvider = FutureProvider<bool>((ref) async {
  // In a real app, this would use shared_preferences
  // final prefs = await SharedPreferences.getInstance();
  // return prefs.getBool('hasViewedOnboarding') ?? false;
  return false; // For initial development, always show onboarding
});


class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Start the navigation process after a short delay
    Timer(const Duration(seconds: 2), _navigateToNextScreen);
  }

  void _navigateToNextScreen() {
    final hasViewedOnboarding = ref.read(hasViewedOnboardingProvider);
    final authState = ref.read(authStateProvider);

    // If authentication state is still loading, let the router handle it
    if (authState.isLoading) return;

    // Check if onboarding needs to be shown (if user is not logged in AND hasn't seen it)
    if (authState.value == null && hasViewedOnboarding.value == false) {
      context.go(AppRoutes.onboarding);
    } else {
      // If logged in OR already viewed onboarding, the main router redirect
      // handles routing to /dashboard or /login based on authState.value
      // We force a refresh of the router to apply the redirect logic immediately.
      context.go(authState.value != null ? AppRoutes.dashboard : AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- Glowing Morphix Neon Logo ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [neonGlowShadow(color: AppColors.electricPurple)],
              ),
              child: Text(
                'MORPHIX',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.neonTeal,
                  fontSize: 48,
                  letterSpacing: 4,
                  shadows: [neonGlowShadow(color: AppColors.neonTeal, blur: 5, spread: 0)],
                ),
              ),
            ),
            const SizedBox(height: 40),
            CircularProgressIndicator(color: AppColors.neonTeal),
          ],
        ),
      ),
    );
  }
}