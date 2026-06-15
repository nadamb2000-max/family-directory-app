import 'package:flutter/material.dart';

import 'create_status_screen.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final List<_StatusItem> _items = [
    const _StatusItem('أهلاً بالعائلة، نلتقي غداً في العشاء', 'منذ 10 دقائق'),
    const _StatusItem('مراجعة مواعيد الزيارة الأسبوعية', 'منذ ساعة'),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الحالات')),
        body: _items.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 56, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('لا توجد حالات بعد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('أنشئ حالة جديدة ليرى الجميع تحديثك.', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _openCreateStatus,
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة حالة'),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ElevatedButton.icon(
                        onPressed: _openCreateStatus,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('إضافة حالة جديدة'),
                      ),
                    );
                  }

                  final item = _items[index - 1];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.chat)),
                      title: Text(item.text),
                      subtitle: Text(item.time),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openCreateStatus,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _openCreateStatus() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateStatusScreen(
          onStatusCreated: (text, duration) {
            setState(() {
              _items.insert(0, _StatusItem(text, 'متاح لمدة $duration'));
            });
          },
        ),
      ),
    );
  }
}

class _StatusItem {
  final String text;
  final String time;

  const _StatusItem(this.text, this.time);
}
