import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'member_detail_screen.dart';

final List<FamilyMember> familyMembers = [
  FamilyMember(
    name: 'محمد أحمد',
    profession: 'مهندس برمجيات',
    description: 'مهندس برمجيات متخصص في تطوير تطبيقات الجوال وتقنيات الذكاء الاصطناعي. يعمل في إحدى كبرى شركات التقنية منذ أكثر من 8 سنوات، وله إسهامات في مشاريع دولية بارزة.',
    location: 'الرياض، السعودية',
    phone: '+966501234567',
    email: 'mohammed@example.com',
    workImages: ['1', '2', '3'],
    avatarColor: const Color(0xFF2563EB),
  ),
  FamilyMember(
    name: 'ليلى خالد',
    profession: 'طبيبة متخصصة',
    description: 'طبيبة متخصصة في طب الأطفال وحديثي الولادة. حاصلة على الزمالة الأمريكية في طب الأطفال، وتعمل في مستشفى الملك فيصل التخصصي منذ 6 سنوات.',
    location: 'جدة، السعودية',
    phone: '+966552345678',
    email: 'layla@example.com',
    workImages: ['1', '2'],
    avatarColor: const Color(0xFF7C3AED),
  ),
  FamilyMember(
    name: 'عمر سالم',
    profession: 'محامٍ',
    description: 'محامٍ متخصص في قضايا الشركات والعقود التجارية. أسس مكتبه القانوني الخاص عام 2018، ويتولى تمثيل عدد من كبرى الشركات في المنطقة.',
    location: 'دبي، الإمارات',
    phone: '+971503456789',
    email: 'omar@example.com',
    workImages: ['1', '2', '3', '4'],
    avatarColor: const Color(0xFF059669),
  ),
  FamilyMember(
    name: 'سارة يوسف',
    profession: 'مصممة جرافيك',
    description: 'مصممة جرافيك إبداعية متخصصة في الهوية البصرية وتصميم واجهات المستخدم. عملت مع أكثر من 50 علامة تجارية محلية وعربية خلال مسيرتها المهنية.',
    location: 'القاهرة، مصر',
    phone: '+201004567890',
    email: 'sara@example.com',
    workImages: ['1', '2', '3'],
    avatarColor: const Color(0xFFDB2777),
  ),
  FamilyMember(
    name: 'أحمد ناصر',
    profession: 'مدرس رياضيات',
    description: 'مدرس رياضيات في المرحلة الثانوية منذ 15 عاماً. حاصل على جائزة المعلم المتميز لثلاث سنوات متتالية، ومهتم بتطوير أساليب التدريس الحديثة.',
    location: 'عمّان، الأردن',
    phone: '+962795678901',
    email: 'ahmed@example.com',
    workImages: ['1'],
    avatarColor: const Color(0xFFD97706),
  ),
  FamilyMember(
    name: 'نور حسن',
    profession: 'صيدلانية',
    description: 'صيدلانية سريرية تعمل في قسم العناية المركزة. متخصصة في جرعات الأدوية الحرجة وتفاعلاتها الدوائية، وتشارك في برامج التوعية الصحية المجتمعية.',
    location: 'بيروت، لبنان',
    phone: '+961706789012',
    email: 'nour@example.com',
    workImages: ['1', '2'],
    avatarColor: const Color(0xFF0891B2),
  ),
  FamilyMember(
    name: 'خالد إبراهيم',
    profession: 'مهندس مدني',
    description: 'مهندس مدني متخصص في تصميم الجسور والأنفاق. شارك في تنفيذ عدد من المشاريع الكبرى في منطقة الخليج، وحاصل على عدة براءات اختراع في مجال الإنشاءات.',
    location: 'الكويت',
    phone: '+96597890123',
    email: 'khaled@example.com',
    workImages: ['1', '2', '3'],
    avatarColor: const Color(0xFF64748B),
  ),
  FamilyMember(
    name: 'رنا فاروق',
    profession: 'كاتبة وصحفية',
    description: 'كاتبة وصحفية متخصصة في الشأن الثقافي والاجتماعي. نشرت ثلاثة كتب أدبية وتكتب بانتظام في عدد من المجلات العربية المرموقة.',
    location: 'تونس',
    phone: '+21690901234',
    email: 'rana@example.com',
    workImages: ['1', '2'],
    avatarColor: const Color(0xFFEA580C),
  ),
  FamilyMember(
    name: 'يوسف منير',
    profession: 'طيار',
    description: 'طيار من الدرجة الأولى لدى إحدى شركات الطيران الخليجية الكبرى. يمتلك أكثر من 12,000 ساعة طيران، ومتخصص في قيادة طائرات الإيرباص A380.',
    location: 'أبوظبي، الإمارات',
    phone: '+971559012345',
    email: 'yousef@example.com',
    workImages: ['1', '2', '3'],
    avatarColor: const Color(0xFF1D4ED8),
  ),
  FamilyMember(
    name: 'هند سامي',
    profession: 'مهندسة زراعية',
    description: 'مهندسة زراعية متخصصة في تقنيات الزراعة المائية والذكية. تعمل على مشاريع الأمن الغذائي في منطقة الشرق الأوسط، وحاصلة على جوائز دولية في مجال الابتكار الزراعي.',
    location: 'المغرب',
    phone: '+212600123456',
    email: 'hind@example.com',
    workImages: ['1', '2'],
    avatarColor: const Color(0xFF16A34A),
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FamilyMember> _filteredMembers = familyMembers;
  bool _isSearching = false;

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMembers = familyMembers;
      } else {
        final q = query.toLowerCase();
        _filteredMembers = familyMembers.where((m) {
          return m.name.toLowerCase().contains(q) ||
              m.profession.toLowerCase().contains(q) ||
              m.phone.replaceAll(' ', '').contains(q.replaceAll(' ', ''));
        }).toList();
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredMembers = familyMembers;
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F6FB);
    final appBarColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

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
            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 14),
            border: InputBorder.none,
          ),
        )
            : Text(
          'الرئيسية',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: !_isSearching,
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isSearching
                ? IconButton(
              key: const ValueKey('close'),
              icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : const Color(0xFF2563EB)),
              onPressed: _toggleSearch,
            )
                : IconButton(
              key: const ValueKey('search'),
              tooltip: 'بحث',
              icon: Icon(Icons.search_rounded, color: isDark ? Colors.white70 : const Color(0xFF2563EB)),
              onPressed: _toggleSearch,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // شريط البحث الموسع
            if (_isSearching)
              Container(
                color: appBarColor,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 14, color: isDark ? Colors.white38 : Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'يمكنك البحث بالاسم أو المهنة أو رقم الهاتف',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  // البانر - يختفي عند البحث
                  if (!_isSearching) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)]),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'مرحبًا، هذا هو دليل العائلة 👨‍👩‍👧‍👦',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${familyMembers.length} فرد من العائلة',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 32),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'أفراد العائلة',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // نتائج البحث
                  if (_isSearching && _filteredMembers.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Column(
                          children: [
                            Icon(Icons.search_off_rounded, size: 64, color: isDark ? Colors.white24 : Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text('لا توجد نتائج', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),

                  ..._filteredMembers.map((member) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MemberCard(
                      member: member,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MemberDetailScreen(member: member)),
                      ),
                      onWhatsApp: () => _openWhatsApp(member.phone),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final FamilyMember member;
  final VoidCallback onTap;
  final VoidCallback onWhatsApp;

  const _MemberCard({required this.member, required this.onTap, required this.onWhatsApp});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white60 : const Color(0xFF64748B);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : const Color(0x0F000000),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: member.avatarColor.withOpacity(isDark ? 0.3 : 0.12),
              child: Text(
                member.name[0],
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: member.avatarColor),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.work_outline_rounded, size: 13, color: member.avatarColor),
                      const SizedBox(width: 4),
                      Text(member.profession, style: TextStyle(color: member.avatarColor, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 13, color: subTextColor),
                      const SizedBox(width: 4),
                      Text(member.location, style: TextStyle(color: subTextColor, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // زر واتساب
            GestureDetector(
              onTap: onWhatsApp,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 22),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: subTextColor),
          ],
        ),
      ),
    );
  }
}