import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (doc.exists) {
      final data = doc.data()!;
      _nameController.text = data['name'] ?? '';
      _professionController.text = data['profession'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _emailController.text = data['email'] ?? '';
      _locationController.text = data['location'] ?? '';
      _bioController.text = data['bio'] ?? '';
    } else {
      _emailController.text = FirebaseAuth.instance.currentUser?.email ?? '';
      _nameController.text = FirebaseAuth.instance.currentUser?.displayName ?? '';
    }

    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _saving = true);

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': _nameController.text.trim(),
      'profession': _professionController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'location': _locationController.text.trim(),
      'bio': _bioController.text.trim(),
      'uid': uid,
    }, SetOptions(merge: true));

    setState(() => _saving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ البيانات بنجاح ✓'),
          backgroundColor: Color(0xFF2563EB),
        ),
      );
      Navigator.pop(context);
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
    final appBarColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
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
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person,
                  size: 48, color: Color(0xFF2563EB)),
            ),
          ),
          const SizedBox(height: 24),

          _buildCard(cardColor, [
            _buildField(
              controller: _nameController,
              label: 'الاسم الكامل',
              icon: Icons.person_outline,
              textColor: textColor,
              isDark: isDark,
            ),
            _divider(isDark),
            _buildField(
              controller: _professionController,
              label: 'مجال العمل',
              icon: Icons.work_outline,
              textColor: textColor,
              isDark: isDark,
            ),
            _divider(isDark),
            _buildField(
              controller: _phoneController,
              label: 'رقم الهاتف',
              icon: Icons.phone_outlined,
              textColor: textColor,
              isDark: isDark,
              keyboardType: TextInputType.phone,
            ),
            _divider(isDark),
            _buildField(
              controller: _emailController,
              label: 'البريد الإلكتروني',
              icon: Icons.email_outlined,
              textColor: textColor,
              isDark: isDark,
              keyboardType: TextInputType.emailAddress,
            ),
            _divider(isDark),
            _buildField(
              controller: _locationController,
              label: 'العنوان / المدينة',
              icon: Icons.location_on_outlined,
              textColor: textColor,
              isDark: isDark,
            ),
          ]),

          const SizedBox(height: 14),

          _buildCard(cardColor, [
            _buildField(
              controller: _bioController,
              label: 'نبذة عن العمل',
              icon: Icons.notes_outlined,
              textColor: textColor,
              isDark: isDark,
              maxLines: null,
              minLines: 3,
            ),
          ]),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: _saving
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
                  : const Text('حفظ التغييرات',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color textColor,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
    int? minLines,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        minLines: minLines,
        style: TextStyle(color: textColor, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey, fontSize: 13),
          prefixIcon:
          Icon(icon, color: const Color(0xFF2563EB), size: 20),
          border: InputBorder.none,
        ),
      ),
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