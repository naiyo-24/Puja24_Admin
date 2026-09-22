import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/responsive.dart';
import '../theme/app_theme.dart';
import '../../features/auth/providers/auth_provider.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/pandals')) return 1;
    if (location.startsWith('/passes')) return 2;
    if (location.startsWith('/users')) return 3;
    if (location.startsWith('/banners')) return 4;
    return 0; // Default to Dashboard
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/pandals');
        break;
      case 2:
        context.go('/passes');
        break;
      case 3:
        context.go('/users');
        break;
      case 4:
        context.go('/banners');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _calculateSelectedIndex(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
            Container(
              color: const Color(0xFF140D0C), // Very dark brown/black
              child: NavigationRail(
                extended: true,
                backgroundColor: Colors.transparent,
                unselectedIconTheme: const IconThemeData(color: Color(0xFF9E9E9E)),
                unselectedLabelTextStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                selectedIconTheme: const IconThemeData(color: Colors.white),
                selectedLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                useIndicator: true,
                indicatorColor: const Color(0xFF8B0000), // Deep Crimson active state
                selectedIndex: currentIndex,
                onDestinationSelected: (index) => _onItemTapped(index, context),
                leading: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/LOGO.png',
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_rounded),
                    label: Text('Dashboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.temple_hindu_rounded),
                    label: Text('Pandals'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.confirmation_number_rounded),
                    label: Text('Pass Management'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.people_alt_rounded),
                    label: Text('Users'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.view_carousel_rounded),
                    label: Text('Banners'),
                  ),
                ],
                trailing: Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: TextButton.icon(
                        icon: const Icon(Icons.logout_rounded, color: Colors.grey),
                        label: const Text('Logout', style: TextStyle(color: Colors.grey)),
                        onPressed: () => ref.read(authStateProvider.notifier).logout(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          
          if (isDesktop)
            const VerticalDivider(thickness: 1, width: 1, color: AppTheme.surfaceHighlight),
            
          Expanded(
            child: child,
          ),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) => _onItemTapped(index, context),
              selectedItemColor: AppTheme.primaryColor,
              unselectedItemColor: AppTheme.textSecondary,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.temple_hindu_rounded),
                  label: 'Pandals',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.confirmation_number_rounded),
                  label: 'Passes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_alt_rounded),
                  label: 'Users',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.view_carousel_rounded),
                  label: 'Banners',
                ),
              ],
            ),
    );
  }
}
