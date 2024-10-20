enum TaskState { pending, inProgress, completed }

enum TaskPriority { low, medium, high }

class Task {
  int? id;
  final String name;
  final TaskState state;
  final TaskPriority priority;
  final int projectId;
  final List<String> assignedTo;

  Task({
    this.id,
    required this.name,
    this.state = TaskState.pending,
    this.priority = TaskPriority.medium,
    required this.projectId,
    required this.assignedTo,
  });

  factory Task.fromMap(Map<String, dynamic> data) {
    return Task(
      id: data['id'],
      name: data['name'],
      state: TaskState.values[data['state']],
      priority: TaskPriority.values[data['priority']],
      projectId: data['projectId'],
      assignedTo: List<String>.from(data['assignedTo']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'state': state.index,
      'priority': priority.index,
      'projectId': projectId,
      'assignedTo': assignedTo,
    };
  }

  @override
  String toString() {
    return 'Task {id: $id, name: $name, state: $state, priority: $priority, projectId: $projectId, assignedTo: $assignedTo}';
  }
}
