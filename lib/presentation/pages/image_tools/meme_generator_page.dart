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

final topTextProvider = StateProvider<TextEditingController>((ref) => TextEditingController(text: 'Top Text'));
final bottomTextProvider = StateProvider<TextEditingController>((ref) => TextEditingController(text: 'Bottom Text'));

class MemeGeneratorPage extends ConsumerWidget {
  const MemeGeneratorPage({super.key});

  Future<void> _processMeme(WidgetRef ref) async {
    final tasks = ref.read(imageToolProvider);
    // FIX: Use the dedicated generateMeme method (Tool 8)
    final service = ref.read(imageServiceProvider);
    final topText = ref.read(topTextProvider).text;
    final bottomText = ref.read(bottomTextProvider).text;
    final notifier = ref.read(imageToolProvider.notifier);

    for (final task in tasks) {
      notifier.updateTask(task.originalFile, isProcessing: true);
      try {
        // FIX: Call the correct method, passing both required strings
        final memeFile = await service.generateMeme(
          task.originalFile,
          topText,
          bottomText,
        );

        notifier.updateTask(task.originalFile, processedFile: memeFile, isCompleted: true, isProcessing: false);
      } catch (e) {
        // Log the error for better debugging
        print('Meme generation failed for ${task.originalFile.path}: $e');
        notifier.updateTask(task.originalFile, error: 'Meme Failed: $e', isProcessing: false);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(imageToolProvider);
    final isProcessing = tasks.any((t) => t.isProcessing);
    final hasFiles = tasks.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Meme Generator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UploadBox(
              title: 'Upload Image for Meme',
              allowedExtensions: 'jpg, png',
              onFilesSelected: ref.read(imageToolProvider.notifier).addFiles,
            ),
            const SizedBox(height: 30),

            Text('Top Text', style: Theme.of(context).textTheme.titleMedium),
            NeonTextField(
              controller: ref.read(topTextProvider),
              labelText: 'Top Text',
              icon: Icons.title,
            ),
            const SizedBox(height: 20),
            Text('Bottom Text', style: Theme.of(context).textTheme.titleMedium),
            NeonTextField(
              controller: ref.read(bottomTextProvider),
              labelText: 'Bottom Text',
              icon: Icons.subtitles,
            ),

            // Only show the grid if files are present
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
                  text: 'Generate Meme (${tasks.length} files)',
                  onPressed: () => _processMeme(ref),
                  neonColor: AppColors.electricPurple,
                  icon: Icons.sentiment_very_satisfied,
                ),
              ),
          ],
        ),
      ),
    );
  }
}