import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/project.dart';
import 'package:todo_app/providers/project_provider.dart';
import '/providers/task_provider.dart';
import '/providers/profile_provider.dart';
import '/models/task.dart';
import '/models/profile.dart';
import '/main.dart';
import 'package:intl/intl.dart';

class ProjectPage extends StatefulWidget {
  final int projectId;

  const ProjectPage({super.key, required this.projectId});

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  late Future<void> _tasksFuture;
  late Future<void> _profilesFuture;
  late int projectId;
  @override
  void initState() {
    super.initState();
    // Cargamos las tareas solo una vez usando initState
    projectId = widget.projectId;
    final userId = supabase.auth.currentUser!.id;
    _profilesFuture =
        Provider.of<ProfileProvider>(context, listen: false).fetchUsers();
    _tasksFuture =
        Provider.of<TaskProvider>(context, listen: false).getTasks(projectId);
  }

  Future<void> _fetchTasks() async {
    final tasksProvider = Provider.of<TaskProvider>(context, listen: false);
    await tasksProvider.getTasks(projectId);
  }

  @override
  Widget build(BuildContext context) {
    final tasksProvider = Provider.of<TaskProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final projectProvider = Provider.of<ProjectProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyect Page'),
      ),
      body: FutureBuilder(
        future: Future.wait([_tasksFuture, _profilesFuture]),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print("Loading tasks...");
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print("Error loading tasks: ${snapshot.error}");
            return const Center(child: Text('Failed to load tasks'));
          } else {
            final _project = projectProvider.projects
                .firstWhere((proj) => proj.id == projectId);
            final members = _project.memberIds
                .map((id) => profileProvider.profiles
                    .firstWhere((profile) => profile.id == id))
                .toList();
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _project.name,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _project.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Created At: ${_formatTimestamp(_project.createdAt.toString())}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Archived: ${_project.isArchived ? "Yes" : "No"}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Owner: ${profileProvider.profiles.firstWhere((profile) => profile.id == _project.ownerId).username}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Members:',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      ...members.map((member) => Text(
                            member.username,
                            style: const TextStyle(fontSize: 14),
                          )),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: tasksProvider.tasks.length + 1,
                    itemBuilder: (ctx, index) {
                      if (index == tasksProvider.tasks.length) {
                        return ListTile(
                          title: const Center(
                            child: Icon(Icons.add, size: 40),
                          ),
                          onTap: () {
                            _showCreateTaskForm(context, projectId,
                                supabase.auth.currentUser!.id);
                          },
                        );
                      }
                      final task = tasksProvider.tasks[index];
                      if (task.projectId == projectId) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(87, 3, 2, 73),
                            border: Border.all(
                                color: _getTaskPriorityColor(task.priority)),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getTaskStateColor(task.state),
                              radius: 10,
                            ),
                            title: Text(task.name),
                            subtitle: Text(
                                'Estado: ${task.state.name}, Prioridad: ${task.priority.name}'),
                            onTap: () {
                              // Navegar a
                            },
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'N/A';
    final dateTime = DateTime.parse(timestamp);
    final formatter = DateFormat('EEEE, MMM d, yyyy h:mm a');
    return formatter.format(dateTime);
  }

  Color _getTaskStateColor(TaskState state) {
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

  Color _getTaskPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showCreateTaskForm(BuildContext context, int projectId, String userId) {
    TaskPriority selectedPriority = TaskPriority.medium;
    TaskState selectedState = TaskState.pending;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final nameController = TextEditingController();
        final tasksProvider = Provider.of<TaskProvider>(context, listen: false);

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
                decoration: const InputDecoration(labelText: 'Task Name'),
              ),
              DropdownButtonFormField<TaskState>(
                value: selectedState,
                onChanged: (TaskState? value) {
                  selectedState = value!;
                },
                items: TaskState.values.map((state) {
                  return DropdownMenuItem<TaskState>(
                    value: state,
                    child: Text(state.toString().split('.')[1]),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Task Priority'),
              ),
              DropdownButtonFormField<TaskPriority>(
                value: selectedPriority,
                onChanged: (TaskPriority? value) {
                  selectedPriority = value!;
                },
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem<TaskPriority>(
                    value: priority,
                    child: Text(priority.toString().split('.')[1]),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Task Priority'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    final newTask = Task(
                      name: name,
                      state: selectedState,
                      priority: selectedPriority,
                      projectId: projectId,
                      assignedTo: [userId], // Replace with actual user ID
                    );
                    print(newTask);
                    await tasksProvider.createTask(newTask);
                    _fetchTasks();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Create Task'),
              ),
            ],
          ),
        );
      },
    );
  }
}
