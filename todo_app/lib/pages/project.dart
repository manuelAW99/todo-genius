import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/profile.dart';
import 'package:todo_app/models/project.dart';
import 'package:todo_app/providers/project_provider.dart';
import '/providers/task_provider.dart';
import '/providers/profile_provider.dart';
import '/models/task.dart';
import '/pages/task.dart';
import '/main.dart';
import '/utils/validation.dart';
import '/utils/colors.dart';
import 'package:intl/intl.dart';

class ProjectPage extends StatefulWidget {
  final Project project;

  const ProjectPage({super.key, required this.project});

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  late Future<void> _fetchFuture;
  late int projectId;
  late bool isArchived;
  late Project project;
  late String userId;
  late String ownerId;
  late List<Profile> members;

  @override
  void initState() {
    super.initState();
    projectId = widget.project.id!;
    isArchived = widget.project.isArchived;
    project = widget.project;
    userId = supabase.auth.currentUser!.id;
    _fetchFuture = _fetch();
  }

  /// Fetches the project, profiles, and tasks
  Future<void> _fetch() async {
    await Future.wait([_fetchProjects(), _fetchProfiles(), _fetchTasks()]);
  }

  /// Fetches the project
  /// If the project does not exist, the user will be navigated back to the previous page
  /// and a snackbar will be displayed
  /// If the project exists, the project will be fetched
  Future<void> _fetchProjects() async {
    final projectsProvider =
        Provider.of<ProjectProvider>(context, listen: false);
    await projectsProvider.getProjects(userId);
    project = projectsProvider.projects.firstWhere(
      (proj) => proj.id == projectId,
      orElse: () => emptyProject,
    );
    final projectExists =
        projectsProvider.projects.any((proj) => proj.id == projectId);
    if (!projectExists) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The project no longer exists')),
        );
      }
    }
  }

  /// Fetches the profiles of the members of the project
  /// The profiles of the members will be fetched
  /// and stored in the [members] list
  Future<void> _fetchProfiles() async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    await profileProvider.fetchUsers();
    members = profileProvider.profiles
        .where((profile) => project.memberIds.contains(profile.id))
        .toList();
  }

  /// Fetches the tasks of the project
  Future<void> _fetchTasks() async {
    final tasksProvider = Provider.of<TaskProvider>(context, listen: false);
    await tasksProvider.getTasks(projectId);
  }

  /// Formats the timestamp to a readable format
  /// If the timestamp is null, empty, or "null", "N/A" will be returned
  /// Otherwise, the timestamp will be formatted to "EEEE, MMM d, yyyy h:mm a"
  /// and returned
  /// [timestamp] is the timestamp to be formatted
  String _formatTimestamp(String? timestamp) {
    if (timestamp == null || timestamp == '' || timestamp == "null")
      return 'N/A';
    final dateTime = DateTime.parse(timestamp);
    final formatter = DateFormat('EEEE, MMM d, yyyy h:mm a');
    return formatter.format(dateTime);
  }

  /// Shows the edit project form
  /// The user will be able to edit the project name, description, and members
  /// The user will be able to add and remove members
  /// If the user is not the owner of the project, a snackbar will be displayed
  /// If the user is the owner of the project, the user will be able to edit the project
  /// and the project will be updated
  /// If the project is updated successfully, the projects and profiles will be fetched
  /// and the modal will be closed
  /// If the project is not updated successfully, a snackbar will be displayed
  /// [context] is the context of the application
  /// [project] is the project to be edited
  void _showEditProjectForm(BuildContext context, Project project) {
    final nameController = TextEditingController(text: project.name);
    final descriptionController =
        TextEditingController(text: project.description);
    Set<String> selectedMembers = project.memberIds.toSet();
    selectedMembers.remove(project.ownerId);
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final projectProvider =
        Provider.of<ProjectProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                    decoration:
                        const InputDecoration(labelText: 'Project Name'),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration:
                        const InputDecoration(labelText: 'Project Description'),
                  ),
                  const SizedBox(height: 16),

                  // Dropdown to add members
                  DropdownButtonFormField<String>(
                    value: null,
                    onChanged: (String? value) {
                      if (value != null && !selectedMembers.contains(value)) {
                        setState(() {
                          selectedMembers.add(value);
                        });
                      }
                    },
                    items: profileProvider.profiles
                        .where((profile) =>
                            profile.id != project.ownerId &&
                            profile.username != null)
                        .map((profile) {
                      return DropdownMenuItem<String>(
                        value: profile.id,
                        child: Text(profile.username!),
                      );
                    }).toList(),
                    decoration: const InputDecoration(labelText: 'Add Member'),
                  ),
                  const SizedBox(height: 16),

                  // Wrap to display members with option to remove
                  Wrap(
                    spacing: 8,
                    children: selectedMembers.map((memberId) {
                      final member = profileProvider.profiles.firstWhere(
                        (profile) =>
                            profile.id == memberId && profile.username != null,
                        orElse: () => emptyProfile,
                      );
                      return Chip(
                        label: Text(member.username!),
                        onDeleted: () {
                          setState(() {
                            selectedMembers.remove(memberId);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      final description = descriptionController.text.trim();

                      if (name.isNotEmpty && description.isNotEmpty) {
                        if (selectedMembers.toSet() !=
                            project.memberIds.toSet()) {
                          final tasksProvider = Provider.of<TaskProvider>(
                            context,
                            listen: false,
                          );

                          // Reassign tasks to the owner if the owner is removed
                          final tasks = tasksProvider.tasks
                              .where((task) =>
                                  task.projectId == project.id &&
                                  !selectedMembers.contains(task.assignedTo))
                              .toList();
                          for (var task in tasks) {
                            task.assignedTo = project.ownerId;
                            await tasksProvider.updateTask(task.id!, task);
                          }
                        }

                        // Create the updated project with the new data
                        final updatedProject = Project(
                          id: project.id,
                          name: name,
                          description: description,
                          isArchived: project.isArchived,
                          ownerId: project.ownerId,
                          memberIds: selectedMembers.toList()
                            ..add(project.ownerId),
                        );

                        // Update the project
                        bool updated =
                            await projectProvider.updateProject(updatedProject);
                        if (updated) {
                          await _fetchProjects();
                          await _fetchProfiles();
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error updating project.'),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Update Project'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Shows the delete task dialog
  /// The user will be able to delete the task
  /// If the user is the owner of the project or the assigned user of the task,
  /// the user will be able to delete the task
  /// If the user is not the owner of the project or the assigned user of the task,
  /// a snackbar will be displayed
  /// If the task is deleted successfully, the task will be deleted
  /// and the projects and tasks will be fetched
  /// If the task is not deleted successfully, a snackbar will be displayed
  /// [context] is the context of the application
  /// [taskId] is the id of the task to be deleted
  void _showDeleteTaskDialog(BuildContext context, int taskId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final tasksProvider =
                    Provider.of<TaskProvider>(context, listen: false);
                bool deleted = await tasksProvider.deleteTask(taskId);
                if (deleted) {
                  _fetchProjects();
                  _fetchTasks();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error deleting task.'),
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  /// Shows the delete project dialog
  /// The user will be able to delete the project
  /// If the user is the owner of the project, the user will be able to delete the project
  /// If the user is not the owner of the project, a snackbar will be displayed
  /// If the project is deleted successfully, the project will be deleted
  /// and the projects will be fetched
  /// If the project is not deleted successfully, a snackbar will be displayed
  /// [context] is the context of the application
  /// [projectId] is the id of the project to be deleted
  void _showDeleteProjectDialog(BuildContext context, int projectId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Project'),
          content: const Text('Are you sure you want to delete this project?'),
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
                await projectsProvider.deleteProject(projectId);
                Navigator.of(context).pop();
                _fetchProjects();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  /// Shows the create task form
  /// The user will be able to create a task
  /// The user will be able to select the task name, state, priority, and assigned user
  /// If the task is created successfully, the task will be created
  /// and the projects and tasks will be fetched
  /// If the task is not created successfully, a snackbar will be displayed
  /// [context] is the context of the application
  /// [projectId] is the id of the project to create the task in
  /// [userId] is the id of the user creating the task
  void _showCreateTaskForm(BuildContext context, int projectId, String userId) {
    TaskPriority selectedPriority = TaskPriority.medium;
    TaskState selectedState = TaskState.pending;
    String? assignedTo;
    final nameController = TextEditingController();
    final tasksProvider = Provider.of<TaskProvider>(context, listen: false);
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Task'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Task Name',
                    ),
                    validator: (value) {
                      if (validateName(value) != null) {
                        return 'Please enter a task name.';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<TaskState>(
                    value: selectedState,
                    onChanged: (TaskState? value) {
                      selectedState = value!;
                    },
                    items: TaskState.values.map((state) {
                      return DropdownMenuItem<TaskState>(
                        value: state,
                        child: Text(correctText[state.name]!),
                      );
                    }).toList(),
                    decoration: const InputDecoration(labelText: 'Task State'),
                  ),
                  DropdownButtonFormField<TaskPriority>(
                    value: selectedPriority,
                    onChanged: (TaskPriority? value) {
                      selectedPriority = value!;
                    },
                    items: TaskPriority.values.map((priority) {
                      return DropdownMenuItem<TaskPriority>(
                        value: priority,
                        child: Text(correctText[priority.name]!),
                      );
                    }).toList(),
                    decoration:
                        const InputDecoration(labelText: 'Task Priority'),
                  ),
                  DropdownButtonFormField<String>(
                    value: assignedTo,
                    validator: (value) =>
                        value == null ? 'Please select a user' : null,
                    onChanged: (String? value) {
                      assignedTo = value;
                    },
                    items: profileProvider.profiles
                        .where((profile) =>
                            widget.project.memberIds.contains(profile.id) &&
                            profile.username != null)
                        .map((profile) {
                      return DropdownMenuItem<String>(
                        value: profile.id,
                        child: Text(profile.username!),
                      );
                    }).toList(),
                    decoration: const InputDecoration(labelText: 'Assign To'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final name = nameController.text.trim();
                  final newTask = Task(
                    name: name,
                    state: selectedState,
                    priority: selectedPriority,
                    projectId: projectId,
                    assignedTo: assignedTo!,
                  );
                  bool insert = await tasksProvider.createTask(newTask);
                  if (insert) {
                    _fetchProjects();
                    _fetchTasks();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Error creating task. The project might not exist.')),
                    );
                  }
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Create Task'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksProvider = Provider.of<TaskProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final projectProvider = Provider.of<ProjectProvider>(context);

    project = projectProvider.projects.firstWhere(
      (proj) => proj.id == projectId,
      orElse: () => emptyProject,
    );
    ownerId = project.ownerId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Page'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchProjects();
          await _fetchProfiles();
          await _fetchTasks();
        },
        child: FutureBuilder(
          future: _fetchFuture,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return const Center(child: Text('Failed to load data.'));
            } else {
              // Verify if the project exists
              if (project.id == -1) {
                return const Center(child: Text('Project not found.'));
              }
              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Project details
                  Text(
                    project.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    project.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Created At: ${_formatTimestamp(project.createdAt.toString())}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Archived: ${project.isArchived ? "Yes" : "No"}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Owner: ${profileProvider.profiles.firstWhere(
                          (profile) => profile.id == project.ownerId,
                          orElse: () => emptyProfile,
                        ).username}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Members:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  ...members.map((member) => Text(
                        "${member.username} (${member.email})",
                        style: const TextStyle(fontSize: 14),
                      )),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Tasks',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Task list
                  ...tasksProvider.tasks
                      .where((task) => task.projectId == projectId)
                      .map((task) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: getTaskPriorityColor(task.priority),
                        border: Border(
                          left: BorderSide(
                              width: 4.0, color: getTaskStateColor(task.state)),
                          right: BorderSide(
                              width: 4.0, color: getTaskStateColor(task.state)),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        title: Text(task.name),
                        subtitle: Text(
                          'State: ${correctText[task.state.name]}, Prioridad: ${correctText[task.priority.name]}',
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskPage(
                                task: task,
                                project: project,
                              ),
                            ),
                          );
                        },
                        onLongPress: () {
                          if (ownerId == userId || task.assignedTo == userId) {
                            _showDeleteTaskDialog(context, task.id!);
                          }
                        },
                      ),
                    );
                  }),

                  if (!isArchived)
                    ListTile(
                      title: const Center(
                        child: Icon(Icons.add, size: 40),
                      ),
                      onTap: () {
                        _showCreateTaskForm(
                            context, projectId, supabase.auth.currentUser!.id);
                      },
                    ),
                ],
              );
            }
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!isArchived)
            FloatingActionButton(
              heroTag: 'edit',
              onPressed: () {
                if (project.id != null &&
                    supabase.auth.currentUser!.id == project.ownerId) {
                  _showEditProjectForm(context, project);
                } else {
                  context.showSnackBar(
                    'You do not have permission to edit this project.',
                    isError: true,
                  );
                }
              },
              child: const Icon(Icons.edit),
            ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'delete',
            onPressed: () {
              if (project.id != null &&
                  supabase.auth.currentUser!.id == project.ownerId) {
                _showDeleteProjectDialog(context, project.id!);
              } else {
                context.showSnackBar(
                  'You do not have permission to delete this project.',
                  isError: true,
                );
              }
            },
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
