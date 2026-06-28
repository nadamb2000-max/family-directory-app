import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_shell.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'الرجاء إدخال البريد الإلكتروني وكلمة المرور');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, password: password,
      );
      TextInput.finishAutofillContext();
      if (!mounted) return;
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const MainShell()),
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
      case 'user-not-found': return 'لا يوجد حساب مرتبط بهذا البريد';
      case 'wrong-password':
      case 'invalid-credential': return 'كلمة المرور غير صحيحة';
      case 'invalid-email': return 'صيغة البريد الإلكتروني غير صحيحة';
      case 'user-disabled': return 'تم تعطيل هذا الحساب';
      default: return 'تعذر تسجيل الدخول، تحقق من البيانات';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height
                  - MediaQuery.of(context).padding.top
                  - MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),

                // الشعار
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.family_restroom, size: 44, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  'روافدكم',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'دليل عائلتك في مكان واحد',
                  style: TextStyle(fontSize: 14, color: subTextColor),
                ),
                const SizedBox(height: 36),

                // بطاقة تسجيل الدخول
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black26 : const Color(0x0F000000),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'أدخل بياناتك للمتابعة',
                          style: TextStyle(fontSize: 13, color: subTextColor),
                        ),
                        const SizedBox(height: 20),

                        // رسالة الخطأ
                        if (_errorMessage != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 14),
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

                        // حقل الإيميل
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          style: TextStyle(color: textColor, fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            labelStyle: TextStyle(color: subTextColor, fontSize: 13),
                            prefixIcon: Icon(Icons.email_outlined,
                                color: const Color(0xFF2563EB), size: 20),
                            filled: true,
                            fillColor: fieldColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: Color(0xFF2563EB), width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // حقل كلمة المرور
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          autofillHints: const [AutofillHints.password],
                          style: TextStyle(color: textColor, fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
                            labelStyle: TextStyle(color: subTextColor, fontSize: 13),
                            prefixIcon: Icon(Icons.lock_outline,
                                color: const Color(0xFF2563EB), size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: subTextColor,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                            ),
                            filled: true,
                            fillColor: fieldColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: Color(0xFF2563EB), width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // زر تسجيل الدخول
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
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
                                Icon(Icons.login_rounded, size: 20),
                                SizedBox(width: 8),
                                Text('تسجيل الدخول',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // زر إنشاء حساب
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('ما عندك حساب؟',
                        style: TextStyle(color: subTextColor, fontSize: 14)),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      ),
                      child: const Text(
                        'إنشاء حساب جديد',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}