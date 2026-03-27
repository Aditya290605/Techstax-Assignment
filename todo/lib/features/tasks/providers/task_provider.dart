import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import '../services/local_db_service.dart';

/// Provides the LocalDbService instance
final localDbServiceProvider = Provider<LocalDbService>((ref) {
  return LocalDbService();
});

/// Provides the TaskService instance
final taskServiceProvider = Provider<TaskService>((ref) {
  final localDb = ref.watch(localDbServiceProvider);
  return TaskService(Supabase.instance.client, localDb, Connectivity());
});

/// Main task list provider — manages all tasks for the current user
final taskListProvider =
    AsyncNotifierProvider<TaskListNotifier, List<Task>>(TaskListNotifier.new);

class TaskListNotifier extends AsyncNotifier<List<Task>> {
  TaskService get _service => ref.read(taskServiceProvider);

  @override
  FutureOr<List<Task>> build() async {
    return await _service.fetchTasks();
  }

  /// Refresh the full task list from Supabase
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.fetchTasks());
  }

  /// Add a new task
  Future<void> addTask({
    required String title,
    String? description,
    required DateTime date,
    String priority = 'medium',
  }) async {
    final newTask = await _service.createTask(
      title: title,
      description: description,
      date: date,
      priority: priority,
    );

    // Add to local state
    final current = state.value ?? [];
    state = AsyncData([newTask, ...current]);
  }

  /// Update an existing task
  Future<void> updateTask(Task task) async {
    final updated = await _service.updateTask(task);

    final current = state.value ?? [];
    state = AsyncData([
      for (final t in current)
        if (t.id == updated.id) updated else t,
    ]);
  }

  /// Toggle task completion status
  Future<void> toggleComplete(Task task) async {
    final updated = await _service.toggleComplete(task);

    final current = state.value ?? [];
    state = AsyncData([
      for (final t in current)
        if (t.id == updated.id) updated else t,
    ]);
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    await _service.deleteTask(taskId);

    final current = state.value ?? [];
    state = AsyncData(current.where((t) => t.id != taskId).toList());
  }
}

/// Derived provider: task completion progress (0.0 to 1.0)
final taskProgressProvider = Provider<double>((ref) {
  final tasks = ref.watch(taskListProvider).value ?? [];
  if (tasks.isEmpty) return 0.0;

  final completed = tasks.where((t) => t.isCompleted).length;
  return completed / tasks.length;
});

/// Derived provider: count of completed tasks
final completedTaskCountProvider = Provider<int>((ref) {
  final tasks = ref.watch(taskListProvider).value ?? [];
  return tasks.where((t) => t.isCompleted).length;
});

/// Derived provider: count of pending tasks
final pendingTaskCountProvider = Provider<int>((ref) {
  final tasks = ref.watch(taskListProvider).value ?? [];
  return tasks.where((t) => !t.isCompleted).length;
});
