import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'create_status_screen.dart';
import 'status_model.dart';
import 'status_viewer_screen.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  Timer? _tickTimer;

  static const List<List<Color>> _gradients = [
    [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    [Color(0xFFEC4899), Color(0xFFF97316)],
    [Color(0xFF10B981), Color(0xFF06B6D4)],
    [Color(0xFFF43F5E), Color(0xFFFB923C)],
    [Color(0xFF0EA5E9), Color(0xFF6366F1)],
    [Color(0xFF8B5CF6), Color(0xFFEC4899)],
  ];

  @override
  void initState() {
    super.initState();
    _tickTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  List<Color> _gradientFor(String id) {
    final index = id.hashCode.abs() % _gradients.length;
    return _gradients[index];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('الحالات'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateStatusScreen()),
        ),
        child: const Icon(Icons.add_rounded),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('statuses')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('حدث خطأ في تحميل الحالات',
                    style: theme.textTheme.bodyMedium));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs
              .map((doc) => StatusItem.fromDoc(doc))
              .where((item) => !item.isExpired)
              .toList();

          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline,
                        size: 64,
                        color: isDark ? Colors.white24 : Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('لا توجد حالات بعد', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('أنشئ حالة جديدة ليرى الجميع تحديثك.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isMe = item.userId == currentUid;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _StatusCard(
                  item: item,
                  isMe: isMe,
                  gradient: _gradientFor(item.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final StatusItem item;
  final bool isMe;
  final List<Color> gradient;

  const _StatusCard({
    required this.item,
    required this.isMe,
    required this.gradient,
  });

  // هيدر الحالة النصية (بدون خلفية زجاجية، لأنو الكرت نفسه ملون)
  Widget _plainHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white.withOpacity(0.25),
          backgroundImage:
          item.userPhoto.isNotEmpty ? CachedNetworkImageProvider(item.userPhoto) : null,
          child: item.userPhoto.isEmpty
              ? Text(item.userName.isNotEmpty ? item.userName[0] : '؟',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold))
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.userName.isNotEmpty ? item.userName : 'بدون اسم',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              Text(item.timeAgo,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.75), fontSize: 11)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.25),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer_outlined, size: 12, color: Colors.white),
              const SizedBox(width: 4),
              Text(item.remainingLabel,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  // شريط زجاجي مموّه - يضمن وضوح المحتوى فوق أي صورة مهما كان لونها
  Widget _glassPanel({required Widget child, required BorderRadius radius}) {
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(12),
          color: Colors.black.withOpacity(0.32),
          child: child,
        ),
      ),
    );
  }

  Widget _glassHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: Colors.white.withOpacity(0.3),
          backgroundImage:
          item.userPhoto.isNotEmpty ? CachedNetworkImageProvider(item.userPhoto) : null,
          child: item.userPhoto.isEmpty
              ? Text(item.userName.isNotEmpty ? item.userName[0] : '؟',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold))
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.userName.isNotEmpty ? item.userName : 'بدون اسم',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              Text(item.timeAgo,
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_outlined, size: 13, color: Colors.white),
            const SizedBox(width: 4),
            Text(item.remainingLabel,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;

    if (hasImage) {
      const radius = BorderRadius.all(Radius.circular(28));
      return ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          height: 300,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // الصورة - المنطقة الوحيدة القابلة للكبس
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          StatusViewerScreen(status: item, isMe: isMe)),
                ),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.withOpacity(0.1),
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),

              // الشريط العلوي الزجاجي - يحمل الاسم والوقت والعداد
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: _glassPanel(
                    radius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    child: _glassHeader(),
                  ),
                ),
              ),

              // الشريط السفلي الزجاجي - يحمل نص الحالة (لو موجود)
              if (item.text.isNotEmpty)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: _glassPanel(
                      radius: const BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                      child: Text(
                        item.text,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // حالة نصية فقط - غير قابلة للكبس
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 190),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -10,
            bottom: -20,
            child: Icon(Icons.format_quote_rounded,
                size: 110, color: Colors.white.withOpacity(0.12)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _plainHeader(),
              const SizedBox(height: 22),
              Text(
                item.text,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}