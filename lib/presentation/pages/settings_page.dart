import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morphixapp/core/utils/app_routes.dart';
import 'package:morphixapp/core/utils/colors.dart';
import 'package:morphixapp/presentation/widgets/custom_button.dart';
import 'package:morphixapp/main.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get auth state to determine if user is logged in
    final user = ref.watch(authStateProvider).value;
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: AppColors.softBlue)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- User Profile/Account Section ---
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.accentCharcoal,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.softBlue.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Status',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.softBlue),
                  ),
                  const Divider(color: AppColors.textGray),

                  if (user != null)
                    ListTile(
                      leading: const Icon(Icons.person, color: AppColors.textWhite),
                      title: Text(user.email, style: const TextStyle(color: AppColors.textWhite)),
                      subtitle: Text(
                        'Tier: ${user.isPremium ? 'Premium' : 'Free'}',
                        style: TextStyle(color: user.isPremium ? AppColors.electricPurple : AppColors.neonTeal),
                      ),
                    ),

                  if (user == null)
                    const Text('You are currently browsing as a Guest.', style: TextStyle(color: AppColors.textGray)),

                  const SizedBox(height: 15),
                  NeonButton(
                    text: user != null ? 'Logout' : 'Login / Sign Up',
                    onPressed: () {
                      if (user != null) {
                        authNotifier.signOut();
                        context.go(AppRoutes.login);
                      } else {
                        context.go(AppRoutes.login);
                      }
                    },
                    neonColor: user != null ? Colors.red : AppColors.neonTeal,
                    icon: user != null ? Icons.logout : Icons.login,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- App Settings Section ---
            Text('App Preferences', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.softBlue)),
            const Divider(color: AppColors.textGray),

            _SettingTile(
              title: 'Default Output Format',
              subtitle: 'PNG', // Static for demo
              icon: Icons.image_outlined,
              onTap: () {},
            ),
            _SettingTile(
              title: 'Clear Temporary Files',
              subtitle: 'Free up space on your device',
              icon: Icons.delete_sweep,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Temporary files cleared.')));
              },
            ),
            _SettingTile(
              title: 'About Morphix',
              subtitle: 'Version 1.0.0',
              icon: Icons.info_outline,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widget for setting list tiles
class _SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.accentCharcoal,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppColors.electricPurple),
        title: Text(title, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textGray)),
        trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.textGray, size: 16),
        onTap: onTap,
      ),
    );
  }
}