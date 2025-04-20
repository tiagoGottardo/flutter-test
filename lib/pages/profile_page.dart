import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Center(
        child: ElevatedButton(
          child: Text('Back to Home'),
          onPressed: () => Get.back(),
        ),
      ),
    );
  }
}
