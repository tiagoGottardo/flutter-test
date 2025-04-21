import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/services/task_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskPage extends StatelessWidget {
  final title = TextEditingController();
  final description = TextEditingController();
  final TaskService _taskService = Get.find<TaskService>();

  TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;

    title.text = args != null ? args['title'] : "";
    description.text = args != null ? args['description'] : "";

    return Scaffold(
      appBar: AppBar(title: Text('Task')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: description,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: Text('Cancel'),
                  onPressed: () => Get.offAllNamed('/'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Save'),
                  onPressed: () async {
                    if (title.text.isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Task must have a title',
                        colorText: Colors.white,
                        backgroundColor: Colors.redAccent,
                      );
                      return;
                    }

                    final currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser == null) {
                      Get.snackbar(
                        'Error',
                        'You must be logged in',
                        backgroundColor: Colors.redAccent,
                      );
                      return;
                    }

                    final task =
                        args != null
                            ? Task.fromMap(args)
                            : Task.createNew(
                              ownerId: currentUser.uid,
                              title: title.text,
                              description: description.text,
                            );

                    try {
                      if (args != null) {
                        task.title = title.text;
                        task.description = description.text;
                        await _taskService.updateTask(task);
                      } else {
                        await _taskService.addTask(task);
                      }

                      Get.offAllNamed('/');
                      Get.snackbar('Success', 'Task saved successfully!');
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        'Failed to save task: $e',
                        backgroundColor: Colors.red,
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
