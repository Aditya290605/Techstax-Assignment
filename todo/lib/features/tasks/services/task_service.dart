import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import 'local_db_service.dart';

class TaskService {
  final SupabaseClient _client;
  final LocalDbService _localDb;
  final Connectivity _connectivity;
  final _uuid = const Uuid();

  TaskService(this._client, this._localDb, this._connectivity);

  String get _userId => _client.auth.currentUser!.id;

  /// Check if device is currently online
  Future<bool> get _isOnline async {
    final results = await _connectivity.checkConnectivity();
    // In connectivity_plus > 5.0.0, checkConnectivity returns List<ConnectivityResult>
    return !results.contains(ConnectivityResult.none);
  }

  /// Synchronize offline operations with backend
  Future<void> syncOfflineOperations() async {
    if (!await _isOnline) return;

    final operations = await _localDb.getQueuedOperations();
    for (final op in operations) {
      final id = op['id'] as int;
      final taskId = op['task_id'] as String;
      final operation = op['operation'] as String;
      final payloadJson = op['payload'] as String?;

      try {
        if (operation == 'add' && payloadJson != null) {
          final payload = jsonDecode(payloadJson) as Map<String, dynamic>;
          await _client.from('tasks').upsert(payload);
        } else if (operation == 'update' && payloadJson != null) {
          final payload = jsonDecode(payloadJson) as Map<String, dynamic>;
          await _client.from('tasks').update(payload).eq('id', taskId);
        } else if (operation == 'delete') {
          await _client.from('tasks').delete().eq('id', taskId);
        }
        // Remove from queue if successful
        await _localDb.dequeueOperation(id);
      } catch (e) {
        // If it fails (e.g., connection lost during sync), we leave it in the queue for next time.
        print('Error syncing operation \$id: \$e');
      }
    }
  }

  /// Fetch all tasks for the current user
  /// Follows the logic: if local length == backend length, use local.
  Future<List<Task>> fetchTasks() async {
    final isOnline = await _isOnline;

    if (isOnline) {
      // First, try to sync any pending offline changes
      await syncOfflineOperations();

      // Check backend task length vs local length
      try {
        final localCount = await _localDb.getTaskCount(_userId);
        final countResponse = await _client
            .from('tasks')
            .select('id')
            .eq('user_id', _userId)
            .count(CountOption.exact);
            
        final backendCount = countResponse.count;

        if (localCount == backendCount && localCount > 0) {
          // If lengths match, don't fetch full list. Just show local tasks.
          return await _localDb.getAllTasks(_userId);
        }

        // Fetch all from backend
        final data = await _client
            .from('tasks')
            .select()
            .eq('user_id', _userId)
            .order('date', ascending: false)
            .order('created_at', ascending: false);

        final backendTasks = (data as List).map((json) => Task.fromJson(json)).toList();
        
        // Save to local cache
        await _localDb.replaceAllTasks(backendTasks);

        return backendTasks;
      } catch (e) {
        // Fallback to local on error
        return await _localDb.getAllTasks(_userId);
      }
    } else {
      // Offline: just return local tasks
      return await _localDb.getAllTasks(_userId);
    }
  }

  /// Fetch tasks for a specific date
  Future<List<Task>> fetchTasksByDate(DateTime date) async {
    final tasks = await fetchTasks();
    final dateStr = date.toIso8601String().split('T').first;
    return tasks.where((t) => t.date.toIso8601String().startsWith(dateStr)).toList();
  }

  /// Create a new task
  Future<Task> createTask({
    required String title,
    String? description,
    required DateTime date,
    String priority = 'medium',
  }) async {
    final isOnline = await _isOnline;
    
    // Generate UUID and timestamps locally
    final taskId = _uuid.v4();
    final now = DateTime.now().toUtc();
    
    final newTask = Task(
      id: taskId,
      userId: _userId,
      title: title,
      description: description,
      date: date,
      priority: priority,
      isCompleted: false,
      createdAt: now,
    );

    // Always store locally first
    await _localDb.insertTask(newTask);

    if (isOnline) {
      try {
        await _client.from('tasks').insert(newTask.toJson());
      } catch (e) {
        // If it fails online, queue it for later
        await _localDb.enqueueOperation(taskId, 'add', task: newTask);
      }
    } else {
      // Offline: queue it
      await _localDb.enqueueOperation(taskId, 'add', task: newTask);
    }

    return newTask;
  }

  /// Update a task
  Future<Task> updateTask(Task task) async {
    final isOnline = await _isOnline;

    // Store locally first
    await _localDb.updateTask(task);

    if (isOnline) {
      try {
        await _client.from('tasks').update(task.toJson()).eq('id', task.id);
      } catch (e) {
        await _localDb.enqueueOperation(task.id, 'update', task: task);
      }
    } else {
      await _localDb.enqueueOperation(task.id, 'update', task: task);
    }

    return task;
  }

  /// Toggle task completion
  Future<Task> toggleComplete(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    return await updateTask(updatedTask);
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    final isOnline = await _isOnline;

    // Delete locally first
    await _localDb.deleteTask(taskId);

    if (isOnline) {
      try {
        await _client.from('tasks').delete().eq('id', taskId);
      } catch (e) {
        await _localDb.enqueueOperation(taskId, 'delete');
      }
    } else {
      await _localDb.enqueueOperation(taskId, 'delete');
    }
  }
}
