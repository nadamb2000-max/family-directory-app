import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعديل الملف الشخصي')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            TextField(decoration: InputDecoration(labelText: 'الاسم الكامل')),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'المهنة')),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'نوع الخدمة')),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'العنوان')),
            SizedBox(height: 18),
            ElevatedButton(onPressed: null, child: Text('حفظ التغييرات')),
          ],
        ),
      ),
    );
  }
}
