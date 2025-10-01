import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morphixapp/core/utils/colors.dart';
import 'package:morphixapp/data/services/image_service.dart';
import 'package:morphixapp/main.dart';
import 'package:morphixapp/presentation/state/image_tool_provider.dart';
import 'package:morphixapp/presentation/widgets/custom_button.dart';
import 'package:morphixapp/presentation/widgets/preview_grid.dart';
import 'package:morphixapp/presentation/widgets/upload_box.dart';

final rotationProvider = StateProvider<int>((ref) => 0);
final flipHProvider = StateProvider<bool>((ref) => false);
final flipVProvider = StateProvider<bool>((ref) => false);
final grayscaleProvider = StateProvider<bool>((ref) => false);

class EditImagePage extends ConsumerWidget {
  const EditImagePage({super.key});

  Future<void> _processEditing(WidgetRef ref) async {
    final tasks = ref.read(imageToolProvider);
    final service = ref.read(imageServiceProvider);
    final rotate = ref.read(rotationProvider);
    final flipH = ref.read(flipHProvider);
    final flipV = ref.read(flipVProvider);
    final grayscale = ref.read(grayscaleProvider);
    final notifier = ref.read(imageToolProvider.notifier);

    if (tasks.isEmpty) return;

    for (final task in tasks) {
      notifier.updateTask(task.originalFile, isProcessing: true);
      try {
        final editedFile = await service.applyEdit(
          task.originalFile,
          rotate: rotate,
          flipH: flipH,
          flipV: flipV,
          grayscale: grayscale,
        );
        notifier.updateTask(task.originalFile, processedFile: editedFile, isCompleted: true, isProcessing: false);
      } catch (e) {
        notifier.updateTask(task.originalFile, error: 'Editing Failed: $e', isProcessing: false);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(imageToolProvider);
    final hasFiles = tasks.isNotEmpty;
    final isProcessing = tasks.any((t) => t.isProcessing);

    // FIX: Define functions that check 'hasFiles' internally
    void rotate() {
      if (!hasFiles) return;
      ref.read(rotationProvider.notifier).state = (ref.read(rotationProvider) + 90) % 360;
    }

    void flipH() {
      if (!hasFiles) return;
      ref.read(flipHProvider.notifier).state = !ref.read(flipHProvider);
    }

    void flipV() {
      if (!hasFiles) return;
      ref.read(flipVProvider.notifier).state = !ref.read(flipVProvider);
    }


    return Scaffold(
      appBar: AppBar(title: const Text('Image Editor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UploadBox(
              title: 'Upload Images to Edit',
              allowedExtensions: 'jpg, png',
              onFilesSelected: ref.read(imageToolProvider.notifier).addFiles,
            ),
            const SizedBox(height: 30),
            Text('Transformations', style: Theme.of(context).textTheme.titleMedium),

            // --- Controls ---
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                // FIX: Pass the non-nullable function. The function handles the `hasFiles` check.
                NeonButton(
                  text: 'Rotate 90°',
                  onPressed: rotate,
                  neonColor: AppColors.softBlue,
                  icon: Icons.rotate_right,
                ),
                // FIX: Pass the non-nullable function.
                NeonButton(
                  text: 'Flip Horizontal',
                  onPressed: flipH,
                  neonColor: ref.watch(flipHProvider) ? AppColors.neonTeal : AppColors.softBlue,
                  icon: Icons.flip,
                ),
                // FIX: Pass the non-nullable function.
                NeonButton(
                  text: 'Flip Vertical',
                  onPressed: flipV,
                  neonColor: ref.watch(flipVProvider) ? AppColors.neonTeal : AppColors.softBlue,
                  icon: Icons.flip_to_front,
                ),

                // Toggle Filters (ChoiceChip)
                ChoiceChip(
                  label: const Text('Grayscale'),
                  selected: ref.watch(grayscaleProvider),
                  selectedColor: AppColors.electricPurple.withOpacity(0.5),
                  // Use the standard nullable onPressed for ChoiceChip
                  onSelected: hasFiles ? (val) => ref.read(grayscaleProvider.notifier).state = val : null,
                  disabledColor: AppColors.accentCharcoal,
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

            if (tasks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: isProcessing
                    ? Center(child: CircularProgressIndicator(color: AppColors.neonTeal))
                    : NeonButton(
                  text: 'Apply Edits (${tasks.length} files)',
                  onPressed: () => _processEditing(ref),
                  neonColor: AppColors.electricPurple,
                  icon: Icons.check,
                ),
              ),
          ],
        ),
      ),
    );
  }
}