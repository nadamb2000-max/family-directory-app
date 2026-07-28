import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/services/cloudinary_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_toast.dart';
import 'main_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _professionController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  File? _profileImageFile;
  String? _profileImageUrl;
  bool _uploadingProfile = false;

  List<String> _workImageUrls = [];
  bool _uploadingWork = false;

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
          CustomToast.show(
            context,
            message: 'فشل رفع الصورة، حاول مرة أخرى',
            type: ToastType.error,
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
          CustomToast.show(
            context,
            message: 'فشل رفع إحدى الصور',
            type: ToastType.error,
          );
        }
      }
    }

    setState(() => _uploadingWork = false);
  }

  void _removeWorkImage(int index) {
    setState(() => _workImageUrls.removeAt(index));
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (password != confirm) {
      setState(() => _errorMessage = 'كلمتا المرور غير متطابقتين');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'uid': cred.user!.uid,
        'name': name,
        'email': email,
        'phone': _phoneController.text.trim(),
        'profession': _professionController.text.trim(),
        'location': _locationController.text.trim(),
        'bio': _bioController.text.trim(),
        'profileImage': _profileImageUrl ?? '',
        'workImages': _workImageUrls,
      });

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
            (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _mapError(e.code));
    } catch (_) {
      setState(() => _errorMessage = 'حدث خطأ غير متوقع، حاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapError(String code) {
    switch (code) {
      case 'email-already-in-use': return 'هذا البريد مستخدم مسبقاً';
      case 'invalid-email': return 'صيغة البريد الإلكتروني غير صحيحة';
      case 'weak-password': return 'كلمة المرور ضعيفة جداً';
      default: return 'تعذر إنشاء الحساب، حاول مرة أخرى';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _professionController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F6FB);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white60 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('إنشاء حساب جديد',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
                const SizedBox(height: 6),
                Text('انضم إلى دليل العائلة',
                    style: TextStyle(fontSize: 14, color: subTextColor)),
                const SizedBox(height: 24),

                // ── صورة الملف الشخصي ──
                Center(
                  child: Column(
                    children: [
                      Stack(
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
                                    ? DecorationImage(
                                        image: FileImage(_profileImageFile!),
                                        fit: BoxFit.cover)
                                    : null,
                              ),
                              child: _profileImageFile == null
                                  ? const Icon(Icons.person,
                                      size: 48, color: Color(0xFF2563EB))
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
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('صورة الملف الشخصي (اختياري)',
                          style: TextStyle(color: subTextColor, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── رسالة الخطأ ──
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(isDark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_errorMessage!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 12.5)),
                        ),
                      ],
                    ),
                  ),

                // ── الحقول الإجبارية ──
                _sectionLabel('معلومات أساسية', textColor),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _nameController,
                  label: 'الاسم الكامل *',
                  icon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _emailController,
                  label: 'البريد الإلكتروني *',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty || !v.contains('@') ? 'بريد غير صحيح' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _passwordController,
                  label: 'كلمة المرور *',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                  validator: (v) => v!.length < 6 ? '6 أحرف على الأقل' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _confirmController,
                  label: 'تأكيد كلمة المرور *',
                  icon: Icons.lock_outline,
                  obscureText: _obscureConfirm,
                  onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                ),
                const SizedBox(height: 20),

                // ── الحقول الاختيارية ──
                _sectionLabel('معلومات إضافية (اختياري)', textColor),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _phoneController,
                  label: 'رقم الهاتف',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _professionController,
                  label: 'مجال العمل',
                  icon: Icons.work_outline,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _locationController,
                  label: 'العنوان / المدينة',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _bioController,
                  label: 'نبذة عن العمل',
                  icon: Icons.notes_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // ── صور الأعمال ──
                _sectionLabel('صور الأعمال (اختياري)', textColor),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      if (_workImageUrls.isNotEmpty) ...[
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
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _uploadingWork ? null : _pickWorkImages,
                          icon: _uploadingWork
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Color(0xFF2563EB)),
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
                const SizedBox(height: 28),

                // ── زر إنشاء الحساب ──
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (_isLoading || _uploadingProfile || _uploadingWork) ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: (_isLoading || _uploadingProfile || _uploadingWork)
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_add_outlined, size: 20),
                              SizedBox(width: 8),
                              Text('إنشاء الحساب',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('عندك حساب؟', style: TextStyle(color: subTextColor, fontSize: 14)),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('تسجيل الدخول',
                            style: TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, Color textColor) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
      ],
    );
  }
}
