import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentThemeMode = ref.watch(themeProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'User';
    final name = email.split('@').first;
    
    // Determine which route is active to highlight the tile
    final String location = GoRouterState.of(context).matchedLocation;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
            ),
            accountName: Text(
              name,
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            accountEmail: Text(
              email,
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.home_rounded),
            title: const Text('Home'),
            selected: location == '/home',
            onTap: () {
              Navigator.pop(context); // close drawer
              if (location != '/home') context.go('/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month_rounded),
            title: const Text('Calendar'),
            selected: location == '/calendar',
            onTap: () {
              Navigator.pop(context);
              if (location != '/calendar') context.go('/calendar');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_rounded),
            title: const Text('Profile'),
            selected: location == '/profile',
            onTap: () {
              Navigator.pop(context);
              if (location != '/profile') context.go('/profile');
            },
          ),

          const Spacer(),
          const Divider(),
          
          // Theme Toggle
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: Icon(
              currentThemeMode == ThemeMode.dark
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
            ),
            value: currentThemeMode == ThemeMode.dark,
            onChanged: (val) {
              ref.read(themeProvider.notifier).setTheme(
                    val ? ThemeMode.dark : ThemeMode.light,
                  );
            },
          ),
          
          ListTile(
            leading: Icon(Icons.logout_rounded, color: theme.colorScheme.error),
            title: Text(
              'Logout',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
