import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morphixapp/core/utils/colors.dart';
import 'package:morphixapp/data/services/image_service.dart';
import 'package:morphixapp/main.dart'; // Assumed to contain imageServiceProvider
import 'package:morphixapp/presentation/state/image_tool_provider.dart';
import 'package:morphixapp/presentation/widgets/custom_button.dart';
import 'package:morphixapp/presentation/widgets/neon_textfield.dart';
import 'package:morphixapp/presentation/widgets/preview_grid.dart';
import 'package:morphixapp/presentation/widgets/upload_box.dart';

// --- State Providers ---
final widthControllerProvider = StateProvider<TextEditingController>((ref) => TextEditingController(text: '800'));
final heightControllerProvider = StateProvider<TextEditingController>((ref) => TextEditingController(text: '600'));
final maintainRatioProvider = StateProvider<bool>((ref) => true);

class ResizeImagePage extends ConsumerWidget {
  const ResizeImagePage({super.key});

  Future<void> _processResize(BuildContext context, WidgetRef ref) async {
    final tasks = ref.read(imageToolProvider);
    final service = ref.read(imageServiceProvider);
    final notifier = ref.read(imageToolProvider.notifier);

    // Parse dimensions, defaulting to 0 if empty or invalid
    final widthText = ref.read(widthControllerProvider).text;
    final heightText = ref.read(heightControllerProvider).text;
    final maintainRatio = ref.read(maintainRatioProvider);

    final width = int.tryParse(widthText) ?? 0;
    final height = int.tryParse(heightText) ?? 0;

    if (width <= 0 && height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid Width or Height value.')),
      );
      return;
    }

    for (final task in tasks) {
      notifier.updateTask(task.originalFile, isProcessing: true);
      try {
        final resizedFile = await service.resizeImage(
          task.originalFile,
          width,
          height,
          maintainRatio: maintainRatio,
        );
        notifier.updateTask(task.originalFile, processedFile: resizedFile, isCompleted: true, isProcessing: false);
      } catch (e) {
        notifier.updateTask(task.originalFile, error: 'Resize Failed: $e', isProcessing: false);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(imageToolProvider);
    final hasFiles = tasks.isNotEmpty;
    final isProcessing = tasks.any((t) => t.isProcessing);

    // Watch controllers for potential UI updates (like enabling/disabling controls)
    final widthController = ref.watch(widthControllerProvider);
    final heightController = ref.watch(heightControllerProvider);
    final maintainRatio = ref.watch(maintainRatioProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Resize Image')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UploadBox(
              title: 'Upload Images to Resize',
              allowedExtensions: 'jpg, png',
              onFilesSelected: ref.read(imageToolProvider.notifier).addFiles,
            ),
            const SizedBox(height: 30),

            Text('Target Dimensions (Pixels)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: NeonTextField(
                    controller: widthController,
                    labelText: 'Width',
                    icon: Icons.unfold_more,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: NeonTextField(
                    controller: heightController,
                    labelText: 'Height',
                    icon: Icons.unfold_less,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- Aspect Ratio Control ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.accentCharcoal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Maintain Aspect Ratio',
                  style: TextStyle(color: AppColors.softBlue, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Ensures the image isn\'t distorted.',
                  style: TextStyle(color: AppColors.textGray),
                ),
                value: maintainRatio,
                onChanged: hasFiles ? (value) {
                  ref.read(maintainRatioProvider.notifier).state = value;
                } : null, // Disable control if no files are uploaded
                activeColor: AppColors.neonTeal,
              ),
            ),

            if (hasFiles) ...[
              const SizedBox(height: 30),
              PreviewGrid(
                files: tasks.map((t) => t.originalFile).toList(),
                onRemove: ref.read(imageToolProvider.notifier).removeFile,
              ),
            ],

            if (hasFiles)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: isProcessing
                    ? Center(child: CircularProgressIndicator(color: AppColors.electricPurple))
                    : NeonButton(
                  text: 'Resize Images (${tasks.length} files)',
                  onPressed: () => _processResize(context, ref),
                  neonColor: AppColors.electricPurple,
                  icon: Icons.aspect_ratio,
                ),
              ),
          ],
        ),
      ),
    );
  }
}