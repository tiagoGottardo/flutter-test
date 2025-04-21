import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/services/task_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/controllers/theme_controller.dart';

TaskFilter toggleFilter(TaskFilter actual) {
  switch (actual) {
    case TaskFilter.favorite:
      return TaskFilter.undone;
    case TaskFilter.undone:
      return TaskFilter.none;
    case TaskFilter.none:
      return TaskFilter.favorite;
  }
}

Icon pickFilterIcon(TaskFilter filter) {
  IconData icon;
  switch (filter) {
    case TaskFilter.favorite:
      icon = Icons.star;
      break;
    case TaskFilter.undone:
      icon = Icons.circle_outlined;
      break;
    case TaskFilter.none:
      icon = Icons.filter_list;
      break;
  }
  return Icon(icon);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();
  final TaskService taskService = Get.find<TaskService>();

  String searchQuery = '';
  TaskFilter filter = TaskFilter.none;
  final themeController = Get.put(ThemeController());

  @override
  void initState() {
    super.initState();

    _syncTasks();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });
  }

  Future<void> _syncTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Get.find<TaskService>().syncWithFirestore(user.uid);
      setState(() {}); // Rebuild with local tasks if needed
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.offAllNamed('/login');
      return const Center(child: Text('You must be logged in'));
    }

    final userName =
        (user.displayName?.trim().isNotEmpty ?? false)
            ? user.displayName!
            : 'Guest';

    return Scaffold(
      appBar: AppBar(title: Text("${userName.split(" ")[0]}'s tasks")),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Text(
                'Settings',
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
            ),
            ListTile(
              title: const Text('Toggle Theme'),
              trailing: Obx(
                () => Icon(
                  themeController.isDark.value
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
              ),
              onTap: () => themeController.toggleTheme(),
            ),
            ListTile(
              title: const Text('Logout'),
              trailing: const Icon(Icons.logout),
              onTap: logout,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: pickFilterIcon(filter),
                onPressed:
                    () => setState(() {
                      filter = toggleFilter(filter);
                    }),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: taskService.taskBox.listenable(),
              builder: (context, Box<Task> box, _) {
                final filteredTasks = taskService.getFilteredTasks(
                  searchQuery,
                  filter,
                );

                if (filteredTasks.isEmpty) {
                  return const Center(child: Text('No tasks found.'));
                }

                return ListView.builder(
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return ExpansionTile(
                      title: Text(task.title),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              task.done
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: task.done ? Colors.green : null,
                            ),
                            onPressed: () => taskService.toggleDone(task),
                          ),
                          IconButton(
                            icon: Icon(
                              task.favorite ? Icons.star : Icons.star_border,
                              color: task.favorite ? Colors.amber : Colors.grey,
                            ),
                            onPressed: () => taskService.toggleFavorite(task),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.description),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed:
                                        () => Get.toNamed(
                                          '/task',
                                          arguments: task.toMap(),
                                        ),
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Edit'),
                                  ),
                                  TextButton.icon(
                                    onPressed: () async {
                                      final confirmed = await Get.defaultDialog<
                                        bool
                                      >(
                                        title: "Confirm Delete",
                                        middleText:
                                            "Are you sure you want to delete this task?",
                                        textConfirm: "Yes",
                                        textCancel: "No",
                                        confirmTextColor: Colors.white,
                                        onConfirm: () => Get.back(result: true),
                                        onCancel: () => Get.back(result: false),
                                      );

                                      if (confirmed == true) {
                                        taskService.deleteTask(task.id);
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.offAllNamed('/task'),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
