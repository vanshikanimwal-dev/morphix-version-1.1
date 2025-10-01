import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:morphixapp/core/utils/app_routes.dart';
import 'package:morphixapp/core/utils/colors.dart';
import 'package:morphixapp/presentation/widgets/custom_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // Requires dependency in pubspec

class OnboardingContent {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingContent(this.title, this.description, this.icon, this.color);
}

final List<OnboardingContent> onboardingData = [
  OnboardingContent(
    "Neo-Compression",
    "Shrink image size without losing quality. Fast, efficient, and powered by neon algorithms.",
    Icons.compress,
    AppColors.neonTeal,
  ),
  OnboardingContent(
    "Edit, Crop, Convert",
    "All the tools you need in one dark, sleek interface. From cropping to converting GIFs to PDF.",
    Icons.edit_attributes,
    AppColors.electricPurple,
  ),
  OnboardingContent(
    "Batch Processing Power",
    "Upload multiple files and apply tools in one go. Optimized for speed and efficiency.",
    Icons.batch_prediction,
    AppColors.softBlue,
  ),
];

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final content = onboardingData[index];
              return OnboardingSlide(content: content);
            },
          ),

          // --- Pagination Dots ---
          Align(
            alignment: const Alignment(0, 0.7),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: onboardingData.length,
              effect: ExpandingDotsEffect(
                activeDotColor: AppColors.neonTeal,
                dotColor: AppColors.textGray.withOpacity(0.5),
                dotHeight: 8,
                dotWidth: 8,
              ),
            ),
          ),

          // --- CTA Buttons ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50, left: 30, right: 30),
              child: _currentPage == onboardingData.length - 1
                  ? NeonButton(
                text: "Sign Up or Log In",
                onPressed: () => context.go(AppRoutes.login),
                neonColor: AppColors.neonTeal,
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => context.go(AppRoutes.dashboard),
                    child: const Text('Continue as Guest', style: TextStyle(color: AppColors.textGray)),
                  ),
                  NeonButton(
                    text: "Next",
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeIn,
                      );
                    },
                    neonColor: AppColors.electricPurple,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Widget for each slide
class OnboardingSlide extends StatelessWidget {
  final OnboardingContent content;

  const OnboardingSlide({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            content.icon,
            size: 120,
            color: content.color,
          ),
          const SizedBox(height: 50),
          Text(
            content.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: content.color,
              fontWeight: FontWeight.bold,
              fontSize: 36,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            content.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textGray,
            ),
          ),
        ],
      ),
    );
  }
}