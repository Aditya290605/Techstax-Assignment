import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';

import '../../features/tasks/screens/home_screen.dart';
import '../../features/tasks/screens/add_task_screen.dart';
import '../../features/tasks/screens/task_detail_screen.dart';

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
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/add-task',
      builder: (context, state) => const AddTaskScreen(),
    ),
    GoRoute(
      path: '/task/:id',
      builder: (context, state) {
        final taskId = state.pathParameters['id']!;
        return TaskDetailScreen(taskId: taskId);
      },
    ),
  ],
);
