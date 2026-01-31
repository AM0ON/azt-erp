import 'package:flutter/material.dart';

enum TaskPriority { baixa, media, alta, urgente }

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
  String category;
  TaskPriority priority;
  String status; // Alterado para String para suportar Kanban dinâmico
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
    required this.status,
    this.assignee,
    List<TaskComment>? comments,
    List<SubTask>? subtasks,
  }) : comments = comments ?? [],
       subtasks = subtasks ?? [];

  // Lógica de compatibilidade para checkboxes
  bool get isCompleted => status == "Concluído";
  
  set isCompleted(bool value) {
    if (value) {
      status = "Concluído";
    } else {
      status = "A Fazer";
    }
  }

  String get categoryLabel => category;
  String get statusLabel => status;

  // Preserva o design das cores baseado no nome do status
  Color get statusColor {
    final s = status.toLowerCase();
    if (s.contains('fazer') || s.contains('backlog') || s.contains('todo')) return const Color(0xFF64748B);
    if (s.contains('progresso') || s.contains('progress')) return const Color(0xFF3B82F6);
    if (s.contains('análise') || s.contains('review')) return const Color(0xFFF59E0B);
    if (s.contains('concluído') || s.contains('done')) return const Color(0xFF10B981);
    // Cor consistente para novos status criados pelo usuário
    return Colors.primaries[status.hashCode % Colors.primaries.length];
  }

  IconData get categoryIcon {
    final cat = category.toLowerCase().replaceAll(' ', '');
    if (cat.contains('pessoal')) return Icons.person_outline;
    if (cat.contains('produção') || cat.contains('producao')) return Icons.layers_outlined;
    if (cat.contains('web')) return Icons.code;
    if (cat.contains('financeiro')) return Icons.attach_money;
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