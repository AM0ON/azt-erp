import 'package:flutter/material.dart';

enum TaskPriority { baixa, media, alta, urgente }
enum TaskCategory { pessoal, azorTechProducao, azorTechWeb, financeiro }
enum TaskStatus { todo, inProgress, review, done }

class TaskComment {
  final String author;
  final String content;
  final DateTime date;

  TaskComment({required this.author, required this.content, required this.date});
}

class TaskModel {
  final String id;
  String title;
  String description;
  String? client; // [FINALIZADO] Campo Cliente
  DateTime dueDate;
  TaskCategory category;
  TaskPriority priority;
  TaskStatus status;
  String? assignee;
  List<TaskComment> comments;

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
  }) : comments = comments ?? [];

  bool get isCompleted => status == TaskStatus.done;

  // Helpers Visuais
  String get categoryLabel {
    switch (category) {
      case TaskCategory.pessoal: return "Pessoal";
      case TaskCategory.azorTechProducao: return "Produção";
      case TaskCategory.azorTechWeb: return "Web Dev";
      case TaskCategory.financeiro: return "Financeiro";
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case TaskCategory.pessoal: return Icons.person_outline;
      case TaskCategory.azorTechProducao: return Icons.layers_outlined;
      case TaskCategory.azorTechWeb: return Icons.code;
      case TaskCategory.financeiro: return Icons.attach_money;
    }
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