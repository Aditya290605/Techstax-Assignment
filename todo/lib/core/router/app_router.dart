import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';

import '../../features/tasks/screens/home_screen.dart';
import '../../features/tasks/screens/add_task_screen.dart';
import '../../features/tasks/screens/task_detail_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';

/// Global flag for onboarding set in main.dart
bool hasSeenOnboarding = false;

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
    final isOnOnboarding = state.matchedLocation == '/onboarding';

    // Let splash handle its timer/auth check
    if (isOnSplash) return null;

    if (isLoggedIn) {
      // Logged in but on auth or onboarding page → go to home
      if (isOnAuth || isOnOnboarding) return '/home';
      return null;
    } else {
      // Not logged in:
      // Show onboarding if they haven't seen it yet
      if (!hasSeenOnboarding && !isOnOnboarding) {
        return '/onboarding';
      }

      // If they have seen onboarding, and aren't on auth routes → go to signup
      if (hasSeenOnboarding && !isOnAuth && !isOnOnboarding) {
        return '/signup';
      }
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
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
      path: '/calendar',
      builder: (context, state) => const CalendarScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
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
