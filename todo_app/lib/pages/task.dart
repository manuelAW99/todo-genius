import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/task.dart';
import '/models/project.dart';
import '/models/profile.dart';
import '/providers/project_provider.dart';
import '/providers/task_provider.dart';
import '/providers/profile_provider.dart';
import '/utils/validation.dart';
import '/utils/colors.dart';
import '/main.dart';

class TaskPage extends StatefulWidget {
  final Task task;
  final Project project;

  const TaskPage({super.key, required this.task, required this.project});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  late TextEditingController _titleController;
  late Future<void> _taskFuture;
  late int taskId;
  late int projectId;
  late bool isArchived;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    taskId = widget.task.id!;
    projectId = widget.task.projectId;
    isArchived = widget.project.isArchived;
    _taskFuture = _fetchTask();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  /// Fetches the task
  /// If the task does not exist, the user will be navigated back to the previous page
  /// and a snackbar will be displayed
  /// If the task exists, the task will be fetched
  /// The task name will be set to the title controller
  Future<void> _fetchTask() async {
    final tasksProvider = Provider.of<TaskProvider>(context, listen: false);
    await tasksProvider.getTasks(projectId);
    final task = tasksProvider.tasks
        .firstWhere((task) => task.id == taskId, orElse: () => emptyTask);
    _titleController = TextEditingController(text: task.name);
  }

  /// Shows a dialog to confirm deleting a task
  /// If the user confirms, the task will be deleted
  /// If the user cancels, the dialog will be dismissed
  /// After the operation, the user will be navigated back to the previous page
  /// If the user is not the owner of the project, a snackbar will be displayed
  /// indicating that the user does not have permission to delete the task
  /// If the user is the owner of the project, the task will be deleted
  /// The task will be deleted from the database
  /// The user will be navigated back to the previous page
  /// The dialog will be dismissed
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
                await tasksProvider.deleteTask(taskId);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  /// Shows the edit task form
  /// The user will be able to edit the task name, state, priority, and assigned user
  /// If the user is the owner of the project or the assigned user of the task,
  /// the user will be able to edit the task
  /// If the user is not the owner of the project or the assigned user of the task,
  /// a snackbar will be displayed
  /// If the task is edited successfully, the task will be updated
  /// The task state will be updated
  /// The dialog will be dismissed
  /// If the task is not edited successfully, a snackbar will be displayed
  /// [context] is the context of the application
  /// [task] is the task to be edited
  void _showEditTaskForm(BuildContext context, Task task) {
    final nameController = TextEditingController(text: task.name);
    TaskPriority selectedPriority = task.priority;
    TaskState selectedState = task.state;
    final tasksProvider = Provider.of<TaskProvider>(context, listen: false);
    final profilesProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    String? selectedAssignedUser = task.assignedTo;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
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
                      setState(() {
                        selectedState = value!;
                      });
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
                      setState(() {
                        selectedPriority = value!;
                      });
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
                  if (supabase.auth.currentUser?.id == widget.project.ownerId)
                    DropdownButtonFormField<String>(
                      value: selectedAssignedUser,
                      validator: (value) =>
                          value == null ? 'Please select a user' : null,
                      onChanged: (String? value) {
                        setState(() {
                          selectedAssignedUser = value;
                        });
                      },
                      items: profilesProvider.profiles
                          .where((profile) =>
                              widget.project.memberIds.contains(profile.id) &&
                              profile.username != null)
                          .map((profile) {
                        return DropdownMenuItem<String>(
                          value: profile.id,
                          child: Text(profile.username!),
                        );
                      }).toList(),
                      decoration:
                          const InputDecoration(labelText: 'Assigned User'),
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
                  if (name.isNotEmpty && selectedAssignedUser != null) {
                    final updatedTask = Task(
                      id: task.id,
                      name: name,
                      state: selectedState,
                      priority: selectedPriority,
                      projectId: task.projectId,
                      assignedTo: selectedAssignedUser!,
                    );
                    await tasksProvider.updateTask(task.id!, updatedTask);
                    setState(() {
                      _taskFuture = _fetchTask();
                    });
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text('Update Task'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksProvider = Provider.of<TaskProvider>(context);
    final profilesProvider = Provider.of<ProfileProvider>(context);
    final projectsProvider = Provider.of<ProjectProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Page'),
      ),
      body: FutureBuilder(
        future: _taskFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load task'));
          } else {
            final task = tasksProvider.tasks.firstWhere(
              (task) => task.id == taskId,
              orElse: () => emptyTask,
            );
            final assignedUser = profilesProvider.profiles.firstWhere(
              (profile) => profile.id == task.assignedTo,
              orElse: () => emptyProfile,
            );

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    task.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Assigned To:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    assignedUser.username == null
                        ? "Unkown"
                        : assignedUser.username!,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'State: ${correctText[task.state.name]}',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: getTaskStateColor(task.state)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Priority: ${correctText[task.priority.name]}',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: getTaskPriorityColor(task.priority,
                            withAlpha: 255)),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: isArchived
            ? []
            : [
                FloatingActionButton(
                  heroTag: 'edit',
                  onPressed: () {
                    final task = tasksProvider.tasks.firstWhere(
                        (task) => task.id == taskId,
                        orElse: () => emptyTask);
                    final project = projectsProvider.projects.firstWhere(
                        (proj) => proj.id == task.projectId,
                        orElse: () => emptyProject);
                    final currentUser = supabase.auth.currentUser;

                    if (currentUser != null &&
                        (currentUser.id == task.assignedTo ||
                            currentUser.id == project.ownerId)) {
                      _showEditTaskForm(context, task);
                    } else {
                      context.showSnackBar(
                          'You do not have permission to edit this task.',
                          isError: true);
                    }
                  },
                  child: const Icon(Icons.edit),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'delete',
                  onPressed: () {
                    final task = tasksProvider.tasks.firstWhere(
                      (task) => task.id == taskId,
                      orElse: () => emptyTask,
                    );
                    final project = projectsProvider.projects.firstWhere(
                      (proj) => proj.id == task.projectId,
                      orElse: () => emptyProject,
                    );
                    final currentUser = supabase.auth.currentUser;

                    if (currentUser != null &&
                        (currentUser.id == task.assignedTo ||
                            currentUser.id == project.ownerId)) {
                      _showDeleteTaskDialog(context, task.id!);
                    } else {
                      context.showSnackBar(
                          'You do not have permission to delete this task.',
                          isError: true);
                    }
                  },
                  child: const Icon(Icons.delete),
                ),
              ],
      ),
    );
  }
}
