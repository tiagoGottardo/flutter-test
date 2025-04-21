import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:uuid/v4.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String ownerId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String description;

  @HiveField(4)
  bool done;

  @HiveField(5)
  bool favorite;

  @HiveField(6)
  DateTime createdAt;

  Task({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.done,
    required this.favorite,
    required this.createdAt,
  });

  factory Task.fromMap(Map<String, dynamic> data) => Task(
    id: data['id'],
    ownerId: data['ownerId'] ?? '',
    title: data["title"] ?? '',
    description: data["description"] ?? '',
    done: data["done"] ?? false,
    favorite: data["favorite"] ?? false,
    createdAt:
        data["createdAt"] is Timestamp
            ? (data["createdAt"] as Timestamp).toDate()
            : data["createdAt"] as DateTime,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'ownerId': ownerId,
    'title': title,
    'description': description,
    'done': done,
    'favorite': favorite,
    'createdAt': createdAt,
  };

  static Task createNew({
    required String ownerId,
    required String title,
    required String description,
  }) {
    return Task(
      id: UuidV4().generate(),
      ownerId: ownerId,
      title: title,
      description: description,
      done: false,
      favorite: false,
      createdAt: DateTime.now(),
    );
  }
}
