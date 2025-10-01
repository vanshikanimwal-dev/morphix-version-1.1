import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

/// Provides core functionality for PDF manipulation and file storage.
class PDFService {
  // Helper to create a unique output path in the temporary directory
  Future<String> _getOutputPath(String filename, String suffix) async {
    final dir = await getTemporaryDirectory();
    final name = filename.substring(0, filename.lastIndexOf('.'));
    const ext = '.pdf';

    return '${dir.path}/Morphix_PDF_${name}_$suffix$ext';
  }

  // --- PDF File Loading ---

  /// Allows the user to select a PDF file from the device.
  Future<File?> pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    // Convert PlatformFile to dart:io File if a file was selected
    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path;
      if (path != null) {
        return File(path);
      }
    }
    return null;
  }

  // ---------------------------------------------
  // --- CORE PDF MANIPULATION TOOLS (MOCK) ---
  // ---------------------------------------------

  /// Tool 1: Merges multiple PDF files into one.
  /// (Mock implementation for demonstration)
  Future<File> mergePdfs(List<File> files) async {
    if (files.isEmpty) throw Exception('No files provided for merging.');

    final originalName = files.first.uri.pathSegments.last;
    final targetPath = await _getOutputPath(originalName, 'merged');

    debugPrint('Merging ${files.length} files...');
    await Future.delayed(const Duration(seconds: 1));

    // Simulation: Create a new mock PDF file in the temporary directory
    final newFile = File(targetPath);
    await newFile.writeAsString('Mock PDF content: Merged from ${files.length} sources.');

    return newFile;
  }

  /// Tool 2: Splits a single PDF file into multiple files (e.g., by page range).
  /// (Mock implementation for demonstration)
  Future<List<File>> splitPdf(File file, List<int> pageIndices) async {
    if (pageIndices.isEmpty) throw Exception('No pages selected for splitting.');

    final originalName = file.uri.pathSegments.last;

    debugPrint('Splitting file into ${pageIndices.length} parts...');
    await Future.delayed(const Duration(seconds: 1));

    // Simulation: Create mock files for each split part
    List<File> resultFiles = [];
    for (int i = 0; i < pageIndices.length; i++) {
      final targetPath = await _getOutputPath(originalName, 'split_page_${pageIndices[i]}');
      final newFile = File(targetPath);
      await newFile.writeAsString('Mock PDF content: Split page ${pageIndices[i]}.');
      resultFiles.add(newFile);
    }

    return resultFiles;
  }

  /// Tool 3: Converts a PDF to another format (e.g., JPG, TXT) or vice-versa.
  /// (Mock implementation for demonstration, returns a mock JPG File)
  Future<File> convertPdf(File file, String outputFormat) async {
    final originalName = file.uri.pathSegments.last;
    // NOTE: Target path will use the new extension, which is fine for mock.
    final targetPath = await _getOutputPath(originalName, 'converted.$outputFormat');

    debugPrint('Converting PDF to $outputFormat...');
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulation: Create a new file with the new extension
    final newFile = File(targetPath);
    await newFile.writeAsString('Mock ${outputFormat.toUpperCase()} content from PDF.');

    return newFile;
  }

  /// Tool 4: Applies password protection to a PDF.
  /// (Mock implementation for demonstration)
  Future<File> protectPdf(File file, String password) async {
    final originalName = file.uri.pathSegments.last;
    final targetPath = await _getOutputPath(originalName, 'protected');

    debugPrint('Applying protection with password: $password...');
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulation: Copy to a new protected file
    await file.copy(targetPath);

    return File(targetPath);
  }

  // ---------------------------------------------
  // --- ADDITIONAL PDF MANIPULATION TOOLS (MOCK) ---
  // ---------------------------------------------

  /// Tool 5: Converts a list of image files (frames) into a single PDF document.
  /// Renamed from convertImagesToPdf to match the user's front-end call.
  Future<File> imagesToPdf(List<File> imageFiles, {String filename = 'Document'}) async {
    if (imageFiles.isEmpty) {
      throw Exception('No image files provided for PDF creation.');
    }

    // --- START SIMULATION: Mock PDF Processing ---

    // 1. Simulate processing time
    await Future.delayed(const Duration(milliseconds: 1800));

    // 2. Determine a unique output path in the system temporary directory
    final tempDir = await getTemporaryDirectory();
    // Use a unique name to prevent collisions, appended with the desired filename
    final targetPath = '${tempDir.path}/${filename}_Morphix_${DateTime.now().millisecondsSinceEpoch}.pdf';

    // 3. Create an empty file with the .pdf extension to simulate a successful output.
    final newPdfFile = File(targetPath);
    await newPdfFile.writeAsString(
        'Successfully generated a PDF containing ${imageFiles.length} pages/images.'
    );

    // --- END SIMULATION ---

    return newPdfFile;
  }

  /// Tool 6: Extracts all pages from a PDF document and returns them as a list of image files.
  Future<List<File>> pdfToImages(File pdfFile) async {
    // --- START SIMULATION: Mock PDF to Image Conversion ---
    await Future.delayed(const Duration(milliseconds: 2000));

    final tempDir = await getTemporaryDirectory();
    List<File> imageFiles = [];

    // Simulate extracting 3 images from the PDF
    for (int i = 0; i < 3; i++) {
      final targetPath = '${tempDir.path}/Page_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.png';
      final newImageFile = File(targetPath);
      // Write a dummy content to simulate an image file
      await newImageFile.writeAsString('Simulated PNG data for page ${i + 1}');
      imageFiles.add(newImageFile);
    }

    // --- END SIMULATION ---
    return imageFiles;
  }

  /// Tool 7: Creates a new PDF by cropping/extracting specific pages from the original PDF document.
  ///
  /// The [pageNumbers] list specifies which pages (1-based index) to include
  /// in the new document.
  Future<File> cropPdfPages(File pdfFile, List<int> pageNumbers) async {
    if (pageNumbers.isEmpty) {
      throw Exception('No pages selected for cropping/extraction.');
    }

    // --- START SIMULATION: Mock PDF Cropping ---
    await Future.delayed(const Duration(milliseconds: 1500));

    final tempDir = await getTemporaryDirectory();
    final filename = pdfFile.uri.pathSegments.last.replaceAll('.pdf', '');
    final targetPath = '${tempDir.path}/${filename}_Cropped_${DateTime.now().millisecondsSinceEpoch}.pdf';

    final newPdfFile = File(targetPath);
    await newPdfFile.writeAsString(
        'Successfully extracted and saved pages ${pageNumbers.join(', ')} from ${pdfFile.uri.pathSegments.last}.'
    );

    // --- END SIMULATION ---

    return newPdfFile;
  }

  // ---------------------------------------------
  // --- UTILITY: PERSISTENT FILE SAVING ---
  // ---------------------------------------------

  /// Saves a processed File (which is currently in temporary storage)
  /// to the application's persistent documents directory. This is the
  /// critical step to ensure files persist across application restarts.
  ///
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

      // We rename the file to avoid conflicts and signify persistence
      final newFilePath = '${directory.path}/Persisted_$fileName';
      final newFile = File(newFilePath);

      // 3. Copy the file content from temporary storage to the persistent location
      await processedFile.copy(newFilePath);

      debugPrint('PDF file successfully persisted to: $newFilePath');

      // Optional: Delete the temporary file now that it is saved
      // await processedFile.delete();

      return newFilePath;
    } catch (e) {
      debugPrint('Error persisting PDF file: $e');
      return 'Error saving PDF file persistently: $e';
    }
  }
}
