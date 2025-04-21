import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:todo_app/models/task.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum Filter { favorite, undone, none }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();
  late Stream<QuerySnapshot> tasksStream;
  String searchQuery = '';
  Filter filter = Filter.none;

  @override
  void initState() {
    super.initState();
    // Initialize the stream
    searchController.addListener(_updateSearchQuery);
    _updateTasksStream(); // Initial stream load
  }

  void _updateSearchQuery() {
    setState(() {
      searchQuery = searchController.text;
    });
    _updateTasksStream(); // Update Firestore query based on the search
  }

  void _updateTasksStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Start with the basic Firestore query
      var query = FirebaseFirestore.instance
          .collection('tasks')
          .where('ownerId', isEqualTo: user.uid);

      if (searchQuery.isNotEmpty) {
        query = query
            .where('title', isGreaterThanOrEqualTo: searchQuery)
            .where('title', isLessThanOrEqualTo: searchQuery + '\uf8ff');
      }

      if (filter == Filter.undone) {
        query = query.where('done', isEqualTo: false);
      }

      if (filter == Filter.favorite) {
        query = query.where('favorite', isEqualTo: true);
      }

      query = query
          .orderBy('done', descending: false)
          .orderBy('favorite', descending: true);

      tasksStream = query.snapshots();
    }
  }

  @override
  void dispose() {
    searchController.removeListener(_updateSearchQuery);
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
              trailing: Icon(
                Get.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
              onTap: () {
                Get.changeThemeMode(
                  Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                );
              },
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
          SizedBox(
            width: 330,
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2.0, // Border width
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: tasksStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No tasks found.'));
                }

                final tasks =
                    snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      data['id'] = doc.id;
                      return Task.fromMap(data);
                    }).toList();

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
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
                            onPressed:
                                () async => await FirebaseFirestore.instance
                                    .collection('tasks')
                                    .doc(task.id)
                                    .update({'done': !task.done}),
                          ),
                          IconButton(
                            icon: Icon(
                              task.favorite ? Icons.star : Icons.star_border,
                              color: task.favorite ? Colors.amber : Colors.grey,
                            ),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('tasks')
                                  .doc(task.id)
                                  .update({'favorite': !task.favorite});
                            },
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
                                    onPressed: () {
                                      Get.toNamed(
                                        '/task',
                                        arguments: task.toMap(),
                                      );
                                    },
                                    icon: Icon(Icons.edit),
                                    label: Text('Edit'),
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
                                        await FirebaseFirestore.instance
                                            .collection('tasks')
                                            .doc(task.id)
                                            .delete();
                                      }
                                    },
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    label: Text(
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
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
