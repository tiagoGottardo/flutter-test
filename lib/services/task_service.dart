import 'package:todo_app/models/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum TaskFilter { favorite, undone, none }

class TaskService {
  final Box<Task> taskBox = Hive.box<Task>('tasks');

  TaskService() {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  }

  void syncWithFirestore(String userId) {
    FirebaseFirestore.instance
        .collection('tasks')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
          for (var doc in snapshot.docs) {
            final task = Task.fromMap({...doc.data(), 'id': doc.id});
            taskBox.put(task.id, task);
          }
        });
  }

  List<Task> getFilteredTasks(String searchQuery, TaskFilter filter) {
    final allTasks = taskBox.values.toList();

    return allTasks.where((task) {
        final matchesSearch =
            searchQuery.isEmpty ||
            task.title.toLowerCase().contains(searchQuery.toLowerCase());
        final matchesFilter = switch (filter) {
          TaskFilter.none => true,
          TaskFilter.undone => !task.done,
          TaskFilter.favorite => task.favorite,
        };
        return matchesSearch && matchesFilter;
      }).toList()
      ..sort((a, b) {
        if (a.done != b.done) return a.done ? 1 : -1;
        if (a.favorite != b.favorite) return b.favorite ? 1 : -1;
        return 0;
      });
  }

  Future<void> addTask(Task task) async {
    final docRef = FirebaseFirestore.instance.collection('tasks').doc();
    task.id = docRef.id;

    await taskBox.put(task.id, task);

    docRef.set(task.toMap());
  }

  Future<void> toggleDone(Task task) async {
    if (task.id.isEmpty) return;

    task.done = !task.done;
    await updateTask(task);
  }

  Future<void> toggleFavorite(Task task) async {
    if (task.id.isEmpty) return;

    task.favorite = !task.favorite;
    await updateTask(task);
  }

  Future<void> updateTask(Task task) async {
    if (task.id.isEmpty) return;

    await taskBox.put(task.id, task);

    FirebaseFirestore.instance
        .collection('tasks')
        .doc(task.id)
        .set(task.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteTask(String taskId) async {
    await taskBox.delete(taskId);

    FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
  }
}
