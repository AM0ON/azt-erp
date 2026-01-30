import 'package:flutter/material.dart';

enum TaskPriority { baixa, media, alta, urgente }
// Enum de Categoria removido: Agora usamos String dinâmica
enum TaskStatus { todo, inProgress, review, done }

class TaskComment {
  final String author;
  final String content;
  final DateTime date;

  TaskComment({required this.author, required this.content, required this.date});
}

class SubTask {
  final String id;
  String title;
  bool isCompleted;

  SubTask({required this.id, required this.title, this.isCompleted = false});
}

class TaskModel {
  final String id;
  String title;
  String description;
  String? client;
  DateTime dueDate;
  String category; // Tipo String Confirmado
  TaskPriority priority;
  TaskStatus status;
  String? assignee;
  List<TaskComment> comments;
  List<SubTask> subtasks;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    this.client,
    required this.dueDate,
    required this.category,
    required this.priority,
    this.status = TaskStatus.todo,
    this.assignee,
    List<TaskComment>? comments,
    List<SubTask>? subtasks,
  }) : comments = comments ?? [],
       subtasks = subtasks ?? [];

  bool _isCompleted = false;
  
  bool get isCompleted {
    return status == TaskStatus.done;
  }
  
  set isCompleted(bool value) {
    _isCompleted = value;
    if (value) {
      status = TaskStatus.done;
    } else {
      if (status == TaskStatus.done) status = TaskStatus.todo;
    }
  }

  String get categoryLabel => category;

  IconData get categoryIcon {
    final cat = category.toLowerCase().replaceAll(' ', '');
    if (cat.contains('pessoal')) return Icons.person_outline;
    if (cat.contains('produção') || cat.contains('producao')) return Icons.layers_outlined;
    if (cat.contains('web')) return Icons.code;
    if (cat.contains('financeiro')) return Icons.attach_money;
    if (cat.contains('marketing')) return Icons.campaign;
    return Icons.bookmark_outline;
  }

  Color get priorityColor {
    switch (priority) {
      case TaskPriority.baixa: return const Color(0xFFE0F2FE);
      case TaskPriority.media: return const Color(0xFFFEF3C7);
      case TaskPriority.alta: return const Color(0xFFFFEDD5);
      case TaskPriority.urgente: return const Color(0xFFFEE2E2);
    }
  }

  Color get priorityTextColor {
    switch (priority) {
      case TaskPriority.baixa: return const Color(0xFF0284C7);
      case TaskPriority.media: return const Color(0xFFD97706);
      case TaskPriority.alta: return const Color(0xFFEA580C);
      case TaskPriority.urgente: return const Color(0xFFDC2626);
    }
  }
  
  String get priorityLabel => priority.name;
}