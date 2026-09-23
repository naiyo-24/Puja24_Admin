import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/pandals/screens/pandal_list_screen.dart';
import '../../features/pandals/screens/pandal_form_screen.dart';
import '../../features/users/screens/user_list_screen.dart';
import '../../features/banners/screens/banner_list_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/passes/screens/pass_management_screen.dart';
import '../../features/pandals/models/place.dart';
import '../widgets/main_layout.dart';
final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: ref.read(authStateProvider) ? '/' : '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final isAuthenticated = ref.read(authStateProvider);
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuthenticated && !isLoggingIn) return '/login';
      if (isAuthenticated && isLoggingIn) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/pandals',
            builder: (context, state) => const PandalListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const PandalFormScreen(),
              ),
              GoRoute(
                path: 'edit',
                builder: (context, state) {
                  final extra = state.extra;
                  Place? place;
                  if (extra is Place) {
                    place = extra;
                  } else if (extra is Map<String, dynamic>) {
                    place = Place.fromJson(extra);
                  }
                  return PandalFormScreen(pandal: place);
                },
              ),
            ]
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UserListScreen(),
          ),
          GoRoute(
            path: '/passes',
            builder: (context, state) => const PassManagementScreen(),
          ),
          GoRoute(
            path: '/banners',
            builder: (context, state) => const BannerListScreen(),
          ),
        ],
      ),
    ],
  );
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<bool>(
      authStateProvider,
      (_, __) => notifyListeners(),
    );
  }
}
