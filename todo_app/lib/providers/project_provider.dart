import 'package:supabase_flutter/supabase_flutter.dart';
import '/models/project.dart';
import 'package:flutter/material.dart';

class ProjectProvider with ChangeNotifier {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  List<Project> _projects = [];

  List<Project> get projects => _projects;
  Future<void> createProject(Project project) async {
    await _supabaseClient.from('projects').insert({
      'name': project.name,
      'description': project.description,
      'isArchived': project.isArchived,
      'ownerId': project.ownerId,
      'memberIds': project.memberIds,
    });
    notifyListeners();
  }

  Future<void> updateProject(Project project) async {
    final response = await _supabaseClient.from('projects').update({
      'name': project.name,
      'description': project.description,
      'isArchived': project.isArchived,
      'memberIds': project.memberIds,
    }).eq('id', project.id!);
    if (response.error != null) {
      print(response.error!.message);
    }
    notifyListeners();
  }

  Future<void> deleteProject(String projectId) async {
    final response =
        await _supabaseClient.from('projects').delete().eq('id', projectId);
    if (response.error != null) {
      print(response.error!.message);
    }
    notifyListeners();
  }

  Future<List<Project>> getProjects(String userId) async {
    final response = await _supabaseClient
        .from('projects')
        .select()
        .eq('memberIds@>', [userId]);
    _projects =
        (response as List).map((data) => Project.fromMap(data)).toList();
    notifyListeners();
    return projects;
  }
}
