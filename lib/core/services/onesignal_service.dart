import 'dart:convert';
import 'package:http/http.dart' as http;

class OneSignalService {
  // ⚠️ حطي هون الـ App ID و الـ REST API Key تبعك من OneSignal
  static const String _appId = '6f991705-2b0a-4a1f-8382-9412f894f0e5';
  static const String _restApiKey = String.fromEnvironment('ONESIGNAL_REST_API_KEY');

  /// بيبعت إشعار لكل المشتركين لما حدا ينشر حالة جديدة
  static Future<void> sendStatusNotification({
    required String userName,
    required String statusText,
  }) async {
    try {
      final title = userName.isNotEmpty ? userName : 'روافدكم';
      final body = statusText.trim().isNotEmpty
          ? statusText.trim()
          : 'نشر حالة جديدة';

      final response = await http.post(
        Uri.parse('https://api.onesignal.com/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Key $_restApiKey',
        },
        body: jsonEncode({
          'app_id': _appId,
          'target_channel': 'push',
          'included_segments': ['Subscribed Users'],
          'headings': {'en': title, 'ar': title},
          'contents': {'en': body, 'ar': body},
        }),
      );

      if (response.statusCode != 200) {
        // ignore: avoid_print
        print('OneSignal error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('OneSignal exception: $e');
    }
  }
}