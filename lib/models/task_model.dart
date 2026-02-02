import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high }
enum TaskStatus { todo, inProgress, done }

// --- CLASSE SUBTAREFA (Checklist) ---
class SubTask {
  final String id;
  final String title;
  bool isCompleted;

  SubTask({
    required this.id, 
    required this.title, 
    this.isCompleted = false
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory SubTask.fromMap(Map<dynamic, dynamic> map) {
    return SubTask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

// --- MODELO PRINCIPAL ---
class TaskModel {
  String id;
  String title;
  String description;
  DateTime createdAt;
  DateTime? deadline;
  TaskPriority priority;
  TaskStatus status;
  String category;
  List<String> assignedTo;
  List<SubTask> subtasks; // [NOVO] Lista de subtarefas

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.deadline,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    this.category = 'Geral',
    this.assignedTo = const [],
    this.subtasks = const [], // [NOVO]
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'deadline': deadline?.millisecondsSinceEpoch,
      'priority': priority.index,
      'status': status.index,
      'category': category,
      'assignedTo': assignedTo,
      'subtasks': subtasks.map((s) => s.toMap()).toList(), // [NOVO] Serialização
    };
  }

  factory TaskModel.fromMap(Map<dynamic, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Sem Título',
      description: map['description'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
      deadline: map['deadline'] != null ? DateTime.fromMillisecondsSinceEpoch(map['deadline']) : null,
      priority: TaskPriority.values[map['priority'] ?? 1],
      status: TaskStatus.values[map['status'] ?? 0],
      category: map['category'] ?? 'Geral',
      assignedTo: List<String>.from(map['assignedTo'] ?? []),
      // [NOVO] Deserialização da lista
      subtasks: (map['subtasks'] as List<dynamic>?)
              ?.map((item) => SubTask.fromMap(item as Map))
              .toList() ?? [],
    );
  }

  // Helpers de UI
  Color get priorityColor {
    switch (priority) {
      case TaskPriority.high: return Colors.redAccent;
      case TaskPriority.medium: return Colors.orangeAccent;
      case TaskPriority.low: return Colors.greenAccent;
    }
  }

  String get priorityLabel {
    switch (priority) {
      case TaskPriority.high: return "Alta";
      case TaskPriority.medium: return "Média";
      case TaskPriority.low: return "Baixa";
    }
  }
}