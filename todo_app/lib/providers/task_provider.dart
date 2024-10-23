import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/models/task.dart';

class TaskProvider with ChangeNotifier {
  final SupabaseClient supabaseClient;
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  TaskProvider(this.supabaseClient);

  /// Fetches tasks for a specific project from the database.
  /// [projectId] The ID of the project whose tasks are to be fetched.
  /// @return A list of tasks for the specified project.
  Future<List<Task>> getTasks(int projectId) async {
    final response =
        await supabaseClient.from('tasks').select().eq('projectId', projectId);
    _tasks = (response as List).map((data) => Task.fromMap(data)).toList();
    notifyListeners();
    return tasks;
  }

  /// Fetches a specific task by its ID from the database.
  /// [taskId] The ID of the task to be fetched.
  /// @return The task object with the specified ID.
  Future<Task> getTaskById(int taskId) async {
    try {
      final response =
          await supabaseClient.from('tasks').select().eq('id', taskId).single();
      final task = Task.fromMap(response);
      return task;
    } catch (error) {
      return emptyTask;
    }
  }

  /// Creates a new task in the database.
  /// [task] The task object to be inserted into the database.
  /// @return A boolean indicating whether the task was successfully created.
  Future<bool> createTask(Task task) async {
    try {
      await supabaseClient.from('tasks').insert(task.toMap());
      notifyListeners();
      return true;
    } catch (error) {
      return false;
    }
  }

  /// Updates an existing task in the database.
  /// [id] The ID of the task to be updated.
  /// [nuevaTask] The updated task object.
  /// @return A boolean indicating whether the task was successfully updated.
  Future<bool> updateTask(int id, Task nuevaTask) async {
    try {
      final response = await supabaseClient
          .from('tasks')
          .update(nuevaTask.toMap())
          .eq('id', id);
      notifyListeners();
      return true;
    } catch (error) {
      return false;
    }
  }

  /// Deletes a specific task from the database.
  /// [id] The ID of the task to be deleted.
  /// @return A boolean indicating whether the task was successfully deleted.
  Future<bool> deleteTask(int id) async {
    try {
      await supabaseClient.from('tasks').delete().eq('id', id);
      _tasks.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (error) {
      return false;
    }
  }
}
