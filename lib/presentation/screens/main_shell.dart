import 'dart:ui';
import 'package:flutter/material.dart';
import 'account_screen.dart';
import 'home_screen.dart';
import 'status_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    StatusScreen(),
    AccountScreen(),
  ];

  static const Color primaryBlue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: _pages[_index],
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1A1A26).withOpacity(0.45)
                        : Colors.white.withOpacity(0.6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: NavigationBarTheme(
                    data: NavigationBarThemeData(
                      labelTextStyle: WidgetStateProperty.resolveWith((states) {
                        final selected = states.contains(WidgetState.selected);
                        return TextStyle(
                          fontSize: 12,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected
                              ? primaryBlue
                              : (isDark ? Colors.grey[500] : Colors.grey[600]),
                        );
                      }),
                      iconTheme: WidgetStateProperty.resolveWith((states) {
                        final selected = states.contains(WidgetState.selected);
                        return IconThemeData(
                          color: selected
                              ? primaryBlue
                              : (isDark ? Colors.grey[500] : Colors.grey[600]),
                          size: 24,
                        );
                      }),
                      indicatorColor: Colors.transparent,
                    ),
                    child: NavigationBar(
                      selectedIndex: _index,
                      onDestinationSelected: (value) => setState(() => _index = value),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      height: 68,
                      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home_rounded),
                          label: 'الرئيسية',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.chat_bubble_outline_rounded),
                          selectedIcon: Icon(Icons.chat_bubble_rounded),
                          label: 'الحالات',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.person_outline_rounded),
                          selectedIcon: Icon(Icons.person_rounded),
                          label: 'حسابي',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}