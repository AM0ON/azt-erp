import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../services/storage_service.dart';
import '../core/utils/input_sanitizer.dart';

class CategoryItem {
  final String label;
  final IconData icon;
  CategoryItem(this.label, this.icon);
}

class TaskController extends ChangeNotifier {
  final Uuid _uuid = const Uuid();
  bool isManager = true;

  List<CategoryItem> _categories = [
    CategoryItem("Projetos", Icons.rocket_launch),
    CategoryItem("Gestão", Icons.work),
    CategoryItem("Pessoal", Icons.person),
    CategoryItem("Infra", Icons.computer),
  ];

  List<TaskModel> _tasks = [];
  String _currentFilter = 'Todos';

  TaskController() {
    _loadData();
  }

  List<TaskModel> get tasks => _currentFilter == 'Todos'
      ? List.unmodifiable(_tasks)
      : _tasks.where((t) => t.category == _currentFilter).toList();

  List<CategoryItem> get categories => List.unmodifiable(_categories);
  String get currentFilter => _currentFilter;
  int get activeTasksCount => _tasks.where((t) => t.status != TaskStatus.done).length;

  void _loadData() {
    final rawTasks = StorageService.getAllTasks();
    if (rawTasks.isNotEmpty) {
      _tasks = rawTasks.map((map) => TaskModel.fromMap(map)).toList();
      _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      _tasks = [];
    }

    final savedCatLabels = StorageService.getCategories();
    for (var label in savedCatLabels) {
      if (!_categories.any((c) => c.label == label)) {
        _categories.add(CategoryItem(label, Icons.label_outline));
      }
    }
    notifyListeners();
  }

  void setFilter(String category) {
    _currentFilter = category;
    notifyListeners();
  }

  void addTask({
    required String title,
    required String description,
    required TaskPriority priority,
    required String category,
    DateTime? deadline
  }) {
    final cleanTitle = InputSanitizer.clean(title);
    final cleanDesc = InputSanitizer.clean(description);

    final newTask = TaskModel(
      id: _uuid.v7(),
      title: cleanTitle.isEmpty ? "Sem Título" : cleanTitle,
      description: cleanDesc,
      createdAt: DateTime.now(),
      deadline: deadline,
      priority: priority,
      category: category,
      status: TaskStatus.todo,
      subtasks: [], // Inicia vazio
    );

    _tasks.insert(0, newTask);
    notifyListeners();
    StorageService.saveTask(newTask.toMap());
  }

  void updateTaskStatus(String id, TaskStatus newStatus) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      task.status = newStatus;
      notifyListeners();
      StorageService.saveTask(task.toMap());
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    StorageService.deleteTask(id);
  }

  // --- MÉTODOS DE SUBTAREFAS (O ERRO ESTAVA AQUI) ---

  // 1. Alternar Checkbox (Concluir/Reabrir Subtarefa)
  void toggleSubTask(String taskId, String subTaskId) {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      // Encontra a subtarefa
      try {
        final subTask = task.subtasks.firstWhere((s) => s.id == subTaskId);
        subTask.isCompleted = !subTask.isCompleted;
        
        notifyListeners();
        StorageService.saveTask(task.toMap()); // Salva o estado atualizado
      } catch (e) {
        debugPrint("Subtarefa não encontrada: $e");
      }
    }
  }

  // 2. Adicionar Subtarefa
  void addSubTask(String taskId, String title) {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1 && title.isNotEmpty) {
      final task = _tasks[taskIndex];
      final newSub = SubTask(id: _uuid.v7(), title: title);
      
      task.subtasks.add(newSub);
      notifyListeners();
      StorageService.saveTask(task.toMap());
    }
  }

  // 3. Remover Subtarefa
  void removeSubTask(String taskId, String subTaskId) {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      task.subtasks.removeWhere((s) => s.id == subTaskId);
      
      notifyListeners();
      StorageService.saveTask(task.toMap());
    }
  }

  // --- FIM DOS MÉTODOS DE SUBTAREFAS ---

  void addCategory(String label, IconData icon) {
    final cleanLabel = InputSanitizer.clean(label);
    if (cleanLabel.isNotEmpty && !_categories.any((c) => c.label == cleanLabel)) {
      _categories.add(CategoryItem(cleanLabel, icon));
      notifyListeners();

      final defaultLabels = ["Projetos", "Gestão", "Pessoal", "Infra"];
      final customCategories = _categories
          .where((c) => !defaultLabels.contains(c.label))
          .map((c) => c.label)
          .toList();

      StorageService.saveCategories(customCategories);
    }
  }

  void clearAll() {
    _tasks.clear();
    notifyListeners();
    StorageService.clearAll();
  }
}