import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/project_provider.dart';
import '/models/project.dart';
import '/pages/project.dart';
import '/main.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late Future<void> _projectsFuture;
  final userId = supabase.auth.currentUser!.id;
  @override
  void initState() {
    super.initState();
    _projectsFuture = _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    final projectsProvider =
        Provider.of<ProjectProvider>(context, listen: false);
    await projectsProvider.getProjects(userId);
  }

  @override
  Widget build(BuildContext context) {
    final projectsProvider = Provider.of<ProjectProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProjects,
        child: FutureBuilder(
          future: _projectsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              print("Loading projects...");
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print("Error loading projects: ${snapshot.error}");
              return const Center(child: Text('Failed to load tasks'));
            }
            print("Projects loaded!");
            return ListView.builder(
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
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(87, 3, 2, 73),
                      border: Border.all(color: Colors.grey)),
                  child: ListTile(
                    title: Text(project.name),
                    subtitle: Text(project.description),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProjectPage(projectId: project.id!),
                        ),
                      );
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                    print("Creating project...");
                    final newProject = Project(
                      name: name,
                      description: description,
                      isArchived: false,
                      ownerId: userId,
                      memberIds: [userId],
                    );
                    await projectsProvider.createProject(newProject);
                    print("Project created!");
                    _fetchProjects();
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
}
