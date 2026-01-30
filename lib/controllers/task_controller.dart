import 'package:flutter/material.dart';
import '../models/task_model.dart';

class CategoryItem {
  final String label;
  final IconData icon;
  CategoryItem({required this.label, required this.icon});
}

class TaskController extends ChangeNotifier {
  // --- PERMISSÕES ---
  // Mude para '_DEV' para testar as restrições de usuário comum
  final String _currentUserRole = '_CTO'; 
  final String _currentUserName = 'Admin'; 

  String get userRole => _currentUserRole;
  String get currentUserName => _currentUserName;

  bool get isManager => _currentUserRole == '_CTO' || _currentUserRole == '_GESTAO';
  
  // Regra: Apenas Gestores criam ou excluem
  bool get canCreateOrDelete => isManager;

  // Regra: Gestores ou o próprio dono podem encerrar/editar status
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
      assignee: "Admin",
      status: TaskStatus.inProgress, 
    ),
    TaskModel(
      id: '2',
      title: "Revisão de contratos",
      description: "Verificar pagamentos.",
      client: "AzorTech Interno",
      dueDate: DateTime.now(),
      category: TaskCategory.financeiro,
      priority: TaskPriority.alta,
      assignee: "DevTeam",
    ),
  ];

  String _selectedCategoryFilter = "Todas";

  List<TaskModel> get activeTasks => 
      _allTasks.where((t) => !t.isCompleted && _matchesFilter(t)).toList();

  List<TaskModel> get completedTasks => 
      _allTasks.where((t) => t.isCompleted && _matchesFilter(t)).toList();

  String get currentFilter => _selectedCategoryFilter;

  void setFilter(String filter) {
    _selectedCategoryFilter = filter;
    notifyListeners();
  }

  void addCategory(String name, IconData icon) {
    if (isManager) {
      _categories.add(CategoryItem(label: name, icon: icon));
      notifyListeners();
    }
  }

  void toggleTaskCompletion(String id) {
    final index = _allTasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _allTasks[index];
      // Verifica permissão antes de completar
      if (canComplete(task)) {
        bool isDone = !task.isCompleted;
        if (isDone) {
          task.status = TaskStatus.done;
        } else {
          task.status = TaskStatus.todo;
        }
        task.status = isDone ? TaskStatus.done : TaskStatus.todo;
        notifyListeners();
      }
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
      _allTasks[index].comments.add(TaskComment(
        author: _currentUserName,
        content: content,
        date: DateTime.now()
      ));
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