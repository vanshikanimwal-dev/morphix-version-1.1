import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morphixapp/core/utils/colors.dart';
import 'package:morphixapp/data/services/pdf_service.dart';
import 'package:morphixapp/main.dart';
import 'package:morphixapp/presentation/state/image_tool_provider.dart';
import 'package:morphixapp/presentation/widgets/custom_button.dart';
import 'package:morphixapp/presentation/widgets/preview_grid.dart';
import 'package:morphixapp/presentation/widgets/upload_box.dart';

class PDFToImagePage extends ConsumerWidget {
  const PDFToImagePage({super.key});

  Future<void> _processConversion(WidgetRef ref) async {
    final tasks = ref.read(imageToolProvider);
    final service = ref.read(pdfServiceProvider);
    final notifier = ref.read(imageToolProvider.notifier);

    final pdfFile = tasks.first.originalFile; // Only process one PDF

    notifier.updateTask(pdfFile, isProcessing: true);
    try {
      final imageFiles = await service.pdfToImages(pdfFile);

      notifier.clear();
      notifier.addFiles(imageFiles);

      for (final file in imageFiles) {
        notifier.updateTask(file, processedFile: file, isCompleted: true, isProcessing: false);
      }

    } catch (e) {
      notifier.updateTask(pdfFile, error: 'Image Extraction Failed: $e', isProcessing: false);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(imageToolProvider);
    final isProcessing = tasks.any((t) => t.isProcessing);

    return Scaffold(
      appBar: AppBar(title: const Text('PDF to Image')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UploadBox(
              title: 'Upload PDF to extract pages as images',
              allowedExtensions: 'pdf',
              onFilesSelected: (files) {
                ref.read(imageToolProvider.notifier).clear(); // Clear previous results
                ref.read(imageToolProvider.notifier).addFiles([files.first]); // Only take the first PDF
              },
            ),
            const SizedBox(height: 30),

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
                  text: 'Extract Images',
                  onPressed: () => _processConversion(ref),
                  neonColor: AppColors.electricPurple,
                  icon: Icons.flip_to_back,
                ),
              ),
          ],
        ),
      ),
    );
  }
}