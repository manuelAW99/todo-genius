import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/models/task.dart';

class TaskProvider with ChangeNotifier {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  Future<List<Task>> getTasks(int projectId) async {
    final response =
        await _supabaseClient.from('tasks').select().eq('projectId', projectId);
    _tasks = (response as List).map((data) => Task.fromMap(data)).toList();
    notifyListeners();
    return tasks;
  }

  Future<void> createTask(Task task) async {
    await _supabaseClient.from('tasks').insert({
      'name': task.name,
      'state': task.state.index,
      'priority': task.priority.index,
      'projectId': task.projectId,
      'assignedTo': task.assignedTo,
    });
    notifyListeners();
  }

  Future<void> editTask(String id, Task nuevaTask) async {
    final response = await _supabaseClient
        .from('tasks')
        .update(nuevaTask.toMap())
        .eq('id', id);
    if (!response.hasData) {
      return;
    }
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = nuevaTask;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    final response = await _supabaseClient.from('tasks').delete().eq('id', id);
    if (!response.hasData) {
      return;
    }
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
