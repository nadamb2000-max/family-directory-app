import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String _cloudName = 'dlu1rcujr';
  static const String _uploadPreset = 'w4wppyzc';

  /// Uploads a single file to Cloudinary.
  /// Returns the secure URL if successful, otherwise null.
  static Future<String?> uploadImage(File file) async {
    try {
      final url = Uri.parse(
          'https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final json = jsonDecode(body);
        return json['secure_url'];
      } else {
        // Log the error response if needed
        return null;
      }
    } catch (e) {
      // Log the exception
      return null;
    }
  }

  /// Uploads multiple files to Cloudinary.
  static Future<List<String>> uploadMultipleImages(List<File> files) async {
    List<String> urls = [];
    for (var file in files) {
      final url = await uploadImage(file);
      if (url != null) {
        urls.add(url);
      }
    }
    return urls;
  }
}
