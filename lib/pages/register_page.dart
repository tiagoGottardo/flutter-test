import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatelessWidget {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  RegisterPage({super.key});

  void register() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      await FirebaseAuth.instance.currentUser!.updateDisplayName(name.text);

      Get.offAllNamed('/');
    } catch (e) {
      Get.snackbar(
        "Registration Failed",
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: const Text('Register')),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
