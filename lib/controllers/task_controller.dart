import 'package:flutter/material.dart';
import '../models/task_model.dart';

class CategoryItem {
  final String label;
  final IconData icon;
  CategoryItem({required this.label, required this.icon});
}

class TaskController extends ChangeNotifier {
  final String _currentUserRole = '_CTO'; 
  String get userRole => _currentUserRole;

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
      description: "Subir alterações no servidor e limpar cache do CDN.",
      dueDate: DateTime.now().add(const Duration(days: 1)),
      category: TaskCategory.azorTechWeb,
      priority: TaskPriority.urgente,
      comments: [
        TaskComment(author: "Dev Lead", content: "Lembrar de minificar os assets.", date: DateTime.now().subtract(const Duration(hours: 2)))
      ]
    ),
    TaskModel(
      id: '2',
      title: "Revisão de contratos mensais",
      description: "Verificar pagamentos pendentes dos clientes recorrentes.",
      dueDate: DateTime.now(),
      category: TaskCategory.financeiro,
      priority: TaskPriority.alta,
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

  // ADICIONAR COMENTÁRIO
  void addComment(String taskId, String content) {
    final index = _allTasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _allTasks[index].comments.add(TaskComment(
        author: _currentUserRole, // Usa o cargo como autor por enquanto
        content: content,
        date: DateTime.now()
      ));
      notifyListeners();
    }
  }

  void addCategory(String name, IconData icon) {
    if (_currentUserRole == '_CTO' || _currentUserRole == '_GESTAO') {
      _categories.add(CategoryItem(label: name, icon: icon));
      notifyListeners();
    }
  }

  void toggleTaskCompletion(String id) {
    final index = _allTasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _allTasks[index].status = _allTasks[index].status == TaskStatus.todo ? TaskStatus.done : TaskStatus.todo;
      notifyListeners();
    }
  }

  void addTask(TaskModel task) {
    _allTasks.add(task);
    notifyListeners();
  }

  void updateTask(TaskModel updatedTask) {
    final index = _allTasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      // Mantemos os comentários originais ao atualizar
      updatedTask.comments = _allTasks[index].comments; 
      _allTasks[index] = updatedTask;
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _allTasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  bool _matchesFilter(TaskModel task) {
    if (_selectedCategoryFilter == "Todas") return true;
    String labelToCheck = _selectedCategoryFilter;
    if (_selectedCategoryFilter == "Produção") labelToCheck = "Produção"; 
    return task.categoryLabel == labelToCheck || 
           (_selectedCategoryFilter == "Produção" && task.categoryLabel == "Produção"); 
  }
}