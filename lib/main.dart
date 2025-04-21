import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:todo_app/services/task_service.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:todo_app/models/task.dart';

import 'pages/login_page.dart';
import 'pages/register_page.dart';

import 'pages/home_page.dart';
import 'pages/task_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();

  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasks');

  Get.put(TaskService());

  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    Get.find<TaskService>().syncWithFirestore(currentUser.uid);
  }

  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/register', page: () => RegisterPage()),
        GetPage(name: '/', page: () => HomePage()),
        GetPage(name: '/task', page: () => TaskPage()),
      ],
    );
  }
}
