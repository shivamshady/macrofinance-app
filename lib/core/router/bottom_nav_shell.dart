import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/loan_application/presentation/loan_flow_screen.dart';
import '../../features/referral/presentation/screens/refer_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

/// Bottom navigation shell — v2 with 4 tabs
class BottomNavShell extends StatefulWidget {
  final bool isLender;

  const BottomNavShell({super.key, this.isLender = false});

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(isLender: widget.isLender),
      const LoanFlowScreen(),
      const ReferScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            if (widget.isLender && index == 1) {
              context.go('/invest');
            } else {
              setState(() => _currentIndex = index);
            }
          },
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(widget.isLender
                  ? Icons.trending_up_outlined
                  : Icons.add_circle_outline_rounded),
              selectedIcon: Icon(widget.isLender
                  ? Icons.trending_up_rounded
                  : Icons.add_circle_rounded),
              label: widget.isLender ? 'Invest' : 'Apply',
            ),
            const NavigationDestination(
              icon: Icon(Icons.card_giftcard_outlined),
              selectedIcon: Icon(Icons.card_giftcard),
              label: 'Refer',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
