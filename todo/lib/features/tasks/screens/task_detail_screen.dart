import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text('Task updated!',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
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
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Task',
          style: GoogleFonts.dmSerifDisplay(fontWeight: FontWeight.w400),
        ),
        content: Text(
          'Are you sure you want to delete this task? This action cannot be undone.',
          style: GoogleFonts.inter(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
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
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'low':
        return const Color(0xFF22C55E);
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
            appBar: AppBar(
              title: Text('Task',
                  style: GoogleFonts.dmSerifDisplay(
                      fontWeight: FontWeight.w400)),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text('Task not found',
                      style: GoogleFonts.inter(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _isEditing ? 'Edit Task' : 'Task Details',
              style: GoogleFonts.dmSerifDisplay(fontWeight: FontWeight.w400),
            ),
            actions: [
              if (!_isEditing) ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 22),
                  tooltip: 'Edit',
                  onPressed: () => _startEditing(task),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded,
                      color: theme.colorScheme.error, size: 22),
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
            padding: const EdgeInsets.all(24),
            child: _isEditing
                ? _buildEditView(task, theme)
                : _buildDetailView(task, theme),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text('Task',
              style: GoogleFonts.dmSerifDisplay(fontWeight: FontWeight.w400)),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(
          title: Text('Task',
              style: GoogleFonts.dmSerifDisplay(fontWeight: FontWeight.w400)),
        ),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildDetailView(Task task, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final priorityCol = _priorityColor(task.priority);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Status Card ───
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: task.isCompleted
                ? const Color(0xFF22C55E).withValues(alpha: 0.08)
                : isDark
                    ? const Color(0xFF1C1C3A)
                    : const Color(0xFFF0EEFF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: task.isCompleted
                  ? const Color(0xFF22C55E).withValues(alpha: 0.3)
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                task.isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: task.isCompleted
                    ? const Color(0xFF22C55E)
                    : theme.colorScheme.onSurfaceVariant,
                size: 26,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  task.isCompleted ? 'Completed' : 'Pending',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: task.isCompleted
                        ? const Color(0xFF22C55E)
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Switch(
                value: task.isCompleted,
                onChanged: (_) {
                  ref.read(taskListProvider.notifier).toggleComplete(task);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ─── Title ───
        Text(
          task.title,
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 26,
            fontWeight: FontWeight.w400,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            decorationColor: theme.colorScheme.onSurfaceVariant,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 20),

        // ─── Description ───
        if (task.description != null && task.description!.isNotEmpty) ...[
          Text(
            'Description',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            task.description!,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: theme.colorScheme.onSurface,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
        ],

        // ─── Metadata Card ───
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF13132A) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.4),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            children: [
              _DetailRow(
                icon: Icons.calendar_today_rounded,
                label: 'Due Date',
                value: DateFormat('EEEE, MMM d, yyyy').format(task.date),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Divider(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  height: 1,
                ),
              ),
              _DetailRow(
                icon: Icons.flag_rounded,
                label: 'Priority',
                value: task.priority[0].toUpperCase() +
                    task.priority.substring(1),
                valueColor: priorityCol,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Divider(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  height: 1,
                ),
              ),
              _DetailRow(
                icon: Icons.access_time_rounded,
                label: 'Created',
                value: DateFormat('MMM d, yyyy – h:mm a')
                    .format(task.createdAt.toLocal()),
              ),
            ],
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
            prefixIcon: Icon(Icons.edit_note_rounded),
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
          borderRadius: BorderRadius.circular(14),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Due Date',
              prefixIcon: Icon(Icons.calendar_today_rounded),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('EEEE, MMM d, yyyy').format(_selectedDate)),
                Icon(Icons.arrow_drop_down_rounded,
                    color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Priority',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
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
        const SizedBox(height: 36),

        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: _isSaving ? null : () => _saveChanges(task),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      strokeCap: StrokeCap.round,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Save Changes',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
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
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              size: 18, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
