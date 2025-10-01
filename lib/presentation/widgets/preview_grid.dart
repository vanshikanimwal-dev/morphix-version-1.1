import 'dart:io';
import 'package:flutter/material.dart';
import 'package:morphixapp/core/utils/colors.dart';
import 'package:morphixapp/core/utils/styles.dart';

class PreviewGrid extends StatelessWidget {
  final List<File> files;
  final Function(File) onRemove;

  const PreviewGrid({super.key, required this.files, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selected Files (${files.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.softBlue)),
          const Divider(color: AppColors.accentCharcoal),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.0,
            ),
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              return _FilePreviewItem(file: file, onRemove: onRemove);
            },
          ),
        ],
      ),
    );
  }
}

class _FilePreviewItem extends StatelessWidget {
  final File file;
  final Function(File) onRemove;

  const _FilePreviewItem({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final isImage = file.path.toLowerCase().endsWith('.jpg') || file.path.toLowerCase().endsWith('.png');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.accentCharcoal,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [neonGlowShadow(color: AppColors.electricPurple.withOpacity(0.1), blur: 5, spread: 0)],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // File Preview (Image or Icon)
          if (isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(file, fit: BoxFit.cover),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description, size: 30, color: AppColors.softBlue),
                  Text(
                    file.path.split('/').last.split('.').last.toUpperCase(),
                    style: TextStyle(color: AppColors.textWhite),
                  )
                ],
              ),
            ),

          // Remove Button
          Positioned(
            top: 5,
            right: 5,
            child: InkWell(
              onTap: () => onRemove(file),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: AppColors.textWhite),
              ),
            ),
          ),
        ],
      ),
    );
  }
}