import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // تهيئة OneSignal للإشعارات
  OneSignal.initialize("6f991705-2b0a-4a1f-8382-9412f894f0e5");
  OneSignal.Notifications.requestPermission(true);

  runApp(const FamilyDirectoryApp());
}