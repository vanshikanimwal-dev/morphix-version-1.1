import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img; // Reverting to aliased import to ensure resolution
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

class ImageService {
  // Helper to create a unique output path
  Future<String> _getOutputPath(String filename, String suffix, {String? newExtension}) async {
    // NOTE: This uses getTemporaryDirectory(), which is NOT persistent storage.
    // The new saveProcessedFileToDocuments method below addresses this.
    final dir = await getTemporaryDirectory();
    final name = filename.substring(0, filename.lastIndexOf('.'));
    // Ensure extension starts with '.'
    final ext = newExtension != null && !newExtension.startsWith('.')
        ? '.$newExtension'
        : newExtension ?? filename.substring(filename.lastIndexOf('.'));

    return '${dir.path}/Morphix_${name}_$suffix$ext';
  }

  // ---------------------------------------------
  // --- CORE IMAGE MANIPULATION TOOLS (1-5) ---
  // ---------------------------------------------

  // --- Tool 1: Compress Image ---
  Future<File> compressImage(File file, int quality) async {
    final filename = file.uri.pathSegments.last;
    final targetPath = await _getOutputPath(filename, 'compressed');

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
      minWidth: 1000,
      minHeight: 1000,
      format: CompressFormat.jpeg,
    );

    if (result == null) throw Exception('Image compression failed.');
    return File(result.path);
  }

  // --- Tool 2: Resize Image ---
  Future<File> resizeImage(File file, int width, int height, {bool maintainRatio = true}) async {
    final filename = file.uri.pathSegments.last;
    final targetPath = await _getOutputPath(filename, 'resized');

    final bytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(bytes); // Added img.

    if (image == null) throw Exception('Could not decode image for resizing.');

    // Calculate final dimensions based on aspect ratio constraint
    int finalWidth = width;
    int finalHeight = height;
    if (maintainRatio) {
      final ratio = image.width / image.height;
      if (width > 0 && height == 0) {
        finalHeight = (width / ratio).round();
      } else if (height > 0 && width == 0) {
        finalWidth = (height * ratio).round();
      } else if (width > 0 && height > 0) {
        final scaleX = width / image.width;
        final scaleY = height / image.height;
        final scale = scaleX < scaleY ? scaleX : scaleY;
        finalWidth = (image.width * scale).round();
        finalHeight = (image.height * scale).round();
      }
    }

    final resized = img.copyResize( // Added img.
      image,
      width: finalWidth > 0 ? finalWidth : image.width,
      height: finalHeight > 0 ? finalHeight : image.height,
    );

    final newFile = File(targetPath);
    await newFile.writeAsBytes(img.encodeJpg(resized)); // Added img.

    return newFile;
  }

  // --- Tool 3: Crop Image ---
  Future<File> cropImage(File file, int x, int y, int width, int height) async {
    final filename = file.uri.pathSegments.last;
    final targetPath = await _getOutputPath(filename, 'cropped');

    final bytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(bytes); // Added img.

    if (image == null) throw Exception('Could not decode image for cropping.');

    // Ensure crop parameters are within image bounds
    final clampedX = x.clamp(0, image.width);
    final clampedY = y.clamp(0, image.height);
    final clampedWidth = width.clamp(0, image.width - clampedX);
    final clampedHeight = height.clamp(0, image.height - clampedY);

    final cropped = img.copyCrop(image, x: clampedX, y: clampedY, width: clampedWidth, height: clampedHeight); // Added img.

    final newFile = File(targetPath);
    await newFile.writeAsBytes(img.encodeJpg(cropped)); // Added img.

    return newFile;
  }

  // --- Tool 4 & 5: Convert to/from any format (Consolidated) ---
  Future<File> convertImage(File file, String outputFormat) async {
    final filename = file.uri.pathSegments.last;
    final extension = outputFormat.toLowerCase();

    final targetPath = await _getOutputPath(filename, 'converted', newExtension: extension);

    final bytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(bytes); // Added img.

    if (image == null) throw Exception('Could not decode image for conversion.');

    List<int> outputBytes;

    switch (extension) {
      case 'png':
        outputBytes = img.encodePng(image); // Added img.
        break;
      case 'gif':
        outputBytes = img.encodeGif(image); // Added img.
        break;
      case 'bmp':
        outputBytes = img.encodeBmp(image); // Added img.
        break;
      case 'tiff':
        outputBytes = img.encodeTiff(image); // Added img.
        break;
      case 'jpg':
      case 'jpeg':
      default:
        outputBytes = img.encodeJpg(image, quality: 95); // Added img.
        break;
    }

    final newFile = File(targetPath);
    await newFile.writeAsBytes(outputBytes);

    return newFile;
  }

  // ---------------------------------------------
  // --- ADVANCED & UTILITY TOOLS (6-10) ---
  // ---------------------------------------------

  // --- Tool 6: Image Editor (Batch Transformations) ---
  Future<File> applyEdit(
      File file, {
        required int rotate,
        required bool flipH,
        required bool flipV,
        required bool grayscale,
      }) async {
    final filename = file.uri.pathSegments.last;
    final targetPath = await _getOutputPath(filename, 'edited');

    final bytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(bytes); // Added img.

    if (image == null) throw Exception('Could not decode image for editing.');

    // 1. Rotation
    if (rotate != 0) {
      image = img.copyRotate(image, angle: rotate.toDouble()); // Added img.
    }

    // 2. Flipping
    if (flipH) {
      image = img.flipHorizontal(image); // Added img.
    }
    if (flipV) {
      image = img.flipVertical(image); // Added img.
    }

    // 3. Grayscale Filter
    if (grayscale) {
      image = img.grayscale(image); // Added img.
    }

    final newFile = File(targetPath);
    await newFile.writeAsBytes(img.encodeJpg(image)); // Added img.

    return newFile;
  }

  // --- Tool 7: Add Watermark ---
  Future<File> addTextWatermark(File originalFile, String text, {required double opacity}) async {
    final filename = originalFile.uri.pathSegments.last;
    final targetPath = await _getOutputPath(filename, 'watermarked');

    await Future.delayed(const Duration(milliseconds: 800));

    final bytes = await originalFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes); // Added img.

    if (image == null) throw Exception('Could not decode image for watermarking.');

    // Using ColorRgba8 to define color with alpha (opacity)
    final color = img.ColorRgba8(255, 255, 255, (255 * opacity).round()); // Added img.

    // Draw text in the center
    img.drawString( // Added img.
      image,
      text,
      font: img.arial24, // Added img.
      x: (image.width / 2).round() - (text.length * 7),
      y: (image.height / 2).round() - 10,
      color: color,
    );

    final newFile = File(targetPath);
    await newFile.writeAsBytes(img.encodeJpg(image)); // Added img.

    return newFile;
  }

  // --- Tool 8: Meme Generator (Simulated) ---
  Future<File> generateMeme(File file, String topText, String bottomText) async {
    final filename = file.uri.pathSegments.last;
    final targetPath = await _getOutputPath(filename, 'meme');

    await Future.delayed(const Duration(milliseconds: 1000));

    await file.copy(targetPath);

    return File(targetPath);
  }

  // --- Tool 9: Photo Organizer (Batch Zipping) ---
  Future<File> organizeAndZip(List<File> files, String baseName) async {
    if (files.isEmpty) throw Exception('No files provided for organization.');

    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/Morphix_Organized_Files_${DateTime.now().millisecondsSinceEpoch}.zip';

    // --- Simulation of file processing and zipping ---
    await Future.delayed(const Duration(milliseconds: 1500));

    // Create an empty file with the .zip extension to simulate success.
    final newZipFile = File(targetPath);
    await newZipFile.writeAsString('This is a simulated ZIP file containing ${files.length} organized images, prefixed by $baseName.');
    // -------------------------------------------------

    return newZipFile;
  }
  // --- Tool 10: GIF Maker ---
  // --- Tool 10: GIF Maker (fixed: uses GifEncoder) ---
  Future<File> createGif(List<File> imageFrames, {int frameDelay = 100}) async {
    if (imageFrames.isEmpty) throw Exception('No frames provided for GIF creation.');

    final outputFilename = 'Morphix_Animation_${DateTime.now().millisecondsSinceEpoch}.gif';
    final targetPath = await _getOutputPath(outputFilename, 'gif', newExtension: '.gif');

    final encoder = img.GifEncoder();
    final int durationHundredths = (frameDelay / 10).round(); // GifEncoder expects 1/100 sec

    int? targetWidth;
    int? targetHeight;

    for (final file in imageFrames) {
      final bytes = await file.readAsBytes();
      final frameImage = img.decodeImage(bytes);
      if (frameImage == null) continue;

      // Ensure all frames share same dimensions (GIFs usually require that)
      if (targetWidth == null) {
        targetWidth = frameImage.width;
        targetHeight = frameImage.height;
      }
      img.Image frameToAdd = frameImage;
      if (frameImage.width != targetWidth || frameImage.height != targetHeight) {
        frameToAdd = img.copyResize(frameImage, width: targetWidth!, height: targetHeight!);
      }

      encoder.addFrame(frameToAdd, duration: durationHundredths);
    }

    final gifBytes = encoder.finish();
    if (gifBytes == null || gifBytes.isEmpty) throw Exception('GIF encoding failed.');

    final newFile = File(targetPath);
    await newFile.writeAsBytes(gifBytes);
    return newFile;
  }

  // ---------------------------------------------
  // --- UTILITY: PERSISTENT FILE SAVING (The Fix) ---
  // ---------------------------------------------

  /// Saves a processed File (which is currently in temporary storage)
  /// to the application's persistent documents directory.
  ///
  /// The app's UI must call this method after any tool finishes running
  /// (e.g., when the user clicks a "Save" button on the editing screen).
  /// Returns the path of the persistently saved file.
  Future<String> saveProcessedFileToDocuments(File processedFile) async {
    try {
      if (!await processedFile.exists()) {
        return 'Error: Source file does not exist. Did you run a tool first?';
      }

      // 1. Get the directory for persistent storage (user-specific app data)
      final directory = await getApplicationDocumentsDirectory();

      // 2. Create a unique file name based on the temporary file name
      final originalPath = processedFile.path;
      // Get filename part after the last '/'
      final fileName = originalPath.substring(originalPath.lastIndexOf('/') + 1);

      final newFilePath = '${directory.path}/Persisted_$fileName';
      final newFile = File(newFilePath);

      // 3. Copy the file content from temporary storage to the persistent location
      await processedFile.copy(newFilePath);

      debugPrint('File successfully persisted to: $newFilePath');

      // Optional: Delete the temporary file now that it is saved
      // await processedFile.delete();

      return newFilePath;
    } catch (e) {
      debugPrint('Error persisting file: $e');
      return 'Error saving file persistently: $e';
    }
  }
}
