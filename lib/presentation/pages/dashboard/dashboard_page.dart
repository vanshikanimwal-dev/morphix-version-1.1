import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for SystemNavigator.pop()
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morphixapp/core/utils/app_routes.dart';
import 'package:morphixapp/core/utils/colors.dart';
import 'package:morphixapp/presentation/widgets/tool_card.dart';

// --- Dashboard Tools Data (13 Features) ---
const List<ToolItem> imageTools = [
  ToolItem(title: 'Compress Image', icon: Icons.compress, color: AppColors.neonTeal, route: AppRoutes.compress),
  ToolItem(title: 'Resize Image', icon: Icons.aspect_ratio, color: AppColors.electricPurple, route: AppRoutes.resize),
  ToolItem(title: 'Crop Image', icon: Icons.crop, color: AppColors.softBlue, route: AppRoutes.crop),
  ToolItem(title: 'Convert to JPG', icon: Icons.image_outlined, color: Color(0xFFFFCC00), route: AppRoutes.convertToJpg), // Yellow
  ToolItem(title: 'Convert from JPG', icon: Icons.switch_left, color: Color(0xFF00FF88), route: AppRoutes.convertFromJpg), // Mint Green
  ToolItem(title: 'Image Editor', icon: Icons.edit_attributes, color: Color(0xFFFF0066), route: AppRoutes.imageEditor), // Hot Pink
  ToolItem(title: 'Add Watermark', icon: Icons.border_color, color: Color(0xFF9900FF), route: AppRoutes.watermark), // Violet
  ToolItem(title: 'Meme Generator', icon: Icons.sentiment_very_satisfied, color: Color(0xFFFF9900), route: AppRoutes.memeGenerator), // Orange
  ToolItem(title: 'Photo Organizer', icon: Icons.grid_on, color: Color(0xFF0099FF), route: AppRoutes.photoOrganizer), // Light Blue
  ToolItem(title: 'GIF Maker', icon: Icons.gif, color: Color(0xFFFF33CC), route: AppRoutes.gifMaker), // Pink
  ToolItem(title: 'Image to PDF', icon: Icons.picture_as_pdf, color: Color(0xFFFF0000), route: AppRoutes.imageToPdf), // Red
  ToolItem(title: 'PDF to Image', icon: Icons.flip_to_back, color: Color(0xFF00FFFF), route: AppRoutes.pdfToImage), // Neon Teal (reused)
  ToolItem(title: 'Crop PDF', icon: Icons.crop_free, color: Color(0xFF33CCFF), route: AppRoutes.cropPdf), // Sky Blue
];


class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  /// Shows a confirmation dialog when the user tries to exit the app.
  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.neonTeal)),
        backgroundColor: AppColors.accentCharcoal,
        title: const Text('Confirm Exit', style: TextStyle(color: AppColors.textWhite)),
        content: const Text('Are you sure you want to exit Morphix Pro?', style: TextStyle(color: AppColors.textGray)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Don't exit
            child: const Text('Cancel', style: TextStyle(color: AppColors.softBlue)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonTeal),
            onPressed: () => Navigator.of(context).pop(true), // Confirm exit
            child: const Text('Exit', style: TextStyle(color: AppColors.backgroundMatteBlack)),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We use PopScope here to intercept the device's back button press.
    return PopScope(
      // 1. Set canPop to false to manually handle the back gesture (prevent default pop)
      canPop: false,

      // 2. Define the handler logic
      onPopInvoked: (bool didPop) async {
        if (didPop) return; // If pop already happened (e.g. internally), ignore.

        final bool shouldExit = await _showExitConfirmationDialog(context);

        if (shouldExit) {
          // If the user confirms exit, we manually close the application.
          // This is necessary because setting canPop: false prevents the default close.
          SystemNavigator.pop();
        }
      },

      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'M O R P H I X',
            style: TextStyle(color: AppColors.neonTeal, letterSpacing: 3, fontWeight: FontWeight.w900),
          ),
          // Back button is correctly omitted here since this is the root screen.
          actions: [
            // Premium Button (Electric Purple Glow)
            IconButton(
              icon: const Icon(Icons.diamond_outlined, color: AppColors.electricPurple),
              onPressed: () => context.go(AppRoutes.premium),
            ),
            // Settings Button (Soft Blue Highlight)
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: AppColors.softBlue),
              onPressed: () => context.go(AppRoutes.settings),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            // Responsive layout for Mobile/Tablet/Web
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180, // Max width of each tile
              childAspectRatio: 0.95,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: imageTools.length,
            itemBuilder: (context, index) {
              // Note: When navigating to a tool page (e.g., AppRoutes.compress),
              // ensure you use context.push() (not context.go()) so the back
              // button appears on the tool page's AppBar.
              return ToolCard(tool: imageTools[index]);
            },
          ),
        ),
      ),
    );
  }
}
