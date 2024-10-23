import 'package:flutter/material.dart';
import 'package:todo_app/models/task.dart';

/// Returns the color of the task state
/// [state] is the state of the task
Color getTaskStateColor(TaskState state) {
  switch (state) {
    case TaskState.pending:
      return Colors.red;
    case TaskState.inProgress:
      return Colors.orange;
    case TaskState.completed:
      return Colors.green;
    default:
      return Colors.grey;
  }
}

/// Returns the color of the task priority
/// [priority] is the priority of the task
Color getTaskPriorityColor(TaskPriority priority, {int withAlpha = 100}) {
  switch (priority) {
    case TaskPriority.low:
      return Colors.green.withAlpha(withAlpha);
    case TaskPriority.medium:
      return Colors.orange.withAlpha(withAlpha);
    case TaskPriority.high:
      return Colors.red.withAlpha(withAlpha);
    default:
      return Colors.grey;
  }
}
