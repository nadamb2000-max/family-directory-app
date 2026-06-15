import 'package:flutter/material.dart';

import 'admin_screen.dart';
import 'profile_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('حسابي')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 36)),
              const SizedBox(height: 12),
              Text('أحمد', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
              Text('مالك الحساب', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 18),
              Card(
                child: ListTile(
                  title: const Text('تعديل الملف الشخصي'),
                  trailing: const Icon(Icons.edit),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('لوحة الإدارة'),
                  trailing: const Icon(Icons.admin_panel_settings),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen())),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('عن التطبيق'),
                  trailing: const Icon(Icons.info_outline),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'روافدكم',
                    applicationVersion: '1.0.0',
                    applicationLegalese: 'تطبيق عائلي بسيط يركّز على التواصل والملف الشخصي.',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
