import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morphixapp/core/utils/colors.dart';
import 'package:morphixapp/data/services/image_service.dart';
import 'package:morphixapp/main.dart'; // Assumed to contain imageServiceProvider
import 'package:morphixapp/presentation/state/image_tool_provider.dart';
import 'package:morphixapp/presentation/widgets/custom_button.dart';
import 'package:morphixapp/presentation/widgets/preview_grid.dart';
import 'package:morphixapp/presentation/widgets/upload_box.dart';

final jpgQualityProvider = StateProvider<double>((ref) => 90.0);

class ConvertToJpgPage extends ConsumerWidget {
  const ConvertToJpgPage({super.key});

  Future<void> _processConversion(WidgetRef ref) async {
    final tasks = ref.read(imageToolProvider);
    // FIX: Use the generic 'convertImage' method defined in ImageService
    final service = ref.read(imageServiceProvider);
    final quality = ref.read(jpgQualityProvider).round();
    final notifier = ref.read(imageToolProvider.notifier);

    for (final task in tasks) {
      notifier.updateTask(task.originalFile, isProcessing: true);
      try {
        // FIX: Call the correct method (convertImage) and pass 'jpg' as the target format.
        // NOTE: The 'quality' parameter is ignored by the current generic convertImage,
        // but it can be handled inside ImageService if needed. For now, we only pass format.
        final convertedFile = await service.convertImage(task.originalFile, 'jpg');

        notifier.updateTask(task.originalFile, processedFile: convertedFile, isCompleted: true, isProcessing: false);
      } catch (e) {
        // Log the error for better debugging
        print('Conversion to JPG error for ${task.originalFile.path}: $e');
        notifier.updateTask(task.originalFile, error: 'Conversion Failed: $e', isProcessing: false);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(imageToolProvider);
    final quality = ref.watch(jpgQualityProvider);
    final isProcessing = tasks.any((t) => t.isProcessing);

    return Scaffold(
      appBar: AppBar(title: const Text('Convert to JPG')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UploadBox(
              title: 'Upload PNG, GIF, BMP, WebP',
              allowedExtensions: 'png, gif, bmp, webp',
              onFilesSelected: ref.read(imageToolProvider.notifier).addFiles,
            ),
            const SizedBox(height: 30),
            Text('JPG Quality: ${quality.round()}%', style: Theme.of(context).textTheme.titleMedium),
            Slider(
              value: quality,
              min: 10,
              max: 100,
              activeColor: AppColors.neonTeal,
              // Only allow changing quality if files are present to avoid unnecessary state changes
              onChanged: tasks.isEmpty ? null : (value) => ref.read(jpgQualityProvider.notifier).state = value,
            ),

            // Only show PreviewGrid if files are present
            if (tasks.isNotEmpty) ...[
              const SizedBox(height: 20),
              PreviewGrid(
                files: tasks.map((t) => t.originalFile).toList(),
                onRemove: ref.read(imageToolProvider.notifier).removeFile,
              ),
            ],

            if (tasks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: isProcessing
                    ? Center(child: CircularProgressIndicator(color: AppColors.neonTeal))
                    : NeonButton(
                  text: 'Convert to JPG (${tasks.length} files)',
                  onPressed: () => _processConversion(ref),
                  neonColor: AppColors.electricPurple,
                  icon: Icons.flash_on,
                ),
              ),
          ],
        ),
      ),
    );
  }
}