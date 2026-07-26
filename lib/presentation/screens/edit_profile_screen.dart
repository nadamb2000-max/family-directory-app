import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/services/cloudinary_service.dart';
import '../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _professionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  String? _profileImageUrl;
  File? _profileImageFile;
  bool _uploadingProfile = false;

  List<String> _workImageUrls = [];
  bool _uploadingWork = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? '';
        _professionController.text = data['profession'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _emailController.text = data['email'] ?? '';
        _locationController.text = data['location'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _profileImageUrl = data['profileImage'];
        _workImageUrls = List<String>.from(data['workImages'] ?? []);
      } else {
        _emailController.text = FirebaseAuth.instance.currentUser?.email ?? '';
        _nameController.text = FirebaseAuth.instance.currentUser?.displayName ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ في تحميل البيانات')),
        );
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    setState(() {
      _profileImageFile = File(picked.path);
      _uploadingProfile = true;
    });

    final url = await CloudinaryService.uploadImage(_profileImageFile!);

    if (mounted) {
      setState(() {
        _profileImageUrl = url;
        _uploadingProfile = false;
        if (url == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل رفع الصورة')),
          );
        }
      });
    }
  }

  Future<void> _pickWorkImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;

    setState(() => _uploadingWork = true);

    for (final img in picked) {
      final file = File(img.path);
      final url = await CloudinaryService.uploadImage(file);
      if (url != null) {
        setState(() => _workImageUrls.add(url));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل رفع إحدى الصور')),
          );
        }
      }
    }

    setState(() => _uploadingWork = false);
  }

  void _removeWorkImage(int index) {
    setState(() => _workImageUrls.removeAt(index));
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _saving = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'profession': _professionController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'location': _locationController.text.trim(),
        'bio': _bioController.text.trim(),
        'uid': uid,
        if (_profileImageUrl != null) 'profileImage': _profileImageUrl,
        'workImages': _workImageUrls,
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ البيانات بنجاح ✓'),
            backgroundColor: Color(0xFF2563EB),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل الحفظ، حاول مرة أخرى')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _professionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F6FB);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white60 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Text('تعديل الملف الشخصي',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── صورة الملف الشخصي ──
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: _uploadingProfile ? null : _pickProfileImage,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF2563EB).withOpacity(0.12),
                            border: Border.all(color: const Color(0xFF2563EB), width: 2),
                            image: _profileImageFile != null
                                ? DecorationImage(image: FileImage(_profileImageFile!), fit: BoxFit.cover)
                                : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                                    ? DecorationImage(
                                        image: CachedNetworkImageProvider(_profileImageUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                          ),
                          child: (_profileImageFile == null && (_profileImageUrl == null || _profileImageUrl!.isEmpty))
                              ? const Icon(Icons.person, size: 48, color: Color(0xFF2563EB))
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _uploadingProfile ? null : _pickProfileImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      if (_uploadingProfile)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.3),
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text('اضغط لتغيير الصورة', style: TextStyle(color: subTextColor, fontSize: 12)),
                ),
                const SizedBox(height: 24),

                // ── حقول البيانات ──
                _buildCard(cardColor, [
                  CustomTextField(
                    controller: _nameController,
                    label: 'الاسم الكامل',
                    icon: Icons.person_outline,
                    fillColor: Colors.transparent,
                  ),
                  _divider(isDark),
                  CustomTextField(
                    controller: _professionController,
                    label: 'مجال العمل',
                    icon: Icons.work_outline,
                    fillColor: Colors.transparent,
                  ),
                  _divider(isDark),
                  CustomTextField(
                    controller: _phoneController,
                    label: 'رقم الهاتف',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    fillColor: Colors.transparent,
                  ),
                  _divider(isDark),
                  CustomTextField(
                    controller: _emailController,
                    label: 'البريد الإلكتروني',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    fillColor: Colors.transparent,
                  ),
                  _divider(isDark),
                  CustomTextField(
                    controller: _locationController,
                    label: 'العنوان / المدينة',
                    icon: Icons.location_on_outlined,
                    fillColor: Colors.transparent,
                  ),
                ]),

                const SizedBox(height: 14),

                _buildCard(cardColor, [
                  CustomTextField(
                    controller: _bioController,
                    label: 'نبذة عن العمل',
                    icon: Icons.notes_outlined,
                    maxLines: 3,
                    fillColor: Colors.transparent,
                  ),
                ]),

                const SizedBox(height: 14),

                // ── صور الأعمال ──
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.photo_library_outlined, color: Color(0xFF2563EB), size: 20),
                          const SizedBox(width: 8),
                          Text('صور الأعمال',
                              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                          const Spacer(),
                          Text('اختياري', style: TextStyle(color: subTextColor, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_workImageUrls.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _workImageUrls.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (_, i) => Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: _workImageUrls[i],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey.withOpacity(0.2),
                                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                    ),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeWorkImage(i),
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, size: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_workImageUrls.isNotEmpty) const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _uploadingWork ? null : _pickWorkImages,
                          icon: _uploadingWork
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
                                )
                              : const Icon(Icons.add_photo_alternate_outlined, size: 18),
                          label: Text(_uploadingWork ? 'جاري الرفع...' : 'إضافة صور'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2563EB),
                            side: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (_saving || _uploadingProfile || _uploadingWork) ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: (_saving || _uploadingProfile || _uploadingWork)
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('حفظ التغييرات',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildCard(Color cardColor, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      indent: 52,
      color: isDark ? Colors.white12 : Colors.grey.shade200,
    );
  }
}
