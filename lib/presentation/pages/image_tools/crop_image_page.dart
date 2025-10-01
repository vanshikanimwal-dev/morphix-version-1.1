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

// --- State Providers for Crop Area ---
final cropXControllerProvider = StateProvider<TextEditingController>((ref) => TextEditingController(text: '100'));
final cropYControllerProvider = StateProvider<TextEditingController>((ref) => TextEditingController(text: '100'));
final cropWidthControllerProvider = StateProvider<TextEditingController>((ref) => TextEditingController(text: '600'));
final cropHeightControllerProvider = StateProvider<TextEditingController>((ref) => TextEditingController(text: '400'));

class CropImagePage extends ConsumerWidget {
  const CropImagePage({super.key});

  Future<void> _processCrop(BuildContext context, WidgetRef ref) async {
    final tasks = ref.read(imageToolProvider);
    final service = ref.read(imageServiceProvider);
    final notifier = ref.read(imageToolProvider.notifier);

    // Parse crop parameters, defaulting to 0 if invalid
    final x = int.tryParse(ref.read(cropXControllerProvider).text) ?? 0;
    final y = int.tryParse(ref.read(cropYControllerProvider).text) ?? 0;
    final width = int.tryParse(ref.read(cropWidthControllerProvider).text) ?? 0;
    final height = int.tryParse(ref.read(cropHeightControllerProvider).text) ?? 0;

    if (tasks.isEmpty || width <= 0 || height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload files and enter valid width/height for cropping.')),
      );
      return;
    }

    for (final task in tasks) {
      notifier.updateTask(task.originalFile, isProcessing: true);
      try {
        final croppedFile = await service.cropImage(
          task.originalFile,
          x,
          y,
          width,
          height,
        );
        notifier.updateTask(task.originalFile, processedFile: croppedFile, isCompleted: true, isProcessing: false);
      } catch (e) {
        notifier.updateTask(task.originalFile, error: 'Crop Failed: $e', isProcessing: false);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(imageToolProvider);
    final hasFiles = tasks.isNotEmpty;
    final isProcessing = tasks.any((t) => t.isProcessing);

    // Watch controllers
    final xController = ref.watch(cropXControllerProvider);
    final yController = ref.watch(cropYControllerProvider);
    final widthController = ref.watch(cropWidthControllerProvider);
    final heightController = ref.watch(cropHeightControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Crop Image')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UploadBox(
              title: 'Upload Images to Crop',
              allowedExtensions: 'jpg, png',
              onFilesSelected: ref.read(imageToolProvider.notifier).addFiles,
            ),
            const SizedBox(height: 30),

            Text('Crop Area (Pixels)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),

            // X and Y Coordinates
            Row(
              children: [
                Expanded(
                  child: NeonTextField(
                    controller: xController,
                    labelText: 'Start X',
                    icon: Icons.east,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: NeonTextField(
                    controller: yController,
                    labelText: 'Start Y',
                    icon: Icons.south,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Width and Height
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
                  text: 'Crop Images (${tasks.length} files)',
                  onPressed: () => _processCrop(context, ref),
                  neonColor: AppColors.softBlue,
                  icon: Icons.crop,
                ),
              ),
          ],
        ),
      ),
    );
  }
}