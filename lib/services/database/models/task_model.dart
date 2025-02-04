import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String? id;
  final String userId;
  final String title;
  final String description;
  final DateTime dueDate;
  final String status;
  final String priority;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TaskModel({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.priority,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      dueDate: (json['dueDate'] as Timestamp).toDate(),
      status: json['status'],
      priority: json['priority'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'status': status,
      'priority': priority,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
