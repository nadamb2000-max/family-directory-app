import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() => _errorMessage = 'الرجاء تعبئة جميع الحقول');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = 'كلمتا المرور غير متطابقتين');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, password: password,
      );

      // نحفظ بيانات المستخدم بـ Firestore فوراً
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'uid': cred.user!.uid,
        'name': name,
        'email': email,
        'profession': '',
        'phone': '',
        'location': '',
        'bio': '',
        'workImages': [],
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
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F6FB);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white60 : const Color(0xFF64748B);
    final fieldColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F6FB);

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // العنوان
              Text('إنشاء حساب جديد',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor)),
              const SizedBox(height: 6),
              Text('انضم إلى دليل العائلة',
                  style: TextStyle(fontSize: 14, color: subTextColor)),
              const SizedBox(height: 28),

              // رسالة الخطأ
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

              // الحقول
              _buildField(
                controller: _nameController,
                label: 'الاسم الكامل',
                icon: Icons.person_outline,
                textColor: textColor,
                subTextColor: subTextColor,
                fieldColor: fieldColor,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _emailController,
                label: 'البريد الإلكتروني',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textColor: textColor,
                subTextColor: subTextColor,
                fieldColor: fieldColor,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _passwordController,
                label: 'كلمة المرور',
                icon: Icons.lock_outline,
                obscure: _obscurePassword,
                onToggleObscure: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                textColor: textColor,
                subTextColor: subTextColor,
                fieldColor: fieldColor,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _confirmController,
                label: 'تأكيد كلمة المرور',
                icon: Icons.lock_outline,                obscure: _obscureConfirm,
                onToggleObscure: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                textColor: textColor,
                subTextColor: subTextColor,
                fieldColor: fieldColor,
              ),
              const SizedBox(height: 28),

              // زر إنشاء الحساب
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('إنشاء الحساب',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('عندك حساب؟',
                        style: TextStyle(color: subTextColor, fontSize: 14)),
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
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color textColor,
    required Color subTextColor,
    required Color fieldColor,
    TextInputType keyboardType = TextInputType.text,
    bool? obscure,
    VoidCallback? onToggleObscure,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure ?? false,
      style: TextStyle(color: textColor, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: subTextColor, fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF2563EB), size: 20),
        suffixIcon: onToggleObscure != null
            ? IconButton(
          icon: Icon(
            obscure!
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: subTextColor,
            size: 20,
          ),
          onPressed: onToggleObscure,
        )
            : null,
        filled: true,
        fillColor: fieldColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
      ),
    );
  }
}