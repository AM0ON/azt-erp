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

  bool _isKanbanMode = false;
  bool get isKanbanMode => _isKanbanMode;

  void toggleViewMode() {
    _isKanbanMode = !_isKanbanMode;
    notifyListeners();
  }

  // --- SUBTAREFAS (Lógica de Negócio) ---
  void addSubTask(String taskId, String title) {
    final index = _allTasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _allTasks[index].subtasks.add(SubTask(id: DateTime.now().toString(), title: title));
      notifyListeners();
    }
  }

  void toggleSubTask(String taskId, String subTaskId) {
    final taskIndex = _allTasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final subIndex = _allTasks[taskIndex].subtasks.indexWhere((s) => s.id == subTaskId);
      if (subIndex != -1) {
        _allTasks[taskIndex].subtasks[subIndex].isCompleted = !_allTasks[taskIndex].subtasks[subIndex].isCompleted;
        notifyListeners();
      }
    }
  }

  void removeSubTask(String taskId, String subTaskId) {
    final taskIndex = _allTasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      _allTasks[taskIndex].subtasks.removeWhere((s) => s.id == subTaskId);
      notifyListeners();
    }
  }

  // Lista de Categorias do Sistema
  final List<CategoryItem> _categories = [
    CategoryItem(label: 'Todas', icon: Icons.grid_view),
    CategoryItem(label: 'Pessoal', icon: Icons.person_outline),
    CategoryItem(label: 'Produção', icon: Icons.layers_outlined),
    CategoryItem(label: 'Web Dev', icon: Icons.code),
    CategoryItem(label: 'Financeiro', icon: Icons.attach_money),
  ];

  List<CategoryItem> get categories => _categories;

  // [CORREÇÃO: Mock Data usando Strings para Categoria e Lista de Subtasks]
  final List<TaskModel> _allTasks = [
    TaskModel(
      id: '1',
      title: "Deploy da Landing Page v2",
      description: "Subir alterações no servidor.",
      client: "Restaurante Bom Sabor",
      dueDate: DateTime.now().add(const Duration(days: 1)),
      category: "Web Dev", // Agora é String, compatível com o Model
      priority: TaskPriority.urgente,
      status: TaskStatus.inProgress,
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
      category: "Financeiro", // String
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

  void updateTaskStatus(String taskId, TaskStatus newStatus) {
    final index = _allTasks.indexWhere((t) => t.id == taskId);
    if (index != -1 && canComplete(_allTasks[index])) {
      _allTasks[index].status = newStatus;
      _allTasks[index].isCompleted = (newStatus == TaskStatus.done);
      notifyListeners();
    }
  }

  void toggleTaskCompletion(String id) {
    final index = _allTasks.indexWhere((t) => t.id == id);
    if (index != -1 && canComplete(_allTasks[index])) {
      _allTasks[index].isCompleted = !_allTasks[index].isCompleted;
      notifyListeners();
    }
  }

  void addCategory(String name, IconData icon) {
    if (isManager) {
      _categories.add(CategoryItem(label: name, icon: icon));
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

  bool _matchesFilter(TaskModel task) {
    if (_selectedCategoryFilter == "Todas") return true;
    return task.category == _selectedCategoryFilter;
  }
}