import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/cloudinary_service.dart';

class CreateStatusScreen extends StatefulWidget {
  const CreateStatusScreen({super.key});

  @override
  State<CreateStatusScreen> createState() => _CreateStatusScreenState();
}

class _CreateStatusScreenState extends State<CreateStatusScreen> {
  final TextEditingController _controller = TextEditingController();
  String _duration = '24 ساعة';
  File? _selectedImage;
  bool _isPublishing = false;

  final Map<String, Duration> _durationMap = {
    '24 ساعة': const Duration(hours: 24),
    '3 أيام': const Duration(days: 3),
    '7 أيام': const Duration(days: 7),
  };

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _publishStatus() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب نص أو اختر صورة للحالة')),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isPublishing = true);

    try {
      // جلب اسم وصورة المستخدم الحالي من Firestore
      final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = userDoc.data() ?? {};
      final userName = userData['name'] ?? '';
      final userPhoto = userData['profileImage'] ?? '';

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await CloudinaryService.uploadImage(_selectedImage!);
      }

      final duration = _durationMap[_duration] ?? const Duration(hours: 24);
      final now = DateTime.now();

      await FirebaseFirestore.instance.collection('statuses').add({
        'userId': uid,
        'userName': userName,
        'userPhoto': userPhoto,
        'text': text,
        'imageUrl': imageUrl,
        'createdAt': Timestamp.fromDate(now),
        'expiresAt': Timestamp.fromDate(now.add(duration)),
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء نشر الحالة: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حالة'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  image: _selectedImage != null
                      ? DecorationImage(
                      image: FileImage(_selectedImage!), fit: BoxFit.cover)
                      : null,
                ),
                child: _selectedImage == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        size: 40,
                        color: isDark ? Colors.white38 : Colors.grey),
                    const SizedBox(height: 8),
                    Text('إضافة صورة (اختياري)',
                        style: TextStyle(
                            color:
                            isDark ? Colors.white38 : Colors.grey)),
                  ],
                )
                    : Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white, size: 18),
                        onPressed: () =>
                            setState(() => _selectedImage = null),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(hintText: 'اكتب حالتك هنا...'),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _duration,
              decoration: const InputDecoration(labelText: 'مدة الظهور'),
              items: _durationMap.keys
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _duration = value ?? '24 ساعة'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPublishing ? null : _publishStatus,
                child: _isPublishing
                    ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                    : const Text('نشر الحالة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}