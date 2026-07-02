import 'package:cloud_firestore/cloud_firestore.dart';

class StatusItem {
  final String id;
  final String userId;
  final String userName;
  final String userPhoto;
  final String text;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime expiresAt;

  StatusItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhoto,
    required this.text,
    required this.imageUrl,
    required this.createdAt,
    required this.expiresAt,
  });

  factory StatusItem.fromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StatusItem(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhoto: data['userPhoto'] ?? '',
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }

  /// الوقت المتبقي حتى تنتهي الحالة
  String get remainingLabel {
    final diff = expiresAt.difference(DateTime.now());
    if (diff.isNegative) return 'انتهت';
    if (diff.inDays >= 1) {
      return 'متبقي ${diff.inDays} ${diff.inDays == 1 ? "يوم" : "أيام"}';
    }
    if (diff.inHours >= 1) {
      return 'متبقي ${diff.inHours} ${diff.inHours == 1 ? "ساعة" : "ساعات"}';
    }
    if (diff.inMinutes >= 1) {
      return 'متبقي ${diff.inMinutes} دقيقة';
    }
    return 'متبقي أقل من دقيقة';
  }
}