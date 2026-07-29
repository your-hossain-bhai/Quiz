import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ImagePickerUtil {
  final ImagePicker _picker = ImagePicker();
  
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];

  Future<File?> pickImage({required ImageSource source}) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      
      // Validate file size
      final fileSize = await file.length();
      if (fileSize > maxFileSize) {
        throw Exception('File size exceeds the 10MB limit.');
      }
      
      // Validate file format
      final extension = path.extension(file.path).toLowerCase();
      if (!allowedExtensions.contains(extension)) {
        throw Exception('Unsupported file format. Please use JPEG, PNG, or WEBP.');
      }
      
      return file;
    }
    return null;
  }
}
