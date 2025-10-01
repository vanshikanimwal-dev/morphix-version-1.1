import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// State model for a single file task
class FileTask {
  final File originalFile;
  File? processedFile;
  bool isProcessing;
  bool isCompleted;
  String? error;

  FileTask({
    required this.originalFile,
    this.processedFile,
    this.isProcessing = false,
    this.isCompleted = false,
    this.error,
  });

  FileTask copyWith({
    File? processedFile,
    bool? isProcessing,
    bool? isCompleted,
    String? error,
  }) {
    return FileTask(
      originalFile: originalFile,
      processedFile: processedFile ?? this.processedFile,
      isProcessing: isProcessing ?? this.isProcessing,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error ?? this.error,
    );
  }
}

// Global provider for managing files in the current tool session
final imageToolProvider = StateNotifierProvider<ImageToolNotifier, List<FileTask>>((ref) {
  return ImageToolNotifier();
});

class ImageToolNotifier extends StateNotifier<List<FileTask>> {
  ImageToolNotifier() : super([]);

  void addFiles(List<File> files) {
    final newTasks = files.map((file) => FileTask(originalFile: file)).toList();
    state = [...state, ...newTasks];
  }

  void removeFile(File fileToRemove) {
    state = [
      for (final task in state)
        if (task.originalFile.path != fileToRemove.path) task,
    ];
  }

  void updateTask(File originalFile, {File? processedFile, bool? isProcessing, bool? isCompleted, String? error}) {
    state = [
      for (final task in state)
        if (task.originalFile.path == originalFile.path)
          task.copyWith(
            processedFile: processedFile,
            isProcessing: isProcessing,
            isCompleted: isCompleted,
            error: error,
          )
        else
          task,
    ];
  }

  void clear() {
    state = [];
  }
}