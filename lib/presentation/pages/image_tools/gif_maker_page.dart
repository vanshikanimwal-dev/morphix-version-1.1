import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morphixapp/core/utils/colors.dart';
import 'package:morphixapp/data/services/image_service.dart';
import 'package:morphixapp/main.dart';
import 'package:morphixapp/presentation/state/image_tool_provider.dart';
import 'package:morphixapp/presentation/widgets/custom_button.dart';
import 'package:morphixapp/presentation/widgets/preview_grid.dart';
import 'package:morphixapp/presentation/widgets/upload_box.dart';

final frameDurationProvider = StateProvider<double>((ref) => 200.0); // ms

class GIFMakerPage extends ConsumerWidget {
  const GIFMakerPage({super.key});

  Future<void> _processGif(WidgetRef ref) async {
    final tasks = ref.read(imageToolProvider);
    final service = ref.read(imageServiceProvider);
    final duration = ref.read(frameDurationProvider).round();
    final notifier = ref.read(imageToolProvider.notifier);

    final files = tasks.map((t) => t.originalFile).toList();

    // Check if there are tasks to prevent crash on tasks.first
    if (tasks.isEmpty) return;

    notifier.updateTask(tasks.first.originalFile, isProcessing: true);
    try {
      // FIX: Pass the duration as the named parameter 'frameDelay'
      final gifFile = await service.createGif(files, frameDelay: duration);

      // Clear old tasks and add the single GIF result
      notifier.clear();
      notifier.addFiles([gifFile]);
      notifier.updateTask(gifFile, processedFile: gifFile, isCompleted: true, isProcessing: false);

    } catch (e) {
      notifier.updateTask(tasks.first.originalFile, error: 'GIF Failed: $e', isProcessing: false);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(imageToolProvider);
    final duration = ref.watch(frameDurationProvider);
    final isProcessing = tasks.any((t) => t.isProcessing);
    final hasFiles = tasks.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('GIF Maker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UploadBox(
              title: 'Upload Images (Frames) in order',
              allowedExtensions: 'jpg, png',
              onFilesSelected: ref.read(imageToolProvider.notifier).addFiles,
            ),
            const SizedBox(height: 30),

            Text('Frame Duration: ${duration.round()}ms', style: Theme.of(context).textTheme.titleMedium),
            Slider(
              value: duration,
              min: 50,
              max: 1000,
              divisions: 19,
              activeColor: AppColors.electricPurple,
              // Only allow changing duration if files are present
              onChanged: hasFiles ? (value) => ref.read(frameDurationProvider.notifier).state = value : null,
            ),

            // Only show grid if files are present
            if (hasFiles) ...[
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
                    ? Center(child: CircularProgressIndicator(color: AppColors.softBlue))
                    : NeonButton(
                  text: 'Create GIF (${tasks.length} frames)',
                  onPressed: () => _processGif(ref),
                  neonColor: AppColors.electricPurple,
                  icon: Icons.gif,
                ),
              ),
          ],
        ),
      ),
    );
  }
}