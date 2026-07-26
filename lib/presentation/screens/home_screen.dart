import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'member_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  void _onSearch(String query) {
    setState(() => _searchQuery = query.toLowerCase());
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  Future<void> _openWhatsApp(String phone) async {
    final number = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final url = Uri.parse('https://wa.me/$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  bool _matchesSearch(Map<String, dynamic> data) {
    if (_searchQuery.isEmpty) return true;
    final name = (data['name'] ?? '').toLowerCase();
    final profession = (data['profession'] ?? '').toLowerCase();
    final phone = (data['phone'] ?? '').replaceAll(' ', '');
    return name.contains(_searchQuery) ||
        profession.contains(_searchQuery) ||
        phone.contains(_searchQuery.replaceAll(' ', ''));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF0F4FF);
    final appBarColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white60 : const Color(0xFF64748B);
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: _onSearch,
          style: TextStyle(color: textColor, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'ابحث بالاسم أو المهنة أو الرقم...',
            hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey,
                fontSize: 14),
            border: InputBorder.none,
          ),
        )
            : Text('الرئيسية',
            style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        centerTitle: !_isSearching,
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isSearching
                ? IconButton(
              key: const ValueKey('close'),
              icon: Icon(Icons.close_rounded,
                  color: isDark
                      ? Colors.white70
                      : const Color(0xFF2563EB)),
              onPressed: _toggleSearch,
            )
                : IconButton(
              key: const ValueKey('search'),
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.search_rounded,
                    color: Color(0xFF2563EB), size: 20),
              ),
              onPressed: _toggleSearch,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isSearching)
              Container(
                color: appBarColor,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 14,
                        color: isDark ? Colors.white38 : Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'يمكنك البحث بالاسم أو المهنة أو رقم الهاتف',
                      style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.grey),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('حدث خطأ في تحميل البيانات',
                          style: TextStyle(color: textColor)),
                    );
                  }
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xFF2563EB),
                        backgroundColor:
                        const Color(0xFF2563EB).withOpacity(0.1),
                      ),
                    );
                  }

                  final allDocs = snapshot.data!.docs;
                  final myDoc = allDocs
                      .where((d) => d.id == currentUid)
                      .firstOrNull;
                  final otherDocs =
                  allDocs.where((d) => d.id != currentUid).toList();
                  final filteredOthers = otherDocs
                      .where((d) =>
                      _matchesSearch(d.data() as Map<String, dynamic>))
                      .toList();
                  final myData = myDoc?.data() as Map<String, dynamic>?;
                  final myMatchesSearch =
                      myData != null && _matchesSearch(myData);
                  final showMe = myData != null &&
                      (_searchQuery.isEmpty || myMatchesSearch);
                  final totalCount = allDocs.length;

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    children: [
                      if (!_isSearching) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withOpacity(0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'مرحبًا بك في روافدكم 👨‍👩‍👧‍👦',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '$totalCount فرد من العائلة',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.people_alt_rounded,
                                    color: Colors.white, size: 32),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('أفراد العائلة',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor)),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],

                      if (showMe)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _MemberCard(
                            data: myData!,
                            isMe: true,
                            onTap: () {
                              final member = _toFamilyMember(myData);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        MemberDetailScreen(member: member)),
                              );
                            },
                            onWhatsApp: () =>
                                _openWhatsApp(myData['phone'] ?? ''),
                            isDark: isDark,
                          ),
                        ),

                      if (_isSearching && filteredOthers.isEmpty && !showMe)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1E293B)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  child: Icon(Icons.search_off_rounded,
                                      size: 56,
                                      color: isDark
                                          ? Colors.white24
                                          : const Color(0xFF2563EB)
                                          .withOpacity(0.3)),
                                ),
                                const SizedBox(height: 16),
                                Text('لا توجد نتائج',
                                    style: TextStyle(
                                        color: isDark
                                            ? Colors.white38
                                            : subTextColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),

                      ...filteredOthers.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _MemberCard(
                            data: data,
                            isMe: false,
                            onTap: () {
                              final member = _toFamilyMember(data);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        MemberDetailScreen(member: member)),
                              );
                            },
                            onWhatsApp: () =>
                                _openWhatsApp(data['phone'] ?? ''),
                            isDark: isDark,
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  FamilyMember _toFamilyMember(Map<String, dynamic> data) {
    return FamilyMember(
      name: data['name'] ?? '',
      profession: data['profession'] ?? '',
      bio: data['bio'] ?? '',
      location: data['location'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      workImages: List<String>.from(data['workImages'] ?? []),
      avatarColor: const Color(0xFF2563EB),
      profileImage: data['profileImage'],
    );
  }
}

class _MemberCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isMe;
  final VoidCallback onTap;
  final VoidCallback onWhatsApp;
  final bool isDark;

  const _MemberCard({
    required this.data,
    required this.isMe,
    required this.onTap,
    required this.onWhatsApp,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white60 : const Color(0xFF64748B);
    const accentColor = Color(0xFF2563EB);

    final name = data['name'] ?? '';
    final profession = data['profession'] ?? '';
    final location = data['location'] ?? '';
    final phone = data['phone'] ?? '';
    final String? profileImage = data['profileImage'];
    final initial = name.isNotEmpty ? name[0] : '?';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isMe ? null : cardColor,
          gradient: isMe
              ? LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E3A5F), const Color(0xFF2D1B69)]
                : [const Color(0xFFEFF6FF), const Color(0xFFF5F3FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          borderRadius: BorderRadius.circular(28),
          border: isMe
              ? Border.all(color: accentColor.withOpacity(0.3), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: isMe
                  ? accentColor.withOpacity(0.15)
                  : (isDark
                  ? Colors.black26
                  : const Color(0xFF2563EB).withOpacity(0.06)),
              blurRadius: isMe ? 20 : 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: isMe
                      ? BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(34),
                  )
                      : null,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: accentColor.withOpacity(isDark ? 0.3 : 0.1),
                    backgroundImage: (profileImage != null && profileImage.isNotEmpty)
                        ? CachedNetworkImageProvider(profileImage)
                        : null,
                    child: (profileImage == null || profileImage.isEmpty)
                        ? Text(
                            initial,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accentColor),
                          )
                        : null,
                  ),
                ),
                if (isMe)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text('أنت',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name.isNotEmpty ? name : 'بدون اسم',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: textColor)),
                  const SizedBox(height: 4),
                  if (profession.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.work_outline_rounded,
                              size: 11, color: accentColor),
                          const SizedBox(width: 4),
                          Text(profession,
                              style: const TextStyle(
                                  color: accentColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 4),
                  if (location.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 12, color: subTextColor),
                        const SizedBox(width: 3),
                        Text(location,
                            style:
                            TextStyle(color: subTextColor, fontSize: 11)),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (phone.isNotEmpty)
              GestureDetector(
                onTap: onWhatsApp,
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366)
                        .withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.chat_rounded,
                      color: Color(0xFF25D366), size: 20),
                ),
              ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_forward_ios_rounded,
                  size: 12, color: accentColor.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}