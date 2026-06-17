import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعديل الملف الشخصي'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TextField(decoration: InputDecoration(labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: 14),
          const TextField(decoration: InputDecoration(labelText: 'المهنة', prefixIcon: Icon(Icons.work_outline))),
          const SizedBox(height: 14),
          const TextField(decoration: InputDecoration(labelText: 'نوع الخدمة', prefixIcon: Icon(Icons.build_outlined))),
          const SizedBox(height: 14),
          const TextField(decoration: InputDecoration(labelText: 'العنوان', prefixIcon: Icon(Icons.location_on_outlined))),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حفظ التغييرات'),
            ),
          ),
        ],
      ),
    );
  }
}