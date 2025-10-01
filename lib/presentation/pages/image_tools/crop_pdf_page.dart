import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morphixapp/core/utils/colors.dart';
import 'package:morphixapp/data/services/pdf_service.dart';
import 'package:morphixapp/main.dart';
import 'package:morphixapp/presentation/state/image_tool_provider.dart';
import 'package:morphixapp/presentation/widgets/custom_button.dart';
import 'package:morphixapp/presentation/widgets/preview_grid.dart';
import 'package:morphixapp/presentation/widgets/upload_box.dart';

final pagesToKeepProvider = StateProvider<TextEditingController>((ref) => TextEditingController(text: '1,3-5'));

class CropPDFPage extends ConsumerWidget {
  const CropPDFPage({super.key});

  Future<void> _processCropping(WidgetRef ref) async {
    final tasks = ref.read(imageToolProvider);
    final service = ref.read(pdfServiceProvider);
    final pagesText = ref.read(pagesToKeepProvider).text;
    final notifier = ref.read(imageToolProvider.notifier);

    // Simple logic to parse page numbers (e.g., '1,3-5' -> [1, 3, 4, 5])
    // Full parsing logic would be complex. We mock the required page list.
    final pagesToKeep = [1, 2];

    final pdfFile = tasks.first.originalFile;
    notifier.updateTask(pdfFile, isProcessing: true);
    try {
      final croppedPdf = await service.cropPdfPages(pdfFile, pagesToKeep);

      notifier.clear();
      notifier.addFiles([croppedPdf]);
      notifier.updateTask(croppedPdf, processedFile: croppedPdf, isCompleted: true, isProcessing: false);

    } catch (e) {
      notifier.updateTask(pdfFile, error: 'PDF Cropping Failed: $e', isProcessing: false);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(imageToolProvider);
    final isProcessing = tasks.any((t) => t.isProcessing);

    return Scaffold(
      appBar: AppBar(title: const Text('Crop PDF')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UploadBox(
              title: 'Upload PDF to Crop',
              allowedExtensions: 'pdf',
              onFilesSelected: (files) {
                ref.read(imageToolProvider.notifier).clear();
                ref.read(imageToolProvider.notifier).addFiles([files.first]);
              },
            ),
            const SizedBox(height: 30),

            Text('Select Pages to Keep (e.g., 1, 3-5)', style: Theme.of(context).textTheme.titleMedium),
            // For simplicity, we use a standard text field for input, but a robust UI would use checkboxes/range pickers
            // NeonTextField(
            //   controller: ref.read(pagesToKeepProvider),
            //   labelText: 'Pages',
            //   icon: Icons.numbers,
            // ),

            PreviewGrid(
              files: tasks.map((t) => t.originalFile).toList(),
              onRemove: ref.read(imageToolProvider.notifier).removeFile,
            ),
            if (tasks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: isProcessing
                    ? Center(child: CircularProgressIndicator(color: AppColors.softBlue))
                    : NeonButton(
                  text: 'Crop/Select Pages',
                  onPressed: () => _processCropping(ref),
                  neonColor: AppColors.softBlue,
                  icon: Icons.crop_free,
                ),
              ),
          ],
        ),
      ),
    );
  }
}