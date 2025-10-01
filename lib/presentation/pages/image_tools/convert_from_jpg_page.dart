import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morphixapp/core/utils/colors.dart';
import 'package:morphixapp/data/services/image_service.dart';
import 'package:morphixapp/main.dart'; // Assumed to contain imageServiceProvider
import 'package:morphixapp/presentation/state/image_tool_provider.dart';
import 'package:morphixapp/presentation/widgets/custom_button.dart';
import 'package:morphixapp/presentation/widgets/preview_grid.dart';
import 'package:morphixapp/presentation/widgets/upload_box.dart';

// Expanded the list to include more common formats supported by ImageService
final targetFormatProvider = StateProvider<String>((ref) => 'png');
const List<String> formats = ['png', 'gif', 'bmp', 'tiff'];

class ConvertFromJpgPage extends ConsumerWidget {
  const ConvertFromJpgPage({super.key});

  Future<void> _processConversion(WidgetRef ref) async {
    final tasks = ref.read(imageToolProvider);
    // FIX: Use the generic 'convertImage' method defined in ImageService
    final service = ref.read(imageServiceProvider);
    final format = ref.read(targetFormatProvider);
    final notifier = ref.read(imageToolProvider.notifier);

    for (final task in tasks) {
      notifier.updateTask(task.originalFile, isProcessing: true);
      try {
        // FIX: Call the correct method
        final convertedFile = await service.convertImage(task.originalFile, format);
        notifier.updateTask(task.originalFile, processedFile: convertedFile, isCompleted: true, isProcessing: false);
      } catch (e) {
        // Log the error for better debugging
        print('Conversion error for ${task.originalFile.path}: $e');
        notifier.updateTask(task.originalFile, error: 'Conversion Failed: $e', isProcessing: false);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(imageToolProvider);
    final format = ref.watch(targetFormatProvider);
    final isProcessing = tasks.any((t) => t.isProcessing);

    return Scaffold(
      appBar: AppBar(title: const Text('Convert from JPG')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UploadBox(
              title: 'Upload JPG files to convert',
              allowedExtensions: 'jpg, jpeg',
              onFilesSelected: ref.read(imageToolProvider.notifier).addFiles,
            ),
            const SizedBox(height: 30),
            Text('Target Format', style: Theme.of(context).textTheme.titleMedium),
            DropdownButtonFormField<String>(
              value: format,
              decoration: InputDecoration(
                fillColor: AppColors.accentCharcoal,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              dropdownColor: AppColors.accentCharcoal,
              style: const TextStyle(color: AppColors.textWhite),
              items: formats.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.toUpperCase(), style: const TextStyle(color: AppColors.textWhite)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) ref.read(targetFormatProvider.notifier).state = newValue;
              },
            ),

            // Check if there are files before showing the grid to prevent layout issues
            if (tasks.isNotEmpty) ...[
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
                    ? Center(child: CircularProgressIndicator(color: AppColors.electricPurple))
                    : NeonButton(
                  text: 'Convert to ${format.toUpperCase()} (${tasks.length} files)',
                  onPressed: () => _processConversion(ref),
                  neonColor: AppColors.softBlue,
                  icon: Icons.switch_left,
                ),
              ),
          ],
        ),
      ),
    );
  }
}