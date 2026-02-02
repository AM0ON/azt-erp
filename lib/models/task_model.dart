import 'package:flutter/material.dart';

enum TaskPriority { baixa, media, alta, urgente }

class SubTask {
  final String id;
  final String title;
  final bool isCompleted;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
}

class Comment {
  final String author;
  final String content;
  final DateTime date;

  Comment({
    required this.author,
    required this.content,
    required this.date,
  });
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final String status;
  final String category;
  final List<SubTask> subtasks;
  final String? client;
  final String? assignee;
  final List<Comment> comments;

  TaskModel({
    required this.id,
    required this.title,
    required this.dueDate,
    this.description = '',
    this.priority = TaskPriority.media,
    this.status = 'A Fazer',
    this.category = 'Geral',
    this.subtasks = const [],
    this.client,
    this.assignee,
    this.comments = const [],
  });

  bool get isCompleted => status == 'Concluído';
  
  Color get priorityTextColor {
    switch (priority) {
      case TaskPriority.urgente: return Colors.redAccent;
      case TaskPriority.alta: return Colors.orangeAccent;
      case TaskPriority.media: return Colors.blueAccent;
      case TaskPriority.baixa: return Colors.greenAccent;
    }
  }
}