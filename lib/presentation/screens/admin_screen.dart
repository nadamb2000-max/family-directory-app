import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('لوحة الإدارة')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _AdminTile(title: 'إدارة المستخدمين', subtitle: 'إضافة أو تعديل أو حذف الحسابات'),
            _AdminTile(title: 'إحصائيات', subtitle: 'عدد المستخدمين والحالات النشطة'),
            _AdminTile(title: 'المحتوى المخالف', subtitle: 'مراجعة الحالات وحذف غير المناسب'),
          ],
        ),
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _AdminTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
