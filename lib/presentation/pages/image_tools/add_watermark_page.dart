import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morphixapp/core/utils/colors.dart';
import 'package:morphixapp/data/services/image_service.dart';
import 'package:morphixapp/main.dart';
import 'package:morphixapp/presentation/state/image_tool_provider.dart';
import 'package:morphixapp/presentation/widgets/custom_button.dart';
import 'package:morphixapp/presentation/widgets/neon_textfield.dart';
import 'package:morphixapp/presentation/widgets/preview_grid.dart';
import 'package:morphixapp/presentation/widgets/upload_box.dart';

final watermarkTextProvider = StateProvider<TextEditingController>((ref) => TextEditingController(text: 'Morphix'));
final watermarkOpacityProvider = StateProvider<double>((ref) => 0.5);

class AddWatermarkPage extends ConsumerWidget {
  const AddWatermarkPage({super.key});

  Future<void> _processWatermark(WidgetRef ref) async {
    final tasks = ref.read(imageToolProvider);
    // This assumes imageServiceProvider is defined in main.dart
    final service = ref.read(imageServiceProvider);
    final text = ref.read(watermarkTextProvider).text;
    final opacity = ref.read(watermarkOpacityProvider);
    final notifier = ref.read(imageToolProvider.notifier);

    for (final task in tasks) {
      notifier.updateTask(task.originalFile, isProcessing: true);
      try {
        // ASSUMPTION: addTextWatermark is now defined in ImageService (see fix 1)
        final watermarkedFile = await service.addTextWatermark(task.originalFile, text, opacity: opacity);
        notifier.updateTask(task.originalFile, processedFile: watermarkedFile, isCompleted: true, isProcessing: false);
      } catch (e) {
        notifier.updateTask(task.originalFile, error: 'Watermark Failed: $e', isProcessing: false);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(imageToolProvider);
    final opacity = ref.watch(watermarkOpacityProvider);
    final isProcessing = tasks.any((t) => t.isProcessing);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Watermark')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UploadBox(
              title: 'Upload Image for Watermark',
              allowedExtensions: 'jpg, png',
              onFilesSelected: ref.read(imageToolProvider.notifier).addFiles,
            ),
            const SizedBox(height: 30),

            Text('Watermark Text', style: Theme.of(context).textTheme.titleMedium),
            NeonTextField(
              controller: ref.read(watermarkTextProvider),
              labelText: 'Text',
              icon: Icons.text_fields,
            ),

            const SizedBox(height: 20),
            Text('Opacity: ${(opacity * 100).round()}%', style: Theme.of(context).textTheme.titleMedium),
            Slider(
              value: opacity,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              activeColor: AppColors.electricPurple,
              onChanged: tasks.isEmpty ? null : (value) => ref.read(watermarkOpacityProvider.notifier).state = value,
            ),

            PreviewGrid(
              files: tasks.map((t) => t.originalFile).toList(),
              onRemove: ref.read(imageToolProvider.notifier).removeFile,
            ),
            if (tasks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: isProcessing
                    ? Center(child: CircularProgressIndicator(color: AppColors.electricPurple))
                    : NeonButton(
                  text: 'Apply Watermark',
                  onPressed: () => _processWatermark(ref),
                  neonColor: AppColors.softBlue,
                  // FIX: Replaced removed Icons.watermark with a valid icon
                  icon: Icons.draw,
                ),
              ),
          ],
        ),
      ),
    );
  }
}