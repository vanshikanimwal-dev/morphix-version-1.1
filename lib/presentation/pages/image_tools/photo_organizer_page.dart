import 'dart:io';
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

final baseNameProvider = StateProvider<TextEditingController>((ref) => TextEditingController(text: 'Image'));

class PhotoOrganizerPage extends ConsumerWidget {
  const PhotoOrganizerPage({super.key});

  Future<void> _processOrganization(WidgetRef ref) async {
    final tasks = ref.read(imageToolProvider);
    final service = ref.read(imageServiceProvider);
    final baseName = ref.read(baseNameProvider).text;
    final notifier = ref.read(imageToolProvider.notifier);

    // Convert FileTask list back to just a File list for the ZIP function
    final files = tasks.map((t) => t.originalFile).toList();

    notifier.updateTask(tasks.first.originalFile, isProcessing: true); // Use first task for global progress
    try {
      final zipFile = await service.organizeAndZip(files, baseName);

      // Since it's a single ZIP output, we show it as a single result
      notifier.clear();
      notifier.addFiles([zipFile]); // Show the ZIP file as the result
      notifier.updateTask(zipFile, processedFile: zipFile, isCompleted: true, isProcessing: false);

    } catch (e) {
      notifier.updateTask(tasks.first.originalFile, error: 'Organization Failed: $e', isProcessing: false);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(imageToolProvider);
    final isProcessing = tasks.any((t) => t.isProcessing);

    return Scaffold(
      appBar: AppBar(title: const Text('Photo Organizer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UploadBox(
              title: 'Upload Multiple Images to Organize',
              allowedExtensions: 'jpg, png',
              onFilesSelected: ref.read(imageToolProvider.notifier).addFiles,
            ),
            const SizedBox(height: 30),

            Text('Base Filename (e.g., Image_1.jpg, Image_2.jpg)', style: Theme.of(context).textTheme.titleMedium),
            NeonTextField(
              controller: ref.read(baseNameProvider),
              labelText: 'Base Name',
              icon: Icons.drive_file_rename_outline,
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
                  text: 'Organize and Zip (${tasks.length} files)',
                  onPressed: () => _processOrganization(ref),
                  neonColor: AppColors.neonTeal,
                  icon: Icons.archive,
                ),
              ),
          ],
        ),
      ),
    );
  }
}