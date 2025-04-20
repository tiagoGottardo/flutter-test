import 'package:uuid/v4.dart';

class Task {
  String id;
  String ownerId;
  String title;
  String description;
  bool done;
  bool favorite;
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

  factory Task.fromMap(Map<String, dynamic> data, String id) => Task(
    id: id,
    ownerId: data['ownerId'],
    title: data["title"],
    description: data["description"],
    done: data["done"],
    favorite: data["favorite"],
    createdAt: (data["createdAt"]).toDate(),
  );

  Map<String, dynamic> toMap() => {
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
