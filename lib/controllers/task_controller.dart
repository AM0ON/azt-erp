import 'package:flutter/material.dart';
import '../models/task_model.dart';

class CategoryItem {
  final String label;
  final IconData icon;
  CategoryItem({required this.label, required this.icon});
}

class TaskController extends ChangeNotifier {
  final String _currentUserRole = '_CTO'; 
  final String _currentUserName = 'Admin'; 

  String get userRole => _currentUserRole;
  String get currentUserName => _currentUserName;

  // CORREÇÃO DO ERRO: Inicializado como false (não nulo)
  bool _isKanbanMode = false;
  bool get isKanbanMode => _isKanbanMode;

  bool get isManager => _currentUserRole == '_CTO' || _currentUserRole == '_GESTAO';
  bool get canCreateOrDelete => isManager;

  bool canComplete(TaskModel task) {
    if (isManager) return true;
    return task.assignee == _currentUserName;
  }

  final List<CategoryItem> _categories = [
    CategoryItem(label: 'Todas', icon: Icons.grid_view),
    CategoryItem(label: 'Pessoal', icon: Icons.person_outline),
    CategoryItem(label: 'Produção', icon: Icons.layers_outlined),
    CategoryItem(label: 'Web Dev', icon: Icons.code),
    CategoryItem(label: 'Financeiro', icon: Icons.attach_money),
  ];

  List<CategoryItem> get categories => _categories;

  final List<TaskModel> _allTasks = [
    TaskModel(
      id: '1',
      title: "Deploy da Landing Page v2",
      description: "Subir alterações no servidor.",
      client: "Restaurante Bom Sabor",
      dueDate: DateTime.now().add(const Duration(days: 1)),
      category: TaskCategory.azorTechWeb,
      priority: TaskPriority.urgente,
      status: TaskStatus.inProgress,
      assignee: "Admin"
    ),
    TaskModel(
      id: '2',
      title: "Revisão de contratos",
      description: "Verificar pagamentos.",
      client: "Interno",
      dueDate: DateTime.now(),
      category: TaskCategory.financeiro,
      priority: TaskPriority.alta,
      status: TaskStatus.todo,
    ),
  ];

  String _selectedCategoryFilter = "Todas";

  List<TaskModel> get activeTasks => _allTasks.where((t) => !t.isCompleted && _matchesFilter(t)).toList();
  List<TaskModel> get completedTasks => _allTasks.where((t) => t.isCompleted && _matchesFilter(t)).toList();
  List<TaskModel> get filteredTasks => _allTasks.where((t) => _matchesFilter(t)).toList();

  String get currentFilter => _selectedCategoryFilter;

  void setFilter(String filter) {
    _selectedCategoryFilter = filter;
    notifyListeners();
  }

  void toggleViewMode() {
    _isKanbanMode = !_isKanbanMode;
    notifyListeners();
  }

  void updateTaskStatus(String taskId, TaskStatus newStatus) {
    final index = _allTasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      if (canComplete(_allTasks[index])) {
        _allTasks[index].status = newStatus;
        notifyListeners();
      }
    }
  }

  void toggleTaskCompletion(String id) {
    final index = _allTasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _allTasks[index];
      if (canComplete(task)) {
        bool isDone = !task.isCompleted;
      if (isDone) {
        task.status = TaskStatus.done;  
      } else {
        task.status = TaskStatus.todo;  
        notifyListeners();
      }
      }
    }
  }

  void addCategory(String name, IconData icon) {
    if (isManager) {
      _categories.add(CategoryItem(label: name, icon: icon));
      notifyListeners();
    }
  }

  void addTask(TaskModel task) {
    if (canCreateOrDelete) {
      _allTasks.add(task);
      notifyListeners();
    }
  }

  void updateTask(TaskModel updatedTask) {
    final index = _allTasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _allTasks[index] = updatedTask;
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    if (canCreateOrDelete) {
      _allTasks.removeWhere((t) => t.id == id);
      notifyListeners();
    }
  }

  void addComment(String taskId, String content) {
    final index = _allTasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _allTasks[index].comments.add(TaskComment(author: _currentUserName, content: content, date: DateTime.now()));
      notifyListeners();
    }
  }

  bool _matchesFilter(TaskModel task) {
    if (_selectedCategoryFilter == "Todas") return true;
    String labelToCheck = _selectedCategoryFilter;
    if (_selectedCategoryFilter == "Produção") labelToCheck = "Produção"; 
    return task.categoryLabel == labelToCheck || 
           (_selectedCategoryFilter == "Produção" && task.categoryLabel == "Produção"); 
  }
}