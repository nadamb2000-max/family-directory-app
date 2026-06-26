import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FamilyMember {
  final String name;
  final String profession;
  final String bio;
  final String location;
  final String phone;
  final String email;
  final List<String> workImages;
  final Color avatarColor;

  const FamilyMember({
    required this.name,
    required this.profession,
    required this.bio,
    required this.location,
    required this.phone,
    required this.email,
    required this.workImages,
    required this.avatarColor,
  });

  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    return FamilyMember(
      name: map['name'] ?? '',
      profession: map['profession'] ?? '',
      bio: map['bio'] ?? map['description'] ?? '',
      location: map['location'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      workImages: List<String>.from(map['workImages'] ?? []),
      avatarColor: const Color(0xFF2563EB),
    );
  }
}

class MemberDetailScreen extends StatelessWidget {
  final FamilyMember member;

  const MemberDetailScreen({super.key, required this.member});

  Future<void> _openWhatsApp(String phone) async {
    final number = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final url = Uri.parse('https://wa.me/$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callPhone(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _sendEmail(String email) async {
    final url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F6FB);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white60 : const Color(0xFF64748B);
    const accentColor = Color(0xFF2563EB);

    final initial = member.name.isNotEmpty ? member.name[0] : '?';

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: accentColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      child: Text(
                        initial,
                        style: const TextStyle(
                            fontSize: 48,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      member.name.isNotEmpty ? member.name : 'بدون اسم',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    if (member.profession.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          member.profession,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // بطاقة معلومات الاتصال
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        if (member.location.isNotEmpty) ...[
                          _InfoRow(
                            icon: Icons.location_on_rounded,
                            label: 'الموقع',
                            value: member.location,
                            textColor: textColor,
                            subTextColor: subTextColor,
                          ),
                          if (member.phone.isNotEmpty ||
                              member.email.isNotEmpty)
                            const Divider(height: 20),
                        ],
                        if (member.phone.isNotEmpty) ...[
                          _InfoRow(
                            icon: Icons.phone_rounded,
                            label: 'الهاتف',
                            value: member.phone,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            onTap: () => _callPhone(member.phone),
                          ),
                          if (member.email.isNotEmpty)
                            const Divider(height: 20),
                        ],
                        if (member.email.isNotEmpty)
                          _InfoRow(
                            icon: Icons.email_rounded,
                            label: 'البريد',
                            value: member.email,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            onTap: () => _sendEmail(member.email),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // أزرار التواصل
                  if (member.phone.isNotEmpty)
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.chat_rounded,
                            label: 'واتساب',
                            color: const Color(0xFF25D366),
                            onTap: () => _openWhatsApp(member.phone),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.phone_rounded,
                            label: 'اتصال',
                            color: accentColor,
                            onTap: () => _callPhone(member.phone),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),

                  // نبذة عن العمل
                  if (member.bio.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('نبذة مهنية',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor)),
                          const SizedBox(height: 8),
                          Text(
                            member.bio,
                            style: TextStyle(
                                color: subTextColor,
                                fontSize: 14,
                                height: 1.6),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color textColor;
  final Color subTextColor;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.textColor,
    required this.subTextColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                    TextStyle(fontSize: 11, color: subTextColor)),
                Text(value,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: onTap != null
                            ? const Color(0xFF2563EB)
                            : textColor)),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: Color(0xFF2563EB)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }
}