import 'package:flutter/material.dart';

class FamilyMember {
  final String name;
  final String profession;
  final String description;
  final String location;
  final String phone;
  final String email;
  final List<String> workImages;
  final Color avatarColor;

  const FamilyMember({
    required this.name,
    required this.profession,
    required this.description,
    required this.location,
    required this.phone,
    required this.email,
    required this.workImages,
    required this.avatarColor,
  });

  // تحويل بيانات العضو لصيغة يقدر Firestore يخزّنها
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profession': profession,
      'description': description,
      'location': location,
      'phone': phone,
      'email': email,
      'workImages': workImages,
      'avatarColor': avatarColor.value, // نحوّل اللون لرقم صحيح
    };
  }

  // تحويل بيانات Firestore رجوع لكلاس FamilyMember
  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    return FamilyMember(
      name: map['name'] ?? '',
      profession: map['profession'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      workImages: List<String>.from(map['workImages'] ?? []),
      avatarColor: Color(map['avatarColor'] ?? 0xFF2563EB),
    );
  }
}

class MemberDetailScreen extends StatelessWidget {
  final FamilyMember member;

  const MemberDetailScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F6FB);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white60 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: member.avatarColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [member.avatarColor, member.avatarColor.withOpacity(0.7)],
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
                        member.name[0],
                        style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(member.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(member.profession, style: const TextStyle(color: Colors.white, fontSize: 13)),
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        _InfoRow(icon: Icons.location_on_rounded, label: 'الموقع', value: member.location, color: member.avatarColor, textColor: textColor, subTextColor: subTextColor),
                        const Divider(height: 20),
                        _InfoRow(icon: Icons.phone_rounded, label: 'الهاتف', value: member.phone, color: member.avatarColor, textColor: textColor, subTextColor: subTextColor),
                        const Divider(height: 20),
                        _InfoRow(icon: Icons.email_rounded, label: 'البريد', value: member.email, color: member.avatarColor, textColor: textColor, subTextColor: subTextColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('نبذة مهنية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                        const SizedBox(height: 8),
                        Text(member.description, style: TextStyle(color: subTextColor, fontSize: 14, height: 1.6)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (member.workImages.isNotEmpty) ...[
                    Text('صور من العمل', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: member.workImages.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) => Container(
                          width: 120,
                          decoration: BoxDecoration(
                            color: member.avatarColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(Icons.image_rounded, size: 40, color: member.avatarColor.withOpacity(0.5)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
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
  final Color color;
  final Color textColor;
  final Color subTextColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: subTextColor)),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
          ],
        ),
      ],
    );
  }
}