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

  bool get isManager => _currentUserRole == '_CTO' || _currentUserRole == '_GESTAO';
  bool get canCreateOrDelete => isManager;

  bool canComplete(TaskModel task) {
    if (isManager) return true;
    return task.assignee == _currentUserName;
  }

  // --- STATUS (Colunas do Kanban) ---
  final List<String> _statuses = ["A Fazer", "Em Progresso", "Em Análise", "Concluído"];
  List<String> get statuses => _statuses;

  void addStatus(String newStatus) {
    if (isManager && !_statuses.contains(newStatus)) {
      _statuses.add(newStatus);
      notifyListeners();
    }
  }

  void removeStatus(String status) {
    if (isManager && _statuses.length > 1) {
      if (_allTasks.any((t) => t.status == status)) {
        // Move tarefas para a primeira coluna antes de deletar
        for (var t in _allTasks) {
          if (t.status == status) t.status = _statuses[0];
        }
      }
      _statuses.remove(status);
      notifyListeners();
    }
  }

  // --- CATEGORIAS ---
  final List<CategoryItem> _categories = [
    CategoryItem(label: 'Todas', icon: Icons.grid_view),
    CategoryItem(label: 'Pessoal', icon: Icons.person_outline),
    CategoryItem(label: 'Produção', icon: Icons.layers_outlined),
    CategoryItem(label: 'Web Dev', icon: Icons.code),
    CategoryItem(label: 'Financeiro', icon: Icons.attach_money),
  ];

  List<CategoryItem> get categories => _categories;

  void addCategory(String name, IconData icon) {
    if (isManager && !_categories.any((c) => c.label == name)) {
      _categories.add(CategoryItem(label: name, icon: icon));
      notifyListeners();
    }
  }

  void removeCategory(String name) {
    if (isManager && name != 'Todas') {
      _categories.removeWhere((c) => c.label == name);
      for (var t in _allTasks) {
        if (t.category == name) t.category = 'Pessoal';
      }
      notifyListeners();
    }
  }

  // --- TAREFAS (Mock Data corrigido para String) ---
  final List<TaskModel> _allTasks = [
    TaskModel(
      id: '1',
      title: "Deploy da Landing Page v2",
      description: "Subir alterações no servidor.",
      client: "Restaurante Bom Sabor",
      dueDate: DateTime.now().add(const Duration(days: 1)),
      category: "Web Dev", 
      priority: TaskPriority.urgente,
      status: "Em Progresso", // String
      assignee: "Admin",
      subtasks: [
        SubTask(id: 's1', title: 'Minificar Assets', isCompleted: true),
        SubTask(id: 's2', title: 'Testar Responsividade', isCompleted: false),
      ]
    ),
    TaskModel(
      id: '2',
      title: "Revisão de contratos",
      description: "Verificar pagamentos.",
      client: "Interno",
      dueDate: DateTime.now(),
      category: "Financeiro", 
      priority: TaskPriority.alta,
      status: "A Fazer", // String
    ),
  ];

  String _selectedCategoryFilter = "Todas";

  // Getters essenciais para o HubPage e Kanban
  List<TaskModel> get activeTasks => _allTasks.where((t) => !t.isCompleted).toList();
  List<TaskModel> get completedTasks => _allTasks.where((t) => t.isCompleted && _matchesFilter(t)).toList();
  List<TaskModel> get filteredTasks => _allTasks.where((t) => _matchesFilter(t)).toList();

  String get currentFilter => _selectedCategoryFilter;

  void setFilter(String filter) {
    _selectedCategoryFilter = filter;
    notifyListeners();
  }

  void updateTaskStatus(String taskId, String newStatus) {
    final index = _allTasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _allTasks[index].status = newStatus;
      notifyListeners();
    }
  }

  void toggleTaskCompletion(String id) {
    final index = _allTasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      if (_allTasks[index].status == "Concluído") {
        _allTasks[index].status = "A Fazer";
      } else {
        _allTasks[index].status = "Concluído";
      }
      notifyListeners();
    }
  }

  void addTask(TaskModel task) { if (canCreateOrDelete) { _allTasks.add(task); notifyListeners(); } }
  
  void updateTask(TaskModel task) { 
    final index = _allTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) { _allTasks[index] = task; notifyListeners(); }
  }
  
  void deleteTask(String id) { if (canCreateOrDelete) { _allTasks.removeWhere((t) => t.id == id); notifyListeners(); } }
  
  void addComment(String taskId, String content) {
    final index = _allTasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _allTasks[index].comments.add(TaskComment(author: _currentUserName, content: content, date: DateTime.now()));
      notifyListeners();
    }
  }

  // Métodos de Subtarefas
  void addSubTask(String taskId, String title) {
    final index = _allTasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _allTasks[index].subtasks.add(SubTask(id: DateTime.now().toString(), title: title));
      notifyListeners();
    }
  }

  void toggleSubTask(String taskId, String subId) {
    final index = _allTasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final sub = _allTasks[index].subtasks.firstWhere((s) => s.id == subId);
      sub.isCompleted = !sub.isCompleted;
      notifyListeners();
    }
  }

  void removeSubTask(String taskId, String subId) {
    final index = _allTasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _allTasks[index].subtasks.removeWhere((s) => s.id == subId);
      notifyListeners();
    }
  }

  bool _isKanbanMode = true;
  bool get isKanbanMode => _isKanbanMode;
  void toggleViewMode() {} // Modo único agora

  bool _matchesFilter(TaskModel task) {
    if (_selectedCategoryFilter == "Todas") return true;
    return task.category == _selectedCategoryFilter;
  }
}