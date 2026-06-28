import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_screen.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F6FB);
    final appBarColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white60 : const Color(0xFF64748B);

    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        title: Text('حسابي',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: uid == null
          ? const Center(child: Text('غير مسجّل'))
          : StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          String name = '';
          String email =
              FirebaseAuth.instance.currentUser?.email ?? '';
          String profession = '';
          String location = '';
          String phone = '';

          if (snapshot.hasData && snapshot.data!.exists) {
            final data =
            snapshot.data!.data() as Map<String, dynamic>;
            name = data['name'] ?? '';
            email = data['email'] ?? email;
            profession = data['profession'] ?? '';
            location = data['location'] ?? '';
            phone = data['phone'] ?? '';
          }

          final displayName =
          name.isNotEmpty ? name : email.split('@').first;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // بطاقة المستخدم
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)]),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white24,
                      child: Text(
                        displayName.isNotEmpty ? displayName[0] : '?',
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (profession.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(children: [
                              const Icon(Icons.work_outline,
                                  size: 13, color: Colors.white60),
                              const SizedBox(width: 4),
                              Text(profession,
                                  style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12)),
                            ]),
                          ],
                          if (location.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Row(children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 13, color: Colors.white60),
                              const SizedBox(width: 4),
                              Text(location,
                                  style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12)),
                            ]),
                          ],
                          if (phone.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Row(children: [
                              const Icon(Icons.phone_outlined,
                                  size: 13, color: Colors.white60),
                              const SizedBox(width: 4),
                              Text(phone,
                                  style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12)),
                            ]),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _SectionTitle(title: 'الإعدادات', textColor: textColor),
              const SizedBox(height: 10),

              _SettingsTile(
                icon: Icons.edit_outlined,
                label: 'تعديل الملف الشخصي',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EditProfileScreen())),
                cardColor: cardColor,
                textColor: textColor,
                isDark: isDark,
              ),
              _SettingsTile(
                icon: Icons.admin_panel_settings_outlined,
                label: 'لوحة الإدارة',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AdminScreen())),
                cardColor: cardColor,
                textColor: textColor,
                isDark: isDark,
              ),
              _SettingsTile(
                icon: Icons.info_outline,
                label: 'عن التطبيق',
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'روافدكم',
                  applicationVersion: '1.0.0',
                  applicationLegalese:
                  'تطبيق عائلي بسيط يركّز على التواصل والملف الشخصي.',
                ),
                cardColor: cardColor,
                textColor: textColor,
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _SettingsTile(
                icon: Icons.logout_rounded,
                label: 'تسجيل الخروج',
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()),
                          (_) => false,
                    );
                  }
                },
                cardColor: cardColor,
                textColor: Colors.red,
                isDark: isDark,
                iconColor: Colors.red,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color textColor;
  const _SectionTitle({required this.title, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: textColor));
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color cardColor;
  final Color textColor;
  final bool isDark;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.cardColor,
    required this.textColor,
    required this.isDark,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : const Color(0x0F000000),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? const Color(0xFF2563EB), size: 22),
            const SizedBox(width: 14),
            Expanded(
                child: Text(label,
                    style: TextStyle(fontSize: 14.5, color: textColor))),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isDark ? Colors.white38 : Colors.grey),
          ],
        ),
      ),
    );
  }
}