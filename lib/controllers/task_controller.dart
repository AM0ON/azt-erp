import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../core/utils/input_sanitizer.dart';

class CategoryItem {
  final String label;
  final IconData icon;
  CategoryItem(this.label, this.icon);
}

class TaskController extends ChangeNotifier {
  final Uuid _uuid = const Uuid();

  final List<TaskModel> _tasks = [];
  List<TaskModel>? _cachedFilteredTasks;

  String _currentFilter = 'Todos';
  final String _userRole = '_CTO';

  final List<String> _statuses = ['A Fazer', 'Em Progresso', 'Revisão', 'Concluído'];

  final List<CategoryItem> _categories = [
    CategoryItem('Todos', Icons.dashboard),
    CategoryItem('Projetos', Icons.rocket_launch),
    CategoryItem('Gestão', Icons.business_center),
    CategoryItem('Pessoal', Icons.person),
    CategoryItem('Infra', Icons.computer),
  ];

  TaskController() {
    _seedInitialData();
  }

  // --- GETTERS ---

  List<String> get statuses => _statuses;
  List<CategoryItem> get categories => _categories;
  String get currentFilter => _currentFilter;
  String get userRole => _userRole;
  
  bool get isManager => _userRole == '_CTO';
  bool get canCreateOrDelete => _userRole == '_CTO';

  int get unreadCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _tasks.where((t) {
      final taskDate = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
      return !t.isCompleted && taskDate.isBefore(today);
    }).length;
  }

  int get activeTasksCount => _tasks.where((t) => t.status != 'Concluído').length;

  List<TaskModel> get filteredTasks {
    if (_cachedFilteredTasks != null) {
      return _cachedFilteredTasks!;
    }

    if (_currentFilter == 'Todos') {
      _cachedFilteredTasks = List.from(_tasks);
    } else {
      _cachedFilteredTasks = _tasks.where((t) => t.category == _currentFilter).toList();
    }
    
    return _cachedFilteredTasks!;
  }

  // --- MÉTODOS DE AÇÃO ---

  void _invalidateCache() {
    _cachedFilteredTasks = null;
    notifyListeners();
  }

  void setFilter(String filter) {
    if (_currentFilter != filter) {
      _currentFilter = filter;
      _invalidateCache();
    }
  }

  void addTask(TaskModel task) {
    final sanitizedTitle = InputSanitizer.clean(task.title);
    final sanitizedDesc = InputSanitizer.clean(task.description);
    final sanitizedClient = task.client != null ? InputSanitizer.clean(task.client!) : null;

    final newTask = TaskModel(
      id: _uuid.v7(),
      title: sanitizedTitle,
      description: sanitizedDesc,
      dueDate: task.dueDate,
      priority: task.priority,
      category: task.category,
      status: task.status,
      subtasks: task.subtasks, 
      client: sanitizedClient,
      assignee: task.assignee,
      comments: task.comments,
    );

    _tasks.add(newTask);
    _invalidateCache();
  }

  void updateTaskStatus(String id, String newStatus) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final old = _tasks[index];
      _tasks[index] = TaskModel(
        id: old.id,
        title: old.title,
        description: old.description,
        dueDate: old.dueDate,
        priority: old.priority,
        category: old.category,
        subtasks: old.subtasks,
        client: old.client,
        assignee: old.assignee,
        comments: old.comments,
        status: newStatus,
      );
      _invalidateCache();
    }
  }

  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final t = _tasks[index];
      final newStatus = t.status == 'Concluído' ? 'A Fazer' : 'Concluído';
      updateTaskStatus(id, newStatus);
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _invalidateCache();
  }

  void addStatus(String status) {
    final cleanStatus = InputSanitizer.clean(status);
    if (!_statuses.contains(cleanStatus) && cleanStatus.isNotEmpty) {
      _statuses.add(cleanStatus);
      notifyListeners();
    }
  }

  void addCategory(String label, IconData icon) {
    final cleanLabel = InputSanitizer.clean(label);
    if (cleanLabel.isNotEmpty && !_categories.any((c) => c.label == cleanLabel)) {
      _categories.add(CategoryItem(cleanLabel, icon));
      notifyListeners();
    }
  }

  void addSubTask(String taskId, String title) {
    final cleanTitle = InputSanitizer.clean(title);
    if (cleanTitle.isEmpty) return;

    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final newSub = SubTask(
        id: _uuid.v7(), 
        title: cleanTitle
      );
      _tasks[index].subtasks.add(newSub);
      notifyListeners(); 
    }
  }

  void removeSubTask(String taskId, String subTaskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index].subtasks.removeWhere((s) => s.id == subTaskId);
      notifyListeners(); 
    }
  }
  
  void toggleSubTask(String taskId, String subTaskId) {
    final tIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (tIndex != -1) {
      final sIndex = _tasks[tIndex].subtasks.indexWhere((s) => s.id == subTaskId);
      if (sIndex != -1) {
        final old = _tasks[tIndex].subtasks[sIndex];
        _tasks[tIndex].subtasks[sIndex] = SubTask(
          id: old.id, 
          title: old.title, 
          isCompleted: !old.isCompleted
        );
        notifyListeners(); 
      }
    }
  }

  void addComment(String taskId, String content) {
    final cleanContent = InputSanitizer.clean(content);
    if (cleanContent.isEmpty) return;

    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final newComment = Comment(
        author: "CTO", 
        content: cleanContent,
        date: DateTime.now()
      );
      _tasks[index].comments.add(newComment);
      notifyListeners();
    }
  }

  // --- PERMISSÕES (As que faltavam) ---
  
  bool canEdit(TaskModel task) => isManager;

  bool canComplete(TaskModel task) => true;

  // --- SEED INICIAL ---

  void _seedInitialData() {
    _tasks.addAll([
      TaskModel(
        id: _uuid.v7(),
        title: 'Finalizar Protótipo do App',
        description: 'Terminar as telas de login e home no Figma.',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        priority: TaskPriority.alta,
        status: 'A Fazer',
        category: 'Projetos',
      ),
      TaskModel(
        id: _uuid.v7(),
        title: 'Reunião com Investidores',
        description: 'Apresentar métricas do Q1.',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        priority: TaskPriority.urgente,
        status: 'A Fazer',
        category: 'Gestão',
      ),
    ]);
  }
}