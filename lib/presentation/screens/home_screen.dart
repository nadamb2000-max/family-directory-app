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
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
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
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded,
                color: const Color(0xFF2563EB)),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await FirebaseFirestore.instance.disableNetwork();
            await FirebaseFirestore.instance.enableNetwork();
          },
          color: const Color(0xFF2563EB),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .snapshots(includeMetadataChanges: true),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('حدث خطأ في تحميل البيانات'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final allDocs = snapshot.data!.docs;
              final myDoc = allDocs.where((d) => d.id == currentUid).firstOrNull;
              final otherDocs = allDocs.where((d) => d.id != currentUid).toList();
              
              final filteredOthers = otherDocs
                  .where((d) => _matchesSearch(d.data() as Map<String, dynamic>))
                  .toList();
              
              final myData = myDoc?.data() as Map<String, dynamic>?;
              final showMe = myData != null && (_searchQuery.isEmpty || _matchesSearch(myData));
              final totalCount = allDocs.length;

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (!_isSearching) ...[
                    _HeaderCard(totalCount: totalCount),
                    const SizedBox(height: 28),
                    _SectionTitle(title: 'أفراد العائلة'),
                    const SizedBox(height: 14),
                  ],
                  if (showMe)
                    _MemberCard(
                      data: myData!,
                      isMe: true,
                      isDark: isDark,
                      onTap: () => _navigateToDetail(context, myData),
                      onWhatsApp: () => _openWhatsApp(myData['phone'] ?? ''),
                    ),
                  ...filteredOthers.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _MemberCard(
                      data: data,
                      isMe: false,
                      isDark: isDark,
                      onTap: () => _navigateToDetail(context, data),
                      onWhatsApp: () => _openWhatsApp(data['phone'] ?? ''),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Map<String, dynamic> data) {
    final member = FamilyMember(
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MemberDetailScreen(member: member)),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final int totalCount;
  const _HeaderCard({required this.totalCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('مرحبًا بك في روافدكم 👨‍👩‍👧‍👦',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('$totalCount فرد من العائلة',
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.people_alt_rounded, color: Colors.white, size: 32),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 20, color: const Color(0xFF2563EB)),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isMe;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onWhatsApp;

  const _MemberCard({
    required this.data,
    required this.isMe,
    required this.isDark,
    required this.onTap,
    required this.onWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color(0xFF2563EB);
    final name = data['name'] ?? '';
    final profileImage = data['profileImage'];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: isMe ? Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.5) : null,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: (profileImage != null && profileImage.isNotEmpty)
                  ? CachedNetworkImageProvider(profileImage)
                  : null,
              child: (profileImage == null || profileImage.isEmpty)
                  ? Text(name.isNotEmpty ? name[0] : '?')
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(data['profession'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            if (data['phone'] != null)
              IconButton(
                icon: const Icon(Icons.chat_rounded, color: Color(0xFF25D366)),
                onPressed: onWhatsApp,
              ),
          ],
        ),
      ),
    );
  }
}
