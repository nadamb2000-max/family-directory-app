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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الحالات'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateStatus,
        child: const Icon(Icons.add_rounded),
      ),
      body: _items.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline, size: 64,
                  color: isDark ? Colors.white24 : Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('لا توجد حالات بعد', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('أنشئ حالة جديدة ليرى الجميع تحديثك.',
                  textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : const Color(0x0F000000),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF2563EB).withOpacity(0.12),
                  child: const Icon(Icons.chat_rounded, color: Color(0xFF2563EB)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.text, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(item.time, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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