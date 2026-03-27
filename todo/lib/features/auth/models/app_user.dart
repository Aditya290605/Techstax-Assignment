import 'package:supabase_flutter/supabase_flutter.dart' as supa;

/// Simple wrapper around Supabase User for app use
class AppUser {
  final String id;
  final String? email;
  final DateTime? createdAt;

  const AppUser({
    required this.id,
    this.email,
    this.createdAt,
  });

  factory AppUser.fromSupabaseUser(supa.User user) {
    return AppUser(
      id: user.id,
      email: user.email,
      createdAt: DateTime.tryParse(user.createdAt),
    );
  }
}
