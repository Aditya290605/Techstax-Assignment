import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';

class TaskService {
  final SupabaseClient _client;

  TaskService(this._client);

  String get _userId => _client.auth.currentUser!.id;

  /// Fetch all tasks for the current user, ordered by date desc
  Future<List<Task>> fetchTasks() async {
    final data = await _client
        .from('tasks')
        .select()
        .eq('user_id', _userId)
        .order('date', ascending: false)
        .order('created_at', ascending: false);

    return (data as List).map((json) => Task.fromJson(json)).toList();
  }

  /// Fetch tasks for a specific date
  Future<List<Task>> fetchTasksByDate(DateTime date) async {
    final dateStr = date.toIso8601String().split('T').first;
    final data = await _client
        .from('tasks')
        .select()
        .eq('user_id', _userId)
        .eq('date', dateStr)
        .order('created_at', ascending: false);

    return (data as List).map((json) => Task.fromJson(json)).toList();
  }

  /// Create a new task
  Future<Task> createTask({
    required String title,
    String? description,
    required DateTime date,
    String priority = 'medium',
  }) async {
    final data = await _client.from('tasks').insert({
      'user_id': _userId,
      'title': title,
      'description': description,
      'date': date.toIso8601String().split('T').first,
      'priority': priority,
    }).select().single();

    return Task.fromJson(data);
  }

  /// Update a task
  Future<Task> updateTask(Task task) async {
    final data = await _client
        .from('tasks')
        .update(task.toJson())
        .eq('id', task.id)
        .select()
        .single();

    return Task.fromJson(data);
  }

  /// Toggle task completion
  Future<Task> toggleComplete(Task task) async {
    final data = await _client
        .from('tasks')
        .update({'is_completed': !task.isCompleted})
        .eq('id', task.id)
        .select()
        .single();

    return Task.fromJson(data);
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    await _client.from('tasks').delete().eq('id', taskId);
  }
}
