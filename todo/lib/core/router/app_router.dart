import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';

// Placeholder for home — will be built in Phase 3
class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mini TaskHub')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome! Auth is working. 🎉'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Notifier that listens to Supabase auth state for GoRouter refresh
class AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _sub;

  AuthNotifier() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final _authNotifier = AuthNotifier();

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: _authNotifier,
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;
    final isOnSplash = state.matchedLocation == '/splash';
    final isOnAuth = state.matchedLocation == '/login' ||
        state.matchedLocation == '/signup';

    // On splash, let it handle the redirect itself
    if (isOnSplash) return null;

    // Not logged in → go to login
    if (!isLoggedIn && !isOnAuth) return '/login';

    // Logged in but on auth page → go to home
    if (isLoggedIn && isOnAuth) return '/home';

    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const _PlaceholderHome(),
    ),
  ],
);
