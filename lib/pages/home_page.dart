import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:todo_app/models/task.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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

    final tasksStream =
        FirebaseFirestore.instance
            .collection('tasks')
            .where('ownerId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: StreamBuilder<QuerySnapshot>(
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
                return Task.fromMap(data, doc.id);
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
                        task.done ? Icons.check_circle : Icons.circle_outlined,
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
                                  arguments: task.toMap()..['id'] = task.id,
                                );
                              },
                              icon: Icon(Icons.edit),
                              label: Text('Edit'),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                final confirmed = await Get.defaultDialog<bool>(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.offAllNamed('/task'),
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
