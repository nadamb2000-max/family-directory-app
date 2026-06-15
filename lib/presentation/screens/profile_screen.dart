import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الملف الشخصي')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 36)),
            const SizedBox(height: 12),
            Text('محمد', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            Text('مهندس برمجيات', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 18),
            Card(
              child: ListTile(title: const Text('الخدمة'), subtitle: const Text('تصميم وتطوير تطبيقات')),
            ),
            const SizedBox(height: 8),
            Card(child: ListTile(title: const Text('العنوان'), subtitle: const Text('دمشق - سوريا'))),
            const SizedBox(height: 8),
            Card(child: ListTile(title: const Text('رقم الهاتف'), subtitle: const Text('+963 992 742 147'))),
          ],
        ),
      ),
    );
  }
}
