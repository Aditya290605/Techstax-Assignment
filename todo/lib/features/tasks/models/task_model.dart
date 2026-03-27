class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime date;
  final String priority; // 'low', 'medium', 'high'
  final bool isCompleted;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.date,
    this.priority = 'medium',
    this.isCompleted = false,
    required this.createdAt,
  });

  /// Create from Supabase JSON row
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      priority: json['priority'] as String? ?? 'medium',
      isCompleted: json['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON for Supabase insert/update
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'date': date.toIso8601String().split('T').first, // date only
      'priority': priority,
      'is_completed': isCompleted,
    };
  }

  /// Create a copy with updated fields
  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? date,
    String? priority,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
