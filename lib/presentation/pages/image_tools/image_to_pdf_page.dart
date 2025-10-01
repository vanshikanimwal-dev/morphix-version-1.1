import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morphixapp/core/utils/colors.dart';
import 'package:morphixapp/data/services/pdf_service.dart';
import 'package:morphixapp/main.dart';
import 'package:morphixapp/presentation/state/image_tool_provider.dart';
import 'package:morphixapp/presentation/widgets/custom_button.dart';
import 'package:morphixapp/presentation/widgets/preview_grid.dart';
import 'package:morphixapp/presentation/widgets/upload_box.dart';

class ImageToPDFPage extends ConsumerWidget {
  const ImageToPDFPage({super.key});

  Future<void> _processConversion(WidgetRef ref) async {
    final tasks = ref.read(imageToolProvider);
    final service = ref.read(pdfServiceProvider);
    final notifier = ref.read(imageToolProvider.notifier);

    final files = tasks.map((t) => t.originalFile).toList();

    notifier.updateTask(tasks.first.originalFile, isProcessing: true);
    try {
      final pdfFile = await service.imagesToPdf(files);

      notifier.clear();
      notifier.addFiles([pdfFile]);
      notifier.updateTask(pdfFile, processedFile: pdfFile, isCompleted: true, isProcessing: false);

    } catch (e) {
      notifier.updateTask(tasks.first.originalFile, error: 'PDF Creation Failed: $e', isProcessing: false);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(imageToolProvider);
    final isProcessing = tasks.any((t) => t.isProcessing);

    return Scaffold(
      appBar: AppBar(title: const Text('Image to PDF')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UploadBox(
              title: 'Upload Images to combine into one PDF',
              allowedExtensions: 'jpg, png',
              onFilesSelected: ref.read(imageToolProvider.notifier).addFiles,
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
                    ? Center(child: CircularProgressIndicator(color: AppColors.neonTeal))
                    : NeonButton(
                  text: 'Create PDF (${tasks.length} images)',
                  onPressed: () => _processConversion(ref),
                  neonColor: AppColors.neonTeal,
                  icon: Icons.picture_as_pdf,
                ),
              ),
          ],
        ),
      ),
    );
  }
}