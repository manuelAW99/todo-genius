import 'package:supabase_flutter/supabase_flutter.dart';
import '/models/project.dart';
import 'package:flutter/material.dart';

class ProjectProvider with ChangeNotifier {
  final SupabaseClient supabaseClient;
  List<Project> _projects = [];

  ProjectProvider(this.supabaseClient);

  /// Returns a list of projects sorted by the project ID.
  /// Projects that are archived are displayed at the end of the list.
  /// @return A list of projects.
  List<Project> get projects {
    _projects.sort((a, b) {
      if (a.isArchived == b.isArchived) {
        return a.id!.compareTo(b.id!);
      }
      return a.isArchived ? 1 : -1;
    });
    return _projects;
  }

  /// Creates a new project in the database.
  /// [project] The project object to be inserted into the database.
  /// @return A boolean indicating whether the project was successfully created.
  Future<bool> createProject(Project project) async {
    try {
      await supabaseClient.from('projects').insert(project.toMap());
      notifyListeners();
      return true;
    } catch (error) {
      return false;
    }
  }

  /// Updates an existing project in the database.
  /// [project] The updated project object.
  /// @return A boolean indicating whether the project was successfully updated.
  Future<bool> updateProject(Project project) async {
    try {
      final response = await supabaseClient
          .from('projects')
          .update(project.toMap())
          .eq('id', project.id!);
      notifyListeners();
      return true;
    } catch (error) {
      return false;
    }
  }

  /// Deletes a project from the database.
  /// [projectId] The ID of the project to be deleted.
  /// @return A boolean indicating whether the project was successfully deleted.
  Future<void> deleteProject(int projectId) async {
    final response =
        await supabaseClient.from('projects').delete().eq('id', projectId);
    notifyListeners();
  }

  /// Fetches projects for a specific user from the database.
  /// [userId] The ID of the user whose projects are to be fetched.
  /// @return A list of projects for the specified user.
  Future<List<Project>> getProjects(String userId) async {
    try {
      final response = await supabaseClient
          .from('projects')
          .select()
          .contains('memberIds', [userId]);
      _projects =
          (response as List).map((data) => Project.fromMap(data)).toList();
      notifyListeners();
      return projects;
    } catch (error) {
      return [];
    }
  }

  /// Fetches a specific project by its ID from the database.
  /// [projectId] The ID of the project to be fetched.
  /// @return The project object with the specified ID.
  Future<bool> updateProjectArchiveStatus(
      int projectId, bool isArchived) async {
    try {
      await supabaseClient
          .from('projects')
          .update({'isArchived': isArchived}).eq('id', projectId);
      notifyListeners();
      return true;
    } catch (error) {
      return false;
    }
  }
}
