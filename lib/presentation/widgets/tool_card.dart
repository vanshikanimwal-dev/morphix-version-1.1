import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:morphixapp/core/utils/colors.dart';
import 'package:morphixapp/core/utils/styles.dart';

// --- Tool Card Model ---
class ToolItem {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  const ToolItem({required this.title, required this.icon, required this.color, required this.route});
}

// --- Tool Card Widget ---
class ToolCard extends StatelessWidget {
  final ToolItem tool;

  const ToolCard({super.key, required this.tool});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(tool.route),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.accentCharcoal,
          borderRadius: BorderRadius.circular(20),
          // Subtle neon glow shadow
          boxShadow: [neonGlowShadow(color: tool.color.withOpacity(0.3), blur: 8, spread: 1)],
          border: Border.all(color: tool.color.withOpacity(0.5), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tool.icon,
              size: 48,
              color: tool.color,
            ),
            const SizedBox(height: 12),
            Text(
              tool.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}