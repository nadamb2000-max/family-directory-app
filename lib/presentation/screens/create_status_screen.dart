import 'package:flutter/material.dart';

class CreateStatusScreen extends StatefulWidget {
  final void Function(String text, String duration)? onStatusCreated;
  const CreateStatusScreen({super.key, this.onStatusCreated});

  @override
  State<CreateStatusScreen> createState() => _CreateStatusScreenState();
}

class _CreateStatusScreenState extends State<CreateStatusScreen> {
  final TextEditingController _controller = TextEditingController();
  String _duration = '24 ساعة';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حالة'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(hintText: 'اكتب حالتك هنا...'),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _duration,
              decoration: const InputDecoration(labelText: 'مدة الظهور'),
              items: const [
                DropdownMenuItem(value: '24 ساعة', child: Text('24 ساعة')),
                DropdownMenuItem(value: '3 أيام', child: Text('3 أيام')),
                DropdownMenuItem(value: '7 أيام', child: Text('7 أيام')),
              ],
              onChanged: (value) => setState(() => _duration = value ?? '24 ساعة'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _publishStatus,
                child: const Text('نشر الحالة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _publishStatus() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب نص الحالة أولاً')),
      );
      return;
    }
    widget.onStatusCreated?.call(text, _duration);
    Navigator.pop(context);
  }
}