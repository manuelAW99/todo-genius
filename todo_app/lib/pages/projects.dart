import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/project_provider.dart';
import '/models/project.dart';
import '/pages/project.dart';
import '/main.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  ProjectsPageState createState() => ProjectsPageState();
}

class ProjectsPageState extends State<ProjectsPage> {
  late Future<void> _projectsFuture;
  final userId = supabase.auth.currentUser!.id;
  @override
  void initState() {
    super.initState();
    _projectsFuture = _fetchProjectsPP();
  }

  /// Fetches the projects of the current user
  Future<void> _fetchProjectsPP() async {
    final projectsProvider =
        Provider.of<ProjectProvider>(context, listen: false);
    await projectsProvider.getProjects(userId);
  }

  /// Shows a dialog to confirm archiving or unarchiving a project
  /// If the user confirms, the project will be archived or unarchived
  /// If the user cancels, the dialog will be dismissed
  /// After the operation, the projects will be fetched again
  /// to reflect the changes
  /// If the user is not the owner of the project, a snackbar will be displayed
  /// indicating that the user does not have permission to archive the project
  /// If the user is the owner of the project, the project will be archived or unarchived
  /// based on the current status
  /// If the project is archived, the project will be unarchived
  /// If the project is unarchived, the project will be archived
  /// The project will be updated in the database
  /// The projects will be fetched again to reflect the changes
  /// The dialog will be dismissed
  /// If the user is not the owner of the project, a snackbar will be displayed
  /// indicating that the user does not have permission to archive the project
  /// If the user is the owner of the project, the project will be archived or unarchived
  /// based on the current status
  /// The project will be updated in the database
  /// The projects will be fetched again to reflect the changes
  /// The dialog will be dismissed
  void _showArchiveProjectDialog(
      BuildContext context, int projectId, bool isArchived) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isArchived ? 'Unarchive Project' : 'Archive Project'),
          content: Text(isArchived
              ? 'Are you sure you want to unarchive this project?'
              : 'Are you sure you want to archive this project?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final projectsProvider =
                    Provider.of<ProjectProvider>(context, listen: false);
                await projectsProvider.updateProjectArchiveStatus(
                    projectId, !isArchived);
                _fetchProjectsPP();
                Navigator.of(context).pop();
              },
              child: Text(isArchived ? 'Unarchive' : 'Archive'),
            ),
          ],
        );
      },
    );
  }

  /// Shows a dialog to create a new project
  /// The user will be able to enter the project name and description
  /// If the user enters a name and description, the project will be created
  /// The project will be added to the database
  /// The projects will be fetched again to reflect the changes
  /// The dialog will be dismissed
  /// If the user does not enter a name or description, the project will not be created
  void _showCreateProjectForm(BuildContext context, String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final nameController = TextEditingController();
        final descriptionController = TextEditingController();
        final projectsProvider =
            Provider.of<ProjectProvider>(context, listen: false);

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Project Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Project Description'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final description = descriptionController.text.trim();
                  if (name.isNotEmpty && description.isNotEmpty) {
                    final newProject = Project(
                      name: name,
                      description: description,
                      isArchived: false,
                      ownerId: userId,
                      memberIds: [userId],
                    );
                    await projectsProvider.createProject(newProject);
                    _fetchProjectsPP();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Create Project'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectsProvider = Provider.of<ProjectProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProjectsPP,
        child: FutureBuilder(
          future: _projectsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Failed to load tasks'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: projectsProvider.projects.length +
                  1, // Add one for the "+" button
              itemBuilder: (context, index) {
                if (index == projectsProvider.projects.length) {
                  return ListTile(
                    title: const Center(
                      child: Icon(Icons.add, size: 40),
                    ),
                    onTap: () {
                      _showCreateProjectForm(context, userId);
                    },
                  );
                }
                final project = projectsProvider.projects[index];
                return Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  decoration: BoxDecoration(
                      color: project.isArchived
                          ? Colors.blueGrey
                          : Theme.of(context).primaryColor,
                      border: const Border(
                          left: BorderSide(width: 4.0, color: Colors.grey),
                          right: BorderSide(width: 4.0, color: Colors.grey)),
                      borderRadius: BorderRadius.circular(20)),
                  child: ListTile(
                    title: Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(project.description),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectPage(project: project),
                        ),
                      );
                    },
                    onLongPress: () {
                      if (project.ownerId == userId) {
                        _showArchiveProjectDialog(
                            context, project.id!, project.isArchived);
                      } else {
                        context.showSnackBar(
                            'You do not have permission to delete this project.',
                            isError: true);
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
