import 'package:flutter/material.dart';
import 'admin_screen.dart';
import 'profile_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // بطاقة المستخدم
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, size: 36, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('أحمد', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    const Text('مالك الحساب', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle('الإعدادات'),
          const SizedBox(height: 10),
          _SettingsTile(
            icon: Icons.edit_outlined,
            label: 'تعديل الملف الشخصي',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            cardColor: cardColor,
          ),
          _SettingsTile(
            icon: Icons.admin_panel_settings_outlined,
            label: 'لوحة الإدارة',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen())),
            cardColor: cardColor,
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            label: 'عن التطبيق',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'روافدكم',
              applicationVersion: '1.0.0',
              applicationLegalese: 'تطبيق عائلي بسيط يركّز على التواصل والملف الشخصي.',
            ),
            cardColor: cardColor,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color cardColor;

  const _SettingsTile({required this.icon, required this.label, required this.onTap, required this.cardColor});

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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF2563EB), size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}