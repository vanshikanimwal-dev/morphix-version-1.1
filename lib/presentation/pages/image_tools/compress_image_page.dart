import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for haptic feedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morphixapp/core/utils/colors.dart';
import 'package:morphixapp/data/services/image_service.dart'; // Ensure this is imported
import 'package:morphixapp/main.dart'; // Assumed to contain imageServiceProvider
import 'package:morphixapp/presentation/state/image_tool_provider.dart';
import 'package:morphixapp/presentation/widgets/custom_button.dart';
import 'package:morphixapp/presentation/widgets/preview_grid.dart';
import 'package:morphixapp/presentation/widgets/upload_box.dart';

// --- State Provider ---
final compressionQualityProvider = StateProvider<double>((ref) => 80.0);

class CompressImagePage extends ConsumerWidget {
  const CompressImagePage({super.key});

  /// Processes all uploaded files with the selected compression quality.
  Future<void> _processCompression(BuildContext context, WidgetRef ref) async {
    final tasks = ref.read(imageToolProvider);
    final service = ref.read(imageServiceProvider);
    final quality = ref.read(compressionQualityProvider).round();
    final notifier = ref.read(imageToolProvider.notifier);

    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least one image to compress.')),
      );
      return;
    }

    // Process all files sequentially
    for (final task in tasks) {
      notifier.updateTask(task.originalFile, isProcessing: true);
      try {
        // The service runs compression and saves the result to a TEMPORARY file
        final compressedFile = await service.compressImage(task.originalFile, quality);
        notifier.updateTask(task.originalFile, processedFile: compressedFile, isCompleted: true, isProcessing: false);
      } catch (e) {
        notifier.updateTask(task.originalFile, error: 'Compression Failed: $e', isProcessing: false);
      }
    }
  }

  /// Saves all files that have been successfully processed and have a processedFile
  /// to the persistent application documents directory.
  Future<void> _saveAllProcessedFiles(BuildContext context, WidgetRef ref) async {
    final service = ref.read(imageServiceProvider);
    final notifier = ref.read(imageToolProvider.notifier);

    // Filter out tasks that are ready to be saved
    final tasksToSave = ref.read(imageToolProvider).where((t) => t.processedFile != null).toList();

    if (tasksToSave.isEmpty) return;
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saving ${tasksToSave.length} file(s) permanently...')),
    );

    int successfulSaves = 0;

    for (final task in tasksToSave) {
      // Mark as processing during the save operation
      notifier.updateTask(task.originalFile, isProcessing: true);

      try {
        // CRITICAL CALL: Move file from temporary to persistent storage
        final resultPath = await service.saveProcessedFileToDocuments(task.processedFile!);

        if (resultPath.startsWith('Error')) {
          notifier.updateTask(task.originalFile, error: 'Save Failed: $resultPath', isProcessing: false);
        } else {
          // Success: Remove the task from the view after successful permanent save
          notifier.removeFile(task.originalFile);
          successfulSaves++;
        }
      } catch (e) {
        notifier.updateTask(task.originalFile, error: 'Critical Save Error: $e', isProcessing: false);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$successfulSaves file(s) saved successfully!')),
    );
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(imageToolProvider);
    final hasFiles = tasks.isNotEmpty;
    final quality = ref.watch(compressionQualityProvider);

    // Derived state for UI logic
    final isProcessing = tasks.any((t) => t.isProcessing);
    final hasProcessedFiles = tasks.any((t) => t.processedFile != null);
    final readyToSaveCount = tasks.where((t) => t.processedFile != null).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Compress Image')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UploadBox(
              title: 'Upload Images to Compress',
              allowedExtensions: 'jpg, jpeg, png',
              onFilesSelected: ref.read(imageToolProvider.notifier).addFiles,
            ),
            const SizedBox(height: 30),

            // --- Quality Slider ---
            Text('Compression Quality: ${quality.round()}%', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Slider(
              value: quality,
              min: 10,
              max: 100,
              divisions: 90,
              activeColor: AppColors.neonTeal,
              // Disable slider if no files are present
              onChanged: hasFiles && !isProcessing ? (value) => ref.read(compressionQualityProvider.notifier).state = value : null,
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
                    ? Center(child: CircularProgressIndicator(color: AppColors.neonTeal))
                    : NeonButton(
                  text: 'Compress Images (${tasks.length} files)',
                  onPressed: () => _processCompression(context, ref),
                  neonColor: AppColors.neonTeal,
                  icon: Icons.compress,
                ),
              ),

            const SizedBox(height: 100), // Extra space for content above the floating bar
          ],
        ),
      ),

      // --- The Persistent Save Confirmation Bar ---
      bottomNavigationBar: hasProcessedFiles
          ? Container(
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.accentCharcoal,
          boxShadow: [BoxShadow(color: AppColors.neonTeal.withOpacity(0.2), blurRadius: 10)],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$readyToSaveCount Edited file(s) ready.',
              style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: isProcessing ? null : () => _saveAllProcessedFiles(context, ref),
              icon: const Icon(Icons.save_alt, size: 20),
              label: Text(isProcessing ? 'Saving...' : 'SAVE ALL ($readyToSaveCount)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonTeal,
                foregroundColor: AppColors.backgroundMatteBlack,
                padding: const EdgeInsets.symmetric(horizontal: 15),
              ),
            ),
          ],
        ),
      )
          : null,
    );
  }
}
