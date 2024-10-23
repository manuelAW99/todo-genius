/// Task state enum.
enum TaskState { pending, inProgress, completed }

/// Task priority enum.
enum TaskPriority { low, medium, high }

/// Task model class.
/// Used to store task information.
class Task {
  int? id;
  final String name;
  final TaskState state;
  final TaskPriority priority;
  final int projectId;
  String assignedTo;

  Task({
    this.id,
    required this.name,
    this.state = TaskState.pending,
    this.priority = TaskPriority.medium,
    required this.projectId,
    required this.assignedTo,
  });

  /// Convert a map to a task object.
  /// The map is used to store the task in the database.
  factory Task.fromMap(Map<String, dynamic> data) {
    return Task(
      id: data['id'],
      name: data['name'],
      state: TaskState.values[data['state']],
      priority: TaskPriority.values[data['priority']],
      projectId: data['projectId'],
      assignedTo: data['assignedTo'],
    );
  }

  /// Convert a task object to a map.
  /// The map is used to store the task in the database.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'state': state.index,
      'priority': priority.index,
      'projectId': projectId,
      'assignedTo': assignedTo,
    };
  }

  /// Override the toString method to give a string representation of the task object.
  @override
  String toString() {
    return 'Task {id: $id, name: $name, state: $state, priority: $priority, projectId: $projectId, assignedTo: $assignedTo}';
  }
}

/// An empty task object.
/// Used to check if the user has a task or not.
Task emptyTask = Task(
  id: -1,
  name: '',
  projectId: 0,
  assignedTo: '',
);
