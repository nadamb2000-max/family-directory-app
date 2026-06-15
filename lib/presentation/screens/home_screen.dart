import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<String> _favoriteNames = <String>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'بحث',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ميزة البحث ستُضاف لاحقًا')),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مرحبًا، هذا هو دليل العائلة', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('تابع أفراد عائلتك، الحالة الجديدة، والمفضلة بسرعة.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _buildSectionTitle('المفضلة'),
            const SizedBox(height: 8),
            SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _FavoriteChip(name: 'أحمد', profession: 'مهندس'),
                  _FavoriteChip(name: 'سارة', profession: 'طبيبة'),
                  _FavoriteChip(name: 'نور', profession: 'مصمم'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('أفراد العائلة'),
            const SizedBox(height: 8),
            _MemberCard(
              name: 'محمد',
              profession: 'مهندس',
              description: 'يعمل في البرمجة والتصميم.',
              isFavorite: _favoriteNames.contains('محمد'),
              onFavoritePressed: () => _toggleFavorite('محمد'),
            ),
            const SizedBox(height: 12),
            _MemberCard(
              name: 'ليلى',
              profession: 'طبيبة',
              description: 'متخصصة في الرعاية الأولية.',
              isFavorite: _favoriteNames.contains('ليلى'),
              onFavoritePressed: () => _toggleFavorite('ليلى'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFavorite(String name) {
    setState(() {
      if (_favoriteNames.contains(name)) {
        _favoriteNames.remove(name);
      } else {
        _favoriteNames.add(name);
      }
    });
  }

  Widget _buildSectionTitle(String title) => Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      );
}

class _FavoriteChip extends StatelessWidget {
  final String name;
  final String profession;

  const _FavoriteChip({required this.name, required this.profession});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      margin: const EdgeInsets.only(left: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color(0x1F2563EB), blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(child: Text(name[0])),
          const SizedBox(height: 6),
          Text(name, overflow: TextOverflow.ellipsis),
          Text(profession, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final String name;
  final String profession;
  final String description;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;

  const _MemberCard({
    required this.name,
    required this.profession,
    required this.description,
    required this.isFavorite,
    required this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const CircleAvatar(radius: 28, child: Icon(Icons.person)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(profession, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            IconButton(
              onPressed: onFavoritePressed,
              icon: Icon(isFavorite ? Icons.star : Icons.star_border),
              color: isFavorite ? Colors.amber : null,
            ),
          ],
        ),
      ),
    );
  }
}
