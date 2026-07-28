import 'package:flutter/material.dart';

enum ToastType { success, error, info }

class CustomToast {
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color bgColor;
    IconData icon;
    Color accentColor;

    switch (type) {
      case ToastType.success:
        bgColor = const Color(0xFFE8F5E9);
        accentColor = const Color(0xFF2E7D32);
        icon = Icons.check_circle_rounded;
        break;
      case ToastType.error:
        bgColor = const Color(0xFFFFEBEE);
        accentColor = const Color(0xFFC62828);
        icon = Icons.error_rounded;
        break;
      case ToastType.info:
        bgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F4FF);
        accentColor = const Color(0xFF2563EB);
        icon = Icons.info_rounded;
        break;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: accentColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: isDark ? Colors.white : accentColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.05,
          left: 24,
          right: 24,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
