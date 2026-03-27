import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../tasks/providers/task_provider.dart';
import '../../../shared/widgets/app_drawer.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'Unknown User';
    final name = email.split('@').first;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    final taskList = ref.watch(taskListProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Name & Email
            Text(
              name,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Stats Header
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Task Statistics',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Use the taskList to derive stats, rather than using separate watcher derived states 
            // since we're displaying stats all at once.
            taskList.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No tasks completed yet.\\nStart adding tasks to see your stats!',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final total = tasks.length;
                final completed = tasks.where((t) => t.isCompleted).length;
                final pending = total - completed;
                final percentage = total == 0 ? 0.0 : completed / total;

                return Column(
                  children: [
                    _StatRow(
                      label: 'Total Tasks',
                      value: '$total',
                      icon: Icons.task_alt,
                    ),
                    const Divider(height: 24),
                    _StatRow(
                      label: 'Completed Tasks',
                      value: '$completed',
                      icon: Icons.check_circle_rounded,
                      color: Colors.green,
                    ),
                    const Divider(height: 24),
                    _StatRow(
                      label: 'Pending Tasks',
                      value: '$pending',
                      icon: Icons.pending_actions_rounded,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 32),
                    
                    // Overall Progress
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Completion Rate: ${(percentage * 100).round()}%',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 12,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(icon, color: color ?? theme.colorScheme.primary, size: 28),
        const SizedBox(width: 16),
        Text(
          label,
          style: theme.textTheme.titleMedium,
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
