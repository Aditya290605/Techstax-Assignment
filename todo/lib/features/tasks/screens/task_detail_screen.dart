import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late String _selectedPriority;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _selectedDate = DateTime.now();
    _selectedPriority = 'medium';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _startEditing(Task task) {
    setState(() {
      _isEditing = true;
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _selectedDate = task.date;
      _selectedPriority = task.priority;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveChanges(Task task) async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updated = task.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        date: _selectedDate,
        priority: _selectedPriority,
      );

      await ref.read(taskListProvider.notifier).updateTask(updated);

      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(taskListProvider.notifier).deleteTask(widget.taskId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted')),
        );
        context.pop();
      }
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = ref.watch(taskListProvider);

    return tasks.when(
      data: (taskList) {
        final task = taskList.where((t) => t.id == widget.taskId).firstOrNull;

        if (task == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Task')),
            body: const Center(child: Text('Task not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit Task' : 'Task Details'),
            actions: [
              if (!_isEditing) ...[
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  tooltip: 'Edit',
                  onPressed: () => _startEditing(task),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: theme.colorScheme.error),
                  tooltip: 'Delete',
                  onPressed: _deleteTask,
                ),
              ] else ...[
                TextButton(
                  onPressed: () => setState(() => _isEditing = false),
                  child: const Text('Cancel'),
                ),
              ],
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _isEditing
                ? _buildEditView(task, theme)
                : _buildDetailView(task, theme),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Task')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Task')),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildDetailView(Task task, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Completion status
        Card(
          child: ListTile(
            leading: Icon(
              task.isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: task.isCompleted ? Colors.green : theme.colorScheme.outline,
              size: 28,
            ),
            title: Text(
              task.isCompleted ? 'Completed' : 'Pending',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Switch(
              value: task.isCompleted,
              onChanged: (_) {
                ref.read(taskListProvider.notifier).toggleComplete(task);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          task.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        const SizedBox(height: 16),

        // Description
        if (task.description != null && task.description!.isNotEmpty) ...[
          Text(
            'Description',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            task.description!,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
        ],

        // Metadata
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: DateFormat('EEEE, MMM d, yyyy').format(task.date),
                ),
                const Divider(height: 24),
                _DetailRow(
                  icon: Icons.flag_rounded,
                  label: 'Priority',
                  value: task.priority[0].toUpperCase() +
                      task.priority.substring(1),
                  valueColor: _priorityColor(task.priority),
                ),
                const Divider(height: 24),
                _DetailRow(
                  icon: Icons.access_time_rounded,
                  label: 'Created',
                  value: DateFormat('MMM d, yyyy – h:mm a')
                      .format(task.createdAt.toLocal()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditView(Task task, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
            prefixIcon: Icon(Icons.title_rounded),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Description',
            prefixIcon: Icon(Icons.description_outlined),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),

        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Date',
              prefixIcon: Icon(Icons.calendar_today_rounded),
            ),
            child: Text(
              DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Priority',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'low', label: Text('Low')),
            ButtonSegment(value: 'medium', label: Text('Medium')),
            ButtonSegment(value: 'high', label: Text('High')),
          ],
          selected: {_selectedPriority},
          onSelectionChanged: (value) {
            setState(() => _selectedPriority = value.first);
          },
        ),
        const SizedBox(height: 32),

        FilledButton(
          onPressed: _isSaving ? null : () => _saveChanges(task),
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
