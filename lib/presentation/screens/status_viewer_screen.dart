import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'status_model.dart';

class StatusViewerScreen extends StatelessWidget {
  final StatusItem status;
  final bool isMe;

  const StatusViewerScreen(
      {super.key, required this.status, required this.isMe});

  Future<void> _deleteStatus(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف الحالة'),
        content: const Text('هل تريد حذف هذه الحالة؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حذف')),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('statuses')
          .doc(status.id)
          .delete();
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (status.imageUrl != null)
              Positioned.fill(
                child: Image.network(status.imageUrl!, fit: BoxFit.contain),
              ),
            if (status.imageUrl == null)
              Container(
                color: const Color(0xFF2563EB),
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(24),
                child: Text(
                  status.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600),
                ),
              ),
            if (status.imageUrl != null && status.text.isNotEmpty)
              Positioned(
                bottom: 30,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(status.text,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center),
                ),
              ),
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white24,
                    backgroundImage: status.userPhoto.isNotEmpty
                        ? NetworkImage(status.userPhoto)
                        : null,
                    child: status.userPhoto.isEmpty
                        ? Text(
                        status.userName.isNotEmpty
                            ? status.userName[0]
                            : '؟',
                        style: const TextStyle(color: Colors.white))
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(status.userName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Text(status.timeAgo,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (isMe)
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.white),
                      onPressed: () => _deleteStatus(context),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}