import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String _cloudName = 'dlu1rcujr';
  static const String _uploadPreset = 'w4wppyzc';

  /// يرفع صورة إلى Cloudinary ويرجع رابط الصورة النهائي
  static Future<String> uploadImage(File file) async {
    final url =
    Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);
      return json['secure_url'];
    } else {
      throw Exception('فشل رفع الصورة إلى Cloudinary');
    }
  }
}