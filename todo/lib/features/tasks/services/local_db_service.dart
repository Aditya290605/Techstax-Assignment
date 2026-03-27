import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class LocalDbService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mini_task_hub.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create Tasks table
        await db.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            user_id TEXT,
            title TEXT,
            description TEXT,
            date TEXT,
            priority TEXT,
            is_completed INTEGER,
            created_at TEXT
          )
        ''');

        // Create Offline Queue table
        await db.execute('''
          CREATE TABLE offline_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            task_id TEXT,
            operation TEXT,
            payload TEXT
          )
        ''');
      },
    );
  }

  // ----------- TASKS -----------

  /// Replace all local tasks (usually called after a fresh sync from backend)
  Future<void> replaceAllTasks(List<Task> tasks) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('tasks');
      for (final task in tasks) {
        await txn.insert('tasks', _taskToMap(task));
      }
    });
  }

  /// Get all local tasks
  Future<List<Task>> getAllTasks(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, created_at DESC',
    );
    return maps.map((map) => _mapToTask(map)).toList();
  }
  
  /// Get total count of tasks for a user
  Future<int> getTaskCount(String userId) async {
    final db = await database;
    final result = await db.query('tasks', where: 'user_id = ?', whereArgs: [userId]);
    return result.length;
  }

  /// Insert a single task into local DB
  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert('tasks', _taskToMap(task),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Update a task in local DB
  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update('tasks', _taskToMap(task),
        where: 'id = ?', whereArgs: [task.id]);
  }

  /// Delete a task from local DB
  Future<void> deleteTask(String taskId) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
  }

  // ----------- OFFLINE QUEUE -----------

  /// Add an operation to the offline queue
  Future<void> enqueueOperation(String taskId, String operation, {Task? task}) async {
    final db = await database;
    await db.insert('offline_queue', {
      'task_id': taskId,
      'operation': operation,
      'payload': task != null ? jsonEncode(task.toJson()) : null,
    });
  }

  /// Get all queued operations
  Future<List<Map<String, dynamic>>> getQueuedOperations() async {
    final db = await database;
    return await db.query('offline_queue', orderBy: 'id ASC');
  }

  /// Remove an operation from the queue after successful sync
  Future<void> dequeueOperation(int id) async {
    final db = await database;
    await db.delete('offline_queue', where: 'id = ?', whereArgs: [id]);
  }

  // ----------- HELPERS -----------

  Map<String, dynamic> _taskToMap(Task task) {
    return {
      'id': task.id,
      'user_id': task.userId,
      'title': task.title,
      'description': task.description,
      'date': task.date.toIso8601String(),
      'priority': task.priority,
      'is_completed': task.isCompleted ? 1 : 0,
      'created_at': task.createdAt.toIso8601String(),
    };
  }

  Task _mapToTask(Map<String, dynamic> map) {
    // Note: Local DB stores ISO dates for everything. 
    // Supabase returns string dates sometimes with T appended for date only,
    // so DateTime.parse handles both safely.
    return Task(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      date: DateTime.parse(map['date'] as String),
      priority: map['priority'] as String,
      isCompleted: (map['is_completed'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
