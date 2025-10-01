import 'dart:io'; // <-- FIX: Import dart:io for the File class

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:morphixapp/core/utils/colors.dart';
import 'package:morphixapp/core/utils/styles.dart';
import 'package:morphixapp/presentation/widgets/custom_button.dart';

class UploadBox extends StatelessWidget {
  final String title;
  final String allowedExtensions;

  // FIX: 'File' is now correctly imported from dart:io
  final Function(List<File>) onFilesSelected;

  const UploadBox({
    super.key,
    required this.title,
    required this.allowedExtensions,
    required this.onFilesSelected,
  });

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions.split(',').map((e) => e.trim()).toList(),
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final List<File> selectedFiles = result.files
      // Filter out files where the path is null (e.g., web uploads)
          .where((p) => p.path != null)
      // Map PlatformFile to dart:io File
          .map((p) => File(p.path!))
          .toList();

      onFilesSelected(selectedFiles);
    }
  }

  @override
  Widget build(BuildContext context) {
    // In a production app, use `DragTarget` for Web/Desktop support
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.accentCharcoal.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonTeal, width: 2),
        // Assuming neonGlowShadow is defined in styles.dart
        boxShadow: [neonGlowShadow(color: AppColors.neonTeal.withOpacity(0.3), blur: 5, spread: 0)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upload_file, size: 40, color: AppColors.neonTeal),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          NeonButton(
            text: 'Select Files',
            onPressed: _pickFiles,
            neonColor: AppColors.electricPurple,
            icon: Icons.add,
          ),
          const SizedBox(height: 10),
          Text(
            'Accepted: $allowedExtensions',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textGray),
          ),
        ],
      ),
    );
  }
}