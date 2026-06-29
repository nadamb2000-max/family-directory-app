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
  final String? profileImage; // << جديد

  const FamilyMember({
    required this.name,
    required this.profession,
    required this.bio,
    required this.location,
    required this.phone,
    required this.email,
    required this.workImages,
    required this.avatarColor,
    this.profileImage, // << جديد
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
      profileImage: map['profileImage'], // << جديد
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
    final hasProfileImage =
        member.profileImage != null && member.profileImage!.isNotEmpty;

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
                      backgroundImage: hasProfileImage
                          ? NetworkImage(member.profileImage!)
                          : null,
                      child: hasProfileImage
                          ? null
                          : Text(
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

                  // صور الأعمال
                  if (member.workImages.isNotEmpty) ...[
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
                          Row(
                            children: [
                              const Icon(Icons.photo_library_outlined,
                                  color: accentColor, size: 18),
                              const SizedBox(width: 8),
                              Text('صور الأعمال',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textColor)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: member.workImages.length,
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemBuilder: (context, index) {
                              final imageUrl = member.workImages[index];
                              return GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  PageRouteBuilder(
                                    opaque: false,
                                    barrierColor: Colors.black,
                                    transitionDuration:
                                    const Duration(milliseconds: 250),
                                    pageBuilder: (_, __, ___) =>
                                        _WorkImageGallery(
                                          images: member.workImages,
                                          initialIndex: index,
                                        ),
                                  ),
                                ),
                                child: Hero(
                                  tag: 'work_image_$index',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, progress) {
                                        if (progress == null) return child;
                                        return Container(
                                          color: accentColor
                                              .withOpacity(0.08),
                                          child: const Center(
                                            child: SizedBox(
                                              width: 18,
                                              height: 18,
                                              child:
                                              CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stack) =>
                                          Container(
                                            color:
                                            accentColor.withOpacity(0.08),
                                            child: const Icon(
                                                Icons.broken_image_outlined,
                                                color: accentColor),
                                          ),
                                    ),
                                  ),
                                ),
                              );
                            },
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

/// معرض صور كامل الشاشة:
/// - سحب لتحت أو لفوق لإغلاق الصورة (drag to dismiss)
/// - سحب يمين/يسار للتنقل بين الصور
/// - تكبير/تصغير بالـ pinch
/// - عداد صور وزر إغلاق واضح
class _WorkImageGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _WorkImageGallery({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_WorkImageGallery> createState() => _WorkImageGalleryState();
}

class _WorkImageGalleryState extends State<_WorkImageGallery>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late int _currentIndex;

  // مقدار السحب العمودي الحالي ومدى تلاشي الخلفية
  double _dragOffset = 0;
  double _backgroundOpacity = 1;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dy;
      // كل ما سحبت أكتر، الخلفية بتختفي أكتر
      final progress = (_dragOffset.abs() / 300).clamp(0.0, 1.0);
      _backgroundOpacity = 1 - progress;
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    // إذا السحب كفاية (مسافة أو سرعة) → سكّر الصورة
    if (_dragOffset.abs() > 120 ||
        details.velocity.pixelsPerSecond.dy.abs() > 800) {
      Navigator.of(context).pop();
    } else {
      // رجّع الصورة لمكانها الطبيعي
      setState(() {
        _dragOffset = 0;
        _backgroundOpacity = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: GestureDetector(
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: Container(
          color: Colors.black.withOpacity(_backgroundOpacity),
          child: Stack(
            children: [
              // الصور القابلة للتنقل والتكبير
              Transform.translate(
                offset: Offset(0, _dragOffset),
                child: Opacity(
                  opacity: _backgroundOpacity,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.images.length,
                    onPageChanged: (i) => setState(() => _currentIndex = i),
                    itemBuilder: (context, index) {
                      return Center(
                        child: Hero(
                          tag: 'work_image_$index',
                          child: InteractiveViewer(
                            minScale: 1,
                            maxScale: 4,
                            child: Image.network(
                              widget.images[index],
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stack) =>
                              const Icon(Icons.broken_image_outlined,
                                  color: Colors.white54, size: 48),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // زر الإغلاق والعداد
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Opacity(
                    opacity: _backgroundOpacity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisAlignment: widget.images.length > 1
                            ? MainAxisAlignment.spaceBetween
                            : MainAxisAlignment.end,
                        children: [
                          // عداد الصور
                          if (widget.images.length > 1)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: SelectionContainer.disabled(
                                child: Text(
                                  '${_currentIndex + 1} / ${widget.images.length}',
                                  textDirection: TextDirection.ltr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),

                          // زر الإغلاق
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded,
                                  color: Colors.white, size: 22),
                            ),
                          ),
                        ],
                      ),
                    ),
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