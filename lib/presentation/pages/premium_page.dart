import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morphixapp/core/utils/colors.dart';
import 'package:morphixapp/presentation/widgets/custom_button.dart';
import 'package:morphixapp/core/utils/styles.dart';

class PremiumPage extends ConsumerWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Morphix Premium', style: TextStyle(color: AppColors.electricPurple)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Icon(Icons.diamond_outlined, size: 80, color: AppColors.electricPurple),
            ),
            const SizedBox(height: 20),
            Text(
              'Unlock Neo-Powered Processing',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.neonTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            // --- Feature List ---
            _PremiumFeature(
              icon: Icons.flash_on,
              title: 'Lightning Batch Mode',
              subtitle: 'Process 100+ files simultaneously with maximum speed.',
              color: AppColors.neonTeal,
            ),
            _PremiumFeature(
              icon: Icons.cloud_upload,
              title: 'Cloud Sync & Storage',
              subtitle: 'Securely store and access your processed files anywhere.',
              color: AppColors.softBlue,
            ),
            _PremiumFeature(
              icon: Icons.hdr_strong,
              title: 'Pro Quality Outputs',
              subtitle: 'Access high-fidelity export formats (e.g., TIFF, HEIC).',
              color: AppColors.electricPurple,
            ),
            _PremiumFeature(
              // FIX: Replaced removed Icons.ad_off with available Icons.block
              icon: Icons.block,
              title: 'Ad-Free Experience',
              subtitle: 'Uninterrupted flow for ultimate productivity.',
              color: Colors.white,
            ),

            const SizedBox(height: 40),

            // --- Pricing Card ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.accentCharcoal,
                borderRadius: BorderRadius.circular(15),
                // Assuming neonGlowShadow is defined in styles.dart
                boxShadow: [neonGlowShadow(color: AppColors.electricPurple, blur: 10, spread: 2)],
              ),
              child: Column(
                children: [
                  Text(
                    'Morphix Pro Subscription',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.electricPurple),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '\$5.99 / month',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.neonTeal, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 20),
                  NeonButton(
                    text: 'Upgrade Now',
                    onPressed: () {
                      // Placeholder for actual subscription logic
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Processing upgrade... (Demo mode)')));
                    },
                    neonColor: AppColors.neonTeal,
                    icon: Icons.lock_open,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widget for premium features
class _PremiumFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _PremiumFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, size: 30, color: color),
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textGray)),
      ),
    );
  }
}